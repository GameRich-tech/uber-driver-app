
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/app_constants.dart';
import '../../utils/images.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body:  Stack(
        children: [
          // Background image with gradient overlay
          
           Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.onBoardOne) ,
                
                fit: BoxFit.contain,
              ),
              
            ),
          ),
          
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
          Padding(
            padding: const EdgeInsets.only(top: 50, right: 200, bottom: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animation (replace with a real animation file)
                Lottie.asset(
                  'assets/animations/phone_search_ride_animation.json', 
                  height: 250,
                  fit: BoxFit.cover,
                  animate: true,
                  repeat:false,
                ),
                
                SizedBox(height: 20),
            
                // Title
                Text(
                  "Accept Rides",
                  style: TextStyle(
                    fontSize: Dimensions.fontSizeOverLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
            
                SizedBox(height: Dimensions.paddingSizeExtraSmall),
            
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    "Earn money on The Go by accepting rides from customers",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
