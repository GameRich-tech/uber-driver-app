import 'package:Bucoride_Driver/screens/privacy_policy.dart';
import 'package:Bucoride_Driver/screens/profile/personal_info.dart';
import 'package:Bucoride_Driver/screens/terms_and_condition.dart';
import 'package:Bucoride_Driver/services/ride_request.dart';
import 'package:Bucoride_Driver/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/images.dart';
import '../../widgets/profile_widgets/edit_page.dart';
import '../auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  RideRequestServices _requestServices = RideRequestServices();
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
  
    var profileImage = userProvider.userModel?.photo ?? Images.person;
    var displayName = userProvider.userModel?.name ?? "John Doe";

    return Scaffold(
      appBar: CustomAppBar(title: "", showNavBack: true, centerTitle: true),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(profileImage, displayName),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildAccountSettings(userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String profileImage, String displayName) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppConstants.lightPrimary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(45),
              bottomRight: Radius.circular(45),
            ),
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                changeScreen(context, EditProfilePage());
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(profileImage),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Trips", "${userProvider.userModel!.trips}"),
              StreamBuilder<double>(
              stream: _requestServices.getWeeklyEarnings(userProvider.userModel!.id), // 🔥 Listen to earnings
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading state
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                double totalEarnings = snapshot.data ?? 0.0;

                return _buildStatItem("Earnings", "Ksh ${totalEarnings.toStringAsFixed(2)}"); // Show earnings
                  
                
              },
            ),
              _buildStatItem("Rating", "${userProvider.userModel!.rating} ⭐"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            _buildSettingItem(Icons.person, "Personal Info", () {
              changeScreen(context, PersonalInfo());
            }),
            _buildDivider(),
            _buildSettingItem(Icons.book, "Terms and Conditions", () {
              changeScreenReplacement(context, TermsScreen());
            }),
            _buildDivider(),
            _buildSettingItem(Icons.privacy_tip, "Privacy Policy", () {
              changeScreenReplacement(context, PrivacyPolicyScreen());
            }),
            _buildDivider(),
            _buildSettingItem(Icons.logout, "Log Out", () {
              userProvider.signOut();
              changeScreenReplacement(context, LoginScreen());
            }, isLogout: true),
            _buildDivider(),
            _buildSettingItem(Icons.delete, "Delete Account", () {
              userProvider.deleteAccount();
              changeScreenReplacement(context, LoginScreen());
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(indent: 20, endIndent: 20, height: 1);
  }
}
