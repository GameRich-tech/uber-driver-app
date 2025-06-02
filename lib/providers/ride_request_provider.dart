import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/ride_Request.dart';
import '../services/ride_request.dart';

class RideRequestProvider with ChangeNotifier {
  final RideRequestServices _rideRequestServices = RideRequestServices();
  Stream<QuerySnapshot>? _rideRequestStream;

  List<RequestModelFirebase> _pendingRequests = [];
  List<RequestModelFirebase> get pendingRequests => _pendingRequests;

  RideRequestProvider() {
    _rideRequestStream = _rideRequestServices.requestStream();
    _rideRequestStream?.listen(_handleRideRequestSnapshot);
  }

  void _handleRideRequestSnapshot(QuerySnapshot snapshot) {
    _pendingRequests = snapshot.docs
        .map((doc) => RequestModelFirebase.fromSnapshot(doc))
        .toList();
    notifyListeners();
  }
}
