import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('parkingReserve').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                final bookingData = document.data() as Map<String, dynamic>;
                final bookingId = document.id;
                final startDate = bookingData['startDate'];
                final endDate = bookingData['endDate'];
                final startTime = bookingData['startTime'];
                final endTime = bookingData['endTime'];
                final totalCost = bookingData['totalCost'];
                return Card(
                  child: ListTile(
                    title: Text('Booking ID: $bookingId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date: $startDate'),
                        Text('End Date: $endDate'),
                        Text('Start Time: $startTime'),
                        Text('End Time: $endTime'),
                        Text('Total Cost: $totalCost'),
                        // Add more specific data as needed
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
