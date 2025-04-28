import 'package:designated_driver_app_2/model/search_prediction_model.dart';
import 'package:flutter/material.dart';

class PredictionPlacesUi extends StatelessWidget {
  SearchPredictionModel? predictionPlacesData;

  PredictionPlacesUi({super.key, this.predictionPlacesData});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){}, 
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
                    Text(predictionPlacesData!.main_text.toString(),
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                      fontSize: 16,
                     ),
                    ),

                    const SizedBox(height: 3,),

                    Text(predictionPlacesData!.secondary_text.toString(),
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