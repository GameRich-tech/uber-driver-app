import 'dart:math';

import 'package:Bucoride_Driver/utils/images.dart';
import 'package:Bucoride_Driver/widgets/loading_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../locators/service_locator.dart';
import '../../models/ride.dart';
import '../../providers/app_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/call_sms.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_text.dart';

class ShowTrip extends StatefulWidget {
  final Map<String, dynamic> request;

  ShowTrip({required this.request});

  @override
  _ViewTripState createState() => _ViewTripState();
}

class _ViewTripState extends State<ShowTrip> {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  late LatLng riderPosition;
  String riderAddress = 'Loading...';
  late RideRequest rideRequest;

  @override
  void initState() {
    super.initState();

    // Convert Map to RideRequest object
    rideRequest = RideRequest.fromJson(widget.request);
    print(rideRequest);

    Provider.of<LocationProvider>(context, listen: false).fetchLocation();
    print(widget.request);
    fetchRiderDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setRiderAddress();
    });
  }

  fetchRiderDetails() {
    //{username: John Doe,
    // destination: Soy Club & Resorts, Eldoret-Kitale Road,
    // Eldoret, Kenya, distance_text: 173 km,
    // distance_value: 173419,
    // destination_latitude: 0.6701188999999999,
    // destination_longitude: 35.1588356,
    // user_latitude: 0.0605847,
    // user_longitude: 34.2934637,
    // id: 72710720-eacd-11ef-aa9b-2db953babc58,
    // userId: zGFDFs4EndP9H1yXNUt6VOvtoxh1
    // }
  }

  setRiderAddress() async {
    print("setRiderAddress called");

    double latitude = widget.request['user_latitude'] as double? ?? 0.0;
    double longitude = widget.request['user_longitude'] as double? ?? 0.0;
    riderPosition = LatLng(latitude, longitude);

    double destinationLatitude =
        widget.request['destination_latitude'] as double? ?? 0.0;
    double destinationLongitude =
        widget.request['destination_longitude'] as double? ?? 0.0;
    LatLng destinationPosition =
        LatLng(destinationLatitude, destinationLongitude);

    try {
      LocationProvider locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      // Set a timeout for fetching address
      await locationProvider.fetchRiderAddress(riderPosition).timeout(
        Duration(seconds: 100),
        onTimeout: () {
          throw Exception("Address fetch timeout");
        },
      );

      locationProvider.addRiderLocationMarker(riderPosition);
      locationProvider.addRiderRoutePolyline(
          riderPosition, destinationPosition);

      if (locationProvider.currentPosition != null) {
        LatLng driverPosition = LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        );

        locationProvider.createJourneyPolyline(driverPosition, riderPosition);

        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            min(driverPosition.latitude, destinationLatitude),
            min(driverPosition.longitude, destinationLongitude),
          ),
          northeast: LatLng(
            max(driverPosition.latitude, destinationLatitude),
            max(driverPosition.longitude, destinationLongitude),
          ),
        );

        locationProvider.mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }

      // Only update UI after successfully fetching the address
      setState(() {
        riderAddress = locationProvider.riderAddress;
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
    if (locationProvider.currentPosition == null) {
      print("No location");

      return LoadingLocationScreen();
    }
    LatLng newPos = LatLng(locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude);
    locationProvider.mapController?.animateCamera(
      CameraUpdate.newLatLng(newPos),
    );

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
                color: red,
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
                      rideRequest.username as String? ?? 'N/A',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Pick up location: $riderAddress",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      "Destination: ${rideRequest.destination ?? 'N/A'}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      "Distance: ${rideRequest.distanceText ?? 'N/A'}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      "Distance value: ${rideRequest.distanceValue ?? 'N/A'}",
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
                            text: rideRequest.destination as String? ?? 'N/A',
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
                    appState.cancelRequest(
                        requestId: appState.requestModelFirebase!.id);
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
