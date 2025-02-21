
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/images.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.onBoardThree),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(100), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              

              SizedBox(height: Dimensions.paddingSizeExtraSmall),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Text(
                  "Deliver Customers anywhere",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Easy management and tracking of your your Trips",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
