import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../helpers/constants.dart';
import '../utils/images.dart';

class LocationProvider with ChangeNotifier {
  static const String LOCATION_MARKER = "locationMarker";
  static const DESTINATION_MARKER_ID = 'destination';

  GoogleMapController? _mapController;

  // LIST OBJECTS
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Position? _currentPosition;
  Position? _destination;
  Stream<Position>? _positionStream;
  String _riderAddress = 'Loading...';
  late LatLng _bounds;
  bool _isTracking = false;
  String? _tripId = "";
  String _eta = "";
  String _remainingDistance = "";

  //Getters
  Position? get currentPosition => _currentPosition;
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers; // Expose markers
  String get riderAddress => _riderAddress;
  Set<Polyline> get polylines => _polylines;
  String get eta => _eta;
  String get remainingDistance => _remainingDistance;

//SETTERS

  // BOOLEANS

  bool _isTrafficEnabled = false;
  get isTrafficEnabled => _isTrafficEnabled;

//OTHERS
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueYellow,
  );
  BitmapDescriptor parcelDestinationIcon = BitmapDescriptor.defaultMarker;

  LocationProvider() {
    _startPositionStream();
    fetchLocation();
    checkPermisions();
  }
  void startTrip(String tripId) {
    _tripId = tripId;
    _isTracking = true;
    notifyListeners();
  }

  void stopTrip() {
    _isTracking = false;
  }

  void checkPermisions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    checkLocationPermission(permission);
  }

  void checkLocationPermission(LocationPermission permission) {
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are denied");
    }
  }

  Future<void> fetchLocation() async {
    print("Trying to fetch location");

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("⚠️ Location services are disabled.");
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("⚠️ Location permission denied.");

          notifyListeners();
          return;
        }
      }
      _currentPosition = await Geolocator.getCurrentPosition();
      print("📍 My Position: $_currentPosition");
    } catch (e) {
      print('❌ Error fetching location: $e');
    } finally {
      notifyListeners();
    }
  }

  void _startPositionStream() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // High accuracy for ride-hailing apps
      distanceFilter: 10, // Update only if moved by 10 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    _positionStream!.listen((Position position) {
      _currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      //_addCustomMarker(pos);
      _addCurrentLocationMarker(position);

      // Update Firestore ONLY if tracking is active
      if (_isTracking && _tripId != null) {
        FirebaseFirestore.instance.collection('rides').doc(_tripId).update({
          'driverLocation': {
            'lat': position.latitude,
            'lng': position.longitude,
          }
        });

        updateTripInfo();
      }

      notifyListeners();
    });
  }

  //Trip Info
  Future<void> updateTripInfo() async {
    if (_currentPosition == null || _destination == null) return;

    createJourneyPolyline(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(_destination!.latitude, _destination!.longitude));
    final response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition?.latitude},${_currentPosition?.longitude}&destination=${_destination?.latitude},${_destination?.longitude}&key=${GOOGLE_MAPS_API_KEY}"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final elements = data["routes"][0]["legs"][0];

      _eta = elements["duration"]["text"]; // Example: "10 mins"
      _remainingDistance = elements["distance"]["text"]; // Example: "3.5 km"

      notifyListeners();
    }
  }

  void startTracking(String tripId) {
    _tripId = tripId;
    _isTracking = true;

    if (_positionStream == null) {
      _startPositionStream();
    }
  }

  void stopTracking() {
    _isTracking = false;
    _tripId = null;
  }

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  toggleTraffic() {
    _isTrafficEnabled = !isTrafficEnabled;
    notifyListeners(); // Update UI
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void animateToDriverPosition(LatLng driverPosition) {
    LatLng pos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(driverPosition, 16.5), // Zoom into driver
    );
  }

  void animateBackToDriverPosition() {
    LatLng pos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 16.5), // Zoom into driver
    );
  }

  // ✅ Add Marker for Current Location
  void _addCurrentLocationMarker(Position position) {
    clearMarkers();
    final marker = Marker(
      markerId: MarkerId(LOCATION_MARKER),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: 'You Are Here'),
      icon: markerIcon,
    );

    _markers
      ..removeWhere(
          (m) => m.markerId.value == 'current_location') // Remove old marker
      ..add(marker); // Add new marker

    notifyListeners();
  }

  void addRiderLocationMarker(LatLng riderPosition) {
    final riderMarker = Marker(
      markerId: MarkerId('riderMarker'),
      position: riderPosition,
      infoWindow: InfoWindow(title: "Rider Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _markers.add(riderMarker);
    notifyListeners(); // Update UI
  }

  Future<void> addCustomParcelDestinationMarker(LatLng position) async {
    clearMarkers();

    BitmapDescriptor icon = await BitmapDescriptor.asset(
      const ImageConfiguration(
          size: Size(80, 80), devicePixelRatio: 2.5), // Adjust size if needed
      Images.mapLocationIcon,
    );

    _markers.add(Marker(
      markerId: const MarkerId(DESTINATION_MARKER_ID),
      position: position,
      icon: icon,
      anchor: const Offset(0.5, 1.0), // Align bottom-center
    ));
  }

  void addParcelDestinationLocationMarker(LatLng riderPosition) {
    final riderMarker = Marker(
      markerId: MarkerId('riderMarker'),
      position: riderPosition,
      infoWindow: InfoWindow(title: "Rider Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _markers.add(riderMarker);
    notifyListeners(); // Update UI
  }

  onCameraMove(CameraPosition position) {
    // TODO implent something
    //notifyListeners();
  }

  // This method will fetch the address based on the rider's location
  Future<void> fetchRiderAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        _riderAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      } else {
        _riderAddress = 'Address not found';
      }
    } catch (e) {
      _riderAddress = 'Error fetching address';
      print('Error fetching address: $e');
    }
    notifyListeners();
  }

  Position convertLatLngToPosition(LatLng latLng) {
    return Position(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0, // Default value
      altitude: 0.0, // Default value
      heading: 0.0, // Default value
      speed: 0.0, // Default value
      speedAccuracy: 0.0, altitudeAccuracy: 0.0,
      headingAccuracy: 0.0, // Default value
    );
  }

  // HERE WE CREATE THE POLY LINES
// Create polyline based on rider's and driver's positions
  Future<void> createJourneyPolyline(
      LatLng driverPosition, LatLng destination) async {
    String? encodedPolyline = await getDirections(driverPosition, destination);
    if (encodedPolyline != null) {
      List<LatLng> polylineCoordinates = decodePolyline(encodedPolyline);
      final polyline = Polyline(
          polylineId: PolylineId('journey_path'),
          color: Colors.blue,
          width: 5,
          points:
              polylineCoordinates // You can extend this with more points if needed
          );
      _polylines.add(polyline);

      _destination = convertLatLngToPosition(destination);
      notifyListeners();
    }
  }

// Add polyline for the rider's journey (from rider's position to destination)
  void addRiderRoutePolyline(LatLng start, LatLng end) async {
    String? encodedPolyline = await getDirections(start, end);
    if (encodedPolyline != null) {
      List<LatLng> polylineCoordinates = decodePolyline(encodedPolyline);
      final polyline = Polyline(
        polylineId: PolylineId('rider_route'),
        points: polylineCoordinates,
        color: Colors.green, // Customize color as needed
        width: 5,
      );
      _polylines.add(polyline);
      notifyListeners();
    }
  }

  // Optionally clear the polyline if needed
  void clearPolylines() {
    _polylines.clear();
    notifyListeners();
  }

  Future<String?> getDirections(LatLng origin, LatLng destination) async {
    final String googleApiKey = GOOGLE_MAPS_API_KEY;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        // Extract polyline from the response
        String polyline = data['routes'][0]['overview_polyline']['points'];
        return polyline;
      } else {
        print("Error fetching directions: ${data['status']}");
        return null;
      }
    } else {
      print("Error fetching directions: ${response.statusCode}");
      return null;
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      while (true) {
        int byte = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        if (byte < 0x20) break;
      }
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      while (true) {
        int byte = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        if (byte < 0x20) break;
      }
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }
}
