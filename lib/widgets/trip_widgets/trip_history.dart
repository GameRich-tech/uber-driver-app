import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  String _selectedFilter = 'All Time'; // Default filter option
  final List<String> _filters = ['Today', 'This Week', 'This Month', 'This Year', 'All Time'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchDriverTrips();
    });
  }

  List filterTrips(UserProvider userProvider) {
    final now = DateTime.now();
    return userProvider.trips.where((trip) {
      final tripDate = trip.date; // Assuming trip.date is a Timestamp
      switch (_selectedFilter) {
        case 'Today':
          return tripDate.day == now.day &&
              tripDate.month == now.month &&
              tripDate.year == now.year;
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return tripDate.isAfter(startOfWeek) && tripDate.isBefore(now.add(Duration(days: 1)));
        case 'This Month':
          return tripDate.month == now.month && tripDate.year == now.year;
        case 'This Year':
          return tripDate.year == now.year;
        case 'All Time':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final filteredTrips = filterTrips(userProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSize),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: AppBar(
              backgroundColor: AppConstants.lightPrimary,
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                'Trip History',
                style: TextStyle(color: Colors.black, fontSize: Dimensions.fontSizeExtraLarge),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 180),
            child: Container(
              
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light grey background
                borderRadius: BorderRadius.circular(12), // Rounded corners
                border: Border.all(color: Colors.grey, width: 1), // Optional border
              ),
              child: DropdownButton<String>(
                value: _selectedFilter,
                items: _filters.map((filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
                isExpanded: true,
                underline: SizedBox(), // Removes the default underline
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),

          Expanded(
            child: filteredTrips.isEmpty
                ? Center(child: Text("No trips available", style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.directions_car, color: Colors.blue),
                          title: Text("Trip to ${trip.destination}", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pickup: ${trip.pickupLocation}"),
                              Text("Date: ${trip.date.toDate()}"), // Convert Firestore Timestamp to DateTime
                              Text("Fare: \$${trip.fare}"),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

