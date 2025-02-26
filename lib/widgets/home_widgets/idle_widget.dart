import 'dart:async';

import 'package:Bucoride_Driver/widgets/radar_animation.dart';
import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class IdleWidget extends StatefulWidget {
  @override
  _IdleWidgetState createState() => _IdleWidgetState();
}

class _IdleWidgetState extends State<IdleWidget> with TickerProviderStateMixin {
  bool isSearching = false;
  late Timer _timer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Toggle search state every 2 seconds for animation
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        isSearching = !isSearching;
      });
    });

    // Icon rotation animation
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.5, // Set to a larger value for dynamic sizing
      expand: true,
      shouldCloseOnMinExtent: true,
      builder: (BuildContext context, myScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(200),
                offset: Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: myScrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: Dimensions.paddingSize,
                right: Dimensions.paddingSize,
              ),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  // Drag Handle
                  GestureDetector(
                    onVerticalDragUpdate: (details) {}, // Enables dragging
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: Colors.black,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No fares at the moment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  RadarAnimation(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
