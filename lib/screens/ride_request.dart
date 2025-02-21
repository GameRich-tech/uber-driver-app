import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../helpers/constants.dart';
import '../helpers/stars_method.dart';
import '../helpers/style.dart';
import '../models/ride_Request.dart';
import '../providers/app_provider.dart';

import '../utils/app_constants.dart';
import '../widgets/custom_btn.dart';
import '../widgets/custom_text.dart';

class RideRequestScreen extends StatefulWidget {
  @override
  _RideRequestScreenState createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {

  late StreamSubscription<QuerySnapshot> requestStreamSubscription;

  @override
  void initState() {
    // TODO: implement initState

    _loadPendingDocument();
    super.initState();
  }

  Future<void> _loadPendingDocument() async {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          final document = querySnapshot.docs.first;
          appState.requestModelFirebase =
              RequestModelFirebase.fromSnapshot(document);
          print("User ID: ${appState.requestModelFirebase!.userId}");
        });
      } else {
        print("No pending documents found.");
      }
    } catch (e) {
      print("Error retrieving document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);

    _loadPendingDocument();
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          text: "New Ride Request",
          size: 19,
          weight: FontWeight.bold,
          color: AppConstants.darkPrimary,
        ),
      ),
      backgroundColor: white,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (appState.riderModel!.photo == null)
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(40)),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 45,
                      child: Icon(
                        Icons.person,
                        size: 65,
                        color: white,
                      ),
                    ),
                  ),
                if (appState.riderModel!.photo != null)
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(40)),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(appState.riderModel!.photo),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: appState.riderModel!.name,
                  size: 20,
                  color: AppConstants.darkPrimary,
                  weight: AppConstants.defaultWeight,
                ),
              ],
            ),
            SizedBox(height: 10),
            stars(
                rating: appState.riderModel!.rating,
                votes: appState.riderModel!.votes),
            Divider(),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Destiation",
                    color: grey,
                    size: 20,
                    weight: AppConstants.defaultWeight,
                  ),
                ],
              ),
              subtitle: ElevatedButton.icon(
                  onPressed: () async {
                    //LatLng destinationCoordiates = LatLng(
                    //appState.rideRequestModel.dLatitude,
                    //appState.rideRequestModel.dLongitude);
                    //appState.addLocationMarker(
                    //    destinationCoordiates,
                    //   appState.rideRequestModel.destination ?? "Nada",
                    //   "Destination Location");
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext bc) {
                          return Container(
                            height: 400,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  target: appState.center, zoom: 13),
                              //onMapCreated: appState.onCreate,
                              myLocationEnabled: true,
                              mapType: MapType.normal,
                              tiltGesturesEnabled: true,
                              compassEnabled: false,
                              //markers: appState.markers,
                              //onCameraMove: appState.onCameraMove,
                              polylines: appState.poly,
                            ),
                          );
                        });
                  },
                  icon: Icon(
                    Icons.location_on,
                  ),
                  label: CustomText(
                    text: "yt",
                    weight: FontWeight.bold,
                    size: AppConstants.defaultTextSize,
                    color: AppConstants.darkPrimary,
                  )),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.flag),
                    label: Text('User is near by')),
                ElevatedButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.attach_money),
                    label: Text("${7 / 500} ")),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomBtn(
                  text: "Accept",
                  onTap: () async {
                    if (appState.requestModelFirebase!.status != "pending") {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0)), //this right here
                              child: Container(
                                height: 200,
                                child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Sorry! Request Expired",
                                          size: 20,
                                          color: AppConstants.darkPrimary,
                                          weight: AppConstants.defaultWeight,
                                        )
                                      ],
                                    )),
                              ),
                            );
                          });
                    } else {
                      //ppState.clearMarkers();

                      appState.changeWidgetShowed(showWidget: Show.RIDER);
                      appState.sendRequest(
                          coordinates:
                              appState.requestModelFirebase!.getCoordinates(),
                          intendedLocation: '');
//                      showDialog(
//                          context: context,
//                          builder: (BuildContext context) {
//                            return Dialog(
//                              shape: RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.circular(
//                                      20.0)), //this right here
//                              child: Container(
//                                height: 200,
//                                child: Padding(
//                                  padding: const EdgeInsets.all(12.0),
//                                  child: Column(
//                                    mainAxisAlignment: MainAxisAlignment.center,
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.start,
//                                    children: [
//                                      SpinKitWave(
//                                        color: black,
//                                        size: 30,
//                                      ),
//                                      SizedBox(
//                                        height: 10,
//                                      ),
//                                      Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.center,
//                                        children: [
//                                          CustomText(
//                                              text:
//                                                  "Awaiting rider confirmation"),
//                                        ],
//                                      ),
//                                      SizedBox(
//                                        height: 30,
//                                      ),
//                                      LinearPercentIndicator(
//                                        lineHeight: 4,
//                                        animation: true,
//                                        animationDuration: 100000,
//                                        percent: 1,
//                                        backgroundColor:
//                                            Colors.grey.withOpacity(0.2),
//                                        progressColor: Colors.deepOrange,
//                                      ),
//                                      SizedBox(
//                                        height: 20,
//                                      ),
//                                      Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.center,
//                                        children: [
//                                          FlatButton(
//                                              onPressed: () {
//                                                appState.cancelRequest(requestId: appState.rideRequestModel.id);
//                                              },
//                                              child: CustomText(
//                                                text: "Cancel",
//                                                color: Colors.deepOrange,
//                                              )),
//                                        ],
//                                      )
//                                    ],
//                                  ),
//                                ),
//                              ),
//                            );
//                          });
                    }
                  },
                  bgColor: green,
                  shadowColor: Colors.greenAccent,
                ),
                CustomBtn(
                  text: "Reject",
                  onTap: () {
                    //appState.clearMarkers();
                    appState.changeRideRequestStatus();
                  },
                  bgColor: red,
                  shadowColor: Colors.redAccent,
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
