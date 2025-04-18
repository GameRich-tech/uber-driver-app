import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const ID = "id";
  static const NAME = "name";
  static const EMAIL = "email";
  static const PHONE = "phone";
  static const VOTES = "votes";
  static const TRIPS = "trips";
  static const RATING = "rating";
  static const TOKEN = "token";
  static const PHOTO = "photo";
  static const BRAND = "brand";
  static const MODEL = "model";
  static const FUEL_TYPE = "fuelType";
  static const LICENSE_PLATE = "licensePlate";
  static const HAS_VEHICLE = "hasVehicle";
  static const VEHICLE_TYPE = "vehicleType";
  static const NEXT_PAYMENT_DATE = "nextPaymentDate"; // ✅ Add this field

  late final String _id;
  late final String _name;
  late final String _email;
  late final String _phone;
  late final String _token;
  late final String _photo;
  late final String _brand;
  late final String _model;
  late final String _vehicleType;
  late final String _fuelType;
  late final String _licensePlate;
  late final bool _hasVehicle;

  late final int _votes;
  late final int _trips;
  late final double _rating;
  late final DateTime? _nextPaymentDate; // ✅ Store the payment date

  // Getters
  String get name => _name;
  String get email => _email;
  String get id => _id;
  String get phone => _phone;
  int get votes => _votes;
  int get trips => _trips;
  double get rating => _rating;
  String get token => _token;
  String get photo => _photo;
  String get brand => _brand;
  String get model => _model;
  String get vehicleType => _vehicleType;
  String get licensePlate => _licensePlate;
  String get fuelType => _fuelType;
  bool get hasVehicle => _hasVehicle;
  DateTime? get nextPaymentDate => _nextPaymentDate; // ✅ Getter for the date

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    _name = data?[NAME] ?? '';
    _email = data?[EMAIL] ?? '';
    _id = data?[ID] ?? '';
    _token = data?[TOKEN] ?? '';
    _vehicleType = data?[VEHICLE_TYPE] ?? '';
    _hasVehicle = data?[HAS_VEHICLE] ?? false;
    _photo = data?[PHOTO] ?? '';
    _fuelType = data?[FUEL_TYPE] ?? '';
    _brand = data?[BRAND] ?? '';
    _model = data?[MODEL] ?? '';
    _licensePlate = data?[LICENSE_PLATE] ?? '';
    _phone = data?[PHONE] ?? '';
    _votes = data?[VOTES] ?? 0;
    _trips = data?[TRIPS] ?? 0;
    _rating = (data?[RATING] ?? 0).toDouble();

    // ✅ Convert Firestore timestamp to DateTime
    // ✅ Convert Firestore timestamp or String to DateTime
    if (data?[NEXT_PAYMENT_DATE] != null) {
      if (data?[NEXT_PAYMENT_DATE] is Timestamp) {
        _nextPaymentDate = (data?[NEXT_PAYMENT_DATE] as Timestamp).toDate();
      } else if (data?[NEXT_PAYMENT_DATE] is String) {
        _nextPaymentDate = DateTime.tryParse(data?[NEXT_PAYMENT_DATE] ?? '');
      } else {
        _nextPaymentDate = null;
      }
    } else {
      _nextPaymentDate = null;
    }
  }
}
