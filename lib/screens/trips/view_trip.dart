import 'dart:math';

import 'package:Bucoride_Driver/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../locators/service_locator.dart';
import '../../providers/app_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/call_sms.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_text.dart';

class ViewTrip extends StatefulWidget {
  final Map<String, dynamic> request;

  ViewTrip({required this.request});

  @override
  _ViewTripState createState() => _ViewTripState();
}

class _ViewTripState extends State<ViewTrip> {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  late LatLng riderPosition;
  String riderAddress = 'Loading...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setRiderAddress();
    });
  }

  setRiderAddress() async {
    print("setRiderAddress called");
    double latitude = widget.request['position']?['latitude'] ?? 0.0;
    double longitude = widget.request['position']?['longitude'] ?? 0.0;
    riderPosition = LatLng(latitude, longitude);
    print("Rider position is====" "${riderPosition}");

    // Get the destination address
    var destinationData = widget.request['destination'];
    double destinationLatitude = destinationData?['latitude'] ?? 0.0;
    double destinationLongitude = destinationData?['longitude'] ?? 0.0;
    LatLng destinationPosition =
        LatLng(destinationLatitude, destinationLongitude);
    print("Destination position is====" "${destinationPosition}");

    try {
      // Fetch address from location provider
      LocationProvider locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      await locationProvider
          .fetchRiderAddress(riderPosition); // Fetch the address

      // Add rider's marker to the map
      locationProvider.addRiderLocationMarker(riderPosition);
      // Add polyline for the rider's route from position to destination
      locationProvider.addRiderRoutePolyline(
          riderPosition, destinationPosition);

      // Create polyline for the journey
      LatLng driverPosition = LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!
              .longitude); // Example driver's location, replace with actual

      locationProvider.createJourneyPolyline(driverPosition, riderPosition);

      // Calculate bounds to include both positions (driver and rider)
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(riderPosition.latitude, destinationLatitude),
          min(riderPosition.longitude, destinationLongitude),
        ),
        northeast: LatLng(
          max(driverPosition.latitude, destinationLatitude),
          max(driverPosition.longitude, destinationLongitude),
        ),
      );

      // Animate the camera to show both positions
      if (locationProvider.mapController != null) {
        locationProvider.mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds,
              100), // Padding of 100 pixels to keep the map from being too tight
        );
      }
      setState(() {
        riderAddress = locationProvider.riderAddress; // Set the fetched address
      });
      print("The rider Address: $riderAddress");
    } catch (e) {
      print("Error fetching rider address: $e");
      setState(() {
        riderAddress = 'Error fetching address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: true);
    final locationProvider = Provider.of<LocationProvider>(context);

    LatLng newPos = LatLng(locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude);
    locationProvider.mapController?.animateCamera(
      CameraUpdate.newLatLng(newPos),
    );

    //appState.sendRequest(
    //    intendedLocation: riderAddress, coordinates: riderPosition);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      expand: true,
      shouldCloseOnMinExtent: true,
      builder: (BuildContext context, myscrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: grey,
                offset: Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: ListView(
            controller: myscrollController,
            children: [
              SizedBox(
                height: 12,
              ),
              ListTile(
                leading: appState.riderModel!.phone == null
                    ? CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person_outline,
                          size: 25,
                        ),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(Images.personPlaceholder),
                      ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request['username'] as String? ?? 'N/A',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Pick up location: $riderAddress",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      "Destination: ${widget.request['destination']?['address'] as String? ?? 'N/A'}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      "Distance: ${widget.request['distance']?['text'] as String? ?? 'N/A'}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      "Distance value: ${widget.request['distance']?['value']?.toString() ?? 'N/A'}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _service.call(appState.riderModel!.phone);
                    },
                    icon: Icon(Icons.call),
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: CustomText(
                  text: "Ride details",
                  size: 18,
                  weight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 100,
                    width: 10,
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 9),
                          child: Container(
                            height: 45,
                            width: 2,
                            color: primary,
                          ),
                        ),
                        Icon(Icons.flag),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "\nPick up location \n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(
                            text: riderAddress,
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),
                          ),
                          TextSpan(
                            text: "\n\nDestination \n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(
                            text: widget.request['destination']?['address']
                                    as String? ??
                                'N/A',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),
                          ),
                        ],
                        style: TextStyle(color: black),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
                    appState.cancelRequest(requestId: appState.requestModelFirebase.id);
                    appState.show = Show.IDLE;
                  },
                  child: CustomText(
                    text: "Cancel Ride",
                    color: white,
                    size: AppConstants.defaultTextSize,
                    weight: AppConstants.defaultWeight,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
