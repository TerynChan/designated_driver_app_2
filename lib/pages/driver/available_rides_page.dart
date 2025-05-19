
import 'package:designated_driver_app_2/model/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AvailableRidesPage extends StatefulWidget {
  const AvailableRidesPage({super.key});

  @override
  State<AvailableRidesPage> createState() => _AvailableRidesPageState();
}

class _AvailableRidesPageState extends State<AvailableRidesPage> {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref('rides');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RideModel> _availableRides = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _currentDriverId;

  @override
  void initState() {
    super.initState();
    _currentDriverId = _auth.currentUser?.uid;
    if (_currentDriverId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Driver not logged in.';
      });
    } else {
      _listenForAvailableRides();
    }
  }

  void _listenForAvailableRides() {
    // Order by status and filter for "pending" rides
    _ridesRef.orderByChild('status').equalTo(RideStatus.pending.name).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        setState(() {
          _availableRides = [];
          _isLoading = false;
          _errorMessage = 'No pending rides found at the moment.';
        });
        return;
      }

      final Map<dynamic, dynamic> ridesMap = data as Map<dynamic, dynamic>;
      List<RideModel> rides = [];

      ridesMap.forEach((rideId, rideData) {
        try {
          rides.add(RideModel.fromMap(rideData, rideId));
        } catch (e) {
          print("Error parsing ride $rideId: $e");
          // Optionally, handle specific malformed ride data here
        }
      });

      setState(() {
        _availableRides = rides;
        _isLoading = false;
        _errorMessage = rides.isEmpty ? 'No pending rides found at the moment.' : '';
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load rides: ${error.toString()}';
      });
      print("Firebase Error loading available rides: $error");
    });
  }

  void _acceptRide(RideModel ride) async {
    if (_currentDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in as a driver to accept rides.')),
      );
      return;
    }

    try {
      // Update the ride status and assign driverId
      await _ridesRef.child(ride.rideId!).update({
        'driverId': _currentDriverId,
        'status': RideStatus.accepted.name,
        // Optional: Add a timestamp for when the ride was accepted
        'acceptedTimestamp': ServerValue.timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride to ${ride.destinationAddress} accepted!')),
      );

      // Optionally navigate the driver to a "Current Ride" or "Ride Details" page
      // For now, it will simply disappear from this list
      // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverRideDetailsPage(ride: ride)));

    } catch (e) {
      print("Error accepting ride: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept ride. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text('Available Rides'),
        backgroundColor: Colors.green, // Driver app theme color
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _availableRides.isEmpty
                  ? const Center(
                      child: Text('No new ride requests available at the moment.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _availableRides.length,
                      itemBuilder: (context, index) {
                        final ride = _availableRides[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From: ${ride.originAddress}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'To: ${ride.destinationAddress}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const Divider(height: 20, thickness: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Distance: ${ride.distanceKm.toStringAsFixed(1)} km'),
                                        Text('Duration: ${ride.durationText}'),
                                        Text('Fare: \$${ride.fareAmount.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _acceptRide(ride),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Accept Ride'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green, // Accept button color
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Requested: ${ride.timestamp.toLocal().toString().split('.')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}