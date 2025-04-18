import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentServices {
  final String collection = "drivers";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for a specific driver's document
  Stream<DocumentSnapshot> requestStream(String driverId) {
    return _firestore.collection(collection).doc(driverId).snapshots();
  }
}
