import 'dart:convert';

import 'package:designated_driver_app_2/appInfo/app_info.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/model/address_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

//create polyline routes
static getLocationLatLngDetails(BuildContext context,String placeID) async {
   //String PlacesdApiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$GoogleMapKey";


   String PlacesdApiUrl = "https://maps.googleapis.com/maps/api/place/details/json?fields=geometry&place_id=${placeID}&key=$GoogleMapKey";
   print("\n\n\n\n\n\n sending Request to Place Details APi \n\n\n\n\n\n");
      
      var responseFromApi = await SendReqeustToAPI(PlacesdApiUrl);

      print("\n\n\n\n\n\n Request from API was successful \n\n\n\n\n\n");

           if (responseFromApi != "error"){

            AddressModel addressModel = AddressModel();
            
              // Assuming responseFromApi is your parsed JSON response
            addressModel.latitudePosition = responseFromApi["result"]["geometry"]["location"]["lat"];
            addressModel.longitudePosition= responseFromApi["result"]["geometry"]["location"]["lng"];

            print( "destionation latlong = + ${addressModel.latitudePosition}");
            print( "destionation latlong = + ${addressModel.longitudePosition}");
            print( "destionation latlong = + ${addressModel.placeName}");



            addressModel.destinationLocation = LatLng(
              addressModel.latitudePosition ?? 0.0,
              addressModel.longitudePosition ?? 0.0,
            );

            print( "destionation latlong = + ${addressModel.destinationLocation}");
 

        
            Provider.of<AppInfo>(context, listen: false).updatedropOffLocation(addressModel);
      }
      else{
        print( "\n\n\n\n Error Occured During Request to Place Details API Request \n\n\n\n");
      }


}


}






