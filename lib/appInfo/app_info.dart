import 'package:designated_driver_app_2/model/address_model.dart';
import 'package:flutter/material.dart';

class AppInfo extends ChangeNotifier {

  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel){
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

    void updatedropOffLocation(AddressModel dropOffModel){
    dropOffLocation = dropOffModel;
    notifyListeners();
  }

}