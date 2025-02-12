import 'dart:async';

import 'package:Bucoride_Driver/helpers/constants.dart';
import 'package:Bucoride_Driver/providers/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../helpers/style.dart';
import '../models/ride_Request.dart';
import '../models/rider.dart';
import '../models/route.dart';
import '../services/map_requests.dart';
import '../services/ride_request.dart';
import '../services/rider.dart';
import '../services/user.dart';

enum Show { IDLE, RIDER, TRIP, INSPECTROUTE, COMPLETETRIP }

class AppStateProvider with ChangeNotifier {
  static const ACCEPTED = 'accepted';
  static const CANCELLED = 'cancelled';
  static const PENDING = 'pending';
  static const EXPIRED = 'expired';
  // ANCHOR: VARIABLES DEFINITION
  Set<Marker> _markers = {};
  Set<Polyline> _poly = {};

  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  late Position position;
  static LatLng _center = LatLng(0, 0);
  LatLng _lastPosition = _center;
  TextEditingController _locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng get center => _center;
  LatLng get lastPosition => _lastPosition;
  TextEditingController get locationController => _locationController;

  Set<Polyline> get poly => _poly;

  late RouteModel routeModel;

  geocoding.Location location = new geocoding.Location(
      latitude: 0, longitude: 0, timestamp: DateTime.timestamp());
  bool hasNewRideRequest = false;
  bool isInMapScreen = false;
  bool _alertIn = false;

  UserServices _userServices = UserServices();

  bool get inMap => isInMapScreen;
  bool get alertIn => _alertIn;

  set alertIn(bool value) {
    _alertIn = value;
    notifyListeners();
  }
  //Stream to count number to ride requests
  StreamController<int> _requestCountController = StreamController<int>();
  late StreamSubscription<QuerySnapshot> requestStreamSubscription;
  // Number of requests
  int _numberOfRequests = 0;
  int get numberOfRequests => _numberOfRequests;

  // ! FROM TRIP WE CAN STORE THE REQUEST AS A VARIABLE
  Map<String, dynamic>? _currentRequest;
  Map<String, dynamic>? get currentRequest => _currentRequest;

  late RequestModelFirebase requestModelFirebase;
  late RiderModel riderModel;
  List<RequestModelFirebase> pendingTrips = [];
  List<RiderModel> pendingTrip = [];
  late RiderServices _riderServices = RiderServices();

  late double distanceFromRider = 0;
  late double totalRideDistance = 0;
  late StreamSubscription<QuerySnapshot> requestStream;
  late int timeCounter = 0;
  late double percentage = 0;
  late Timer periodicTimer;
  RideRequestServices _requestServices = RideRequestServices();
  late Show show = Show.IDLE;

  @override
  void dispose() {
    // TODO: implement dispose
    _requestCountController.close();
    requestStreamSubscription.cancel();
    super.dispose();
  }

  AppStateProvider() {
    InitialiseRequests();
    _enableNotifications();

//    _subscribeUser();
    saveDeviceToken();

  }

  //This prevents the user from getting
  setMapState(bool state) {
    isInMapScreen = state;
    notifyListeners();
  }

  // ! END OF APPSTATEPROVIDER
  // STORE THE REQUEST FROM TH TRIP HISTORY SCREEN
  setRequest(Map<String, dynamic> request) {
    _currentRequest = request;
    notifyListeners();
  }

  void setRideRequest(RequestModelFirebase request) {
    requestModelFirebase = request;
    fetchRiderDetails(request.userId);
    //_hasNewRideRequest = true;
    show = Show.RIDER; // Show the RiderWidget
    notifyListeners();
  }

