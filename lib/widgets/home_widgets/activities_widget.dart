import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of activity statuses
    final List<Map<String, dynamic>> activityData = [
      {
        'title': 'Active Hours',
        'value': '5h 30m',
        'icon': Icons.access_time,
        'color': Colors.green,
      },
      {
        'title': 'Idle Time',
        'value': '1h 15m',
        'icon': Icons.pause_circle_filled,
        'color': Colors.orange,
      },
      {
        'title': 'Offline',
        'value': '3h 45m',
        'icon': Icons.power_settings_new,
        'color': Colors.red,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSize),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Activity',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),

          // Scrollable Activity Cards
          SizedBox(
            height: 130, // Adjust height based on design
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activityData.length,
              itemBuilder: (context, index) {
                final item = activityData[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ActivityCard(
                    title: item['title'],
                    value: item['value'],
                    icon: item['icon'],
                    color: item['color'],
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

// 📌 Activity Card Widget
class ActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ActivityCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190, // Adjust width as needed
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
