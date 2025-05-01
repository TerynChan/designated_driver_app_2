import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage; // Import with prefix
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'package:path/path.dart' as path; // For getting file extension
import 'package:permission_handler/permission_handler.dart'; // For handling permissions

class ProfileImageUploader extends StatefulWidget {
  final String userId; // Pass the user's ID
  const ProfileImageUploader({super.key, required this.userId});

  @override
  _ProfileImageUploaderState createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  File? _imageFile;
  String? _imageUrl;
  bool _isUploading =
      false; // Track upload state to show progress indicator
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref(); // Reference to the Realtime Database
  // Or, for Firestore:
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Picks an image from device
  Future<void> _pickImage() async {
    // Request Permission
    var status = await Permission.photos.status;
    if (status.isDenied) {
      // Ask the user for permission.
      status = await Permission.photos.request();
      if (status.isDenied) {
        // The user denied the permission.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission to access photos was denied.'),
          ),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('No image selected.'); // Important for debugging
    }
  }

  // Uploads image to firebase storage
  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first.'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? downloadUrl; // Declare downloadUrl outside the try block
    try {
      // 1. Upload to Firebase Storage
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/${widget.userId}/${path.basename(_imageFile!.path)}'); // Include userId in path

      final uploadTask = storageRef.putFile(_imageFile!);
      await uploadTask.whenComplete(() => {}); // Wait for upload to complete
      downloadUrl = await storageRef.getDownloadURL(); // Get the download URL
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
        ),
      );
      setState(() {
        _isUploading = false;
      });
      return; // IMPORTANT: Exit the function on error!
    }

    // 2. Store the URL in the Realtime Database
    try {
      await _database.child('users/${widget.userId}/profileImageUrl').set(
          downloadUrl); // Use the downloadUrl here
      setState(() {
        _imageUrl = downloadUrl; // Update the UI
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated successfully!'),
        ),
      );
    } catch (e) {
      print('Error updating database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile image URL: $e'),
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _imageFile?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : _imageUrl != null
                          ? NetworkImage(_imageUrl!) as ImageProvider<Object>? // Cast to ImageProvider
                          : const AssetImage(
                              'assets/placeholder.png'), // Use a placeholder
                  child: _imageFile == null && _imageUrl == null
                      ? const Icon(Icons.person, size: 80, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage, // Disable during upload
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            if (_imageUrl != null)
              Text('Current Profile Image URL: $_imageUrl'),
          ],
        ),
      ),
    );
  }
}