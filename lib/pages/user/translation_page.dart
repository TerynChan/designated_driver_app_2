
import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      drawer: SizedBox(
        width: 256,
        child: Drawer(
          child: ListView(
            children: [

              //header of drawer
              SizedBox(
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                  child: Row(
                    children: [
                      Image.asset("assets/avatar.jpg",
                      width: 60,
                      height: 60,
                      ),

                      const SizedBox(width: 16,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox( height: 16,),

                          const Text(
                            "profile",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      )
                    ],
                  ), 
                ),
              ),

              //body of drawer
              
         
               GestureDetector(
                onTap: (){ 
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
                },
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.grey,),
                  title: Text("Log Out",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      
      appBar: AppBar(
       
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