import 'package:designated_driver_app_2/model/route_update.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class RouteUpdateCard extends StatelessWidget {
  final RouteUpdate update;

  const RouteUpdateCard({Key? key, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              update.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(update.description),
            if (update.location != null) ...[
              const SizedBox(height: 8.0),
              Text('Location: ${update.location}'),
            ],
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Source: ${update.source}', style: const TextStyle(fontStyle: FontStyle.italic)),
                Text(DateFormat('yyyy-MM-dd HH:mm').format(update.timestamp), style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


