import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<LatLng>> getParkingLocations() async {
    final db = FirebaseFirestore.instance;
    final collection = db.collection('parkingSpot');

    final snapshot = await collection.get();

    return snapshot.docs.map((doc) {
      final locationString = doc.data()['Location'] as String;
      final latLngStrings = locationString.split(', ');
      final latitude = double.parse(latLngStrings[0]);
      final longitude = double.parse(latLngStrings[1]);
      return LatLng(latitude, longitude);
    }).toList();
  }

  //  static Future<void> clearExpiredReservations(BuildContext context) async {
  //   final now = DateTime.now();
  //
  //   // Query for reservations where the end date and time are before the current time
  //   final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('parkingReserve')
  //       .where('endDate', isLessThan: now.toIso8601String())
  //       .get();
  //
  //   // Iterate over the query snapshot and prompt the user before deleting each expired reservation
  //   for (QueryDocumentSnapshot doc in querySnapshot.docs) {
  //     bool? deleteConfirmed = await _showDeleteConfirmationDialog(context,"Your Reservation time has been exceeded.Do you prefer to clear the reservation spot?");
  //     if (deleteConfirmed ?? false) {
  //       await doc.reference.delete();
  //     }
  //   }
  // }
  // static Future<bool?> _showDeleteConfirmationDialog(
  //     BuildContext context, String message) async {
  //   return await showDialog<bool>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Confirm To Clear Reservation"),
  //         content: Text(message),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(false); //not delete
  //             },
  //             child: const Text("No"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(true); // Yes, delete
  //             },
  //             child: const Text("Yes"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  static Future<void> clearExpiredReservations(BuildContext context) async {
    final now = DateTime.now();

    // Query for reservations where the end date and time are before the current time
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('parkingReserve')
        .where('endDate', isLessThan: now.toIso8601String())
        .get();

    // Iterate over the query snapshot and add late charges to each expired reservation
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      final reservationData = doc.data() as Map<String, dynamic>;
      final String areaId = reservationData['areaId'];
      final Timestamp endDateTimestamp = reservationData['endDate'];
      final DateTime endDate = endDateTimestamp.toDate();

      final parkingSpotDoc = await FirebaseFirestore.instance
          .collection('parkingSpot')
          .doc(areaId)
          .get();

      if (parkingSpotDoc.exists) {
        final parkingSpotData = parkingSpotDoc.data() as Map<String, dynamic>;
        final lateChargeRate = parkingSpotData['price'];
        final lateChargeAmount = calculateLateCharge(now, endDate, lateChargeRate);

        // Update reservation document to include late charge amount
        await doc.reference.update({
          'lateCharge': lateChargeAmount,
          'lateChargeRate': lateChargeRate,
        });

        // Display popup message to user about late payment
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your parking time has exceeded. Late payment will apply now.'),
          ),
        );
      }
    }
  }

  // Function to calculate late charge based on current time, end time, and late charge rate
  static double calculateLateCharge(DateTime currentTime, DateTime endTime, double lateChargeRate) {
    final lateHours = currentTime.difference(endTime).inHours;
    return lateHours * lateChargeRate;
  }
}






  // static Future<String?> getAreaIdForLocation(String documentId) async {
  //   final snapshot = await _firestore.collection('parkingSpot').doc(documentId).get();
  //   if (snapshot.exists) {
  //     return snapshot.get('areaId') as String?;
  //   } else {
  //     return null;
  //   }
  // }


// class AuthController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Method to authenticate user using Firebase Authentication
//   Future<bool> authenticateUser(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential.user != null;
//     } catch (e) {
//       print("Error authenticating user: $e");
//       return false;
//     }
//   }
//
//   // Method to get user role from Firestore
//   Future<String?> getUserRole(String email) async {
//     try {
//       DocumentSnapshot userSnapshot = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get()
//           .then((value) => value.docs.first);
//
//       return userSnapshot.get('userRole');
//     } catch (e) {
//       print("Error getting user role: $e");
//       return null;
//     }
//   }
// }
