import 'package:flutter/material.dart';
import 'package:plantit/screens/values/constants.dart';
import 'package:plantit/screens/infoScreen.dart';
import 'package:plantit/screens/sensorScreen.dart';

import 'homeScreen.dart';
import 'loginScreen.dart';

class RootScreen extends StatefulWidget {
  final String userEmail;
  final List plantDb;

  const RootScreen({
    Key? key,
    required this.userEmail,
    required this.plantDb,
  }) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MyGardenScreen(
        plantCollection: widget.plantDb,
        userEmail: widget.userEmail,
      ),
      SensorScreen(userEmail: widget.userEmail),
      InfoScreen(
        title: "Search",
        text: "Search for info...",
        hinttext: "Search plants",
        plantCollection: widget.plantDb,
        userEmail: widget.userEmail,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) {
        // If the user taps on the already selected tab, force a rebuild of the screen
        _widgetOptions[_selectedIndex] = _buildScreen(index);
      } else {
        _selectedIndex = index;
      }
    });
  }


  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return MyGardenScreen(
          key: UniqueKey(),
          plantCollection: widget.plantDb,
          userEmail: widget.userEmail,
        );
      case 1:
        return SensorScreen(
          key: UniqueKey(), // Add a UniqueKey here
          userEmail: widget.userEmail,
        );
      case 2:
        return InfoScreen(
          key: UniqueKey(),
          title: "Search",
          text: "Search for info...",
          hinttext: "Search plants",// Add a UniqueKey here
          plantCollection: widget.plantDb,
          userEmail: widget.userEmail,
        );
      default:
        return Container();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ??
    false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.black54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist),
              label: 'My Plants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors_outlined),
              label: 'Sensors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: 'Search',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
