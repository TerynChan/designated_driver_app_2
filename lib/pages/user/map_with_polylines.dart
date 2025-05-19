import 'dart:async';
import 'dart:convert';
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:designated_driver_app_2/model/ride_model.dart';
import 'package:designated_driver_app_2/model/search_prediction_model.dart';
import 'package:designated_driver_app_2/widgets/available_drivers.dart';
import 'package:designated_driver_app_2/widgets/ride_infor_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';



class MapWithPolyline extends StatefulWidget {
  const MapWithPolyline({super.key});

  @override
  _MapWithPolylineState createState() => _MapWithPolylineState();
}

class _MapWithPolylineState extends State<MapWithPolyline> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final TextEditingController _destinationController = TextEditingController();
  List<SearchPredictionModel> dropOffPredictionPlaces = [];
  String _distanceText = '';
  String _durationText = '';
  String _priceText = 'Calculating...'; // Initial state for price
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref('rides');

  final PanelController _panelController = PanelController();

  Future<void> _setDestinationFromAddress(String? destinationLocationName) async {
    String? address = destinationLocationName;
    try {
      List<Location> locations = await locationFromAddress(address!);
      if (locations.isNotEmpty) {
        setState(() {
          _destinationPosition =
              LatLng(locations.first.latitude, locations.first.longitude);
          _markers.add(
            Marker(
              markerId: MarkerId('destination'),
              position: _destinationPosition!,
              infoWindow: InfoWindow(title: 'Destination'),
            ),
          );
          _getDirections(_currentPosition!, _destinationPosition!);
          _zoomToFit(_currentPosition!, _destinationPosition!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid address')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error geocoding address')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  searchPlace(String userInput) async {
    if (userInput.length > 1) {
      String placesApiUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userInput&key=$GoogleMapKey&components=country:ZWE";
      var responseFromPlacesApi =
          await GoogleMapsMethods.SendReqeustToAPI(placesApiUrl);

      if (responseFromPlacesApi == "error") {
        return;
      }

      if (responseFromPlacesApi["status"] == "OK") {
        var predictionsInJsonFormat = responseFromPlacesApi["predictions"];
        var predictionsInNormalFormat = (predictionsInJsonFormat as List)
            .map((eachPredictedPlace) =>
                SearchPredictionModel.fromJson(eachPredictedPlace))
            .toList();

        setState(() {
          dropOffPredictionPlaces = predictionsInNormalFormat;
        });
      }
    }
  }
  
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // Handle permission denial appropriately
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
      // Move camera to current location on initial load
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 15),
        ),
      );
    });
  }

    double _calculateFare(double distanceInKm) {
    const double ratePerKm = 0.50; // $0.50 USD for every 1 km (1 USD for 2 km)
    double fare = distanceInKm * ratePerKm;
    const double minimumFare = 2.00; // Example minimum fare
    if (fare < minimumFare) {
       fare = minimumFare;
    }
    return fare;
  }

  Future<void> _setDestinationFromSuggestions(SearchPredictionModel prediction) async {
    if (prediction.place_id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid place selected')),
      );
      return;
    }

    // need to get the exact coordinates for the selected place using its place_id
    String detailsApiUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.place_id}&key=$GoogleMapKey";

    var responseFromPlaceDetailsApi = await GoogleMapsMethods.SendReqeustToAPI(detailsApiUrl);

    if (responseFromPlaceDetailsApi == null || responseFromPlaceDetailsApi == "error") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching place details')),
      );
      return;
    }

    if (responseFromPlaceDetailsApi["status"] == "OK") {
      final location = responseFromPlaceDetailsApi['result']['geometry']['location'];
      setState(() {
        _destinationPosition = LatLng(location['lat'], location['lng']);
        // Update the text field with the full description for display
        _destinationController.text = prediction.description ?? prediction.main_text ?? 'Selected Place';
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: _destinationPosition!,
            infoWindow: InfoWindow(title: prediction.description),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
        _getDirections(_currentPosition!, _destinationPosition!);
        _zoomToFit(_currentPosition!, _destinationPosition!);

        if (_panelController.isAttached) {
          _panelController.animatePanelToPosition(1.0); // 1.0 means fully open
        }


      });
    } else {
      print('Place Details API error: ${responseFromPlaceDetailsApi['error_message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting details for selected place')),
      );
    }
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
  if (destination == null) {
    setState(() {
      _distanceText = '';
      _durationText = '';
      _priceText = 'N/A'; // Clear price on error/no route
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

        // *** Calculate Fare Here ***
        final double calculatedFare = _calculateFare(distanceInKm);
        final String formattedFare = calculatedFare.toStringAsFixed(2); // Format to 2 decimal places

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
          // Intermediate markers
          for (int i = 0; i < points.length; i += 50) {
            if (i < points.length) {
              _markers.add(
                Marker(
                  markerId: MarkerId('intermediate_$i'),
                  position: points[i],
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              );
            }
          }
          _distanceText = '$formattedDistance km';
          _durationText = formattedDuration;
          _priceText = '\$$formattedFare'; // Set the calculated fare here
        });
      } else {
        print('Directions API error: ${data['error_message'] ?? 'No routes found'}');
        setState(() {
          _distanceText = 'N/A';
          _durationText = 'N/A';
          _priceText = 'No route';
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
        _priceText = 'Error';
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
      _priceText = 'Error';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching directions')),
    );
  }
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
  
  void _zoomToFit(LatLng p1, LatLng p2) {
    double minLat = p1.latitude <= p2.latitude ? p1.latitude : p2.latitude;
    double maxLat = p1.latitude > p2.latitude ? p1.latitude : p2.latitude;
    double minLng = p1.longitude <= p2.longitude ? p1.longitude : p2.longitude;
    double maxLng = p1.longitude > p2.longitude ? p1.longitude : p2.longitude;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

void _onBookRideNow() async {
    // 1. Basic Validation
    if (_currentPosition == null || _destinationPosition == null ||
        _distanceText.isEmpty || _durationText.isEmpty ||
        _priceText.isEmpty || FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a destination and ensure location is available and you are logged in.')),
      );
      return;
    }

    // 2. Get Current User's UID (the passenger)
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please sign in.')),
      );
      return;
    }

    // 3. Parse numerical values from text
    final double fare = double.tryParse(_priceText.replaceAll('\$', '')) ?? 0.0;
    final double distance = double.tryParse(_distanceText.replaceAll(' km', '').replaceAll(' km', '')) ?? 0.0;


    // 4. Create a new RideModel instance
    final newRide = RideModel(
      userId: userId,
      originLatLng: _currentPosition!,
      originAddress: "Client's Location", // You might use geocoding to get a real address here
      destinationLatLng: _destinationPosition!,
      destinationAddress: destinationLocationName ?? 'Unknown Location',
      distanceKm: distance,
      durationText: _durationText,
      fareAmount: fare,
      status: RideStatus.pending, // Initial status
      timestamp: DateTime.now(), // Current time
    );

    // Close the panel before navigation
    if (_panelController.isAttached && _panelController.isPanelOpen) {
      _panelController.close();
    }

    // 5. Save the ride request to Firebase Realtime Database
    try {
      // Use .push() to generate a unique, auto-incrementing key for the new ride
      DatabaseReference newRideRef = _ridesRef.push();
      await newRideRef.set(newRide.toJson()); // Save the RideModel data as JSON
      final String? rideId = newRideRef.key; // Get the auto-generated ride ID

      print("Ride request saved successfully with ID: $rideId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride request sent! Looking for drivers...')),
      );

      // 6. Navigate to AvailableDriversScreen, passing the generated rideId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableDriversScreen(
            rideId: rideId!, // Pass the ID of the newly created ride
            destinationAddress: destinationLocationName ?? 'Unknown Location',
            fare: _priceText, originAddress: '',
          ),
        ),
      );
    } catch (e) {
      print("Error saving ride request to database: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send ride request. Please try again.')),
      );
      // Re-open panel if save failed, or handle gracefully
      if (_panelController.isAttached && _panelController.isPanelClosed) {
        _panelController.open();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Define min and max panel heights
    final double panelMinHeight = 120; // Enough for the drag handle and a peek
    final double panelMaxHeight = MediaQuery.of(context).size.height * 0.45; // Max 45% of screen height


    return Scaffold(

      drawer: SizedBox(
        width: 256,
        child: Drawer(
          child: ListView(
            children: [

              //header of drawer
              SizedBox(
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                  child: Row(
                    children: [
                      Image.asset("assets/avatar.jpg",
                      width: 60,
                      height: 60,
                      ),

                      const SizedBox(width: 16,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox( height: 16,),

                          const Text(
                            "profile",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      )
                    ],
                  ), 
                ),
              ),

              //body of drawer
              
         
               GestureDetector(
                onTap: (){ 
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
                },
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.grey,),
                  title: Text("Log Out",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      
      appBar: AppBar(
        title: Text('Map with Autocomplete'),
      ),
      
       body: SlidingUpPanel(
        controller: _panelController,
        minHeight: panelMinHeight,
        maxHeight: panelMaxHeight,
        parallaxEnabled: true,
        parallaxOffset: .5,
        panelSnapping: true, // Snap to min/max heights
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        // The content of the panel itself
        panel: RideInfoPanel(
          distanceText: _distanceText,
          durationText: _durationText,
          priceText: _priceText, // Pass the price text
          onBookRidePressed: _onBookRideNow,
        ),
      
      body: Stack(
        children:<Widget> [
               Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                  ),
          ),

        Padding(
            padding: const EdgeInsets.all(8.0),
            
            child:  Column(
              children: [

                const SizedBox(height: 50),

                   TextField(
                     onChanged: (userInput) {searchPlace(userInput);},
                    controller: _destinationController, // Your existing controller
                    decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Enter Destination Address',
                              hintText: 'e.g., Harare Gardens, Harare', // Added hint text
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                      icon: Icon(Icons.clear),
                                       // Add a clear button
                                      onPressed: () {
                                        _destinationController.clear();
                                        // You might also want to clear markers/polyline here if needed
                                        setState(() {
                                          _polylines.clear();
                                          _markers.removeWhere((marker) =>
                                          marker.markerId.value == 'destination' ||
                                          marker.markerId.value.startsWith('intermediate'));
                                          }
                                        );
                                      },
                                    ),
                                ),
                  
                          ),
 


                if (dropOffPredictionPlaces.isNotEmpty)
                            Expanded( // Use Expanded to take remaining vertical space
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListView.separated(
                  itemCount: dropOffPredictionPlaces.length,
                  // Removed shrinkWrap: true
                  physics: const ClampingScrollPhysics(), // Or another appropriate physics
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      child:  ElevatedButton(
      onPressed: (){
        //we want to collect the index of the place predicted, take  its place id value and draw a polyline between current location and predicted place location  
        setState(() {
        destinationLocationName = dropOffPredictionPlaces[index].main_text.toString();
        print("\n\n\n\n\ndestinationlocation name: $destinationLocationName\n\n\n\n\n");
        _setDestinationFromAddress(destinationLocationName);
        dropOffPredictionPlaces.clear();
        _destinationController.clear();
        });
        
      }, 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 10,),

            Row(
              children: [
                const Icon(
                  Icons.place,
                  color: Colors.green,
                ),

                const SizedBox(width: 13,),

                Expanded(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,      
                  children: [
                    Text(dropOffPredictionPlaces[index].main_text.toString(),
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                      fontSize: 16,
                     ),
                    ),

                    const SizedBox(height: 3,),

                    Text(dropOffPredictionPlaces[index].secondary_text.toString(),
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                      fontSize: 12,
                     ),
                    ),
                  ],            
                ),
                ),
              ],
            )
          ],
        ),
      )
    )
    

                    );
                  },
                ),
              ),
            ),
              
              const SizedBox(height: 13,),

              ],
                        
            )
          ),

          

        ],
      ),
      ),
    );
  }
}