  _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    handleOnResume(message as Map<String, dynamic>);
  }

  Future<bool> checkIfFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      prefs.setBool('isFirstLaunch', false);
    }
    return isFirstLaunch;
  }
  // Save the device token

  _enableNotifications() async {
    // Request permissions
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notifications enabled');
    } else {
      print('🚨 Notifications NOT enabled');
    }
  }

  // ANCHOR LOCATION METHODS
  _userCurrentLocationUpdate(Position updatedPosition) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

  getRiderAddress(LatLng position) async {
    List<geocoding.Placemark> rider_Placemark = await geocoding
        .placemarkFromCoordinates(position.latitude, position.longitude);
    return rider_Placemark;
  }

  // ANCHOR MAPS METHODS

  setLastPosition(LatLng position) {
    _lastPosition = position;
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
      /* if value is negative then bitwise not the value */
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
  addLocationMarker(
      LatLng position, String destination, String distance) async {
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

  saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    String? deviceToken = await fcm.getToken();

    if (deviceToken != null) {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(prefs.getString('id')) // Ensure this is the correct driver ID
          .update({
        'token': deviceToken,
      });

      print("🚀 FCM Token updated in Firestore: $deviceToken");
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

    notifyListeners();
  }

// ANCHOR RIDE REQUEST METHODS
  changeRideRequestStatus() {
    hasNewRideRequest = false;
    notifyListeners();
  }

  Future<void> addNewRideRequest(Map<String, dynamic> request) async {
    var rideRequest = RequestModelFirebase.fromMap(request);

    show = Show.RIDER;
    pendingTrips.add(rideRequest);
    print("Pending Tripes=========" + "${pendingTrips}");
    notifyListeners();

    //_initializeRiderModel(rideRequest);
  }

  void showRideRequestDialog(
      BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Ride Request'),
          content: Text(
              'Details:\n\nUsername: ${request['username']}\nDestination: ${request['destination']['address']}\nDistance: ${request['distance']['text']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void InitialiseRequests() {
    print("======Initialise Requests======");
    requestStream = RideRequestServices().requestStream().listen(
      (querySnapshot) {
        querySnapshot.docChanges.forEach((change) async {
          if (change.type == DocumentChangeType.added) {
            _numberOfRequests = querySnapshot.docs.length;
            // Handle new ride request
            var request = change.doc.data() as Map<String, dynamic>?;
            print(request);
            if (request != null) {
              print('New ride request: $request');
              // Map request to RequestModelFirebase
              requestModelFirebase = RequestModelFirebase.fromMap(request);

              // Extract userId
              String userId = requestModelFirebase.userId;

              // Fetch rider details using userId
              riderModel = await RiderServices().getRiderById(userId);

              // Print rider details (optional)
              print('Rider details: ${riderModel}');

              // Continue with further processing
              // addNewRideRequest(requestModelFirebase);
              // showRideRequestDialog(context, request);
            }
          }
        });
      },
      onError: (error) {
        print('Error listening to ride requests: $error'); // Print any errors
      },
    );
  }

  listenToRequest({required String id, required BuildContext context}) async {
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

  // Accept Request Function
  void handleAccept(Map<String, dynamic> request, driverId) {
    final updatedRequest = {
      ...request,
      'status': 'accepted',
      'driverId': '${driverId}', // Replace with actual driver ID
    };
    _requestServices.updateRequest(updatedRequest);
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
  Future<void> completeTrip(String requestId) async {
  if (requestId.isEmpty) return;

  try {
    

    // 1️⃣ Get the current request from Firestore
    DocumentReference requestRef =
        FirebaseFirestore.instance.collection('rideRequests').doc(requestId);

    await requestRef.update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
    

    // 2️⃣ Increment the driver's trip count in Firestore
    //String driverId = userModel?.id ?? ''; // Ensure the driver ID exists
    //DocumentReference driverRef =
    //    FirebaseFirestore.instance.collection('users').doc(driverId);

    //await driverRef.update({
    //  'trip': FieldValue.increment(1),
    //});

    // 3️⃣ Reset app state variables
    //requestModelFirebase = null;
    show = Show.IDLE;

    notifyListeners(); // Notify UI about the state change

    print("Trip $requestId marked as completed.");
  } catch (e) {
    print("Error completing trip: $e");
  }
}


  Future<void> fetchRiderDetails(String riderId) async {
    try {
      DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(riderId)
          .get();

      if (riderDoc.exists) {
        riderModel =
            RiderModel.fromMap(riderDoc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching rider details: $e");
    }
  }
}
