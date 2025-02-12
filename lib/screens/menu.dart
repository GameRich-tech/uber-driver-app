import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/models/ride_Request.dart';
import 'package:Bucoride_Driver/screens/home.dart';
import 'package:Bucoride_Driver/screens/notification.dart';
import 'package:Bucoride_Driver/screens/ride_request.dart';
import 'package:Bucoride_Driver/services/ride_request.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../providers/app_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user.dart';
import '../utils/app_constants.dart';
import '../widgets/home_widgets/floating_nav_bar.dart';
import '../widgets/home_widgets/home_widget.dart';
import '../widgets/trip_widgets/trip_history.dart';

class Menu extends StatefulWidget {
  Menu({super.key, required this.title});
  final String title;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late RideRequestServices _rideRequestServices;

  @override
  void initState() {
    super.initState();
    _rideRequestServices = RideRequestServices();

    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      appState.saveDeviceToken();
      _deviceToken();
    }).onError((err) {
      // Error getting token.
    });

    /// Fetch location asynchronously **after** the widget has built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchLocation();
    });
  }

  int _selectedIndex = 0;

  // List of pages/screens for navigation
  final List<Widget> _pages = [
    MenuWidgetScreen(),
    MenuWidgetScreen(),
    TripHistory(),
    NotificationHistory(), // Profile Screen
  ];

  // Method to handle bottom nav item taps
  _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      selectedNavIndex = index;
    });
  }

  _deviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    if (_user.userModel?.token != preferences.getString('token')) {
      Provider.of<UserProvider>(context, listen: false).saveDeviceToken();
    }
  }

  void _showRequestDialog(RequestModelFirebase request) {
  AppStateProvider appState =
      Provider.of<AppStateProvider>(context, listen: false);

  // Prevent multiple alerts
  if (appState.alertIn) return; 

  appState.alertIn = true; // Set flag to true before showing the dialog

  showDialog(
    context: context,
    builder: (context) {
      UserProvider _user = Provider.of<UserProvider>(context, listen: false);

      appState.setRideRequest(request);

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "New Ride Request",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Username: ${request.username}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Destination: ${request.destination['address']}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Distance: ${request.distance['text']}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _rideRequestServices.updateRequest({
                'id': request.id,
                'status': 'accepted',
                'driverId': '${_user.userModel?.id}',
              });
              Navigator.of(context).pop();
              appState.alertIn = false; // Reset flag after closing
              //update the trips count
              _user.updateUserData({
                'trip': FieldValue.increment(1), // Increments trip count by 1
                'id': request.id,
              });

              appState.show = Show.RIDER;
              changeScreen(context, HomePage(title: "title"));
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Accept"),
          ),
          TextButton(
            onPressed: () {
              appState.show = Show.INSPECTROUTE;
              Navigator.of(context).pop();
              appState.alertIn = false; // Reset flag after closing
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.yellow,
              iconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Check Route"),
          ),
          TextButton(
            onPressed: () {
              _rideRequestServices.updateRequest({
                'id': request.id,
                'status': 'ignored',
              });
              Navigator.of(context).pop();
              appState.alertIn = false; // Reset flag after closing
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Ignore"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);

    var requestCount = appState.numberOfRequests;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _pages[_selectedIndex],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _rideRequestServices.requestStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var requests = snapshot.data!.docs
                    .map((doc) => RequestModelFirebase.fromSnapshot(doc))
                    .toList();

                if (requests.isNotEmpty) {
                  var request = requests.firstWhere(
                    (req) => req.status == 'pending',
                  );
                  if (request != null) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _showRequestDialog(request!));
                  }
                }
              }
              return Container(); // Return an empty container when there are no new requests
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0), // Adjust the bottom padding to raise the FAB
        child: SpeedDial(
          activeBackgroundColor: AppConstants.lightPrimary,
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor:
              AppConstants.lightPrimary, // Make it blend with the image
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16), // Adjust for more rounded corners
          ),
          children: [
            SpeedDialChild(
              label: "Requests",
              onTap: () {
                appState.show == Show.IDLE;
                changeScreen(context, HomePage(title: "title"));
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                        Images.map,
                        color: AppConstants.lightPrimary,
                      ),
                    ),
                    Positioned(
                      top: 0, // Position at the top
                      right: 0, // Position at the left
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$requestCount',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SpeedDialChild(
              label: "Parcels",
              onTap: () {
                appState.show == Show.IDLE;
                changeScreen(context, RideRequestScreen());
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                        Images.parcelDetails,
                        color: AppConstants.lightPrimary,
                      ),
                    ),
                    Positioned(
                      top: 0, // Position at the top
                      right: 0, // Position at the left
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$requestCount',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (index) {
        print("Bottom nav selected: $index");
        _onNavItemTapped(index);
      }),
    );
  }
}
