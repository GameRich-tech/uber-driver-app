import 'dart:math';

import 'package:Bucoride_Driver/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../providers/app_provider.dart';
import '../../services/call_sms.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

import '../../widgets/loading.dart';

class RiderWidget extends StatefulWidget {
  const RiderWidget({Key? key}) : super(key: key);

  @override
  _RideRequestState createState() => _RideRequestState();
}

class _RideRequestState extends State<RiderWidget> {
  final CallsAndMessagesService _service = CallsAndMessagesService();
  String? riderAddress; // Rider address to display

  @override
  void initState() {
    super.initState();
    _fetchRiderAddress(); // Fetch the rider's address on widget load
  }

  Future<void> _fetchRiderAddress() async {
  print("Fetching rider address...");

  AppStateProvider appState =
      Provider.of<AppStateProvider>(context, listen: false);
  LocationProvider locationProvider =
      Provider.of<LocationProvider>(context, listen: false);

  if (appState.requestModelFirebase != null) {
    // Get rider position
    LatLng riderPos = LatLng(
      appState.requestModelFirebase.position['latitude'],
      appState.requestModelFirebase.position['longitude'],
    );
    print("Rider position: $riderPos");

    // Get destination position
    var destinationData = appState.requestModelFirebase.destination;
    LatLng destinationPos = LatLng(
      destinationData['latitude'],
      destinationData['longitude'],
    );
    print("Destination position: $destinationPos");

    try {
      // Fetch rider's address
      List<geocoding.Placemark> riderPlacemark =
          await geocoding.placemarkFromCoordinates(
        riderPos.latitude,
        riderPos.longitude,
      );

      if (riderPlacemark.isNotEmpty) {
        setState(() {
          riderAddress =
              "${riderPlacemark[0].street}, ${riderPlacemark[0].locality}";
        });
        print("Fetched Rider Address: $riderAddress");
      }

      // Add rider marker to the map
      locationProvider.addRiderLocationMarker(riderPos);

      // Add polyline for the rider's route from position to destination
      locationProvider.addRiderRoutePolyline(riderPos, destinationPos);

      // Get driver's position
      LatLng driverPos = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );

      // Create polyline for the journey
      locationProvider.createJourneyPolyline(driverPos, riderPos);

      // Calculate bounds for camera zoom
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(riderPos.latitude, destinationPos.latitude),
          min(riderPos.longitude, destinationPos.longitude),
        ),
        northeast: LatLng(
          max(driverPos.latitude, destinationPos.latitude),
          max(driverPos.longitude, destinationPos.longitude),
        ),
      );

      // Animate camera to fit the locations
      if (locationProvider.mapController != null) {
        locationProvider.mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      print("Error fetching rider address: $e");
      setState(() {
        riderAddress = 'Error fetching address';
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    _fetchRiderAddress();
    return DraggableScrollableSheet(
  initialChildSize: 0.4,
  minChildSize: 0.1,
  maxChildSize: 0.6,
  expand: true,
  shouldCloseOnMinExtent: true,
  builder: (BuildContext context, myscrollController) {
    return appState.riderModel == null
        ? Loading()
        : Container(
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
              padding: EdgeInsets.all(12),
              children: [
                SizedBox(height: 12),

                // Rider Info
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: appState.riderModel.photo != null
                        ? NetworkImage(appState.riderModel.photo)
                        : null,
                    child: appState.riderModel.photo == null
                        ? Icon(Icons.person_outline, size: 25)
                        : null,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rider: ${appState.riderModel.name ?? 'Loading...'}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Pickup: ${riderAddress ?? 'Fetching location...'}",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Destination: ${appState.requestModelFirebase.destination['address'] ?? 'Loading...'}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      if (appState.riderModel.phone != null) {
                        _service.call(appState.riderModel.phone);
                      }
                    },
                  ),
                ),

                Divider(),

                // Dynamic Content: Before or During Trip
                if (appState.show == Show.TRIP) ...[
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trip in Progress",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.darkPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Distance Remaining:",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey)),
                                Text(
                                  "${appState.requestModelFirebase.distance['text'] ?? 'Loading...'}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("ETA:",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey)),
                                Text(
                                  "10 mins", // Fetch from API later
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(),

                  // "Complete Trip" Button
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () {
                        appState.completeTrip(appState.requestModelFirebase.id);
                        appState.show = Show.IDLE; // Reset state after trip ends
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Complete Trip"),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSize,),
                  // "Start Trip" Button (Before Trip Starts)
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () {
                        appState.show = Show.IDLE; // Change state to trip mode
                        appState.cancelRequest(requestId: appState.requestModelFirebase.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Cancel Trip"),
                    ),
                  ),
                ] else ...[
                  // "Start Trip" Button (Before Trip Starts)
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () {
                        appState.show = Show.TRIP; // Change state to trip mode
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.lightPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Start Trip"),
                    ),
                  ),

                  SizedBox(height: Dimensions.paddingSize,),
                  // "Start Trip" Button (Before Trip Starts)
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () {
                        appState.show = Show.IDLE; // Change state to trip mode
                        appState.cancelRequest(requestId: appState.requestModelFirebase.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Cancel Trip"),
                    ),
                  ),
                ],

                SizedBox(height: Dimensions.paddingSize),
              ],
            ),
          );
  },
);

  }
}
