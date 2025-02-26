import 'package:cloud_firestore/cloud_firestore.dart';

class ParcelRequestServices {
  final String collection = "parcels";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Update Parcel Request (e.g., when status changes)
  void updateRequest(Map<String, dynamic> values) {
    _firebaseFirestore.collection(collection).doc(values['id']).update(values);
  }

  // Listen for changes in the request (real-time updates)
  Stream<QuerySnapshot> parcelRequestStream({String? id}) {
    CollectionReference reference = _firebaseFirestore.collection(collection);
    return reference.where('status', isEqualTo: 'PENDING').snapshots();
  }
}
