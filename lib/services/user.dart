import 'package:cabdriver/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  final String collection = "drivers";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void createUser(
      {required String id,
      required String name,
      required String email,
      required String phone,
      required String token,
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
      "trips": trips,
      "rating": rating,
      "position": position,
      "car": "Toyota Corolla",
      "plate": "CBA 321 7",
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
}
