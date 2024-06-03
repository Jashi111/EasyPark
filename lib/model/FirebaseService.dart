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
      final data = doc.data();
      if (data == null || !data.containsKey('Location')) {
        print('Document ${doc.id} does not contain "Location" field or is null');
        return null;  // Skip this document
      }

      final locationString = data['Location'] as String?;
      if (locationString == null) {
        print('Location field in document ${doc.id} is null');
        return null;  // Skip this document
      }

      final latLngStrings = locationString.split(', ');
      if (latLngStrings.length != 2) {
        print('Invalid Location format in document ${doc.id}');
        return null;  // Skip this document
      }

      final latitude = double.tryParse(latLngStrings[0]);
      final longitude = double.tryParse(latLngStrings[1]);
      if (latitude == null || longitude == null) {
        print('Invalid latitude or longitude in document ${doc.id}');
        return null;  // Skip this document
      }

      return LatLng(latitude, longitude);
    }).whereType<LatLng>().toList();  // Filter out null values
  }

  static Future<void> clearExpiredReservations(BuildContext context) async {
    final now = DateTime.now();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('parkingReserve')
        .where('endDate', isLessThan: now.toIso8601String())
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      final reservationData = doc.data() as Map<String, dynamic>;
      final String? areaId = reservationData['areaId'] as String?;
      final Timestamp? endDateTimestamp = reservationData['endDate'] as Timestamp?;

      if (areaId == null || endDateTimestamp == null) {
        print('Missing areaId or endDate in reservation document ${doc.id}');
        continue;  // Skip this document
      }

      final DateTime endDate = endDateTimestamp.toDate();
      final parkingSpotDoc = await FirebaseFirestore.instance
          .collection('parkingSpot')
          .doc(areaId)
          .get();

      if (!parkingSpotDoc.exists) {
        print('Parking spot document ${areaId} does not exist');
        continue;  // Skip this document
      }

      final parkingSpotData = parkingSpotDoc.data() as Map<String, dynamic>;
      final double? lateChargeRate = parkingSpotData['price'] as double?;

      if (lateChargeRate == null) {
        print('Missing price in parking spot document ${areaId}');
        continue;  // Skip this document
      }

      final lateChargeAmount = calculateLateCharge(now, endDate, lateChargeRate);

      await doc.reference.update({
        'lateCharge': lateChargeAmount,
        'lateChargeRate': lateChargeRate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your parking time has exceeded. Late payment will apply now.'),
        ),
      );
    }
  }

  static double calculateLateCharge(DateTime currentTime, DateTime endTime, double lateChargeRate) {
    final lateHours = currentTime.difference(endTime).inHours;
    return lateHours * lateChargeRate;
  }
}
