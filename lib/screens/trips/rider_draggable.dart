import 'dart:math';

import 'package:Bucoride_Driver/providers/location_provider.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:Bucoride_Driver/widgets/loading_location.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../providers/app_provider.dart';
import '../../providers/user.dart';
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
  bool _gotTrip = false;
  @override
  void initState() {
    super.initState();
    _gotTrip = false;
    // Fetch the rider's address on widget load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRiderAddress();
    });
  }

  Future<void> _fetchRiderAddress() async {
    print("Fetching rider address...");

    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    appState.fetchRiderDetails(appState.requestModelFirebase!.userId);
    if (appState.requestModelFirebase != null) {
      // Get rider position
      LatLng riderPos = LatLng(
        appState.requestModelFirebase!.position['latitude'],
        appState.requestModelFirebase!.position['longitude'],
      );
      print("Rider position: $riderPos");

      // Get destination position
      var destinationData = appState.requestModelFirebase!.destination;
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
        locationProvider.addRiderLocationMarker(riderPos);
        //locationProvider.addDestinationMarker(destinationPos);

        // Get driver's position
        LatLng driverPos = LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        );

        // Create polyline for the journey
        locationProvider.createJourneyPolyline(driverPos, riderPos);
        locationProvider.addCustomParcelDestinationMarker(destinationPos);

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
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    if (appState.riderModel == null) {
      return LoadingLocationScreen();
    }
    if (appState.onTrip == true && _gotTrip == false) {
      locationProvider.updateTripInfo();
      _gotTrip = true;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
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

                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1), // Subtle border
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rider Info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: (appState.riderModel!.photo !=
                                            null &&
                                        appState.riderModel!.photo!.isNotEmpty)
                                    ? NetworkImage(appState.riderModel!.photo!)
                                    : AssetImage(Images.person)
                                        as ImageProvider,
                                child: (appState.riderModel!.photo.isNotEmpty)
                                    ? null
                                    : Icon(Icons.person_outline, size: 25),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appState.riderModel!.name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            color: Colors.green, size: 16),
                                        SizedBox(width: 5),
                                        Text(
                                          appState.riderModel!.phone,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.call, color: Colors.green),
                                onPressed: () {
                                  _service.call(appState.riderModel!.phone);
                                },
                              ),
                            ],
                          ),

                          Divider(
                              height: 24,
                              thickness: 1,
                              color: Colors.grey.shade300),

                          /// Pickup Location
                          Row(
                            children: [
                              Icon(Icons.my_location,
                                  color: Colors.blue, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  riderAddress ?? 'Fetching location...',
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.paddingSizeSmall),

                          // Destination
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${appState.requestModelFirebase?.destination['address']}",
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.paddingSizeSmall),

                          // Price (if available)
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  color: Colors.green, size: 18),
                              SizedBox(width: 10),
                              Text(
                                "Price: \ksh${appState.requestModelFirebase!.distance['value'] ?? 'N/A'}",
                                style: TextStyle(
                                    fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Dynamic Content: Before or During Trip
                    if (appState.onTrip == true) ...[
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Trip in Progress",
                              style: TextStyle(
                                fontSize: Dimensions.fontSizeDefault,
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
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.grey)),
                                    Text(
                                      "${locationProvider.remainingDistance}",
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
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.grey)),
                                    Text(
                                      locationProvider
                                          .eta, // Fetch from API later
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
                            appState.setRideStatus(false);

                            locationProvider.stopTracking();
                            locationProvider.stopTrip();
                            locationProvider.clearPolylines();
                            locationProvider.clearMarkers();
                            locationProvider.animateBackToDriverPosition();
                            locationProvider.clearPolylines();
                            locationProvider.clearMarkers();
                            userProvider.incrementTripCount();
                            appState.completeTrip(
                                appState.requestModelFirebase!.id);
                            appState.setTripStatus(false);

                            appState.show =
                                Show.IDLE; // Reset state after trip ends
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
                      SizedBox(
                        height: Dimensions.paddingSize,
                      ),
                      // "Start Trip" Button (Before Trip Starts)
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: ElevatedButton(
                          onPressed: () {
                            appState.setRideStatus(false);
                            appState.setTripStatus(false);
                            locationProvider.stopTracking();
                            locationProvider.stopTrip();
                            locationProvider.clearPolylines();
                            locationProvider.clearMarkers();
                            locationProvider.fetchLocation();
                            appState.cancelRequest(
                                requestId: appState.requestModelFirebase!.id);

                            appState.show =
                                Show.IDLE; // Change state to trip mode
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
                      Column(
                        children: [
                          // Accept Ride Button (Only if ride is not accepted)
                          if (!appState.hasAcceptedRide)
                            Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      appState.setRideStatus(true);
                                      appState.acceptRide();
                                      appState.handleAccept(
                                        appState.requestModelFirebase!.id,
                                        userProvider.userModel!.id,
                                      );
                                      locationProvider
                                          .animateBackToDriverPosition();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text("Accept Ride"),
                                  ),
                                )),

                          // Confirm Pickup Button (Only if ride is accepted but not started)
                          if (appState.hasAcceptedRide &&
                              !appState.hasArrivedAtLocation)
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () {
                                    print(
                                        "Arrived At User location ==========");
                                    appState.handleArrived(
                                      appState.requestModelFirebase!.id,
                                      userProvider.userModel!.id,
                                    );
                                    appState.hasArrivedAtlocation(true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.lightPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text("Rider Picked Up"),
                                ),
                              ),
                            ),

                          // Start Trip Button (Only after confirming pickup)
                          if (appState.hasAcceptedRide &&
                              appState.hasArrivedAtLocation)
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    print("Starting Trip==========");
                                    appState.setTripStatus(true);
                                    appState.startTrip(
                                        appState.requestModelFirebase!.id,
                                        userProvider.userModel!.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.lightPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text("Start Trip"),
                                ),
                              ),
                            ),

                          // Complete Trip Button (Only after starting the trip)
                          if (appState.hasAcceptedRide &&
                              appState.hasArrivedAtLocation &&
                              appState.onTrip)
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: ElevatedButton(
                                onPressed: () {
                                  print("Trip Completed==========");
                                  appState.completeTrip(
                                      appState.requestModelFirebase!.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Complete Trip"),
                              ),
                            ),

                          SizedBox(height: Dimensions.paddingSize),

                          /// Cancel Button (Always Visible)
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: ElevatedButton(
                                onPressed: () {
                                  appState.cancelRequest(
                                      requestId:
                                          appState.requestModelFirebase!.id);
                                  appState.setRideStatus(false);
                                  appState.setTripStatus(false);
                                  locationProvider.stopTracking();
                                  locationProvider.stopTrip();
                                  locationProvider.clearPolylines();
                                  locationProvider.clearMarkers();
                                  locationProvider
                                      .animateBackToDriverPosition();
                                  appState.show = Show.IDLE;
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
                          ),
                        ],
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
