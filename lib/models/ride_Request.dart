import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestModelFirebase {
  static const ID = "id";
  static const USERNAME = "username";
  static const USER_ID = "userId";
  static const DRIVER_ID = "driverId";
  static const STATUS = "status";
  static const POSITION = "position";
  static const DESTINATION = "destination";
  static const DISTANCE = "distance";
  static const DESTINATION_LAT = "destination_latitude";
  static const DESTINATION_LNG = "destination_longitude";
  static const USER_LAT = "user_latitude";
  static const USER_LNG = "user_longitude";
  static const DISTANCE_TEXT = "distance_text";
  static const DISTANCE_VALUE = "distance_value";

  late final String _id;
  late final String _username;
  late final String _userId;
  late final String _driverId;
  late final String _status;
  late final Map<String, dynamic> _position;
  late final Map<String, dynamic> _destination;
  late final Map<String, dynamic> _distance;
  late final double _dLatitude;
  late final double _dLongitude;
  late final double _uLatitude;
  late final double _uLongitude;
  late final double _distanceValue;

  String get id => _id;
  String get username => _username;
  String get userId => _userId;
  String get driverId => _driverId;
  String get status => _status;

  Map<String, dynamic> get position => _position;
  Map<String, dynamic> get destination => _destination;
  Map<String, dynamic> get distance => _distance;
  double get dLatitude => _dLatitude;
  double get dLongitude => _dLongitude;
  double get uLatitude => _uLatitude;
  double get uLongitude => _uLongitude;
  double get distanceValue => _distanceValue;

  RequestModelFirebase.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    _id = data?[ID] ?? '';
    _username = data?[USERNAME] ?? '';
    _userId = data?[USER_ID] ?? '';
    _driverId = data?[DRIVER_ID] ?? '';
    _status = data?[STATUS] ?? '';
    _position = data?[POSITION] ?? {};
    _destination = data?[DESTINATION] ?? {};
    _distance = data?[DISTANCE] ?? {};
    // Fix: Extract distance_value from the nested map
    _distanceValue =
        (data?[DISTANCE] != null && data?[DISTANCE]['value'] != null)
            ? double.tryParse(data![DISTANCE]['value'].toString()) ?? 0.0
            : 0.0;
    _dLatitude = double.parse(data?[DESTINATION_LAT]?.toString() ?? '0');
    _dLongitude = double.parse(data?[DESTINATION_LNG]?.toString() ?? '0');
    _uLatitude = double.parse(data?[USER_LAT]?.toString() ?? '0');
    _uLongitude = double.parse(data?[USER_LNG]?.toString() ?? '0');
  }

  // Add the fromMap constructor
  RequestModelFirebase.fromMap(Map<String, dynamic> data) {
    _id = data[ID] ?? '';
    _username = data[USERNAME] ?? '';
    _userId = data[USER_ID] ?? '';
    _driverId = data[DRIVER_ID] ?? '';
    _status = data[STATUS] ?? '';
    _position = data[POSITION] ?? {};
    _destination = data[DESTINATION] ?? {};
    _distance = data[DISTANCE] ?? {};
    _dLatitude = double.parse(data[DESTINATION_LAT]?.toString() ?? '0');
    _dLongitude = double.parse(data[DESTINATION_LNG]?.toString() ?? '0');
    _uLatitude = double.parse(data[USER_LAT]?.toString() ?? '0');
    _uLongitude = double.parse(data[USER_LNG]?.toString() ?? '0');
  }

  LatLng getCoordinates() => LatLng(_uLatitude, _uLongitude);
}

class Distance {
  late String text;
  late int value;

  Distance.fromMap(Map<String, dynamic> data) {
    text = data["text"];
    value = data["value"];
  }

  Map<String, dynamic> toJson() => {"text": text, "value": value};
}
