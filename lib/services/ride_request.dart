import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ride_Request.dart';

class RideRequestServices {
  final String collection = "requests";
  final String parcel_collection = "parcels";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void updateRequest(Map<String, dynamic> values) {
    _firestore.collection(collection).doc(values['id']).update(values);
  }

  Stream<QuerySnapshot> getDriverTrips(String driverId) {
    return _firestore
        .collection(collection)
        .where('driverId', isEqualTo: driverId) // Fetch trips for the driver
        .orderBy('createdAt', descending: true) // Order by latest trips
        .snapshots();
  }

  Stream<double> getWeeklyEarnings(String driverId) {
    DateTime now = DateTime.now();
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Monday
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // Sunday

    return FirebaseFirestore.instance
        .collection('requests')
        .where('driverId',
            isEqualTo: driverId) // Only fetch trips for this driver
        .where('status', isEqualTo: 'COMPLETED') // Only completed trips
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .snapshots()
        .map((snapshot) {
      double totalEarnings = 0;
      for (var doc in snapshot.docs) {
        totalEarnings +=
            (doc['distance']['value'] ?? 0).toDouble(); // Sum all fares
      }
      return totalEarnings;
    });
  }

  Stream<QuerySnapshot> requestStream({String? id}) {
    CollectionReference reference = _firestore.collection(collection);
    return reference.where('status', isEqualTo: 'PENDING').snapshots();
  }

  Stream<QuerySnapshot> parcelRequestStream({String? id}) {
    CollectionReference reference = _firestore.collection(parcel_collection);
    return reference.where('status', isEqualTo: 'parcels').snapshots();
  }

  Future<RequestModelFirebase> getRequestById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return RequestModelFirebase.fromSnapshot(doc);
      });
}
