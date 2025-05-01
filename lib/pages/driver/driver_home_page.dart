import 'package:designated_driver_app_2/pages/driver/driver_profile_page.dart';
import 'package:flutter/material.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Map Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Earnings Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Ratings Page', style: TextStyle(fontSize: 24))),
    DriverProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Ratings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
         unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DriverHomePage(),
  ));
}
