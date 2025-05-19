import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart'; 
import 'package:designated_driver_app_2/methods/profile_image_uploader.dart';
import 'package:designated_driver_app_2/model/driver_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database


class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  // State variables for profile data
  DriverModel? _driverData; // Will hold the fetched driver data
  bool _isLoading = true;
  String _errorMessage = '';

  // Placeholder values for data not in DriverModel (jobs completed, earnings)
  // You would need to add these fields to your DriverModel and save them in Firebase
  // if you want them to be dynamic.
  int _jobsCompleted = 0;
  double _earnings = 0.00;

  final double coverHeight = 280;
  final double profileHeight = 144;

  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  void _fetchDriverProfile() {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in.';
      });
      return;
    }

    _usersRef.child(currentUser.uid).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          _driverData = DriverModel.fromMap(data, currentUser.uid);
          _isLoading = false;
          _errorMessage = '';
          // If you ever add jobsCompleted or earnings to DriverModel, update them here:
          // _jobsCompleted = _driverData!.jobsCompleted;
          // _earnings = _driverData!.earnings;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Driver data not found or invalid.';
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: ${error.toString()}';
      });
      print("Error fetching driver profile: $error");
    });
  }

  // Function to handle logout
  void _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (c) => const SigninPage()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : ListView(
                  children: <Widget>[
                    buildTop(),
                    BuildContent(),
                  ],
                ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: FadeInImage.assetNetwork(
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
          placeholder: 'assets/background.jpg', // Ensure this asset exists
          image: 'https://picsum.photos/250?image=9', // Your cover image URL
        ),
      );

  Widget buildProfileImage() {
    final String? currentUserId = _auth.currentUser?.uid; // Get user ID here

    return GestureDetector(
      onTap: () {
        if (currentUserId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileImageUploader(userId: currentUserId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to upload a profile image.')),
          );
        }
      },
      child: CircleAvatar(
        radius: 60,
        backgroundImage: const NetworkImage(
          'https://via.placeholder.com/150/A9A9A9/FFFFFF?Text=Avatar', // Your profile image URL
        ),
        child: const Align(
          alignment: Alignment.bottomRight,
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget buildTop() {
    final top = coverHeight - profileHeight / 3;
    final bottom = profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: buildProfileImage(),
        ),
      ],
    );
  }

  Widget BuildContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Text(
            _driverData?.name ?? 'Driver Name', // Display actual name or default
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _driverData?.email ?? 'driver@example.com', // Display actual email or default
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 74),

          // Rating, Jobs Completed, Earnings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildProfileInfo('Rating', _driverData?.rating.toStringAsFixed(1) ?? 'N/A'), // Display actual rating
                _buildProfileInfo('Jobs Completed', _jobsCompleted.toString()), // Placeholder
                _buildProfileInfo('Earnings', '\$${_earnings.toStringAsFixed(2)}'), // Placeholder
              ],
            ),
          ),

          const SizedBox(height: 54),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: ElevatedButton(
                    onPressed: _signOut, // Call the _signOut function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}