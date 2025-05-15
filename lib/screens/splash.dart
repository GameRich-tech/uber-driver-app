import 'dart:async';

import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/intro_pages/OnBoard.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/user.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import '../utils/images.dart';
import 'auth/login.dart';
import 'menu.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late StreamSubscription<List<ConnectivityResult>> _onConnectivityChanged;

  bool isConnected = false;
  bool isFirst = true;
  bool firstLaunch = false;

  late AnimationController _controller;
  late Animation _animation;
  late AppStateProvider appState;

  @override
  void initState() {
    super.initState();

    if (!GetPlatform.isIOS) {
      _checkConnectivity();
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(max: 1);
    _controller.forward();

    _route();
    _hideSystemUI();
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar fully transparent
      statusBarIconBrightness:
          Brightness.light, // Change icons to light if needed
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _onConnectivityChanged.cancel();
    super.dispose();
  }

  void _checkConnectivity() {
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      isConnected = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);

      // Show updated SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ),
      );

      if (isConnected) {
        _route();
      }

      isFirst = false;
    });
  }

  void _route() async {
    await Future.delayed(Duration(seconds: 7)); // splash delay

    if (!mounted) return;

    UserProvider auth = Provider.of<UserProvider>(context, listen: false);
    AppStateProvider appState = Provider.of<AppStateProvider>(context, listen: false);

    while (auth.status == Status.Authenticating) {
      await Future.delayed(Duration(milliseconds: 100));
      if (!mounted) return; // check again in case unmounted during loop
    }

    if (!mounted) return;

    if (auth.status == Status.Authenticated) {
      changeScreenReplacement(context, Menu());
    } else {
      firstLaunch = await appState.checkIfFirstLaunch();
      if (!mounted) return;

      if (firstLaunch) {
        changeScreenReplacement(context, OnBoarding());
      } else {
        changeScreenReplacement(context, LoginScreen());
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppConstants.lightPrimary),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  transform: Matrix4.translationValues(
                      0,
                      320 -
                          (320 * double.tryParse(_animation.value.toString())!),
                      0),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: _animation.value,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 120 -
                                  ((120 *
                                      double.tryParse(
                                          _animation.value.toString())!))),
                          child: Image.asset(Images.logoWithName, width: 100),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      Image.asset(Images.splashBackgroundOne,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 2,
                          fit: BoxFit.cover),
                    ],
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0, 20, 0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (70 *
                            double.tryParse(_animation.value.toString())!)),
                    child: Image.asset(Images.splashBackgroundTwo,
                        width: MediaQuery.of(context).size.width),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
