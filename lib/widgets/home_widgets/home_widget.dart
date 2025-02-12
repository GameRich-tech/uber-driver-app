import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/auth/login.dart';
import 'package:Bucoride_Driver/screens/privacy_policy.dart';
import 'package:Bucoride_Driver/screens/terms_and_condition.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:Bucoride_Driver/widgets/home_widgets/activities_widget.dart';
import 'package:Bucoride_Driver/widgets/home_widgets/banner_widget.dart';
import 'package:Bucoride_Driver/widgets/home_widgets/vehicle_prompt_widget.dart';
import 'package:Bucoride_Driver/widgets/profile_widgets/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../utils/dimensions.dart';

class MenuWidgetScreen extends StatefulWidget {
  const MenuWidgetScreen({Key? key}) : super(key: key);

  @override
  _MenuWidgetScreenState createState() => _MenuWidgetScreenState();
}

class _MenuWidgetScreenState extends State<MenuWidgetScreen> {
  late final LatLng? userLocation;
  late String? locationAddress = null;
// Track the selected index (for example, Home, Activity, etc.)

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: Padding(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSize,
            left: Dimensions.paddingSize,
            right: Dimensions.paddingSize,
            bottom: Dimensions.paddingSize,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: AppBar(
              backgroundColor: AppConstants.lightPrimary,
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: () {
                  changeScreen(context, ProfileScreen());
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () {
                      changeScreen(context, ProfileScreen());
                    },
                    child: CircleAvatar(
                      radius: 20, // Adjust size as needed
                      backgroundImage: userProvider.user?.photoURL != null
                          ? NetworkImage(userProvider.user!.photoURL!)
                          : AssetImage(Images.profileProfile)
                              as ImageProvider, // Default image
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    '${userProvider.user?.displayName}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ]),
              ),
              leading: Builder(
                // ✅ This ensures correct context access
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // ✅ Now works correctly
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppConstants.lightPrimary,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(0), // Adjust corner radius as needed
                bottomRight:
                    Radius.circular(0), // Adjust corner radius as needed
              ),
            ),
            padding: EdgeInsets.only(
                top: Dimensions.paddingSize), // ✅ Adds space at the top
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                    decoration: const BoxDecoration(
                      color: AppConstants.lightPrimary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 5),
                        CircleAvatar(
                          radius: 30, // Adjust size as needed
                          backgroundImage: AssetImage(Images.profileProfile)
                              as ImageProvider, // Default image
                        ),
                        
                        SizedBox(width: 100),
                      ],
                    )),
                ListTile(
                  leading: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    height: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.profileProfile,
                      color: Colors.black,
                    ), // Ensure Images.privacyPolicy is an AssetImage
                  ),
                  title: const Text('Profile'),
                  onTap: () {
                    // Navigate to Settings
                    changeScreen(context, ProfileScreen());
                  },
                ),
                ListTile(
                  leading: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    height: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.profileSetting,
                      color: Colors.black,
                    ), // Ensure Images.privacyPolicy is an AssetImage
                  ),
                  title: const Text('Settings'),
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
                ListTile(
                  leading: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    height: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.termsAndCondition,
                      color: Colors.black,
                    ), // Ensure Images.privacyPolicy is an AssetImage
                  ),
                  title: const Text('Terms and Condition'),
                  onTap: () {
                    // Navigate to Settings
                    changeScreen(context, TermsScreen());
                  },
                ),
                ListTile(
                  leading: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    height: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.privacyPolicy,
                      color: Colors.black,
                    ), // Ensure Images.privacyPolicy is an AssetImage
                  ),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    // Navigate to Settings
                    changeScreen(context, PrivacyPolicyScreen());
                  },
                ),
                ListTile(
                  leading: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    height: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.profileLogout,
                      color: Colors.black,
                    ), // Ensure Images.privacyPolicy is an AssetImage
                  ),
                  title: const Text('Logout'),
                  onTap: () {
                    // Navigate to Settings
                    userProvider.signOut();
                    changeScreenReplacement(context, LoginScreen());
                  },
                ),
                ListTile(
                  leading: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    height: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.deleteAccountIcon,
                      color: Colors.black,
                    ), // Ensure Images.privacyPolicy is an AssetImage
                  ),
                  title: const Text('Permanently Delete Account'),
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
        child: Column(
          children: [
            VehiclePromptWidget(hasVehicle: false),
            SizedBox(height: 16.0),
            //ActivityWidget(),
            SizedBox(height: 16.0),
            BannerView()
          ],
        ),
      ),
    );
  }
}
