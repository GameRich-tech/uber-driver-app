import 'dart:math';

import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/providers/location_provider.dart';
import 'package:Bucoride_Driver/screens/home.dart';
import 'package:Bucoride_Driver/screens/parcels/parcel_trips.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:Bucoride_Driver/widgets/loading_location.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/style.dart';
import '../../providers/app_provider.dart';
import '../../providers/user.dart';
import '../../services/call_sms.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/loading.dart';

class ParcelRiderWidget extends StatefulWidget {
  const ParcelRiderWidget({Key? key}) : super(key: key);

  @override
  _RideRequestState createState() => _RideRequestState();
}

class _RideRequestState extends State<ParcelRiderWidget> {
  final CallsAndMessagesService _service = CallsAndMessagesService();
  String? riderAddress; // Rider address to display

  @override
  void initState() {
    super.initState();
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

    appState.fetchRiderDetails(appState.parcelRequestModel!.userId);
    if (appState.parcelRequestModel != null) {
      // Get rider position
      LatLng riderPos = LatLng(
        appState.parcelRequestModel!.destinationLatLng?['lat'],
        appState.parcelRequestModel!.destinationLatLng?['lng'],
      );
      print("Rider position: $riderPos");

      // Get destination position

      LatLng destinationPos = LatLng(
        appState.parcelRequestModel!.destinationLatLng?['lat'],
        appState.parcelRequestModel!.destinationLatLng?['lng'],
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

    print(appState.riderModel);

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
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(border_radius)),
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
                                child: (appState.riderModel!.photo != null &&
                                        appState.riderModel!.photo!.isNotEmpty)
                                    ? null
                                    : Icon(Icons.person_outline, size: 25),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appState.riderModel!.name ?? 'Loading...',
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
                                          appState.riderModel!.phone ??
                                              "No phone number",
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
                                  if (appState.riderModel!.phone != null) {
                                    _service.call(appState.riderModel!.phone);
                                  }
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

                          SizedBox(height: 10),

                          /// Destination
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  appState.parcelRequestModel!.destination ??
                                      'Loading...',
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.paddingSizeSmall),

                          /// Price (if available)
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  color: Colors.green, size: 18),
                              SizedBox(width: Dimensions.paddingSizeSmall),
                              Text(
                                "Price: \Ksh ${appState.parcelRequestModel!.totalPrice}",
                                style: TextStyle(
                                    fontSize: Dimensions.fontSizeSmall,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Dynamic Content: Before or During Trip
                    if (appState.onTrip == true) ...[
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
                                      "${locationProvider.remainingDistance ?? 'Loading...'}",
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

                      /// "Complete Trip" Button
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
                            appState
                                .completeTrip(appState.parcelRequestModel!.id);
                            appState.setTripStatus(false);

                            appState.show =
                                Show.IDLE; // Reset state after trip ends
                            changeScreenReplacement(context, HomePage());
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
                        height: Dimensions.paddingSizeExtraSmall,
                      ),

                      /// "Start Trip" Button (Before Trip Starts)
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
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
                              appState.cancelParcelRequest(
                                  requestId: appState.parcelRequestModel!.id);

                              changeScreenReplacement(
                                  context, ParcelTripsScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text("Cancel Trips"),
                          ),
                        ),
                      ),
                    ] else ...[
                      ///Accept Ride
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
                                      appState.handleParcelAccept(
                                        appState.parcelRequestModel!.id,
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
                                    appState.handleParcelArrived(
                                      appState.parcelRequestModel!.id,
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
                                  child: Text("Parcel Picked Up"),
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
                                    appState.startParcelTrip(
                                        appState.parcelRequestModel!.id,
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
                                  appState.completeParcelTrip(
                                      appState.parcelRequestModel!.id);
                                  changeScreenReplacement(context, HomePage());
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

                          SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          // Cancel Button (Always Visible)
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: ElevatedButton(
                                onPressed: () {
                                  appState.setRideStatus(false);
                                  appState.setTripStatus(false);
                                  locationProvider.stopTracking();
                                  locationProvider.stopTrip();
                                  locationProvider.clearPolylines();
                                  locationProvider.clearMarkers();
                                  locationProvider
                                      .animateBackToDriverPosition();
                                  appState.show = Show.IDLE;
                                  appState.cancelParcelRequest(
                                      requestId:
                                          appState.parcelRequestModel!.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Cancel"),
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
