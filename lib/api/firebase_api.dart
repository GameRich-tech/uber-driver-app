import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/trips/view_trip.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool hasNewRideRequest = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      final fcmToken = await _firebaseMessaging.getToken();
      print("FCM Token: $fcmToken");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📩 New Notification: ${message.notification?.title}");
        //_handleInAppRideRequest(message);
        _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("📂 Notification Clicked: ${message.notification?.title}");
        //_handleRideRequest(message);
      });
    } else {
      print('❌ User denied notification permission');
    }
  }

  void _handleInAppRideRequest(RemoteMessage message) {
    if (message.data['type'] == "RIDE_REQUEST") {
      hasNewRideRequest = true;

      // Extract ride request details
      Map<String, dynamic> requestData = {
        "username": message.data['username'],
        "destination": message.data['destination'],
        "distance_text": message.data['distance_text'],
        "distance_value": int.parse(message.data['distance_value']),
        "destination_latitude":
            double.parse(message.data['destination_latitude']),
        "destination_longitude":
            double.parse(message.data['destination_longitude']),
        "user_latitude": double.parse(message.data['user_latitude']),
        "user_longitude": double.parse(message.data['user_longitude']),
        "id": message.data['id'],
        "userId": message.data['userId'],
      };

      // Navigate to the ride request screen
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => ViewTrip(request: requestData),
      ));
    }
  }

 

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ride_request_channel', // Unique channel ID
      'Ride Requests', // Channel Name
      channelDescription: 'Notifications for ride requests',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Ensure this exists
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? "New Ride Request",
      message.notification?.body ?? "A user is requesting a ride",
      notificationDetails,
    );
  }
}
