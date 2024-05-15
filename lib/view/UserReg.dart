import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class UserReg extends StatefulWidget {
  const UserReg({super.key});

  @override
  State<UserReg> createState() => _UserRegState();
}

class _UserRegState extends State<UserReg> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contactNumber = TextEditingController();
  String? _selectedUserRole;
  final _email = TextEditingController();
  final _password = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Registration",
          style: TextStyle(color: Colors.deepPurple),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    hintText: 'Please enter User name',
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
                    hintText: 'Please enter User contact number',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedUserRole,
                  hint: const Text('Select user role'),
                  style: const TextStyle(color: Colors.white),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: 'User',
                      child: Text('User'),
                    ),
                    DropdownMenuItem(
                      value: 'Supervisor',
                      child: Text('Supervisor'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a user role';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedUserRole = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Select user role',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  dropdownColor: Colors.lightBlue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _email,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Please enter Email Address',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _password,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                        right: Radius.circular(50.0),
                      ),
                    ),
                    hintText: 'Please enter password',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              //   child: TextFormField(
              //     controller: _confirmPassword,
              //     style: const TextStyle(color: Colors.white),
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.horizontal(
              //           left: Radius.circular(50.0),
              //           right: Radius.circular(50.0),
              //         ),
              //       ),
              //       hintText: 'Please confirm password',
              //       hintStyle: TextStyle(color: Colors.black54),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            try {
              CollectionReference dbRef = FirebaseFirestore.instance.collection('users');
              await dbRef.add({
                'Name': _name.text,
                'Contact': _contactNumber.text,
                'userRole': _selectedUserRole,
                'email': _email.text,
                'password': _password.text,
              });

              // Clear text fields after successful submission
              _name.clear();
              _contactNumber.clear();
              _selectedUserRole = null;
              _email.clear();
              _password.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data saved successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              if (e is FirebaseException) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.message}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                // Handle other exceptions
                print('Unexpected error: $e');
              }
            }
          },
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: UserReg(),
  ));
}
