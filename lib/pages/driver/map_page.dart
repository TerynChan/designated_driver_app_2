import 'dart:async';
import 'dart:convert';
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:designated_driver_app_2/model/ride_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.ride});
  final RideModel ride ;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  double bottomMapPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController =  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  double searchContainerHeight = 220;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  String _distanceText = '';
  String _durationText = '';


  getUserInforAndCheckBlockStatus() async{
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid);
    await reference.once().then((dataSnap){
      if(dataSnap.snapshot.value != null){
        if((dataSnap.snapshot.value as Map)['blockStatus'] == 'no'){
          userName = (dataSnap.snapshot.value as Map)['name'];
          userPhone = (dataSnap.snapshot.value as Map)['phone'];
        }

        else{
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
          associateMethods.showSnackBarMsg("You are blocked, contact admin: terynchanetsa@gmaii.com", context);
        }
      }

      else{
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
      }
    }); 
  }
  
  getCurrentLocation() async {
    // ignore: deprecated_member_use
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    currentPositionOfUser = userPosition;

    //lotion in form of geographic coordinates
    LatLng userLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));

    await GoogleMapsMethods.convertGeoCoordinatesIntoHumanReadableAddress(currentPositionOfUser!, context);
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return points;
  }

  String _formatDuration(int seconds) {
  Duration duration = Duration(seconds: seconds);
  String formatted = '';

  if (duration.inDays > 0) {
    formatted += '${duration.inDays} d ';
  }
  if (duration.inHours % 24 > 0) { // Remainder of hours after days
    formatted += '${duration.inHours % 24} h ';
  }
  if (duration.inMinutes % 60 > 0) { // Remainder of minutes after hours
    formatted += '${duration.inMinutes % 60} min';
  }

  return formatted.trim(); // Trim any trailing space
}  
  
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
  if (destination == null) {
    setState(() {
      _distanceText = '';
      _durationText = '';

    });
    return;
  }

  final String apiUrl =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$GoogleMapKey';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final distanceInMeters = data['routes'][0]['legs'][0]['distance']['value'];
        final double distanceInKm = distanceInMeters / 1000.0; // **Use double here**
        final formattedDistance = distanceInKm.toStringAsFixed(2);

        final durationInSeconds = data['routes'][0]['legs'][0]['duration']['value'];
        final String formattedDuration = _formatDuration(durationInSeconds);

        List<LatLng> points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);

        setState(() {
          _polylines.clear();
          _markers.removeWhere((marker) => marker.markerId.value.startsWith('intermediate'));

          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 5,
            ),
          );
    
          _distanceText = '$formattedDistance km';
          _durationText = formattedDuration;

        });
      } else {
        print('Directions API error: ${data['error_message'] ?? 'No routes found'}');
        setState(() {
          _distanceText = 'N/A';
          _durationText = 'N/A';

        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching directions or no route found')),
        );
      }
    } else {
      print('HTTP error: ${response.statusCode}');
      setState(() {
        _distanceText = 'Error';
        _durationText = 'Error';

      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load directions')),
      );
    }
  } catch (e) {
    print('Error fetching directions: $e');
    setState(() {
      _distanceText = 'Error';
      _durationText = 'Error';

    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching directions')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      body: Stack(
        children: [

          //google map
          GoogleMap(
            polylines: _polylines,
            markers: _markers,
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLocation();
              _getDirections(LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude), widget.ride.originLatLng);
            },
          ),
         ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: (){
        setState(() {
          _getDirections(LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude), widget.ride.originLatLng);
         });
           
      }, label: Text("Show Pick Up Location"),),
   
    );
  }
}
