import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/models/parcel_request.dart';
import 'package:Bucoride_Driver/screens/parcels/parcel_delivery.dart';
import 'package:Bucoride_Driver/services/parcel_request.dart';
import 'package:Bucoride_Driver/widgets/app_bar/app_bar.dart';
import 'package:Bucoride_Driver/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';

class ParcelTripsScreen extends StatefulWidget {
  const ParcelTripsScreen({super.key});

  @override
  State<ParcelTripsScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<ParcelTripsScreen> {
  final ParcelRequestServices _parcelRequestServices = ParcelRequestServices();
  ParcelRequestModel? parcelRequestModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    return Scaffold(
      appBar:
          CustomAppBar(title: "Parcels", showNavBack: true, centerTitle: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: _parcelRequestServices.parcelRequestStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Loading());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print(snapshot.data);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.noDataFound,
                    width: 50,
                    height: 50,
                  ),
                  const Text(
                    "No Parcel Request Available",
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: AppConstants.defaultTextSize,
                    ),
                  ),
                ],
              ),
            );
          }
          // Display requests in a ListView
          return Padding(
              padding: EdgeInsets.all(Dimensions.paddingSize),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final request = doc.data() as Map<String, dynamic>;
                  parcelRequestModel = ParcelRequestModel.fromMap(
                      doc.data() as Map<String, dynamic>);
                  appState.fetchRiderDetails(parcelRequestModel!.userId);
                  appState.parcelRequestModel = parcelRequestModel;
                  return Card(
                    color: AppConstants.lightPrimary,
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ExpansionTile(
                      leading: appState.riderModel?.photo != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(appState.riderModel!.photo),
                            )
                          : Image.asset(Images.person, color: Colors.white),
                      title: Text(
                        parcelRequestModel!.senderName ?? "Unknown User",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Status: ${request['status']}"),
                      trailing: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Destination: ${parcelRequestModel!.destination}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              // Text(
                              //   "Distance: ${request['distance']['text']}",
                              //   style: const TextStyle(fontSize: 14),
                              // ),
                              const SizedBox(height: Dimensions.paddingSize),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Accept Button
                                  ElevatedButton(
                                    onPressed: () {
                                      appState.handleParcelAccept(
                                          parcelRequestModel!.id,
                                          userProvider.user?.uid);
                                      appState.show = Show.RIDER;
                                      changeScreenReplacement(
                                          context, ParcelDelivery());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical:
                                              12), // Button background color
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Accept',
                                          style: TextStyle(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),
                                  // Decline Button
                                  ElevatedButton(
                                    onPressed: () {
                                      _openMapBottomSheet();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical:
                                              12), // Button background color
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.map, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'View on Map',
                                          style: TextStyle(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        },
      ),
    );
  }

  void _openMapBottomSheet() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.fetchLocation();
    final position = locationProvider.currentPosition;
    print(parcelRequestModel?.destinationLatLng);
    locationProvider.addCustomParcelDestinationMarker(LatLng(
        parcelRequestModel?.destinationLatLng?['lat'],
        parcelRequestModel?.destinationLatLng?['lng']));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(border_radius),
                          topRight: Radius.circular(border_radius)),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                parcelRequestModel!.destinationLatLng?['lat'],
                                parcelRequestModel!.destinationLatLng?['lng']),
                            zoom: 17.0),
                        onMapCreated: (GoogleMapController controller) {
                          locationProvider.onCreate(controller);
                        },
                        markers: locationProvider.markers,
                        compassEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Dimensions.paddingSizeExtraSmall,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue, // Background color
                        backgroundColor: AppConstants.lightPrimary,
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
