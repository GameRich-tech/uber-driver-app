import 'package:Bucoride_Driver/helpers/constants.dart';
import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/auth/login.dart';
import 'package:Bucoride_Driver/screens/privacy_policy.dart';
import 'package:Bucoride_Driver/screens/profile/profile_page.dart';
import 'package:Bucoride_Driver/screens/terms_and_condition.dart';
import 'package:Bucoride_Driver/services/ride_request.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:Bucoride_Driver/widgets/home_widgets/banner_widget.dart';
import 'package:Bucoride_Driver/widgets/home_widgets/subscription_widget.dart';
import 'package:Bucoride_Driver/widgets/home_widgets/vehicle_prompt_widget.dart';
import 'package:Bucoride_Driver/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../utils/dimensions.dart';

class MenuWidgetScreen extends StatefulWidget {
  @override
  _MenuWidgetScreenState createState() => _MenuWidgetScreenState();
}

class _MenuWidgetScreenState extends State<MenuWidgetScreen> {
  final RideRequestServices _requestServices = RideRequestServices();

  @override
  void initState() {
    super.initState();
    // Set Android system navigation bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppConstants.lightPrimary, // Change color here
      systemNavigationBarIconBrightness: Brightness.dark, // Adjust icon color
    ));
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    userProvider.checkSubscriptionStatus(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AppConstants.lightPrimary,
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Aligns elements properly
          children: [
            ///profile section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: Dimensions.radiusLarge,
                  backgroundImage: userProvider.userModel?.photo != null
                      ? NetworkImage(userProvider.userModel!.photo!)
                      : AssetImage(Images.profileProfile) as ImageProvider,
                ),
                SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  userProvider.user?.displayName ?? "Driver",
                  style: GoogleFonts.poppins(
                      fontSize: Dimensions.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ],
            ),

            /// Online switch section
            Row(
              children: [
                FlutterSwitch(
                  width: 100.0,
                  height: 35.0,
                  toggleSize: 25.0,
                  value: userProvider.isOnline,
                  borderRadius: border_radius,
                  padding: Dimensions.paddingSizeExtraSmall,
                  activeText: "Online", // ✅ Text when online
                  inactiveText: "Offline", // ✅ Text when offline
                  activeTextColor: Colors.black38,
                  inactiveTextColor: Colors.black38,
                  activeColor: Colors.green,
                  inactiveColor: Colors.red,
                  activeToggleColor: Colors.white,
                  inactiveToggleColor: Colors.white,
                  showOnOff: true, // Hide default text
                  activeIcon: Icon(Icons.check,
                      color: Colors.green, size: 18), // ✅ Use activeIcon
                  inactiveIcon: Icon(Icons.close,
                      color: Colors.red, size: 18), // ✅ Use inactiveIcon
                  onToggle: (bool value) {
                    userProvider.setOnlineStatus(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context, userProvider),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDivider(),
            SizedBox(height: Dimensions.paddingSizeSmall),
            VehiclePromptWidget(
              hasVehicle: userProvider.userModel!.hasVehicle,
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),
            _buildDivider(),
            SizedBox(height: Dimensions.paddingSizeSmall),
            SubscriptionWidget(
              nextPaymentDate: userProvider.userModel!.nextPaymentDate,
            ),
            _buildDivider(),
            SizedBox(height: Dimensions.paddingSizeSmall),
            _buildDivider(),
            SizedBox(height: Dimensions.paddingSizeSmall),
            _buildTripSummary(context, userProvider),
            SizedBox(height: Dimensions.paddingSizeSmall),
            _buildDivider(),
            SizedBox(height: Dimensions.paddingSizeSmall),
            BannerView(),
            SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummary(BuildContext context, UserProvider userProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This Week's Earnings",
              style: GoogleFonts.poppins(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Dimensions.paddingSize),
            StreamBuilder<double>(
              stream: _requestServices.getWeeklyEarnings(
                  userProvider.userModel!.id), // 🔥 Listen to earnings
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Loading(); // Loading state
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                double totalEarnings = snapshot.data ?? 0.0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Trips", "${userProvider.userModel?.trips}"),
                    _buildStatCard("Earnings",
                        "Ksh ${totalEarnings.toStringAsFixed(2)}"), // Show earnings
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: Dimensions.fontSizeSmall,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style:
                  GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserProvider userProvider) {
    return Drawer(
      backgroundColor: AppConstants.lightPrimary,
      child: Column(
        children: [
          DrawerHeader(
            //decoration: BoxDecoration(color: Colors.grey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: (userProvider.userModel?.photo != null &&
                          userProvider.userModel!.photo.isNotEmpty)
                      ? NetworkImage(
                          userProvider.userModel!.photo) // Load from Firebase
                      : AssetImage("assets/images/default_avatar.png")
                          as ImageProvider, // Fallback image
                  child: (userProvider.userModel?.photo == null ||
                          userProvider.userModel!.photo.isEmpty)
                      ? Icon(Icons.person_outline,
                          size: 25) // Show icon if no image
                      : null,
                ),
                SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  userProvider.user?.displayName ?? "Driver",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, "Profile",
              () => changeScreen(context, ProfileScreen())),
          //_buildDrawerItem(Icons.settings, "Settings", () {}),
          _buildDrawerItem(Icons.article, "Terms & Conditions",
              () => changeScreen(context, TermsScreen())),
          _buildDrawerItem(Icons.privacy_tip, "Privacy Policy",
              () => changeScreen(context, PrivacyPolicyScreen())),
          Divider(),
          _buildDrawerItem(Icons.logout, "Logout", () {
            userProvider.signOut();
            changeScreenReplacement(context, LoginScreen());
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title,
          style: GoogleFonts.poppins(fontSize: Dimensions.fontSizeSmall)),
      onTap: onTap,
    );
  }
}

Widget _buildDivider() {
  return const Divider(indent: 20, endIndent: 20, height: 1);
}
