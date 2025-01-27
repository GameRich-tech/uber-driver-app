import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestModel {
  static const String ID = "id";
  static const String USERNAME = "username";
  static const String USER_ID = "userId";
  static const String DESTINATION = "destination";
  static const String DESTINATION_LAT = "destination_latitude";
  static const String DESTINATION_LNG = "destination_longitude";
  static const String USER_LAT = "user_latitude";
  static const String USER_LNG = "user_longitude";
  static const String DISTANCE_TEXT = "distance_text";
  static const String DISTANCE_VALUE = "distance_value";

  late final String _id;
  late final String _username;
  late final String _userId;
  late final String _destination;
  late final double _dLatitude;
  late final double _dLongitude;
  late final double _uLatitude;
  late final double _uLongitude;
  late final Distance _distance;

  String get id => _id;

  String get username => _username;

  String get userId => _userId;

  String get destination => _destination;

  double get dLatitude => _dLatitude;

  double get dLongitude => _dLongitude;

  double get uLatitude => _uLatitude;

  double get uLongitude => _uLongitude;

  Distance get distance => _distance;

  RideRequestModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    String _d = data?[DESTINATION];
    _id = data?[ID];
    _username = data?[USERNAME];
    _userId = data?[USER_ID];
    _destination = _d.substring(0, _d.indexOf(','));
    _dLatitude = double.parse(data?[DESTINATION_LAT]);
    _dLongitude = double.parse(data?[DESTINATION_LNG]);
    _uLatitude = double.parse(data?[USER_LAT]);
    _uLongitude = double.parse(data?[USER_LAT]);
    _distance = Distance.fromMap({
      "text": data?[DISTANCE_TEXT],
      "value": int.parse(data?[DISTANCE_VALUE])
    });
  }
}

class Distance {
  late String text;
  late int value;

  Distance.fromMap(Map data) {
    text = data["text"];
    value = data["value"];
  }

  Map toJson() => {"text": text, "value": value};
}

class RequestModelFirebase {
  static const ID = "id";
  static const USERNAME = "username";
  static const USER_ID = "userId";
  static const DRIVER_ID = "driverId";
  static const STATUS = "status";
  static const POSITION = "position";
  static const DESTINATION = "destination";

  late final String _id;
  late final String _username;
  late final String _userId;
  late final String _driverId;
  late final String _status;
  late final Map _position;
  late final Map _destination;

  String get id => _id;
  String get username => _username;
  String get userId => _userId;
  String get driverId => _driverId;
  String get status => _status;
  Map get position => _position;
  Map get destination => _destination;

  RequestModelFirebase.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    _id = data?[ID] ?? ''; // Default to empty string if null
    _username = data?[USERNAME] ?? '';
    _userId = data?[USER_ID] ?? '';
    _driverId = data?[DRIVER_ID]; // Nullable
    _status = data?[STATUS] ?? '';
    _position = data?[POSITION] ?? {};
    _destination = data?[DESTINATION] ?? {};
  }

  LatLng getCoordinates() =>
      LatLng(_position['latitude'], _position['longitude']);
}
