import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../screens/vehicle_registration/add_vehicle_page.dart';
import '../loading.dart';

class VehiclePromptWidget extends StatefulWidget {
  final bool hasVehicle;

  const VehiclePromptWidget({super.key, required this.hasVehicle});

  @override
  _VehiclePromptWidgetState createState() => _VehiclePromptWidgetState();
}

class _VehiclePromptWidgetState extends State<VehiclePromptWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    return _fadeAnimation == null
        ? Center(child: Loading()) // Avoid using it before initialization
        : FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: AppConstants.lightPrimary,
                    width: 1), // Yellow border
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: widget.hasVehicle
                  ? _buildVehicleDetails(userProvider)
                  : _buildAddVehicleButton(),
            ),
          );
  }

  Widget _buildVehicleDetails(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Details',
          style: TextStyle(
            fontSize: Dimensions.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        _buildDetailRow('Brand', userProvider.userModel!.brand),
        _buildDetailRow('Model', userProvider.userModel!.model),
        _buildDetailRow('Fuel Type', userProvider.userModel!.fuelType),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(Images.carPlaceholder, width: 45, height: 45),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddVehicleButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Add Your Vehicle',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Dimensions.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Provide details of your vehicle to start accepting rides.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: Dimensions.fontSizeLarge),
        ),
        SizedBox(height: 12),
        Divider(height: 16),
        Image.asset(
          Images.car,
          height: 200,
        ),
        SizedBox(height: 12),
        Divider(height: 16),
        TweenAnimationBuilder(
          duration: Duration(milliseconds: 300),
          tween: Tween<double>(begin: 1.0, end: 1.05),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.lightPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  changeScreen(context, AddVehiclePage());
                },
                child: Text('Add Vehicle'),
              ),
            );
          },
        ),
      ],
    );
  }
}
