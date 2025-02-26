import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/screens/home.dart';
import 'package:Bucoride_Driver/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../providers/user.dart';
import '../../services/ride_request.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final RideRequestServices _requestServices = RideRequestServices();

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _requestServices.requestStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Loading());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.noDataFound,
                    width: 50,
                    height: 50,
                  ),
                  const Text(
                    "No Trip Requests Found",
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: AppConstants.defaultTextSize,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display requests in a ListView
          return Padding(
              padding: EdgeInsets.all(Dimensions.paddingSize),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final request = doc.data() as Map<String, dynamic>;

                  return Card(
                    color: AppConstants.lightPrimary,
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ExpansionTile(
                      leading: Image.asset(Images.person, color: Colors.white),
                      title: Text(
                        request['username'] ?? "Unknown User",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Status: ${request['status']}"),
                      trailing: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Destination: ${request['destination']['address']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Distance: ${request['distance']['text']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Accept Button
                                  IconButton(
                                    iconSize: Dimensions.iconSizeLarge,
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () {
                                      appState.handleAccept(request['id'],
                                          userProvider.user?.uid);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  // Decline Button
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () {
                                      _handleDecline(request);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  // View Trip Button
                                  IconButton(
                                    icon: const Icon(Icons.map,
                                        color: Colors.blue),
                                    onPressed: () {
                                      appState.show = Show.INSPECTROUTE;
                                      // Set the request in the provider
                                      appState.setRequest(request);
                                      changeScreen(context, HomePage());
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        },
      ),
    );
  }

  // Decline Request Function
  void _handleDecline(Map<String, dynamic> request) {
    final updatedRequest = {
      ...request,
      'status': 'declined',
    };
    //_requestServices.updateRequest(updatedRequest);
  }
}
