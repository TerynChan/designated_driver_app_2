import 'dart:async';
import 'package:designated_driver_app_2/appInfo/app_info.dart';
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:designated_driver_app_2/pages/user/select_destination_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

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

   
  @override
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

          //google map
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLocation();
            },
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
                              "${(Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName!).substring(0, 20)}...",
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
                                const Text("where to go?" , style: TextStyle(fontSize: 12),),
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
                      
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (C)=> SelectDestinationPage()));
                      },
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
