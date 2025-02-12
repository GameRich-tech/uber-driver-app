import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:flutter/material.dart';

import '../../screens/add_vehicle_page.dart';

class VehiclePromptWidget extends StatelessWidget {
  final bool hasVehicle;

  const VehiclePromptWidget({super.key, required this.hasVehicle});

  @override
  Widget build(BuildContext context) {
    if (hasVehicle) return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.lightPrimary, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Add Your Vehicle',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Dimensions.fontSizeExtraLarge,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Provide details of your vehicle to start accepting rides.',
            style: TextStyle(fontSize: Dimensions.fontSizeLarge),
          ),
          SizedBox(height: 12),
          Divider(
            height: 16,
          ),
          Image.asset(Images.carPlaceholder, height: 150), // Placeholder image
          SizedBox(height: 12),
          Divider(
            height: 16,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.lightPrimary, // Button color
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              elevation: 5, // Button shadow
            ),
            onPressed: () {
              changeScreen(context, AddVehiclePage());
            },
            child: Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }
}
