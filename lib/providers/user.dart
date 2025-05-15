import 'dart:async';
import 'dart:io';

import 'package:Bucoride_Driver/helpers/constants.dart';
import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/Paywall/Paywall.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/credentials.dart';
import '../models/ride_Request.dart';
import '../models/user.dart';
import '../services/user.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  static const LOGGED_IN = "loggedIn";
  static const ID = "id";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  Status _status = Status.Uninitialized;
  final UserServices _userServices = UserServices();
  UserModel? _userModel;
  bool _isActiveRememberMe = false;

  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Getters
  UserModel? get userModel => _userModel;
  Status get status => _status;
  User? get user => _user;
  bool get isActiveRememberMe => _isActiveRememberMe;

  // Getters for ride earnings and referral credits
  double get rideEarnings => _rideEarnings;
  double get referralCredits => _referralCredits;
  double get bonus => _bonus;


  double _rideEarnings = 0;
  double _referralCredits = 0;
  final double _bonus = 500;
  final double _withdrawThreshold = 3000;

  

  /// Text controllers for input
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController identification = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  //Vehicle Registration
  final TextEditingController modelController = TextEditingController();
  final TextEditingController mpesaNumberController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController weightCapacityController =
      TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController fuelTypeController =
      TextEditingController(text: "Petrol");
  final TextEditingController vehicleTypeController =
      TextEditingController(text: "Sedan");

  List<RequestModelFirebase> _trips = [];
  List<RequestModelFirebase> get trips => _trips;
  File? profileImage;

  ///Booleans
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  UserProvider() {
    _initialize();
  }

  String? _verificationId;
  String _formattedPhone = "";
  String get formattedPhone => _formattedPhone;

  void setFormattedPhone(String phoneNumber) {
    _formattedPhone = phoneNumber;
    notifyListeners();
  }

  String? get verificationId => _verificationId;

  set verificationId(String? id) {
    _verificationId = id;
    notifyListeners(); // Notify listeners when it's updated
  }

  get isRememberMe => false;

  ///Get Mpesa Credentials
  Future<Credentials?> getCredentials() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('credentials')
          .doc('mpesa')
          .get();

      if (snapshot.exists) {
        return Credentials.fromFirestore(snapshot);
      } else {
        print("⚠️ No credentials found in Firestore.");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching credentials: $e");
      return null;
    }
  }

  /// Sign-in method
  Future<String> signIn() async {
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // if (user != null && _user!.emailVerified) {
      //   return "Please verify your email before logging in.";
      // }

      _user = result.user;

      if (_user != null) {
        if (_isActiveRememberMe) {
          await _saveUserToPreferences(_user!);
        }
        _userModel = await _userServices.getUserById(_user!.uid);
        _status = Status.Authenticated;
        notifyListeners();
        return "Success";
      } else {
        return "Failed to sign in user.";
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      switch (e.code) {
        case 'user-not-found':
          return "No user found for that email.";
        case 'wrong-password':
          return "Wrong password provided for the user.";
        case 'invalid-email':
          return "The email address is not valid.";
        case 'The supplied auth credential is incorrect, malformed or has expired.':
          return "Incorrect credentials";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return "An unknown error occurred when authenticating: $e";
    }
  }

  Future<bool> PhoneSignIn(String phoneNumber, BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _status = Status.Authenticated;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _status = Status.Unauthenticated;
          notifyListeners();

          String errorMessage = "Verification failed. Try again.";

          if (e.code == 'invalid-phone-number') {
            errorMessage =
                "Invalid phone number format. Please check and try again.";
          } else if (e.code == 'quota-exceeded') {
            errorMessage = "Too many OTP requests. Try again later.";
          } else {
            errorMessage = e.message ?? errorMessage;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          notifyListeners();

          // ✅ Notify user OTP is sent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP sent successfully!")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );

      return true; // ✅ OTP Sent Successfully
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      return false; // ❌ Failed to Send OTP
    }
  }

  Future<void> resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<String> uploadProfilePix(File imageFile, String uid) async {
    try {
      // ✅ Create storage reference for user's profile picture
      Reference storageRef =
          FirebaseStorage.instance.ref().child("profile_pictures/$uid.jpg");

      // ✅ Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // ✅ Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw "Error uploading profile picture: $e";
    }
  }

  Future<String> ResetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.text.trim());
      return "Success";
    } on FirebaseException catch (e) {
      return ("Something Went Wrong. Check your Email");
    }
  }

  /// Sign-up method
  Future<String> signUp(
      {required String idNumber, required File profileImage}) async {
    try {
      // Validate Required Fields
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }
      if (name.text.trim().isEmpty) {
        return "Full Name is required.";
      }
      if (phone.text.trim().isEmpty) {
        return "Phone number is required.";
      }

      if (idNumber.isEmpty) {
        return "Identification number is required.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      _user = result.user;
      if (_user != null) {
        // ✅ Step 3: Upload Profile Picture After Signup
        String imageUrl = await uploadProfilePix(profileImage, _user!.uid);

        // ✅ Step 4: Update Firebase User Profile
        await _user!.updateDisplayName(name.text.trim());
        await _user!.updatePhotoURL(imageUrl);

        //await _user!.sendEmailVerification();

        await _saveUserToPreferences(_user!);
        await _user!.updateDisplayName(name.text.trim()); // ✅ Save display name
        await _user!.reload(); // Refresh user info

        _userServices.createUser(
          id: _user!.uid,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          photo: imageUrl,
          hasVehicle: false,
          identification: idNumber,
          position: {},
          token: '',
        );

        // Step 3: Link Phone Number to FirebaseAuth
        // await _auth.verifyPhoneNumber(
        //   phoneNumber: phone.text.trim(),
        //   verificationCompleted: (PhoneAuthCredential credential) async {
        //     await _user!.linkWithCredential(credential);
        //   },
        //   verificationFailed: (FirebaseAuthException e) {
        //     print("Phone verification failed: ${e.message}");
        //     //return "Check Your Phone Number";
        //   },
        //   codeSent: (String verificationId, int? resendToken) {
        //     print("OTP Sent");
        //   },
        //   codeAutoRetrievalTimeout: (String verificationId) {},
        // );

        _userModel = await _userServices.getUserById(_user!.uid);
        _status = Status.Authenticated;
        notifyListeners();

        return "Success";
      } else {
        return "Failed to create user.";
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      switch (e.code) {
        case 'email-already-in-use':
          return "The email address is already in use by another account.";
        case 'invalid-email':
          return "The email address is not valid.";
        case 'weak-password':
          return "The password provided is too weak.";
        case 'The supplied auth credential is incorrect, malformed or has expired.':
          return "Incorrect credentials";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return "An unknown error occurred: $e";
    }
  }

  /// Sign-out method
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _clearUserFromPreferences();
    _status = Status.Unauthenticated;
    _user = null;
    _userModel = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false); // Reset Remember Me
    _isActiveRememberMe = false;

    notifyListeners();
  }

  Future<void> updateProfile(
      {required String displayName, File? photoFile}) async {
    String? photoURL;

    // Upload photo to Firebase Storage if selected
    if (photoFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${_user!.uid}.jpg');
      await storageRef.putFile(photoFile);
      photoURL = await storageRef.getDownloadURL();
    }

    // Update Firestore with the display name and photoURL
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(user!.uid)
        .update({
      'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
    });

    // Update Firebase Auth Profile
    await user!.updateDisplayName(displayName);
    if (photoURL != null) {
      await user!.updatePhotoURL(photoURL);
    }

    // Refresh user data
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  /// Reload user model after updates
  Future<void> reloadUserModel() async {
    if (_user != null) {
      _userModel = await _userServices.getUserById(_user!.uid);
      notifyListeners();
    }
  }

  Future<String?> uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    File file = File(pickedFile.path);
    String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref("profile_pictures/$fileName")
          .putFile(file);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Method to refresh user data from Firebase
  Future<void> refreshUser() async {
    if (_user != null) {
      await _user!.reload(); // Reloads the user from Firebase
      _user = FirebaseAuth.instance.currentUser; // Update local user data
      notifyListeners(); // Notifies UI to rebuild with new data
    }
  }

  Future<void> deleteAccount() async {
    if (_user != null) {
      await _user!.delete();
      await _clearUserFromPreferences();
      _status = Status.Unauthenticated;
      _user = null;
      _userModel = null;

      notifyListeners();
    }
  }

  /// Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    _userServices.updateUserData(data);
    await reloadUserModel();
    notifyListeners();
  }

  Future<void> incrementTripCount() async {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('drivers').doc(userModel?.id);

    await userDoc.update({
      'trips': FieldValue.increment(1), // Increments the 'trips' field by 1
    });
    print("added Trips");
    // Reload user model to reflect the updated trip count
    await reloadUserModel();
  }

  /// Save device token (e.g., for FCM)
  Future<void> saveDeviceToken() async {
    String? deviceToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (deviceToken != null && _user != null) {
      _userServices.addDeviceToken(userId: _user!.uid, token: deviceToken);
    }
  }

  void setOnlineStatus(bool status) async {
    _isOnline = status;
    notifyListeners();

    // Update Firestore
    await _userServices.setOnlineStatus(userModel!.id, status);
  }

  void fetchOnlineStatus() async {
    _isOnline = await _userServices.getOnlineStatus(userModel!.id);
    notifyListeners();
  }

  void fetchMpesaCredentials() async {
    Credentials? creds = await getCredentials();
    if (creds != null) {
      print("✅ Consumer Key: ${creds.consumerKey}");
      print("✅ Consumer Secret: ${creds.consumerSecret}");
    }
  }

  /// Initialize user status and preferences
  Future<void> _initialize() async {
    _status = Status.Authenticating;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isActiveRememberMe = await prefs.getBool('remember_me') ?? false;

    bool isLoggedIn = await prefs.getBool(LOGGED_IN) ?? false;

    print("IsLogged In====:${isLoggedIn}");
    print("ISACTIVE REMEMBER ME:========${_isActiveRememberMe}");
    if (isLoggedIn && _isActiveRememberMe) {
      String? userId = prefs.getString(ID);
      if (userId != null) {
        _userModel = await _userServices.getUserById(userId);
        VEHICLE_TYPE = _userModel!.vehicleType;
        fetchMpesaCredentials();
      
        _user = _auth.currentUser;
        _status = Status.Authenticated;
      } else {
        _status = Status.Unauthenticated;
      }
    } else {
      _status = Status.Unauthenticated;
    }
    notifyListeners();
  }

  /// Save user data to preferences
  Future<void> _saveUserToPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(LOGGED_IN, true);
    await prefs.setString(ID, user.uid);
    await _secureStorage.write(key: 'user_email', value: user.email);
  }

  Future<void> checkSubscriptionStatus(BuildContext context) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("drivers")
        .doc(_user?.uid)
        .get();

    if (snapshot.exists) {
      final user = UserModel.fromSnapshot(snapshot);

      if (user.nextPaymentDate != null) {
        DateTime? nextPaymentDate;

        if (user.nextPaymentDate is Timestamp) {
          nextPaymentDate = (user.nextPaymentDate as Timestamp).toDate();
        } else {
          nextPaymentDate = user.nextPaymentDate;
        }

        if (nextPaymentDate != null &&
            DateTime.now().isAfter(nextPaymentDate)) {
          // ✅ Subscription expired
          await FirebaseFirestore.instance
              .collection("drivers")
              .doc(_user?.uid)
              .update({"hasVehicle": false}); // Reset hasVehicle

          showSubscriptionExpiredDialog(context);
        }
      }
    }
  }

  void showSubscriptionExpiredDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Subscription Expired"),
          content: Text(
              "Your subscription has expired. Please renew to continue using the service."),
          actions: [
            TextButton(
              onPressed: () {
                changeScreen(
                    context,
                    Paywall(
                      isRenewal: true,
                    ));
              },
              child: Text("Renew Now"),
            ),
          ],
        );
      },
    );
  }

  /// Clear user data from preferences
  Future<void> _clearUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LOGGED_IN);
    await prefs.remove(ID);
    await _secureStorage.deleteAll();
  }

  // Load data from Firebase using the service
  Future<void> loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      UserModel user = await _userServices.getUserById(uid);
      _rideEarnings = user.rideEarnings;
      _referralCredits = user.referralCredits;
      notifyListeners();
    } catch (e) {
      print("Error loading user data: $e");
    }
  }
 
  // Inside UserProvider class
  void clearController() {
    email.clear();
    password.clear();
    name.clear();
    phone.clear();
    identification.clear();
  }

  void toggleRememberMe() async {
    _isActiveRememberMe = !_isActiveRememberMe;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _isActiveRememberMe);
    notifyListeners();
  }

  void setRememberMe() {
    _isActiveRememberMe = true;
  }

  double get withdrawableBalance {
    if (_rideEarnings >= _withdrawThreshold) {
      return _rideEarnings + _bonus;
    } else {
      return _rideEarnings;
    }
  }

  
}
