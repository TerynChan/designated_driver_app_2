import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/methods/google_maps_methods.dart';
import 'package:designated_driver_app_2/model/search_prediction_model.dart';
import 'package:designated_driver_app_2/widgets/prediction_places_ui.dart';
import 'package:flutter/material.dart';

class SelectDestinationPage extends StatefulWidget {
  const SelectDestinationPage({super.key});

  @override
  State<SelectDestinationPage> createState() => _SelectDestinationPageState();
}

class _SelectDestinationPageState extends State<SelectDestinationPage> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<SearchPredictionModel> dropOffPredictionPlaces = [];

  //method for auto complete search predictions
  searchPlace(String userInput) async {
    if (userInput.length > 1) {
      String placesApiUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userInput&key=$GoogleMapKey&components=country:ZWE";
      var responseFromPlacesApi =
          await GoogleMapsMethods.SendReqeustToAPI(placesApiUrl);

      if (responseFromPlacesApi == "error") {
        return;
      }

      if (responseFromPlacesApi["status"] == "OK") {
        var predictionsInJsonFormat = responseFromPlacesApi["predictions"];
        var predictionsInNormalFormat = (predictionsInJsonFormat as List)
            .map((eachPredictedPlace) =>
                SearchPredictionModel.fromJson(eachPredictedPlace))
            .toList();

        setState(() {
          dropOffPredictionPlaces = predictionsInNormalFormat;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column( 
        children: [
          Card(
            elevation: 12,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 2,
                    spreadRadius: 0.2,
                    offset: Offset(0.3, 0.3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 48, left: 24, right: 24, bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Center(
                          child: Text(
                            "search destination",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        //pickup text field
                        Row(
                          children: [
                            Image.asset(
                              "assets/initial.png",
                              height: 16,
                              width: 16,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: TextField(
                                    controller: pickUpTextEditingController,
                                    decoration: InputDecoration(
                                      hintText: "pick up address",
                                      fillColor: Colors.white12,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.only(
                                        left: 11,
                                        top: 9,
                                        bottom: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // destination text field
                        Row(
                          children: [
                            Image.asset(
                              "assets/final.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: TextField(
                                    controller: destinationTextEditingController,
                                    onChanged: (userInput) {
                                      searchPlace(userInput);
                                    },
                                    decoration: InputDecoration(
                                      hintText: "search destination address",
                                      fillColor: Colors.white12,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.only(
                                        left: 11,
                                        top: 9,
                                        bottom: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          //displaying dropofflocation suggestions/ predictions
          if (dropOffPredictionPlaces.isNotEmpty)
            Expanded( // Use Expanded to take remaining vertical space
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListView.separated(
                  itemCount: dropOffPredictionPlaces.length,
                  // Removed shrinkWrap: true
                  physics: const ClampingScrollPhysics(), // Or another appropriate physics
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      child: PredictionPlacesUi(
                        predictionPlacesData: dropOffPredictionPlaces[index],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}