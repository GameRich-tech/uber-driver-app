class RiderModel {
  static const ID = "id";
  static const NAME = "name";
  static const EMAIL = "email";
  static const PHONE = "phone";
  static const VOTES = "votes";
  static const TRIPS = "trips";
  static const RATING = "rating";
  static const TOKEN = "token";
  static const PHOTO = "photo";

  late final String _id;
  late final String _name;
  late final String _email;
  late final String _phone;
  late final String _token;
  late final String _photo;

  late final int _votes;
  late final int _trips;
  late final double _rating;

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

  // Constructor from Map
  RiderModel.fromMap(Map<String, dynamic> data) {
    _name = data[NAME] ?? '';
    _email = data[EMAIL] ?? '';
    _id = data[ID] ?? '';
    _phone = data[PHONE] ?? '';
    _token = data[TOKEN] ?? '';
    _votes = data[VOTES] ?? 0;
    _trips = data[TRIPS] ?? 0;
    _rating = data[RATING] ?? 0.0;
    _photo = data[PHOTO] ?? '';
  }
}
