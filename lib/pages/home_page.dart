import 'dart:async';
import 'package:designated_driver_app_2/appInfo/app_info.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double bottomMapPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController =  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  double searchContainerHeight = 220;

  getCurrentLocation() async{
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    currentPositionOfUser = userPosition;

    //lotion in form of geographic coordinates
    LatLng userLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));

    await GoogleMapsMethods.convertGeoCoordinatesIntoHumanReadableAddress(currentPositionOfUser!, context);
  }

  @override
  Widget build(BuildContext contextr) {
    return Scaffold(
      body: Stack(
        children: [
          //google map
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLocation();
            },
          ),

          // search location container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeInOut,
              duration: const Duration(microseconds: 122),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  )
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [

                      //Departure Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.blue,),
                          const SizedBox(width: 13,),
                          Column( 
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("From", style: TextStyle(fontSize: 12),),
                              
                              Text(Provider.of<AppInfo>(context, listen: true).pickUpLocation == null? 'UPDATING...': 
                              (Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName!).substring(0, 20) + "...",
                              style: const TextStyle(fontSize: 12),),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 10,),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 10,),

                      //Destination Location
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.green,),
                          const SizedBox(width: 13,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("To", style: TextStyle(fontSize: 12),),
                              const Text("where to go?" , style: TextStyle(fontSize: 12),),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 10,),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 10,),
                      
                      ElevatedButton(onPressed: (){},
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                       ), 
                       child: Text("Select Destination",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                        )
                      ),
                      
                    ],
                  ),
                ),

              ),
            ),
          ),
        ],
      ),
   
    );
  }
}
