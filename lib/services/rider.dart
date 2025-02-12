import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rider.dart'; // Import your Rider model

class RiderServices {
  String collection = "users";

  Future<RiderModel> getRiderById(String id) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection(collection).doc(id).get();

    // Extract data from the document snapshot
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Create a RiderModel using fromMap
    return RiderModel.fromMap(data);
  }
}
