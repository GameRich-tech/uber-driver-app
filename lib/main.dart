import 'dart:io';

import 'package:Bucoride_Driver/api/firebase_api.dart';
import 'package:Bucoride_Driver/providers/app_provider.dart';
import 'package:Bucoride_Driver/providers/location_provider.dart';
import 'package:Bucoride_Driver/providers/ride_request_provider.dart';
import 'package:Bucoride_Driver/providers/user.dart';
import 'package:Bucoride_Driver/screens/splash.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'locators/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    //webProvider: ReCaptchaV3Provider('your-recaptcha-key'), // For Web
    androidProvider: AndroidProvider.playIntegrity, // For Android
    //appleProvider: AppleProvider.deviceCheck, // For iOS
  );

  FirebaseApi firebaseApi = FirebaseApi();
  await firebaseApi.initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  setupLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RideRequestProvider()),
      ],
      child: MaterialApp(
        navigatorKey: firebaseApi.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: Splash(), // Directly pass Splash here
      ),
    ),
  );
}
