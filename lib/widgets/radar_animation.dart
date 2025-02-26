import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RadarAnimation extends StatefulWidget {
  @override
  _RadarAnimationState createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: Center(
              child: // Lottie animation (replace with a real animation file)
                  Lottie.asset(
                'assets/animations/Animation - 1739866740839.json',
                height: 200,
                fit: BoxFit.contain,
                animate: true,
                repeat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;

  RadarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent.withAlpha(100)
      ..style = PaintingStyle.fill;

    double radius = size.width / 2;
    double sweepAngle = animationValue * 2 * 3.141592653589793; // Full circle

    canvas.drawCircle(size.center(Offset.zero), radius, paint);

    paint.color = Colors.yellowAccent.withAlpha(130);
    canvas.drawCircle(size.center(Offset.zero), radius * 0.75, paint);

    paint.color = Colors.yellowAccent.withAlpha(120);
    canvas.drawCircle(size.center(Offset.zero), radius * 0.5, paint);

    paint.color = Colors.yellowAccent.withAlpha(100);
    canvas.drawCircle(size.center(Offset.zero), radius * 0.25, paint);

    paint.color = Colors.yellowAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
