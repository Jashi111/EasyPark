import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  void deleteBooking(BuildContext context, String bookingId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this booking? Our team will contact you for payment refund.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the booking from Firestore
                  await FirebaseFirestore.instance.collection('parkingReserve').doc(bookingId).delete();
                  Navigator.of(context).pop(); // Dismiss the dialog
                  // Show a SnackBar with a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking deleted. Our team will contact you for payment refund.'),
                    ),
                  );
                } catch (e) {
                  print('Error deleting booking: $e');
                  Navigator.of(context).pop(); // Dismiss the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting booking. Please try again.'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void editBooking(BuildContext context, String bookingId, Map<String, dynamic> bookingData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Booking'),
          content: Text('Currently you are unable to edit reservation ID: $bookingId'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('parkingReserve').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
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
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            editBooking(context, bookingId, bookingData);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteBooking(context, bookingId);
                          },
                        ),
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
