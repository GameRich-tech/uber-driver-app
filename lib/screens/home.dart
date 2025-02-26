import 'dart:async';

import 'package:Bucoride_Driver/screens/ride_request.dart';
import 'package:Bucoride_Driver/screens/trips/view_trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:provider/provider.dart';

import '../helpers/constants.dart';
import '../providers/app_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user.dart';
import '../widgets/home_widgets/idle_widget.dart';
import 'map/map.dart';
import 'trips/rider_draggable.dart';

GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);

class HomePage extends StatefulWidget {
  HomePage({super.key});

  //final RequestModelFirebase request;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _updatePosition();

    _restoreSystemUI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restore UI
  }

  _updatePosition() async {
    //    this section down here will update the drivers current position on the DB when the app is opened
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    _user.updateUserData({
      "id": _user.userModel?.id,
      "position": locationProvider.currentPosition
    });
    print(
        "just updated my position: ${locationProvider.currentPosition}, For DirverID: ${_user.userModel?.id}");
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);

    print("==============State of Ride Request: ${appState.hasNewRideRequest}");

    Widget home = Scaffold(
      key: scaffoldState,
      body: Stack(
        children: [
          MapScreen(scaffoldState),
          Visibility(visible: appState.show == Show.IDLE, child: IdleWidget()),
          Visibility(
              visible: appState.show == Show.RIDER, child: RiderWidget()),
          Visibility(visible: appState.show == Show.TRIP, child: RiderWidget()),
          Visibility(
            visible: appState.show == Show.INSPECTROUTE,
            child: ViewTrip(
              request: appState.currentRequest ?? {},
            ),
          ),
        ],
      ),
    );

    // Show RideRequestScreen as a dialog instead of replacing the home screen
    if (appState.hasNewRideRequest) {
      Future.microtask(() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RideRequestScreen(),
        ).then((_) {
          // Reset the flag after dialog is dismissed
          appState.setHasNewRideRequest(false);
        });
      });
    }

    return home;
  }
}
