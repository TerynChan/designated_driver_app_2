import 'dart:convert';

import 'package:designated_driver_app_2/appInfo/app_info.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/model/address_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; 

class GoogleMapsMethods{

  static SendReqeustToAPI(String apiUrl) async{
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl)); 

    try{

      if (responseFromAPI.statusCode == 200){
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      }

      else{
        return "error";
      }
      
    }

    catch(errorMsg){
      print( "\n\n Error Occured \n $errorMsg\n");
      return "error";
    }
  }

  //reserve geocoding  
    static Future<String> convertGeoCoordinatesIntoHumanReadableAddress(Position position, BuildContext context)  async{
      String HumanReadableAddress = "";
      String GeocodingApiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$GoogleMapKey";
      
      var responseFromApi = await SendReqeustToAPI(GeocodingApiUrl);

      if (responseFromApi != "error"){
        HumanReadableAddress = responseFromApi["results"][0]["formatted_address"];
        print( "human readable address = $HumanReadableAddress");

        AddressModel addressModel = AddressModel();
        addressModel.HumanReadableAddress = HumanReadableAddress;
        addressModel.placeName = HumanReadableAddress;
        addressModel.placeID = responseFromApi["results"][0]["place_id"];
        addressModel.latitudePosition = position.latitude ;
        addressModel.longitudePosition = position.longitude;
        
        Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(addressModel);
      }
      else{
        print( "\n\n Error Occured 2 \n\n");
      }
      return HumanReadableAddress;
    }
}