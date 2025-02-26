import 'package:Bucoride_Driver/screens/map/map.dart';
import 'package:Bucoride_Driver/screens/parcels/parcel_rider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class ParcelDelivery extends StatefulWidget {
  const ParcelDelivery({super.key});

  @override
  State<ParcelDelivery> createState() => _ParcelDeliveryState();
}

class _ParcelDeliveryState extends State<ParcelDelivery> {
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapScreen(scaffoldState),
          Visibility(
              visible: appState.show == Show.RIDER, child: ParcelRiderWidget()),
        ],
      ),
    );
  }
}
