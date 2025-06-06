import 'dart:io';

import 'package:Bucoride_Driver/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/app_provider.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/loading.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? profileImageUrl;
  File? _profileImage; // Local image file
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool alreadyclicked = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider authProvider =
        Provider.of<UserProvider>(context, listen: true);
    final appState  = Provider.of<AppStateProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.lightPrimary,
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SafeArea(
              child: _fadeAnimation == null
                  ? Center(
                      child: Loading()) // Avoid using it before initialization
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(Images.logoWithName, height: 75),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${'Welcome to'.tr} ' +
                                        AppConstants.appName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Image.asset(Images.hand,
                                      width: 40), // Ensure you have this image
                                ]),
                            SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),
                            Center(
                              child: Text(
                                'Register an account.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),
                            // Profile Picture Upload with Bounce Effect
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  var status = await Permission.storage.request(); // for Android 13+
                                  if (status.isGranted) {
                                    final pickedFile = await ImagePicker().pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 70, // compress image
                                      maxWidth: 1024,   // reduce memory usage
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        _profileImage = File(pickedFile.path);
                                      });
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Gallery permission denied! \nPlease allow it in settings."
                                          "\nPlease grant app permission to use access storage to upload profile picture"
                                        ),
                                        action: SnackBarAction(
                                          label: 'Open Settings',
                                          onPressed: () {
                                            openAppSettings(); // from permission_handler
                                          },
                                        ),
                                      )
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.bounceOut,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(
                                            _profileImage!) // Show local image if available
                                        : profileImageUrl != null
                                            ? NetworkImage(
                                                profileImageUrl!) // Show Firebase image if exists
                                            : AssetImage(
                                                    Images.personPlaceholder)
                                                as ImageProvider,
                                    child: _profileImage == null &&
                                            profileImageUrl == null
                                        ? Icon(Icons.camera_alt,
                                            size: 40, color: Colors.white)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),

                            // Form Fields with Slide Animation
                            SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  buildTextField(authProvider.name, "Full Name",
                                      Icons.person),
                                  buildTextField(
                                      authProvider.email, "Email", Icons.email,
                                      keyboardType: TextInputType.emailAddress),
                                  Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeThree),
                                    child: IntlPhoneField(
                                      controller: authProvider
                                          .phone, // This holds only the local number
                                          style: TextStyle(fontSize: Dimensions.fontSizeSmall),
                                      decoration: InputDecoration(
                                        labelText: "Phone",
                                        labelStyle: TextStyle(fontSize: Dimensions.fontSizeSmall),
                                        filled: true,
                                        fillColor:
                                            Colors.white, // White background
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              25.0), // Rounded corners
                                          borderSide: BorderSide(
                                              color: Colors.black,
                                              width: 1), // Black border
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Colors.black,
                                              width: 2.5), // Thicker on focus
                                        ),
                                        prefixIcon: Icon(Icons.phone_android,
                                            color: Colors.grey[700]),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 20),
                                      ),
                                      initialCountryCode:
                                          'KE', // Set Kenya as default country
                                      onChanged: (phone) {
                                        authProvider.setFormattedPhone(phone
                                            .completeNumber); // Store full E.164 number
                                      },
                                    ),
                                  ),
                                  buildTextField(authProvider.identification,
                                      "Identification Number", Icons.badge,
                                      keyboardType: TextInputType.number),
                                  buildTextField(authProvider.password,
                                      "Password", Icons.lock,
                                      obscureText: true),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Register Button with Ripple Effect
                            InkWell(
                              onTap: () async {
                                if (_profileImage == null) {
                                  showError("Profile picture is required!", appState);
                                  return;
                                }
                                if (authProvider.identification.text.isEmpty) {
                                  showError(
                                      "Identification number is required!", appState);
                                  return;
                                }
                                if (authProvider.name.text.isEmpty ||
                                    authProvider.email.text.isEmpty ||
                                    authProvider.phone.text.isEmpty ||
                                    authProvider.password.text.isEmpty) {
                                  showError("All fields are required!", appState);

                                  return;
                                }

                                String resultMessage =
                                    await authProvider.signUp(
                                        idNumber: authProvider
                                            .identification.text
                                            .trim(),
                                        profileImage: _profileImage!);
                                if (resultMessage == "Success") {
                                  // showVerificationAlert(
                                  //   context,
                                  //   "A verification email has been sent to your email address. "
                                  //   "Please check your inbox and verify before proceeding.",
                                  // ); // Show full-screen alert
                                  changeScreenReplacement(
                                      context, LoginScreen());
                                  showError(
                                      "Account Creation Successful. Login", appState);
                                } else {
                                  showError(resultMessage, appState);
                                }
                                authProvider.clearController();
                                authProvider.identification.clear();
                                profileImageUrl = null;
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${'Already an account'.tr} ',
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor)),
                                TextButton(
                                  onPressed: () {
                                    changeScreen(context, LoginScreen());
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: Dimensions.fontSizeSmall),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: Dimensions.fontSizeSmall),
          filled: true,
          fillColor: Colors.white, // White background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0), // Rounded corners
            borderSide:
                BorderSide(color: Colors.black, width: 1), // Black border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide:
                BorderSide(color: Colors.black, width: 2.5), // Thicker on focus
          ),
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }

  void showError(String message, AppStateProvider appState) {
    appState.showCustomSnackBar(context, message, AppConstants.darkPrimary);
  }

  void checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Refresh user data

    if (user != null && user.emailVerified) {
      Navigator.pop(context); // Close the dialog
      changeScreenReplacement(context, LoginScreen()); // Redirect to login
    } else {
      if (alreadyclicked) {
        changeScreen(context, LoginScreen());
      } else {
        showVerificationAlert(context, "Didnt work");
        alreadyclicked = true;
      }
    }
  }

  void showVerificationAlert(BuildContext context, String Message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return PopScope(
          canPop: false, // Prevent back navigation
          child: AlertDialog(
            title: Text("Verify Your Email"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email, size: 50, color: Colors.blue),
                SizedBox(height: 10),
                Text(
                  Message,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => checkEmailVerification(),
                  child: Text("I've Verified",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
