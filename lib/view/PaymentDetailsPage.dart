import 'package:easypark/view/PaymentScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark/view/reservationDialog.dart';

//ReservationDialog reservationDialog = ReservationDialog(spotIndex: spotIndex, areaId: areaId);

class PaymentDetailsPage extends StatelessWidget {
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;
  final String areaId;
  final String reservationId;
  final String vehicleType;
  final int spotIndex;

  const PaymentDetailsPage({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.areaId,
     required this.reservationId,
    required this.vehicleType,
    required this.spotIndex,
  });

  @override
  Widget build(BuildContext context) {
    print('Area ID: $areaId');
    print('Start Date: $startDate');
    print('Start Time: $startTime');
    print('End Date: $endDate');
    print('End Time: $endTime');
    print('Area ID: $areaId');
    print('Reservation ID: $reservationId');
    print('Vehicle Type: $vehicleType');
    print('Spot Index: $spotIndex');

    return FutureBuilder<Map<String, double>>(
      future: _processPayment(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Payment Details'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Payment Details'),
            ),
            body: Center(
              child: Text('Error processing payment: ${snapshot.error}'),
            ),
          );
        } else {
          final parkingCost = snapshot.data!['parkingCost'];
          final totalCost = snapshot.data!['totalCost'];
          final totalParkingHours = snapshot.data!['totalParkingHours'];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Payment Details'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Reservation Charge: Rs. 100.00',
                      style: TextStyle(fontSize: 20),),
                  // Assuming reservation charge is 0 for now
                  const SizedBox(height: 25),
                  Text('Parking Duration: ${_formatDuration(totalParkingHours!)}',
                      style: const TextStyle(fontSize: 20),),
                  const SizedBox(height: 25),
                  Text('Parking Cost: Rs. $parkingCost.00',
                      style: const TextStyle(fontSize: 20),),
                  const SizedBox(height: 25),
                  Text('Total Cost: Rs. $totalCost.00',
                      style: const TextStyle(fontSize: 20),),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            reservationId: reservationId,
                            startDate: startDate,
                            startTime: startTime,
                            endDate: endDate,
                            endTime: endTime,
                            areaId: areaId,
                            vehicleType: vehicleType,
                            spotIndex: spotIndex,
                            totalCost: totalCost!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Change button color here
                    ),
                    child: const Text('PAY',
                      style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String _formatDuration(double hours) {
    final int roundedHours = hours.floor();
    final int minutes = ((hours - roundedHours) * 60).round();
    return '$roundedHours hours $minutes minutes';
  }

  Future<Map<String, double>> _processPayment() async {
    try {
      // Step 1: Query the parkingSpot collection to retrieve the price per hour
      final parkingSpotSnapshot = await FirebaseFirestore.instance
          .collection('parkingSpot')
          .where('areaId', isEqualTo: areaId)
          .limit(1)
          .get();

      if (parkingSpotSnapshot.docs.isNotEmpty) {
        final pricePerHourString = parkingSpotSnapshot.docs.first['Price'] as String;
        print('Price per hour string: $pricePerHourString');
        final pricePerHour = double.parse(pricePerHourString);

        // Step 2: Calculate total parking hours
        final startDateTime = DateTime(
            startDate.year, startDate.month, startDate.day, startTime.hour,
            startTime.minute);
        final endDateTime = DateTime(
            endDate.year, endDate.month, endDate.day, endTime.hour,
            endTime.minute);
        print('Start parking date and time: $startDateTime');
        print('End parking date and time: $endDateTime');
        final totalParkingHours = endDateTime
            .difference(startDateTime)
            .inHours
            .toDouble();
        print('Total parking hours: $totalParkingHours');

        // Step 3: Calculate parking cost
        final parkingCost = totalParkingHours * pricePerHour;
        print('Total parking cost : $parkingCost');

        // Step 4: Calculate total cost
        final totalCost = parkingCost + 100; // For now, assume reservation charge is 0

        return {
          'parkingCost': parkingCost,
          'totalCost': totalCost,
          'totalParkingHours': totalParkingHours,
        };
      } else {
        print('Price per hour not found for the selected area.');
        throw Exception('Price per hour not found for the selected area.');
      }
    } catch (e) {
      print('Error processing payment: $e');
      throw e;
    }
  }
}


