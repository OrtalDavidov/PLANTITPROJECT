import 'package:flutter/material.dart';
import 'package:plantit/screens/homeInfoCard/body.dart';

class DetailsScreen extends StatelessWidget {
      var c_plant;


    DetailsScreen({Key? key, required this.c_plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("rooooooooooon");
    print(c_plant);
    return  Scaffold(
      body: Body(
        cPlant: c_plant,
      ),
    );
  }
}