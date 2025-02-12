import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../helpers/constants.dart';
import '../utils/images.dart';

class LocationProvider with ChangeNotifier {
  GoogleMapController? _mapController;

  // LIST OBJECTS
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Position? _currentPosition;
  Stream<Position>? _positionStream;
  String _riderAddress = 'Loading...';
  late LatLng _bounds;
  //Getters
  Position? get currentPosition => _currentPosition;
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers; // Expose markers
  String get riderAddress => _riderAddress;
  Set<Polyline> get polylines => _polylines;
//LatLng get bounds => _bounds;

//SETTERS

  // BOOLEANS

  bool _isTrafficEnabled = false;
  get isTrafficEnabled => _isTrafficEnabled;

//OTHERS
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  LocationProvider() {
    _startPositionStream();
    fetchLocation();
    checkPermisions();
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
    _currentPosition = await Geolocator.getCurrentPosition();
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

      notifyListeners();
    });
  }

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  toggleTraffic() {
    _isTrafficEnabled = !isTrafficEnabled;
    notifyListeners(); // Update UI
  }

  _addCustomMarker(LatLng position) {
    BitmapDescriptor.asset(
            ImageConfiguration(size: Size(30, 30), devicePixelRatio: 2.5),
            Images.mapLocationIcon)
        .then((icon) {
      markerIcon = icon;
    });
    var uuid = new Uuid();
    String markerId = uuid.v1();
    _markers.add(Marker(
        markerId: MarkerId(markerId), position: position, icon: markerIcon));
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  // ✅ Add Marker for Current Location
  void _addCurrentLocationMarker(Position position) {
    clearMarkers();
    final marker = Marker(
      markerId: MarkerId('current_location'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: 'You Are Here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
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
