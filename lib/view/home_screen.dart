import 'package:easypark/view/MyBookings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:easypark/controllers/location_service.dart'; // Placeholder import for location service
// Placeholder import for theme
import 'package:easypark/controllers/search_service.dart'; // Placeholder import for search service
import 'package:easypark/view/ParkingSpot.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark/model/FirebaseService.dart';
import 'package:easypark/view/PopUpMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng? currentLocation;
  String searchQuery = "";
  LatLng? searchedLocation;
  int _selectedIndex = 0;
  List<LatLng> parkingLocations = [];
  //List<String> areaIds = [];



  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Your existing code to get current location
    _getParkingLocations(); // Call the new method to fetch parking data
    FirebaseService.clearExpiredReservations(context);
  }

  Future<void> _getCurrentLocation() async {
    currentLocation = await getCurrentLocation();
    setState(() {});
  }

  Future<void> _getParkingLocations() async {
    final locations = await FirebaseService.getParkingLocations();
    setState(() {
      parkingLocations = locations;
      //areaIds = areaIds;
    });
  }


  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      return;
    }

    // Placeholder search function
    searchedLocation = await searchLocation(query);
    if (searchedLocation != null) {
      setState(() {
        currentLocation = searchedLocation;
        searchQuery = query;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          print('Home Page tapped');
          break;
        case 1:
          print('My Bookings tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyBookingsPage()),
          );
          break;
        case 2:
          print('Rent Parking Spot tapped');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const InsertParkingData()),
          // );
          // Show AlertDialog directly
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Access Denied"),
                content: Text("You are not an admin user."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
          break;
        case 3:
          print('Profile tapped');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          flutter_map.FlutterMap(
            options: flutter_map.MapOptions(
              center: currentLocation ?? const LatLng(6.927079, 79.861244),
              zoom: 13.0,
            ),
            children: [
              flutter_map.TileLayer(
                tileProvider: flutter_map.NetworkTileProvider(),
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              if (currentLocation != null) // Only add marker if current location is available
                flutter_map.MarkerLayer(
                  markers: [
                    flutter_map.Marker(
                      width: 40.0,
                      height: 40.0,
                      point: currentLocation!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              flutter_map.MarkerLayer(
                markers: parkingLocations
                    .map((location) => flutter_map.Marker(
                    width: 40.0,
                    height: 40.0,
                    point: location,
                    child: GestureDetector(
                      onTap: () => _onMarkerTapped(context, location, parkingLocations),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            top: 30.0,
            left: 20.0,
            right: 20.0,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search location...',
                filled: true,
                fillColor: Colors.black54,
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(50.0),
                    right: Radius.circular(50.0),
                  ),
                  borderSide: BorderSide(color: Colors.white),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                print('Search query: $value');
              },
              onSubmitted: (value) => _onSearch(value),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.blue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_sharp),
            label: 'Rent Parking Spot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

void _onMarkerTapped(BuildContext context, LatLng markerLocation, List<LatLng> parkingLocations) async {
  // Check if the tapped marker location exists in parkingLocations list
  if (parkingLocations.contains(markerLocation)) {
    print('Location tapped at $markerLocation');

    final String locationString = '${markerLocation.latitude}, ${markerLocation.longitude}';

    print('Location String: $locationString');

    // Fetch areaId from Firebase
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('parkingSpot')
          .where('Location', isEqualTo: locationString)
          //.where('Location', isEqualTo: '6.856453, 79.8653852')
          .limit(1)
          .get();

      //print('Query Snapshot: $querySnapshot');
      //print('Query Parameters:');
      print('Latitude: ${markerLocation.latitude}');
      print('Longitude: ${markerLocation.longitude}');

      if (querySnapshot.docs.isNotEmpty) {
        final String areaId = querySnapshot.docs.first.get('areaId');
        print('Area ID: $areaId');

        // Optionally, you can navigate to the PopUpMenu widget here if needed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PopUpMenu(areaId: areaId)),
        );

      } else {
        print('No parking spot found at the tapped location');
      }
    } catch (e) {
      print('Error fetching areaId: $e');
    }

  }
}



class InsertData extends StatelessWidget {
  const InsertData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Semi-transparent black background
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Your form widgets here
            ],
          ),
        ),
      ),
    );
  }
}
