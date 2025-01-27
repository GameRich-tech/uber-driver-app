import 'dart:async';
import 'dart:typed_data';

import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/helpers/style.dart';
import 'package:cabdriver/models/ride_Request.dart';
import 'package:cabdriver/models/rider.dart';
import 'package:cabdriver/models/route.dart';
import 'package:cabdriver/services/map_requests.dart';
import 'package:cabdriver/services/ride_request.dart';
import 'package:cabdriver/services/rider.dart';
import 'package:cabdriver/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum Show { RIDER, TRIP }

class AppStateProvider with ChangeNotifier {
  static const ACCEPTED = 'accepted';
  static const CANCELLED = 'cancelled';
  static const PENDING = 'pending';
  static const EXPIRED = 'expired';
  // ANCHOR: VARIABLES DEFINITION
  Set<Marker> _markers = {};
  Set<Polyline> _poly = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  late GoogleMapController _mapController;
  late Position position;
  static LatLng _center = LatLng(0, 0);
  LatLng _lastPosition = _center;
  TextEditingController _locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng get center => _center;
  LatLng get lastPosition => _lastPosition;
  TextEditingController get locationController => _locationController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get poly => _poly;
  GoogleMapController get mapController => _mapController;
  late RouteModel routeModel;
  late SharedPreferences prefs;

  geocoding.Location location = new geocoding.Location(
      latitude: 0, longitude: 0, timestamp: DateTime.timestamp());
  bool hasNewRideRequest = false;
  UserServices _userServices = UserServices();
  late RideRequestModel rideRequestModel;
  late RequestModelFirebase requestModelFirebase;

  late RiderModel riderModel;
  late RiderServices _riderServices = RiderServices();
  late double distanceFromRider = 0;
  late double totalRideDistance = 0;
  late StreamSubscription<QuerySnapshot> requestStream;
  late int timeCounter = 0;
  late double percentage = 0;
  late Timer periodicTimer;
  RideRequestServices _requestServices = RideRequestServices();
  late Show show;

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  AppStateProvider() {
//    _subscribeUser();
    _saveDeviceToken();
    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleOnMessage(message as Map<String, dynamic>);
    });

    // App launched by tapping a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleOnLaunch(message as Map<String, dynamic>);
    });

    // App is in the background, and notification taps open the app
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleOnResume(message as Map<String, dynamic>);
      }
    });

    _getUserLocation();
    Geolocator.getPositionStream().listen(_userCurrentLocationUpdate);
  }

  // ANCHOR LOCATION METHODS
  _userCurrentLocationUpdate(Position updatedPosition) async {
    // Provide fallback value for latitude and longitude
    double latitude = prefs.getDouble('lat') ?? 0.0;
    double longitude = prefs.getDouble('lng') ?? 0.0;

    double distance = await Geolocator.distanceBetween(latitude, longitude,
        updatedPosition.latitude, updatedPosition.longitude);

    Map<String, dynamic> values = {
      "id": prefs.getString("id"),
      "position": updatedPosition.toJson()
    };

    if (distance >= 50) {
      if (show == Show.RIDER) {
        sendRequest(
            coordinates: requestModelFirebase.getCoordinates(),
            intendedLocation: '');
      }
      _userServices.updateUserData(values);
      await prefs.setDouble('lat', updatedPosition.latitude);
      await prefs.setDouble('lng', updatedPosition.longitude);
    }
  }

  _getUserLocation() async {
    prefs = await SharedPreferences.getInstance();
    position = await Geolocator.getCurrentPosition();
    List<geocoding.Placemark> placemark = await geocoding
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _center = LatLng(position.latitude, position.longitude);
    await prefs.setDouble('lat', position.latitude);
    await prefs.setDouble('lng', position.longitude);
    _locationController.text = placemark[0].name!;
    notifyListeners();
  }

  // ANCHOR MAPS METHODS

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  setLastPosition(LatLng position) {
    _lastPosition = position;
    notifyListeners();
  }

  onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  void sendRequest(
      {required String intendedLocation, required LatLng coordinates}) async {
    LatLng origin = LatLng(position.latitude, position.longitude);

    LatLng destination = coordinates;
    RouteModel route =
        await _googleMapsServices.getRouteByCoordinates(origin, destination);
    routeModel = route;
    addLocationMarker(
        destination, routeModel.endAddress, routeModel.distance.text);
    _center = destination;
    destinationController.text = routeModel.endAddress;

    _createRoute(route.points);
    notifyListeners();
  }

  void _createRoute(String decodeRoute) {
    _poly = {};
    var uuid = new Uuid();
    String polyId = uuid.v1();
    poly.add(Polyline(
        polylineId: PolylineId(polyId),
        width: 8,
        color: primary,
        onTap: () {},
        points: _convertToLatLong(_decodePoly(decodeRoute))));
    notifyListeners();
  }

  List<LatLng> _convertToLatLong(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List<double> _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = <double>[];
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  // ANCHOR MARKERS
  addLocationMarker(LatLng position, String destination, String distance) {
    _markers = {};
    var uuid = new Uuid();
    String markerId = uuid.v1();
    _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: destination, snippet: distance),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("images/car.png");
    return byteData.buffer.asUint8List();
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  _saveDeviceToken() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      String? deviceToken = await fcm.getToken();
      await prefs.setString('token', deviceToken!);
    }
  }

// ANCHOR PUSH NOTIFICATION METHODS
  Future handleOnMessage(Map<String, dynamic> data) async {
    _handleNotificationData(data);
  }

  Future handleOnLaunch(Map<String, dynamic> data) async {
    _handleNotificationData(data);
  }

  Future handleOnResume(Map<String, dynamic> data) async {
    _handleNotificationData(data);
  }

  _handleNotificationData(Map<String, dynamic> data) async {
    hasNewRideRequest = true;
    rideRequestModel = RideRequestModel.fromSnapshot(data['data']);
    riderModel = await _riderServices.getRiderById(rideRequestModel.userId);
    notifyListeners();
  }

// ANCHOR RIDE REQUEST METHODS
  changeRideRequestStatus() {
    hasNewRideRequest = false;
    notifyListeners();
  }

  listenToRequest({required String id, required BuildContext context}) async {
    // requestModelFirebase = await _requestServices.getRequestById(id);
    print("======= LISTENING =======");
    requestStream = _requestServices.requestStream().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((doc) {
        var data = doc.doc.data() as Map<String, dynamic>?; // Cast to Map

        if (data != null && data['id'] == id) {
          requestModelFirebase = RequestModelFirebase.fromSnapshot(doc.doc);
          notifyListeners();

          switch (data['status']) {
            case CANCELLED:
              print("====== CANCELLED");
              break;
            case ACCEPTED:
              print("====== ACCEPTED");
              break;
            case EXPIRED:
              print("====== EXPIRED");
              break;
            default:
              print("==== PENDING");
              break;
          }
        }
      });
    });
  }

  //  Timer counter for driver request
  percentageCounter(
      {required String requestId, required BuildContext context}) {
    notifyListeners();
    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      print("====== GOOOO $timeCounter");
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        time.cancel();
        hasNewRideRequest = false;
        requestStream.cancel();
      }
      notifyListeners();
    });
  }

  acceptRequest({required String requestId, required String driverId}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest(
        {"id": requestId, "status": "accepted", "driverId": driverId});
    notifyListeners();
  }

  cancelRequest({required String requestId}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest({"id": requestId, "status": "cancelled"});
    notifyListeners();
  }

  //  ANCHOR UI METHODS
  changeWidgetShowed({required Show showWidget}) {
    show = showWidget;
    notifyListeners();
  }
}
