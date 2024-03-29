import 'package:flutter/material.dart';
import 'infoCard/details_screen.dart';

/// this is the ChoosePlantScreen screen - shows the filtered plants according to the info from sensors

class ChoosePlantScreen extends StatefulWidget {
  final String light;
  final String moisture;
  final String temperature;
  final List plantCollection ;
  final String userEmail;
  final Function render;

  const ChoosePlantScreen({
    Key? key,
    required this.light,
    required this.moisture,
    required this.temperature,
    required this.plantCollection,
    required this.userEmail,
    required this.render
  }) : super(key: key);

  @override
  _ChoosePlantScreenState createState() => _ChoosePlantScreenState();
}

class _ChoosePlantScreenState extends State<ChoosePlantScreen> {
  TextEditingController searchController = TextEditingController();
  //list of plants that matches the search
  late List searchResult;

  @override
  void initState() {
    super.initState();
    searchResult = widget.plantCollection;
    //this func run every time the text in search bar is being changed
    searchController.addListener(() {
      setState(() {
        String query = searchController.text.toLowerCase();
        //return only plants that matches the search
        searchResult = widget.plantCollection.where((plant) {
          String plantName = plant['Common_name'].toLowerCase();
          return plantName.contains(query);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Suitable plants')),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff07a36f),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))),
      ),
      body: Container(
        decoration:  const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search plants',
                  hintText: 'Search plants',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResult.length, // Number of plants to display
                itemBuilder: (BuildContext context, int index) {
                  var cPlant = searchResult[index];
                  return GestureDetector(
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
                              child: Image.network(
                                cPlant["Image_url"],
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
                            cPlant["Botanical Name"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    DetailsScreen(c_plant: cPlant,
                                      userEmail: widget.userEmail,
                                      render: widget.render,),),);},
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}