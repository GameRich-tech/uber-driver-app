import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class NotificationHistory extends StatefulWidget {
  const NotificationHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<NotificationHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Add
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: Padding(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSize,
            left: Dimensions.paddingSize,
            right: Dimensions.paddingSize,
            bottom: Dimensions.paddingSize,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: AppBar(
              backgroundColor: AppConstants.lightPrimary,
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                'Notification History',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
            ),
          ),
        ),
      ),
      body: userProvider.trips.isEmpty
          ? Center(
              child: Text(
                "No notifications available",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            )
          : Container(
              color: AppConstants.lightPrimary,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: userProvider.trips.length,
                itemBuilder: (context, index) {
                  if (index < 0 || index >= userProvider.trips.length) {
                    return SizedBox(); // Prevents RangeError
                  }

                  final trip = userProvider.trips[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.directions_car, color: Colors.blue),
                      title: Text(
                        "Trip to ${trip.destination}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text("Pickup: ${trip['destination']['address'] ?? 'Unknown'}"),
                          //Text("Date: ${trip.}"),
                          //Text("Fare: \$${trip.distance.values}"),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
