import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/auth/login.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/widgets/profile_widgets/profile_round_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import 'edit_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    var profileImage = userProvider.user?.photoURL ?? Images.profileProfile;
    var displayName = userProvider.user?.displayName ?? "John Doe";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppConstants.lightPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider
              .refreshUser(); // Optional: Add this in UserProvider
          setState(() {}); // Force UI to rebuild with new data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileWidget(
                  imagePath: profileImage,
                  isNetworkImage: userProvider.user?.photoURL != null,
                  onClicked: () {
                    changeScreen(context, EditProfilePage()).then((_) {
                      userProvider.refreshUser();
                      setState(
                          () {}); // Refresh after returning from EditProfilePage
                    });
                  },
                ),
                const SizedBox(height: 20),
                buildProfileInfo(displayName),
                const SizedBox(height: Dimensions.paddingSize),
                buildAccountSettings(userProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileInfo(String displayName) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppConstants.lightPrimary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSize),
        child: Column(
          children: [
            Text(
              displayName,
              style: TextStyle(
                fontSize: Dimensions.fontSizeExtraLarge,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Divider(
              height: 15,
              color: Colors.black,
              indent: 20,
              endIndent: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ProfileStat(title: "Trips", value: "30"),
                VerticalDivider(),
                ProfileStat(title: "Distance", value: "30 km"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAccountSettings(UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppConstants.lightPrimary,
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Account Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              userProvider.signOut();
              changeScreenReplacement(context, LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
