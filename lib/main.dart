import 'dart:io';
import 'package:designated_driver_app_2/appInfo/app_info.dart';
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'pages/user/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCqGNpMUoIJQrf2R8ddKeD6vZNjNZJyj_g",
        authDomain: "designated-driver-app-1fd31.firebaseapp.com",
        projectId: "designated-driver-app-1fd31",
        storageBucket: "designated-driver-app-1fd31.firebasestorage.app",
        messagingSenderId: "580696882617",
        appId: "1:580696882617:android:f4fcd149bc7ddc74a28a68",
        measurementId: "G-9QG6EMSQF0"
      )
    );
  }

  else{
    await Firebase.initializeApp();
  }

//waiting for user to allow location services
  await Permission.locationWhenInUse.isDenied.then((value){

    if (value){
      Permission.locationWhenInUse.request();
    }
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> AppInfo(),

      child: MaterialApp(
        title: 'Designated Driver App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        
        home: FirebaseAuth.instance.currentUser == null?   SigninPage() : HomePage(),
      ),
    );
  }
}

