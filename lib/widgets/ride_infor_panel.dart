// lib/widgets/ride_info_panel.dart
import 'package:flutter/material.dart';

class RideInfoPanel extends StatelessWidget {
  final String distanceText;
  final String durationText;
  final String priceText; // Placeholder for now
  final VoidCallback onBookRidePressed;
  
  const RideInfoPanel({
    super.key,
    required this.distanceText,
    required this.durationText,
    this.priceText = 'Price: -', // Default placeholder
    required this.onBookRidePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag Handle Bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Expanded( // Use Expanded to ensure the content takes available space
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ride Info Card Design
                Card(
                  elevation: 6, // Increased elevation for a "food card" feel
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Ride Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Divider(height: 20, thickness: 1),
                        _buildInfoRow(Icons.alt_route, 'Distance:', distanceText),
                        _buildInfoRow(Icons.timer, 'Est. Time:', durationText),
                        _buildInfoRow(Icons.payments, 'Fare:', priceText),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Book Ride Button
                ElevatedButton(
                  onPressed: onBookRidePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Book Ride Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right, // Align value to the right
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}