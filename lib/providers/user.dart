import 'dart:async';

import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/models/user.dart';
import 'package:cabdriver/services/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  late User _user;
  Status _status = Status.Uninitialized;
  UserServices _userServices = UserServices();
  late UserModel _userModel;

//  getter
  UserModel get userModel => _userModel;
  Status get status => _status;
  User get user => _user;

  // public variables
  final formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  UserProvider.initialize() {
    _initialize();
  }

  Future<bool> signIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      _status = Status.Authenticating;
      notifyListeners();
      await auth
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim())
          .then((value) async {
        await prefs.setString("id", value.user!.uid);
      });
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future<bool> signUp(Position position) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await auth
          .createUserWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim())
          .then((result) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Get device token as a string
        String _deviceToken = await FirebaseMessaging.instance.getToken() ?? '';

        await prefs.setString("id", result.user!.uid);
        _userServices.createUser(
            id: result.user!.uid,
            name: name.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            position: position.toJson(),
            token: _deviceToken);
      });
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  static const String LOGGED_IN = "loggedIn"; // Define constant for the key

  /// Initialize user status and preferences
  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(LOGGED_IN) ?? false;

    if (isLoggedIn) {
      FirebaseAuth.instance.authStateChanges().listen((currentUser) async {
        if (currentUser != null) {
          _user = currentUser;
          _userModel = await _userServices.getUserById(_user!.uid);
          _status = Status.Authenticated;
        } else {
          _status = Status.Unauthenticated;
        }
        notifyListeners();
      });
    } else {
      _status = Status.Unauthenticated;
      notifyListeners();
    }
  }

  Future signOut() async {
    auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    name.text = "";
    password.text = "";
    email.text = "";
    phone.text = "";
  }

  Future<void> reloadUserModel() async {
    _userModel = await _userServices.getUserById(user.uid);
    notifyListeners();
  }

  updateUserData(Map<String, dynamic> data) async {
    _userServices.updateUserData(data);
  }

  saveDeviceToken() async {
    String? deviceToken = await fcm.getToken();
    if (deviceToken != null) {
      _userServices.addDeviceToken(userId: user.uid, token: deviceToken);
    }
  }

  _onStateChanged(User firebaseUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      await prefs.setString("id", firebaseUser.uid);

      _userModel = await _userServices.getUserById(user.uid).then((value) {
        _status = Status.Authenticated;
        return value;
      });
    }
    notifyListeners();
  }
}
