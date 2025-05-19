import 'package:designated_driver_app_2/pages/user/bookings_page.dart';
import 'package:designated_driver_app_2/pages/user/map_with_polylines.dart';
import 'package:designated_driver_app_2/pages/user/news_page.dart';
import 'package:designated_driver_app_2/pages/user/translation_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

   int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    MapWithPolyline(),
    const BookingsPage(),
    TranslationPage(),
    const NewsPage(),
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
            icon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Bookings',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.translate_rounded),
            label: 'Translate',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_rounded),
            label: 'Feed',
          ),
        ],
        iconSize: 40,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
