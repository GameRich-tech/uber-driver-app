import 'package:flutter/material.dart';

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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RadarPainter(_controller.value),
                child: Container(
                  width: 200,
                  height: 200,
                ),
              );
            },
          ),
          Text(
            'No fares\nat the moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
      ..color = Colors.yellowAccent.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    double radius = size.width / 2;
    double sweepAngle = animationValue * 2 * 3.141592653589793; // Full circle

    canvas.drawCircle(size.center(Offset.zero), radius, paint);

    paint.color = Colors.yellowAccent.withOpacity(0.3);
    canvas.drawCircle(size.center(Offset.zero), radius * 0.75, paint);

    paint.color = Colors.yellowAccent.withOpacity(0.2);
    canvas.drawCircle(size.center(Offset.zero), radius * 0.5, paint);

    paint.color = Colors.yellowAccent.withOpacity(0.1);
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
