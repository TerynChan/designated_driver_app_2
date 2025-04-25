import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; //package for stylish loading screens

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SpinKitSquareCircle(
          color: Colors.green,
          size: 50.0,
          ),
        ),
      );
  }
}