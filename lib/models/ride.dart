class RideRequest {
  final String username;
  final String destination;
  final String distanceText;
  final int distanceValue;
  final double destinationLatitude;
  final double destinationLongitude;
  final double userLatitude;
  final double userLongitude;
  final String id;
  final String userId;

  RideRequest({
    required this.username,
    required this.destination,
    required this.distanceText,
    required this.distanceValue,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.userLatitude,
    required this.userLongitude,
    required this.id,
    required this.userId,
  });

  // Factory method to create an instance from JSON
  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      username: json['username'] ?? '',
      destination: json['destination'] ?? '',
      distanceText: json['distance_text'] ?? '',
      distanceValue: int.tryParse(json['distance_value'].toString()) ?? 0, // Ensures int
      destinationLatitude: double.tryParse(json['destination_latitude'].toString()) ?? 0.0,
      destinationLongitude: double.tryParse(json['destination_longitude'].toString()) ?? 0.0,
      userLatitude: double.tryParse(json['user_latitude'].toString()) ?? 0.0,
      userLongitude: double.tryParse(json['user_longitude'].toString()) ?? 0.0,
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}
