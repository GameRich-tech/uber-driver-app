import 'dart:io';

import 'package:Bucoride_Driver/api/firebase_api.dart';
import 'package:Bucoride_Driver/providers/app_provider.dart';
import 'package:Bucoride_Driver/providers/location_provider.dart';
import 'package:Bucoride_Driver/providers/ride_request_provider.dart';
import 'package:Bucoride_Driver/providers/user.dart';
import 'package:Bucoride_Driver/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'locators/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
  setupLocator();

  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(
        value: AppStateProvider(),
      ),
      ChangeNotifierProvider.value(value: UserProvider.initialize()),
      ChangeNotifierProvider(
        create: (_) => LocationProvider(), // Stream starts here
        child: MyApp(),
      ),
      ChangeNotifierProvider(create: (_) => RideRequestProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
    
      theme: ThemeData.light(),

      home: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Splash();
  }
}
