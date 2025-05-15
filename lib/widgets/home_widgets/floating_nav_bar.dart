import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;

  CustomBottomNavBar({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: AppConstants.lightPrimary,
      animationDuration: Duration(milliseconds: 300),
      items: [
        CurvedNavigationBarItem(
          child: Image.asset(
            Images.homeActive,
            width: Dimensions.iconSizeLarge,
            height: Dimensions.iconSizeLarge,
            color: Colors.white,
          ),
          label: 'Home',
        ),
        CurvedNavigationBarItem(
          child: Image.asset(
            Images.newBidFareIcon,
            width: Dimensions.iconSizeLarge,
            height: Dimensions.iconSizeLarge,
            color: Colors.white,
          ),
          label: 'Fares',
        ),
        CurvedNavigationBarItem(
          child: Icon(
            Icons.turn_sharp_right_rounded,
            color: Colors.white,
          ),
          label: 'Trips',
        ),
        CurvedNavigationBarItem(
          child: Image.asset(
            Images.walletMoney,
            width: Dimensions.iconSizeLarge,
            height: Dimensions.iconSizeLarge,
            color: Colors.white,
          ),
          label: 'Wallet',
        ),
      ],
      onTap: (index) {
        onItemSelected(index);
      },
    );
  }
}

