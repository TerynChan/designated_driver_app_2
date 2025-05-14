import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:designated_driver_app_2/model/search_prediction_model.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class PredictionPlacesUi extends StatefulWidget {
  SearchPredictionModel? predictionPlacesData;

  PredictionPlacesUi({super.key, this.predictionPlacesData});

  @override
  State<PredictionPlacesUi> createState() => _PredictionPlacesUiState();
}

class _PredictionPlacesUiState extends State<PredictionPlacesUi> {

  CreateUserRoute(String placeID) async {
    await GoogleMapsMethods.getLocationLatLngDetails(context, placeID);

  }


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        //we want to collect the index of the place predicted, take  its place id value and draw a polyline between current location and predicted place location  
        setState(() {
        Navigator.pop(context);
        CreateUserRoute(widget.predictionPlacesData!.place_id.toString());
        });
        
      }, 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 10,),

            Row(
              children: [
                const Icon(
                  Icons.place,
                  color: Colors.green,
                ),

                const SizedBox(width: 13,),

                Expanded(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,      
                  children: [
                    Text(widget.predictionPlacesData!.main_text.toString(),
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                      fontSize: 16,
                     ),
                    ),

                    const SizedBox(height: 3,),

                    Text(widget.predictionPlacesData!.secondary_text.toString(),
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                      fontSize: 12,
                     ),
                    ),
                  ],            
                ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}