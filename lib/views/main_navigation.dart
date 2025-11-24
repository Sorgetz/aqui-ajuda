import 'package:aqui_ajuda_app/views/help_screen.dart';
import 'package:aqui_ajuda_app/views/home_screen.dart';
import 'package:aqui_ajuda_app/views/map_page.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final screens = [HomePage(), Maps(), HelpScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Ajuda"),
        ],
      ),
    );
  }
}
