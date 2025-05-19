// lib/widgets/available_drivers_screen.dart
import 'dart:async';

import 'package:designated_driver_app_2/model/driver_model.dart';
import 'package:designated_driver_app_2/model/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class AvailableDriversScreen extends StatefulWidget {
  final String rideId;
  final String destinationAddress;
  final String fare;
    

  const AvailableDriversScreen({
    Key? key,
    required this.rideId,
    required this.destinationAddress,
    required this.fare, required String originAddress,
  }) : super(key: key);

  @override
  State<AvailableDriversScreen> createState() => _AvailableDriversScreenState();
    
}

class _AvailableDriversScreenState extends State<AvailableDriversScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  List<DriverModel> _availableDrivers = [];
  bool _isLoading = true;
  String _error = '';
  StreamSubscription<DatabaseEvent>? _rideSubscription;
  late DatabaseReference _rideRef;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDrivers();
    _setupRideListener();
  }

 void _fetchAvailableDrivers() {
    print("Attempting to fetch available drivers...");
    _usersRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("Raw data from Firebase: $data"); // <-- Add this print

      if (data == null) {
        setState(() {
          _availableDrivers = [];
          _isLoading = false;
          _error = 'No users found in the database.';
        });
        print("No data received from Firebase.");
        return;
      }

      final Map<dynamic, dynamic> usersMap = data as Map<dynamic, dynamic>;
      List<DriverModel> drivers = [];
      int driversFound = 0; // For debugging count

      usersMap.forEach((uid, userData) {
        print("Processing user UID: $uid, Data: $userData"); // <-- Add this print

        final Map<dynamic, dynamic> driverData = userData as Map<dynamic, dynamic>;

        // Check if this user is a driver and is available
        bool isDriver = driverData['isDriver'] == true; // Ensure boolean comparison
        bool isAvailable = driverData['isAvailable'] == true; // Ensure boolean comparison

        print("  isDriver: $isDriver, isAvailable: $isAvailable"); // <-- Add this print

        if (isDriver && isAvailable) {
          try {
            drivers.add(DriverModel.fromMap(driverData, uid));
            driversFound++;
            print("  Driver added: ${driverData['name']}"); // <-- Add this print
          } catch (e) {
            print("  ERROR parsing driver data for $uid: $e"); // <-- Catch parsing errors
          }
        } else {
            print("  Skipping user $uid: Not a driver or not available.");
        }
      });

      print("Total available drivers found: $driversFound"); // <-- Add this print

      setState(() {
        _availableDrivers = drivers;
        _isLoading = false;
        _error = drivers.isEmpty ? 'No available drivers nearby at the moment.' : '';
      });
    }, onError: (error) {
      // This block will catch any errors from the Firebase Realtime Database
      setState(() {
        _isLoading = false;
        _error = 'Failed to load drivers: ${error.toString()}';
      });
      print("Firebase Realtime Database Error: $error"); // <-- Crucial error log
    });
  }


  void _showDriverAcceptedDialog({required String driverId, required String rideId}) {
    // Prevent duplicate dialogs
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ride Accepted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your driver is on the way'),
            FutureBuilder(
              future: _getDriverInfo(driverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final driver = snapshot.data;
                  return driver != null 
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(driver['photoUrl'] ?? ''),
                          ),
                          title: Text(driver['name'] ?? 'Driver'),
                          subtitle: Text(driver['vehicle'] ?? ''),
                        )
                      : const Text('Driver information');
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to ride tracking screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Placeholder()//ride tracking screen
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _getDriverInfo(String driverId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .get();
    
    return snapshot.value as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _rideSubscription?.cancel();
    super.dispose();
  }

  void _selectDriver(DriverModel driver) async {
    print('Selected driver: ${driver.name} (UID: ${driver.uid}) for ride ${widget.rideId}');

    try {
      await FirebaseDatabase.instance.ref('rides').child(widget.rideId).update({
        'driverId': driver.uid,
        'status': RideStatus.accepted.name,
        
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride assigned to ${driver.name}! Awaiting driver acceptance.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error assigning driver to ride: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign driver. Please try again.')),
      );
    }
  }

    void _setupRideListener() {
    _rideRef = FirebaseDatabase.instance.ref().child('rides').child(widget.rideId);
    
    _rideSubscription = _rideRef.onValue.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return;

      final data = snapshot.value as Map<dynamic, dynamic>;
      final status = data['status'] as String?;
      
      if (status == 'accepted') {
        // Show dialog when ride is accepted
        _showDriverAcceptedDialog(
          driverId: data['driverId'] as String,
          rideId: widget.rideId,
        );
      }
    });
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Drivers'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Ride to ${widget.destinationAddress}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Estimated Fare: ${widget.fare}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Nearby Drivers:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
                    : _availableDrivers.isEmpty
                        ? const Center(child: Text('No available drivers found at the moment.'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _availableDrivers.length,
                              itemBuilder: (context, index) {
                                final driver = _availableDrivers[index];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      child: const Icon(Icons.person, size: 30, color: Colors.white),
                                    ),
                                    title: Text(
                                      driver.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Updated car info display
                                        Text('${driver.carColor} ${driver.carModel} (${driver.carType})'),
                                        Text('License: ${driver.carNumber}'), // Display carNumber as License
                                        Text('Contact: ${driver.phoneNumber}'),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(driver.rating.toStringAsFixed(1)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: (){
                                        _selectDriver(driver);
                                        _setupRideListener();
                                      }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      child: const Text('Select', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}