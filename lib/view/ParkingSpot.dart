import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:easypark/controllers/location_service.dart';

class InsertParkingData extends StatefulWidget {
  const InsertParkingData({super.key});

  @override
  State<InsertParkingData> createState() => _InsertParkingDataState();
}

class _InsertParkingDataState extends State<InsertParkingData> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contactNumber = TextEditingController();
  final _NumberofSpot = TextEditingController();
  String? _selectedCarParkingSize;
  String? _vehicleCategory;
  String? _minimumBookingDuration;
  final _completeAddress = TextEditingController();
  final _monthlyPrice = TextEditingController();

  // Variable to store user's current location
  String? _userCurrentLocation;

  // Function to get user's current location
  void _getUserCurrentLocation() async {
    LatLng? currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      setState(() {
        _userCurrentLocation =
        '${currentLocation.latitude}, ${currentLocation.longitude}';
      });
    } else {
      setState(() {
        _userCurrentLocation = 'Location not available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Parking Spot Registration",
          style: TextStyle(color: Colors.deepPurple), // Change app bar text color to white
        ),
        backgroundColor: Colors.transparent, // Set background color as transparent
        elevation: 0, // Remove app bar shadow
      ),
      backgroundColor: const Color(0xFF29B6F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _name,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Please enter Owner name',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _contactNumber,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Please enter Owner contact number',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _NumberofSpot,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'How many parking spots are available on the area',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCarParkingSize,
                  hint: const Text('Select car parking size'),
                  style: const TextStyle(color: Colors.white),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: 'Small',
                      child: Text('Small'),
                    ),
                    DropdownMenuItem(
                      value: 'Medium',
                      child: Text('Medium'),
                    ),
                    DropdownMenuItem(
                      value: 'Large',
                      child: Text('Large'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a car parking size';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedCarParkingSize = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Car Parking Size',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  dropdownColor: Colors.lightBlue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: DropdownButtonFormField<String>(
                  value: _vehicleCategory,
                  hint: const Text('Vehicle Category'),
                  style: const TextStyle(color: Colors.white),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: 'Light',
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: 'Heavy',
                      child: Text('Heavy'),
                    ),
                    DropdownMenuItem(
                      value: 'MotorBikes',
                      child: Text('MotorBikes'),
                    ),
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _vehicleCategory = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Select Vehicle Category',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  dropdownColor: Colors.lightBlue,
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              //   child: DropdownButtonFormField<String>(
              //     value: _minimumBookingDuration,
              //     hint: const Text('Minimum booking duration (1 Day/1 Month)'),
              //     style: const TextStyle(color: Colors.white),
              //     items: const <DropdownMenuItem<String>>[
              //       DropdownMenuItem(
              //         value: '1 Day',
              //         child: Text('1 Day'),
              //       ),
              //       DropdownMenuItem(
              //         value: '1 Month',
              //         child: Text('1 Month'),
              //       ),
              //     ],
              //     onChanged: (value) {
              //       setState(() {
              //         _minimumBookingDuration = value;
              //       });
              //     },
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.horizontal(
              //           left: Radius.circular(50.0),
              //           right: Radius.circular(50.0),
              //         ),
              //       ),
              //       hintText: 'Minimum Booking Duration',
              //       hintStyle: TextStyle(color: Colors.white),
              //     ),
              //     dropdownColor: Colors.lightBlue,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _completeAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Please enter Owner complete address',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _monthlyPrice,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Price for Hour',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              // Add button to get user's current location
              ElevatedButton(
                onPressed: () {
                  print("button clicked");
                  _getUserCurrentLocation();
                },
                child: const Text('Get Current Location'),
              ),
              // Display user's current location if available
              if (_userCurrentLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0), // Add padding only at the top
                  child: Text(
                    'Your Current Location is: $_userCurrentLocation',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            // Save data to Firestore database
            try {
              CollectionReference dbRef =
              FirebaseFirestore.instance.collection('parkingSpot');

              // Generate a unique ID for the document
              DocumentReference docRef = dbRef.doc();

              await dbRef.add({
                'areaId': docRef.id,
                'Name': _name.text,
                'Contact': _contactNumber.text,
                'NumberofSpots': _NumberofSpot.text,
                'ParkingSize': _selectedCarParkingSize,
                'VehicleCategory':_vehicleCategory,
                'Duration': _minimumBookingDuration,
                //'ServiceAvailable': _servicesAvailable.text,
                'Address': _completeAddress.text,
                'Price': _monthlyPrice.text,
                'Location': _userCurrentLocation, // Save user's current location
              });

              print('User Current Location: $_userCurrentLocation');

              // Clear text fields after successful submission
              _name.clear();
              _contactNumber.clear();
              _NumberofSpot.clear();
              _selectedCarParkingSize = null;
              _vehicleCategory = null;
              _minimumBookingDuration = null;
              _completeAddress.clear();
              _monthlyPrice.clear();
              _userCurrentLocation = null;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data saved successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              print('Error adding data to Firestore: $e');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error saving data. Please try again.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.black54,
          ),
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: InsertParkingData(),
  ));
}
