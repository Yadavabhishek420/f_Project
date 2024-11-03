import 'package:flutter/material.dart';
import '../Product/ProductAdd.dart';
import '../Product/ProductList.dart';
import '../Profile/Profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Profile(),
    ProductAdd(),
    ProductList(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: _pages[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.deepOrange,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1_outlined),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_chart),
              label: "ProductAdd",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "ProductList",
            ),
          ],
        ),
        );
  }
}

