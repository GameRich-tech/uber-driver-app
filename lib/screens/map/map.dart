import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/screen_navigation.dart';
import '../../providers/app_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/images.dart';
import '../../widgets/loading.dart';
import '../menu.dart';
import '../parcels/parcel_trips.dart';
import '../trips/available_trips.dart';

class MapScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  MapScreen(this.scaffoldState);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GlobalKey<ScaffoldState> scaffoldSate = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    scaffoldSate = widget.scaffoldState;

    /// Fetch location asynchronously **after** the widget has built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);

    final locationProvider = Provider.of<LocationProvider>(context);
    final position = locationProvider.currentPosition;
    final showTraffic = locationProvider.isTrafficEnabled;
    final _mapController = locationProvider.mapController;
    final _markers = locationProvider.markers;
// Get the current polyline to be drawn on the map
    final Set<Polyline> _polylines = locationProvider.polylines;

    return position == null
        ? Loading()
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 16),
                onMapCreated: (GoogleMapController controller) {
                  locationProvider.onCreate(
                      controller); // This ensures the map controller is set
                },
                trafficEnabled: showTraffic,
                myLocationEnabled: false,
                mapType: MapType.normal,
                tiltGesturesEnabled: true,
                compassEnabled: false,
                markers: _markers,
                onCameraMove: locationProvider.onCameraMove,
                polylines: _polylines,
              ),

              /// FAB for home
              Positioned(
                top: MediaQuery.of(context).size.height *
                    0.05, // Adjust percentage
                left: MediaQuery.of(context).size.width * 0.05,
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(
                      8), // Adds spacing inside the red background
                  decoration: BoxDecoration(
                    color: AppConstants.lightPrimary, // Red background
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128), // 128 is 50% opacity
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ], // Rounded corners
                  ),

                  child: IconButton(
                    icon: Image.asset(
                      Images.homeIcon,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      changeScreen(context, Menu());
                    },
                  ),
                ),
              ),

              if (!appState.hasAcceptedRide)

                /// FAB for Parcels
                Positioned(
                  top: MediaQuery.of(context).size.height *
                      0.11, // Adjust percentage
                  left: MediaQuery.of(context).size.width * 0.05,
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: EdgeInsets.all(
                        8), // Adds spacing inside the red background
                    decoration: BoxDecoration(
                      color: AppConstants.lightPrimary, // Red background
                      borderRadius: BorderRadius.circular(border_radius),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.grey.withAlpha(128), // 128 is 50% opacity
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(0, 3), // Changes position of shadow
                        ),
                      ], // Rounded corners
                    ),

                    child: IconButton(
                      icon: Image.asset(
                        Images.parcel,
                      ),
                      onPressed: () {
                        changeScreen(context, ParcelTripsScreen());
                      },
                    ),
                  ),
                ),

              // New FAB for Centering Location
              Positioned(
                top: MediaQuery.of(context).size.height * 0.53,
                right: 15,
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Different color for distinction
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Center the map on the user's current location
                      LatLng newPos =
                          LatLng(position.latitude, position.longitude);
                      _mapController
                          ?.animateCamera(CameraUpdate.newLatLng(newPos));
                    },
                  ),
                ),
              ),
              // FAB for Toggling Traffic
              Positioned(
                top: MediaQuery.of(context).size.height * 0.46,
                right: 15,
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: showTraffic
                        ? Colors.green
                        : Colors.grey, // Changes color based on state
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.traffic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      locationProvider
                          .toggleTraffic(); // Toggle traffic visibility
                    },
                  ),
                ),
              ),

              if (!appState.hasAcceptedRide)
                // Requests
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.55,
                  left: (MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width * 0.55) /
                      2, // Centering horizontally
                  child: GestureDetector(
                    onTap: () {
                      changeScreen(context, TripScreen());
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.55, // Set the width here
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.lightPrimary,
                        borderRadius: BorderRadius.circular(
                            12), // Rounded rectangle corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(
                                128), // 128 is 50% opacity (range: 0-255)
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center items horizontally
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.car_repair,
                            color: Colors.white,
                          ),
                          SizedBox(
                              width: 8), // Add spacing between icon and text
                          Flexible(
                            // Prevents text overflow
                            child: Text(
                              "${appState.numberOfRequests} More Requests",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow
                                    .ellipsis, // Handle overflow gracefully
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          );
  }
}
// Positioned(
//   top: 20,
//   left: MediaQuery.of(context).size.width / 6,
//   child: Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 30),
//     child: Container(
//       decoration: BoxDecoration(
//         color: white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [BoxShadow(color: grey, blurRadius: 17)],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               child: userProvider.userModel?.photo == null
//                   ? const CircleAvatar(
//                       radius: 30,
//                       child: Icon(
//                         Icons.person_outline,
//                         size: 25,
//                       ),
//                     )
//                   : CircleAvatar(
//                       radius: 30,
//                       backgroundImage:
//                           AssetImage(Images.profileProfile),
//                       onBackgroundImageError: (_, __) {
//                         debugPrint("Failed to load network image");
//                       },
//                       child: userProvider.userModel?.photo == null ||
//                               userProvider.userModel!.photo.isEmpty
//                           ? Icon(Icons.person_outline, size: 30)
//                           : null,
//                     ),
//             ),
//             SizedBox(width: 10),
//             Container(
//               height: 60,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomText(
//                     text: userProvider.userModel?.name ??
//                         'Unknown User',
//                     size: AppConstants.defaultTextSize,
//                     color: AppConstants.greenColor,
//                     weight: AppConstants.defaultWeight,
//                   ),
//                   stars(
//                     rating: userProvider.userModel?.rating ?? 0.0,
//                     votes: userProvider.userModel?.votes ?? 0,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ),
// ),
