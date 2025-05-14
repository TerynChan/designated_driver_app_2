import 'dart:convert';

import 'package:designated_driver_app_2/global.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  String translated = "";


  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.translate_rounded),
        title: const Text('Translation'),
      ),
      body: Card(
        margin: EdgeInsets.all(12),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("English "),

            const SizedBox(height: 12,),

            TextField(
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),

              onChanged: (text) async{
                /*const to = "sn";
                final url = Uri.parse(
                  'https://translation.googleapis.com/language/translate/v2'
                  '?q=$text&target=$to&key=$GoogleMapKey'
                );

                final response = await http.post(url);

                if (response.statusCode == 200){
                  final body = json.decode(response.body);
                  final translations = body["data"]["translation"] as List;
                  final translation = HtmlUnescape().convert(translations.first["translatedText"]);
                  print("\n\n\n\n\n\n\n $translation\n\n\n\n\n\n\n\n");
                
                
                setState(() {
                  translated = translation;
                });
                
                }
                */ 


                final translation = await text.translate(
                  
                  from: "en",
                  to: "sn" ,
                );
                setState(() {
                  translated = translation.text;
                });

                
              },

              decoration: const InputDecoration(
                hintText: "Enter Text",
              ),
            ),

            const Divider(
              height: 32,
            ),

            Text(
                translated,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                )
              ),

            ],
         ),
      )
      );
  }
}