// lib/driver_app/widgets/ride_request_dialog.dart
import 'package:designated_driver_app_2/model/ride_model.dart';
import 'package:designated_driver_app_2/pages/driver/map_page.dart';
import 'package:flutter/material.dart';


class RideRequestDialog extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RideRequestDialog({
    super.key,
    required this.ride,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Ride Request!'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${ride.originAddress}'),
            Text('To: ${ride.destinationAddress}'),
            const Divider(),
            Text('Distance: ${ride.distanceKm.toStringAsFixed(1)} km'),
            Text('Duration: ${ride.durationText}'),
            Text('Fare: \$${ride.fareAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            // You can add passenger name here if you fetch it
            // Text('Passenger: ${ride.passengerName ?? 'Unknown'}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onReject,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Reject'),
        ),
        ElevatedButton(
          onPressed: (){
            onAccept;
            Navigator.push(context, MaterialPageRoute(builder: (c)=> MapPage(ride: ride)));
          },

          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}