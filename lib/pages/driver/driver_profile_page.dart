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
  final double profileHeight= 144;

  

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
     
    return Scaffold(
      body: ListView(
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

Widget buildCoverImage()=> Container(
        color: Colors.grey,
        child:FadeInImage.assetNetwork(
        width: double.infinity,
        height: coverHeight,
        fit: BoxFit.cover,
        placeholder: 'assets/background.jpg',
        image: 'https://picsum.photos/250?image=9',
),
    

  );

  Widget buildProfileImage() => GestureDetector(
    onTap: () {
      // Navigate to the ProfileImageUploader widget when the avatar is clicked
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileImageUploader(userId: userId),
        ),
      );
    },
    child: CircleAvatar(
      radius: 60,
      backgroundImage: const NetworkImage(
        'https://via.placeholder.com/150/A9A9A9/FFFFFF?Text=Avatar', // Replace with your profile image URL
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 20,
        ), // Optional: Add a camera icon overlay
      ),
    ),
  );

  Widget buildTop( ){
    final top = coverHeight - profileHeight/3;
    final bottom = profileHeight /2;

    return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
             Container(
              margin: EdgeInsets.only(bottom: bottom),
              child: buildCoverImage()
            ),
                     
            // Avatar 
            Positioned(
              top: top, // screenHeight * 0.3 - 60, // Position above the cover image
              child: buildProfileImage(),
            ),
          ],
    );
  }

  Widget BuildContent(){
    // Profile Details and Sign Out Button
    return Padding(
              padding: const EdgeInsets.only(top: 10.0), // Adjust padding based on avatar size and cover image height
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
                  const SizedBox(height: 74),
         
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
         
                  const SizedBox(height: 54), // Adds spacing before the sign-out button
         
                  // Sign Out Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the button horizontally
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3, // Set width to one-third of the screen
                          child: ElevatedButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.push(context, MaterialPageRoute(builder: (c) => SigninPage()));
                              
                              // Example of updating data (you'd have your actual logic here)
                              _updateProfileData();
                            },
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


