import 'package:designated_driver_app_2/model/ride_model.dart';
import 'package:designated_driver_app_2/pages/driver/available_rides_page.dart';
import 'package:designated_driver_app_2/pages/driver/driver_profile_page.dart';
import 'package:designated_driver_app_2/pages/driver/map_page.dart';
import 'package:designated_driver_app_2/widgets/ride_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import for StreamSubscription


class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;

  // Firebase references
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref('rides');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DatabaseEvent>? _rideRequestSubscription; // To manage the listener

  bool _isRideRequestDialogShowing = false; // Flag to prevent multiple dialogs



  static final List<Widget> _pages = <Widget>[
    Placeholder(),
    AvailableRidesPage(),
    DriverProfilePage(),
  ];


  // Default ride instance for MapPage

  @override
  void initState() {
    super.initState();
    _listenForRideRequests();
  }

  @override
  void dispose() {
    _rideRequestSubscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _listenForRideRequests() {
    final String? currentDriverId = _auth.currentUser?.uid;

    if (currentDriverId == null) {
      print("Driver not logged in, cannot listen for ride requests.");
      return;
    }

    print("Driver ID: $currentDriverId - Listening for accepted ride requests...");

    // Listen for rides where driverId matches current driver AND status is 'accepted'
    // This is how Firebase will notify this specific driver.
    _rideRequestSubscription = _ridesRef
        .orderByChild('driverId')
        .equalTo(currentDriverId)
        .onValue
        .listen((event) {
      if (event.snapshot.value == null) {
        // print("No ride data for this driver or value is null.");
        return; // No rides assigned to this driver yet
      }

      final Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map<dynamic, dynamic>;
      RideModel? incomingRide;

      ridesMap.forEach((rideId, rideData) {
        try {
          final ride = RideModel.fromMap(rideData, rideId);
          // Check if it's an accepted ride specifically for this driver
          if (ride.driverId == currentDriverId && ride.status == RideStatus.accepted) {
            incomingRide = ride; // Found the assigned ride awaiting confirmation
            return; // Exit forEach once found
          }
        } catch (e) {
          print("Error parsing ride data for dialog: $e");
        }
      });

      if (incomingRide != null && !_isRideRequestDialogShowing) {
        _showRideRequestDialog(incomingRide!);
      } else if (incomingRide == null && _isRideRequestDialogShowing && Navigator.of(context).canPop()) {
        // If the ride somehow disappeared or changed status, and dialog is showing, dismiss it.
        // This handles cases where passenger cancels while driver is still seeing dialog.
        Navigator.of(context).pop();
        _isRideRequestDialogShowing = false;
      }
    }, onError: (error) {
      print("Error listening for ride request notification: $error");
    });
  }

  void _showRideRequestDialog(RideModel ride) {
    _isRideRequestDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false, // Driver must accept or reject
      builder: (BuildContext context) {
        return RideRequestDialog(
          ride: ride,
          onAccept: () => _handleRideAccept(ride),
          onReject: () => _handleRideReject(ride),
        );
      },
    ).then((_) {
      // This callback runs after the dialog is dismissed
      _isRideRequestDialogShowing = false;
    });
  }

  void _handleRideAccept(RideModel ride) async {
    Navigator.of(context).pop(); // Dismiss the dialog
    _isRideRequestDialogShowing = false; // Reset flag

    try {
      // The ride status is already 'accepted' from the passenger's selection.
      // Here, you might update it to 'driverArrived' if that's the next step,
      // or simply confirm it as 'accepted' and proceed.
      // For now, we'll assume 'accepted' is the state for assigned and confirmed.
      // await _ridesRef.child(ride.rideId!).update({'status': RideStatus.driverArrived.name});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride to ${ride.destinationAddress} confirmed!')),
      );

      // TODO: Navigate driver to a live ride tracking/details page
      // For example:
      // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverLiveRidePage(ride: ride)));

    } catch (e) {
      print("Error confirming ride: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm ride. Please try again.')),
      );
    }
  }

  void _handleRideReject(RideModel ride) async {
    Navigator.of(context).pop(); // Dismiss the dialog
    _isRideRequestDialogShowing = false; // Reset flag

    try {
      // Update status to cancelled by driver and remove driverId
      await _ridesRef.child(ride.rideId!).update({
        'status': RideStatus.cancelledByDriver.name,
        'driverId': null, // Remove driver assignment
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride to ${ride.destinationAddress} rejected.')),
      );

      // TODO: Notify passenger about the rejection (this would require a listener on passenger side)
    } catch (e) {
      print("Error rejecting ride: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject ride. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earn',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        iconSize: 40,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

/*void main() {
  runApp(MaterialApp(
    home: DriverHomePage(),
  ));
}*/


