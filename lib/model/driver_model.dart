// lib/models/driver_model.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber; 
  final String carModel;
  final String carType;
  final String carColor;
  final String carNumber; 
  final bool isAvailable;
  final bool isDriver;
  final double rating;
  final LatLng? currentLocation;

  DriverModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.carModel,
    required this.carType,
    required this.carColor,
    required this.carNumber,
    this.isAvailable = false,
    this.isDriver = false,
    this.rating = 5.0,
    this.currentLocation,
  });

  // Convert to JSON for Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phoneNumber, // <-- Matches 'phone' in your DB
      'carModel': carModel,
      'carType': carType,
      'carColor': carColor,
      'carNumber': carNumber,
      'isAvailable': isAvailable,
      'isDriver': isDriver,
      'rating': rating,
      'currentLocation': currentLocation != null
          ? {'latitude': currentLocation!.latitude, 'longitude': currentLocation!.longitude}
          : null,
    };
  }

  // Create from a Realtime Database map
  factory DriverModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    final locationMap = map['currentLocation'] as Map<dynamic, dynamic>?;
    LatLng? location;
    if (locationMap != null && locationMap['latitude'] != null && locationMap['longitude'] != null) {
      location = LatLng(
        (locationMap['latitude'] as num).toDouble(),
        (locationMap['longitude'] as num).toDouble(),
      );
    }

    // Defensive parsing: directly cast as String? and provide default
    return DriverModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phone'] as String? ?? '', // <-- Corrected: Expects String directly
      carModel: map['carModel'] as String? ?? '',
      carType: map['carType'] as String? ?? '',
      carColor: map['carColor'] as String? ?? '',
      carNumber: map['carNumber'] as String? ?? '', // <-- Corrected: Expects String directly
      isAvailable: map['isAvailable'] as bool? ?? false,
      isDriver: map['isDriver'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      currentLocation: location,
    );
  }
}