import 'package:flutter/material.dart';

class CompleteTrip extends StatefulWidget {
  const CompleteTrip({super.key});

  @override
  State<CompleteTrip> createState() => _CompleteTripState();
}

class _CompleteTripState extends State<CompleteTrip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Complete Trip'),
      ),
    );
  }
}