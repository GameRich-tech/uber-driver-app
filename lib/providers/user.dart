import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip.dart';
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

  // Text controllers for input
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TripModel> _trips = [];
  List<TripModel> get trips => _trips;

  UserProvider.initialize() {
    _initialize();
  }

  get isRememberMe => false;

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
        default:
          return e.message ?? "An unknown error occurred.";
      }
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return "An unknown error occurred: $e";
    }
  }

  /// Sign-up method
  Future<String> signUp() async {
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      _user = result.user;
      if (_user != null) {
        await _saveUserToPreferences(_user!);
        await user?.updateDisplayName(name.text.trim()); // ✅ Save display name
        await user?.reload(); // Refresh user info

        _userServices.createUser(
          id: _user!.uid,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          position: {},
          token: '',
        );
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

  Future<void> updateProfile({required String displayName, File? photoFile}) async {
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
    await FirebaseFirestore.instance.collection('drivers').doc(user!.uid).update({
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
  // Method to refresh user data from Firebase
  Future<void> refreshUser() async {
    if (_user != null) {
      await _user!.reload(); // Reloads the user from Firebase
      _user = FirebaseAuth.instance.currentUser; // Update local user data
      notifyListeners(); // Notifies UI to rebuild with new data
    }
  }

  /// Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    _userServices.updateUserData(data);
    await reloadUserModel();
  }

  /// Save device token (e.g., for FCM)
  Future<void> saveDeviceToken() async {
    String? deviceToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (deviceToken != null && _user != null) {
      _userServices.addDeviceToken(userId: _user!.uid, token: deviceToken);
    }
  }

  /// Initialize user status and preferences
  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isActiveRememberMe = prefs.getBool('remember_me') ?? false;

    bool isLoggedIn = prefs.getBool(LOGGED_IN) ?? false;
    if (isLoggedIn && _isActiveRememberMe) {
      String? userId = prefs.getString(ID);
      if (userId != null) {
        _userModel = await _userServices.getUserById(userId);
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

  /// Clear user data from preferences
  Future<void> _clearUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LOGGED_IN);
    await prefs.remove(ID);
    await _secureStorage.deleteAll();
  }

  // Fetch trips for the currently logged-in driver
  Future<void> fetchDriverTrips() async {
    try {
      if (_userModel == null) return; // Ensure user is logged in
      String driverId = _userModel!.id;

      QuerySnapshot snapshot = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .orderBy('date', descending: true)
          .get();

      _trips =
          snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching trips: $e");
    }
  }

  // Inside UserProvider class
  void clearController() {
    email.clear();
    password.clear();
    name.clear();
    phone.clear();
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
}
