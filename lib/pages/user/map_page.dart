import 'dart:async';
import 'package:designated_driver_app_2/appInfo/app_info.dart';
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:designated_driver_app_2/pages/user/select_destination_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';



class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _HomePageState();
}

class _HomePageState extends State<MapPage> {

  double bottomMapPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController =  Completer<GoogleMapController>();


  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  double searchContainerHeight = 220;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  List<LatLng> polylineCoordinates = [];


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
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 13.5);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));

    await GoogleMapsMethods.convertGeoCoordinatesIntoHumanReadableAddress(currentPositionOfUser!, context);
  }

  getPolyPoints()async{
    print("\n\n\n\n\n\n\n\n calling getRouteBetween Coordinates function  .... \n\n\n\n\n\n\n\n");

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GoogleMapKey,
      
      PointLatLng(
        currentPositionOfUser!.latitude,
        currentPositionOfUser!.longitude
      ),



      PointLatLng(
        Provider.of<AppInfo>(context, listen: false).dropOffLocation?.latitudePosition ?? 0.0,
        Provider.of<AppInfo>(context, listen: false).dropOffLocation?.longitudePosition ?? 0.0,
        )
      );

      print("\n\n\n\n\n\n\n\n CREATING polyline points.... \n\n\n\n\n\n\n\n");

      if(result.points.isNotEmpty){
        print("\n\n\n\n\n\n\n\npolyline points created successfully\n\n\n\n\n\n\n\n");
        result.points.forEach((PointLatLng point)=>polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
          ),
        );
      }

  }

   
  @override

  void initState(){
    super.initState();
    getPolyPoints();
    }


  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,

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
                onTap: (){},
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey,),
                  title: Text("history",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                  ),
                ),
              ),
 
               GestureDetector(
                onTap: (){},
                child: const ListTile(
                  leading:  Icon(Icons.info, color: Colors.grey,),
                  title: Text("About",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  ),
                ),
              ),

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
      
      body: Stack(
        children: [

            
          GoogleMap(
            polylines:{
              Polyline(polylineId:PolylineId("route"),
              points: polylineCoordinates,

              )
            },
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLocation();
              
            },
          
          markers: currentPositionOfUser != null
              ? {
                  Marker(
                    markerId: const MarkerId("source"),
                    position: LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude),
                  ),
                  Marker(
                    markerId: MarkerId("destination"),
                    position: Provider.of<AppInfo>(context, listen: false).dropOffLocation?.destinationLocation?? LatLng(0.0, 0.0),
                  )
                }
              : {},
          ),

          //drawer button
          Positioned(
            top: 37,
            left: 20,
            child: GestureDetector(
              onTap: (){
                sKey.currentState?.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                  )]
                ),

                child: const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 20,
                  child: Icon(Icons.menu,color: Colors.white,),
                ),
              ),
            ),
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
                              "${(Provider.of<AppInfo>(context, listen: false).pickUpLocation?.placeName ?? 'Unknown').substring(0, 20)}...",
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
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (C)=> SelectDestinationPage()));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("To", style: TextStyle(fontSize: 12),),
                                Text(Provider.of<AppInfo>(context, listen: true).dropOffLocation == null? 'Where to go...?': 
                              "${(Provider.of<AppInfo>(context, listen: false).dropOffLocation?.placeName ?? 'Unknown').substring(0, 20)}...",
                              style: const TextStyle(fontSize: 12),),
                              ],
                            ),
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
                      
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (C) => SelectDestinationPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            "Select Destination",
                            style: TextStyle(
                            color: Colors.white,
                            ),
                          ),
                          ),
                          ElevatedButton(
                          onPressed: () {
                            setState(() {
                              getPolyPoints();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            "Show Route",
                            style: TextStyle(
                            color: Colors.white,
                            ),
                          ),
                          ),
                        ],
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
