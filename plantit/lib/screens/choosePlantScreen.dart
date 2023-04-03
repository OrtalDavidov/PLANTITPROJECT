import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'infoCard/details_screen.dart';

class ChoosePlantScreen extends StatelessWidget {
  final String light;
  final String moisture;
  final String temperature;
  final List plantCollection ;
  final String userEmail;


  const ChoosePlantScreen({
    Key? key,
    required this.light,
    required this.moisture,
    required this.temperature,
    required this.plantCollection,
    required this.userEmail
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Screen'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: plantCollection.length, // Number of plants to display
              itemBuilder: (BuildContext context, int index) {
                var cPlant = plantCollection[index];
                var name = plantCollection[index]["Common_name"];
                var des;
                if(name == "African Violets"){
                  des = plantCollection[index]["Description"];

                }else{plantCollection[index]["Description"]="hi";}

                 return GestureDetector(
                    onTap: () {

                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/5.ico',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      cPlant["Common_name"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Description of plant ${index + 1}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              c_plant: cPlant,
                              userEmail: userEmail,
                            ),
                          ),
                        );

                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}