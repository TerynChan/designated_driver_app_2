// lib/models/ride_model.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RideStatus {
  pending,
  accepted,
  driverArrived,
  started,
  completed,
  cancelledByPassenger,
  cancelledByDriver,
}

class RideModel {
  final String? rideId; // Nullable if not yet assigned when creating
  final String userId;
  final String? driverId; // Nullable initially
  final LatLng originLatLng;
  final String originAddress;
  final LatLng destinationLatLng;
  final String destinationAddress;
  final double distanceKm;
  final String durationText;
  final double fareAmount;
  final RideStatus status; // Use the enum
  final DateTime timestamp;

  RideModel({
    this.rideId, // New: Add rideId to constructor
    required this.userId,
    this.driverId,
    required this.originLatLng,
    required this.originAddress,
    required this.destinationLatLng,
    required this.destinationAddress,
    required this.distanceKm,
    required this.durationText,
    required this.fareAmount,
    this.status = RideStatus.pending, // Default status
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'driverId': driverId,
      'originLatLng': {'latitude': originLatLng.latitude, 'longitude': originLatLng.longitude},
      'originAddress': originAddress,
      'destinationLatLng': {'latitude': destinationLatLng.latitude, 'longitude': destinationLatLng.longitude},
      'destinationAddress': destinationAddress,
      'distanceKm': distanceKm,
      'durationText': durationText,
      'fareAmount': fareAmount,
      'status': status.name, // Store enum name as string
      'timestamp': timestamp.millisecondsSinceEpoch, // Store as milliseconds since epoch
    };
  }

  factory RideModel.fromMap(Map<dynamic, dynamic> map, String rideId) {
    // Safely parse LatLng
    final originMap = map['originLatLng'] as Map<dynamic, dynamic>?;
    final destinationMap = map['destinationLatLng'] as Map<dynamic, dynamic>?;

    LatLng origin = const LatLng(0, 0); // Default if null
    if (originMap != null && originMap['latitude'] != null && originMap['longitude'] != null) {
      origin = LatLng(
        (originMap['latitude'] as num).toDouble(),
        (originMap['longitude'] as num).toDouble(),
      );
    }

    LatLng destination = const LatLng(0, 0); // Default if null
    if (destinationMap != null && destinationMap['latitude'] != null && destinationMap['longitude'] != null) {
      destination = LatLng(
        (destinationMap['latitude'] as num).toDouble(),
        (destinationMap['longitude'] as num).toDouble(),
      );
    }

    // Safely parse status string to enum
    RideStatus parsedStatus = RideStatus.pending; // Default
    try {
      String statusString = map['status'] as String;
      parsedStatus = RideStatus.values.firstWhere((e) => e.name == statusString);
    } catch (e) {
      print("Warning: Could not parse ride status '${map['status']}': $e. Defaulting to pending.");
      parsedStatus = RideStatus.pending;
    }

    return RideModel(
      rideId: rideId, // Pass the rideId when creating the model
      userId: map['userId'] as String? ?? '',
      driverId: map['driverId'] as String?, // Can be null
      originLatLng: origin,
      originAddress: map['originAddress'] as String? ?? 'Unknown Origin',
      destinationLatLng: destination,
      destinationAddress: map['destinationAddress'] as String? ?? 'Unknown Destination',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationText: map['durationText'] as String? ?? 'N/A',
      fareAmount: (map['fareAmount'] as num?)?.toDouble() ?? 0.0,
      status: parsedStatus,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? 0),
    );
  }
}