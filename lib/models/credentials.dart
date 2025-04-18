import 'package:cloud_firestore/cloud_firestore.dart';

class Credentials {
  // Static keys for Firestore fields
  static const String CONSUMER_KEY = 'consumerKey';
  static const String CONSUMER_SECRET = 'consumerSecret';

  // Fields

  final String consumerKey;
  final String consumerSecret;

  // Constructor
  Credentials({
    required this.consumerKey,
    required this.consumerSecret,
  });

  // Convert Firestore snapshot to Credentials instance
  factory Credentials.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Credentials(
      consumerKey: data[CONSUMER_KEY] ?? '',
      consumerSecret: data[CONSUMER_SECRET] ?? '',
    );
  }

  // Convert a Map to Credentials instance
  factory Credentials.fromMap(Map<String, dynamic> data) {
    return Credentials(
      consumerKey: data[CONSUMER_KEY] ?? '',
      consumerSecret: data[CONSUMER_SECRET] ?? '',
    );
  }

  // Convert Credentials instance to Map (for Firestore updates)
  Map<String, dynamic> toMap() {
    return {
      CONSUMER_KEY: consumerKey,
      CONSUMER_SECRET: consumerSecret,
    };
  }
}
