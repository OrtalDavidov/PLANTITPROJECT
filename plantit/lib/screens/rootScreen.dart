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
        userEmail: widget.userEmail,
      ),
      SensorScreen(userEmail: widget.userEmail),
      InfoScreen(
        plantCollection: widget.plantDb,
        userEmail: widget.userEmail,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              icon: Icon(Icons.info_outline),
              label: 'information',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
