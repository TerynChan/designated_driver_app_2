import 'dart:ffi';

import 'package:designated_driver_app_2/methods/associate_methods.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


AssociateMethods associateMethods = AssociateMethods();
String userName = "";
String userPhone = "";
bool isDriver = false;  

String GoogleMapKey = "AIzaSyA8Zb2zL4aJP3G_Z7FBtZJbOHI4Bo4IX0U";

// ignore: unused_element
const CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
   
  );