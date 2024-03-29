import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

/// this is the history screen - shows the growth progress
class HistoryScreen extends StatefulWidget {
  final String userEmail;
  final String plant;

  const HistoryScreen({
    Key? key,
    required this.plant,
    required this.userEmail,
  }) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _plantHistory = [];
  //indication for us to know if the loading of the history is done or not
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load data from database
    _loadPlantHistory();
  }

  //get from server the plant history
  void _loadPlantHistory() async {
    final response = await http.get(Uri.parse('$serverUrl/history/${widget.userEmail}/${widget.plant}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _plantHistory = data;
        //loading data is done
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("${widget.plant}'s history")),
        backgroundColor: const Color(0xff07a36f),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))),
      ),
      //if loading data - show progress indicator.
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
            //if history empty -
          : _plantHistory.isEmpty ?
      Container(
        decoration:  const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            "No history yet...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      )
      // else - if data finished loading and also there is history to show :
      : Container(
        decoration:  const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: _plantHistory.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _plantHistory[index]["date"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      _plantHistory[index]["image"],
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          // The image has finished loading
                          return child;
                        } else {
                          // The image is still loading, show a progress indicator
                          return Container(
                            height: 200,
                            width: double.infinity,
                            child: Center(
                              child: SizedBox(
                                width: 30.0,
                                height: 30.0,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}