import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class UserServices {
  final String collection = "drivers";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void createUser(
      {required String id,
      required String name,
      required String email,
      required String phone,
      required String token,
      required String photo,
      required bool hasVehicle,
      required String identification,
      int votes = 0,
      int trips = 0,
      double rating = 0,
      required Map position}) {
    firestore.collection(collection).doc(id).set({
      "name": name,
      "id": id,
      "phone": phone,
      "email": email,
      "votes": votes,
      "photo": photo,
      "trips": trips,
      "rating": rating,
      "position": position,
      "hasVehicle": hasVehicle,
      "identification": identification,
      "token": token
    });
  }

  void updateUserData(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).update(values);
  }

  void addDeviceToken({required String token, required String userId}) {
    firestore.collection(collection).doc(userId).update({"token": token});
  }

  Future<UserModel> getUserById(String id) =>
      firestore.collection(collection).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });

  /// Set the driver Online Status
  Future<void> setOnlineStatus(String userId, bool isOnline) async {
    try {
      await firestore.collection(collection).doc(userId).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      print("Error updating online status: $e");
    }
  }

  /// Get the driver Online Status
  Future<bool> getOnlineStatus(String userId) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection(collection).doc(userId).get();
      return doc.exists ? doc['isOnline'] ?? false : false;
    } catch (e) {
      print("Error fetching online status: $e");
      return false;
    }
  }
}
