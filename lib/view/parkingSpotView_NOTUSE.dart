import 'package:flutter/material.dart';

class ParkingSpotRegistration extends StatefulWidget {
  const ParkingSpotRegistration({super.key});

  @override
  _ParkingSpotRegistrationState createState() => _ParkingSpotRegistrationState();
}

class _ParkingSpotRegistrationState extends State<ParkingSpotRegistration> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _contactNumber = "";
  String _alternateContactNumber = "";
  String? _selectedCarParkingSize; // Changed to nullable
  String? _minimumBookingDuration; // Changed to nullable
  final List<String> _servicesAvailable = []; // Replace with actual list of services
  String _completeAddress = "";
  String _hourPrice = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Spot Registration'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Your name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _name = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contact number *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _contactNumber = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Alternate contact number'),
                  onSaved: (value) {
                    setState(() {
                      _alternateContactNumber = value!;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCarParkingSize,
                  hint: const Text('Select car parking size *'),
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
                ),
                DropdownButtonFormField<String>(
                  value: _minimumBookingDuration,
                  hint: const Text('Minimum booking duration (1 Day/1 Month)'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: '1 Day',
                      child: Text('1 Day'),
                    ),
                    DropdownMenuItem(
                      value: '1 Month',
                      child: Text('1 Month'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _minimumBookingDuration = value;
                    });
                  },
                ),
                // Add checkbox widgets for services available
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Complete address *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your complete address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _completeAddress = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price for Hour *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '_hourPrice';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _hourPrice = value!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Process form data
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
void main() {
  runApp(const MaterialApp(
    home: ParkingSpotRegistration(),
  ));
}
