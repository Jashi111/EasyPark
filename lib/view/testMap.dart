import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OSMHome(),
    );
  }
}

class OSMHome extends StatefulWidget {
  const OSMHome({super.key});

  @override
  State<OSMHome> createState() => _OSMHomeState();
}

class _OSMHomeState extends State<OSMHome> {
  String locationaddress = "Pick Location";
  double latitude = 23, longitude = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('OSM Home'),
        ),
        body: Center(
            child: Container(
              child: InkWell(
                child: Text(locationaddress),
                onTap: () {
                  _showModal(context);
                },
              ),
            )
        )
    );
  }
  void _showModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 600,
              //color: Colors.red,
              child: Center(
                child: OpenStreetMapSearchAndPick(
                    //center: LatLong(latitude, longitude),
                    buttonColor: Colors.blue,
                    buttonText: 'Set Current Location',
                    onPicked: (pickedData) {
                      Navigator.pop(context);
                      setState(() {
                        locationaddress = pickedData.address as String;
                        latitude = pickedData.latLong.latitude;
                        longitude = pickedData.latLong.longitude;
                      });
                      print(pickedData.latLong.latitude);
                      print(pickedData.latLong.longitude);
                      print(pickedData.address);
                    }),
              )

          );
        }
    );
  }
}


