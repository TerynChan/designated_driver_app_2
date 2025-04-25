import 'package:flutter/material.dart';
import 'package:designated_driver_app_2/widgets/loading_screen.dart';

class AssociateMethods {
  showSnackBarMsg(String smg, BuildContext cxt){
    var snackBar = SnackBar(content: Text(smg)); 
    ScaffoldMessenger.of(cxt).showSnackBar(snackBar);
  }

  LoadingScreen showLoadingDialog(BuildContext context) {
    return LoadingScreen();
  }
}  