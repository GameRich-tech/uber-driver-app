import 'package:flutter/material.dart';

class AnimatedWifiBars extends StatefulWidget {
  @override
  _AnimatedWifiBarsState createState() => _AnimatedWifiBarsState();
}

class _AnimatedWifiBarsState extends State<AnimatedWifiBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = IntTween(begin: 1, end: 4).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWifiIcon(int level) {
    switch (level) {
      case 1:
        return Icon(Icons.signal_wifi_0_bar, size: 50, color: Colors.blue);
      case 2:
        return Icon(Icons.signal_wifi_0_bar, size: 50, color: Colors.blue);
      case 3:
        return Icon(Icons.signal_wifi_0_bar, size: 50, color: Colors.blue);
      case 4:
        return Icon(Icons.signal_wifi_4_bar, size: 50, color: Colors.blue);
      default:
        return Icon(Icons.signal_wifi_off, size: 50, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildWifiIcon(_animation.value);
      },
    );
  }
}
