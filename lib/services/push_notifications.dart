import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission for iOS devices if needed
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Configure the behavior for handling messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("=== onMessage: ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("=== onMessageOpenedApp: ${message.data}");
    });
  }

  Future<void> handleOnMessage(RemoteMessage message) async {
    print("=== onMessage Data: ${message.data}");
  }

  Future<void> handleOnLaunch(RemoteMessage message) async {
    print("=== onLaunch Data: ${message.data}");
  }

  Future<void> handleOnResume(RemoteMessage message) async {
    print("=== onResume Data: ${message.data}");
  }
}
