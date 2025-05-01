
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/profile_image_uploader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  double _rating = 0.0;
  int _jobsCompleted = 0;
  double _earnings = 00.00;
  final double coverHeight = 280;

  // Function to simulate updating the values (you'd replace this with actual logic)
  void _updateProfileData() {
    setState(() {
      _rating = 4.9;
      _jobsCompleted = 130;
      _earnings = 5750.50;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
 
       body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // Cover Image
          Container(
            color: Colors.grey,
            height: screenHeight * 0.3, // Adjusted cover image height
             child:Image.network('https://via.placeholder.com/800x400/8FBC8F/FFFFFF?Text=Cover+Image',
                    width: double.infinity,
                    height: coverHeight,
                    fit: BoxFit.cover,
                ), // Replace with your cover image URL
          ),

          // Avatar 
          Positioned(
            top: screenHeight * 0.3 - 60, // Position above the cover image
            child: GestureDetector(
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://via.placeholder.com/150/A9A9A9/FFFFFF?Text=Avatar'), // Replace with your profile image URL
              ),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileImageUploader(userId: userId), // Pass the user ID
                  ),
                );
              },
            ),
          ),

          // Profile Details and Sign Out Button
          Padding(
            padding: const EdgeInsets.only(top: 200.0), // Adjust padding based on avatar size and cover image height
            child: Column(
              children: <Widget>[
                const SizedBox(height: 16),
                const Text(
                  'John Doe', // Replace with user's name
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'johndoe@example.com', // Replace with user's email
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Rating, Jobs Completed, Earnings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildProfileInfo('Rating', _rating.toStringAsFixed(1)),
                      _buildProfileInfo('Jobs Completed', _jobsCompleted.toString()),
                      _buildProfileInfo('Earnings', '\$${_earnings.toStringAsFixed(2)}'),
                    ],
                  ),
                ),

                const Spacer(), // Pushes the sign-out button to the bottom

                // Sign Out Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
                        
                        // Example of updating data (you'd have your actual logic here)
                        _updateProfileData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 18),
                      ),
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

  Widget _buildProfileInfo(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}