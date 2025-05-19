import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/model/route_update.dart';
import 'package:designated_driver_app_2/widgets/route_update_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override

State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {

  final newUpdate1 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate2 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate3 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate4 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate5 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate6 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate7 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate8 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate9 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

  final newUpdate10 = RouteUpdate(
  title: 'Accident on Harare Road',
  description: 'A major accident has blocked the Harare Road near the flyover. Expect significant delays.',
  location: 'Harare Road near Flyover',
  severity: 'High',
  timestamp: DateTime.now(),
  source: 'Community Report',   
);

 List<RouteUpdate> routeUpdatesList = [];

 @override
  void initState() {
    super.initState();
    routeUpdatesList.addAll([newUpdate1,newUpdate2,newUpdate3,newUpdate4,newUpdate5,newUpdate6,newUpdate7,newUpdate8,newUpdate9,newUpdate10]);
  }

 


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
        title:Text("Route Updates") 
      ),

      body: ListView.separated(
                  itemCount: routeUpdatesList.length,

                  // Removed shrinkWrap: true
                  physics: const ClampingScrollPhysics(), // Or another appropriate physics
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    return RouteUpdateCard(update: routeUpdatesList[index]);
                  },
                ),
    );
  }
}