import 'package:cabdriver/models/rider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class RiderServices {
  String collection = "users";

  Future<RiderModel> getRiderById(String id) =>
      FirebaseFirestore.instance // Use FirebaseFirestore
          .collection(collection)
          .doc(id)
          .get()
          .then((doc) {
        return RiderModel.fromSnapshot(doc);
      });
}
