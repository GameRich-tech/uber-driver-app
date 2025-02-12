import 'dart:async';

import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/intro_pages/OnBoard.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/user.dart';
import '../utils/app_constants.dart';
import '../utils/images.dart';
import '../widgets/loading.dart';
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
    // TODO: implement initState
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

      // Remove existing SnackBar if Get.context is not null
      final context = Get.context;
      if (context != null) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.hideCurrentSnackBar();
      }
      // Show updated SnackBar
      ScaffoldMessenger.of(context!).showSnackBar(
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
    UserProvider auth = Provider.of<UserProvider>(context, listen: false);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    await Future.delayed(Duration(seconds: 5)); // add delay for splash

    if (auth.status == Status.Authenticated) {
      // Navigate to Home if authenticated
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Menu(title: AppConstants.appName)),
        (Route<dynamic> route) => false,
      );
    } else {
      // Navigate to Login if not authenticated
      firstLaunch = await appState.checkIfFirstLaunch();

      if (firstLaunch) {
        changeScreenReplacement(context, OnBoarding());
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
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
                          child: Text(
                            "BucoRide",
                            style: TextStyle(
                                fontSize: Dimensions.fontSizeDefault,
                                fontFamily: AppConstants.fontFamily,
                                color: AppConstants.darkPrimary),
                          ),
                        ),
                      ),
                      Loading(), // add loading widget here
                      const SizedBox(height: 50),
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
