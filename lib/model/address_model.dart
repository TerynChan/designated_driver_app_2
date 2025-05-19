import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressModel {
  String? HumanReadableAddress;
  double? latitudePosition;
  double? longitudePosition;
  String? placeID;
  String? placeName;
  LatLng? destinationLocation;

  AddressModel({
    this.HumanReadableAddress,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.placeName,
    this.destinationLocation,
  });

}