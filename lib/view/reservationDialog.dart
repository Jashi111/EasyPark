import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark/view/QrCodePage.dart';
import 'package:easypark/view/PaymentDetailsPage.dart';


class ReservationDialog extends StatefulWidget {
  final int spotIndex;
  final String areaId;

  const ReservationDialog({super.key, required this.spotIndex, required this.areaId});
  //const ReservationDialog({Key? key, this.spotIndex, this.areaId}) : super(key: key);

  @override
  _ReservationDialogState createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  DateTime endDate = DateTime.now();
  TimeOfDay endTime = TimeOfDay.now();
  bool isSpotReserved = false;
  String selectedVehicleCategory = '';
  List<int> reservedSpots = [];

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (pickedTime != null && pickedTime != startTime) {
      setState(() {
        startTime = pickedTime;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (pickedTime != null && pickedTime != endTime) {
      setState(() {
        endTime = pickedTime;
      });
    }
  }

  // Function to check if a spot is reserved
  Future<void> checkSpotReservation(int spotIndex) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('parkingReserve')
        .where('spotIndex', isEqualTo: spotIndex)
        .get();

    setState(() {
      isSpotReserved = snapshot.docs.isNotEmpty;
      if (isSpotReserved) {
        // If spot is reserved, add it to the reservedSpots list
        reservedSpots.add(spotIndex);
      }
    });
  }


  //
  // Future<void> _saveReservation() async {
  //   final reservation = {
  //     'spotIndex': widget.spotIndex,
  //     'startDate': startDate.toIso8601String(),
  //     'startTime': startTime.format(context),
  //     'endDate': endDate.toIso8601String(),
  //     'endTime': endTime.format(context),
  //     'vehicleType': selectedVehicleCategory,
  //     'areaId': widget.areaId,
  //   };
  //
  //   try {
  //     // Generate a unique ID for the reservation
  //     final reservationRef = FirebaseFirestore.instance.collection('parkingReserve').doc();
  //     // Set the reservation data with the generated ID
  //     await reservationRef.set({...reservation, 'reservationId': reservationRef.id});
  //     print('Reservation saved successfully with ID: ${reservationRef.id}');
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PaymentDetailsPage(
  //           startDate: startDate,
  //           startTime: startTime,
  //           endDate: endDate,
  //           endTime: endTime,
  //           areaId: widget.areaId,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error saving reservation: $e');
  //   }
  // }

  Future<void> _saveReservation() async {
    final reservation = {
      'spotIndex': widget.spotIndex,
      'startDate': startDate.toIso8601String(),
      'startTime': startTime.format(context),
      'endDate': endDate.toIso8601String(),
      'endTime': endTime.format(context),
      'vehicleType': selectedVehicleCategory,
      'areaId': widget.areaId,
    };

    try {
      final reservationRef = FirebaseFirestore.instance.collection('parkingReserve').doc();
      //await reservationRef.set({...reservation, 'reservationId': reservationRef.id});
      //print('Reservation saved successfully with ID: ${reservationRef.id}');

      // Navigate to PaymentDetailsPage and pass reservationId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailsPage(
            reservationId: reservationRef.id,
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            areaId: widget.areaId,
            vehicleType: selectedVehicleCategory,
            spotIndex: widget.spotIndex,
          ),
        ),
      );
    } catch (e) {
      print('Error saving reservation: $e');
    }
  }





  // void _showQRCodeDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Reservation QR Code'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text('Scan the QR code to view reservation details:'),
  //           const SizedBox(height: 20),
  //           QrImageView(
  //             data: '123456789', // Adjust as per your reservation data
  //             version: QrVersions.auto,
  //             size: 200.0,
  //           ),
  //         ],
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(); // Close the dialog
  //           },
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showQRCodeDialog(Map<String, dynamic> reservationData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spot Reservation Successfully!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Click on the QR button to Generate Qr code'),
            SizedBox(height: 20),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Close the reservation dialog
              //_navigateToQRDisplayPage(reservationData); // Navigate to QR display page
            },
            child: const Text('Ok'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              _navigateToQRDisplayPage(reservationData); // Navigate to QR display page
            },
            child: const Text('QR'),
          ),
        ],
      ),
    );
  }

  // void _navigateToQRDisplayPage() {
  //   const String reservationData = '123456789'; // Replace with your reservation data
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const QRDisplayPage(qrData: reservationData),
  //     ),
  //   );
  // }

  void _navigateToQRDisplayPage(Map<String, dynamic> reservationData) { // Accept reservationData as Map
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRDisplayPage(reservationData: reservationData), // Pass reservationData
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reserve Spot ${widget.spotIndex}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Start Date:'),
          TextButton(
            onPressed: () => _selectStartDate(context),
            child: Text(startDate.toIso8601String()),
          ),
          const SizedBox(height: 10),
          const Text('Start Time:'),
          TextButton(
            onPressed: () => _selectStartTime(context),
            child: Text(startTime.format(context)),
          ),
          const Divider(thickness: 1),
          const Text('End Date:'),
          TextButton(
            onPressed: () => _selectEndDate(context),
            child: Text(endDate.toIso8601String()),
          ),
          const SizedBox(height: 10),
          const Text('End Time:'),
          TextButton(
            onPressed: () => _selectEndTime(context),
            child: Text(endTime.format(context)), // Replace with your desired text
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          const Text('Vehicle Category:'),
          // Radio buttons for vehicle categories
          Row(
            children: [
              Radio<String>(
                value: 'light',
                groupValue: selectedVehicleCategory,
                onChanged: (value) {
                  setState(() {
                    selectedVehicleCategory = value!;
                  });
                },
              ),
              const Text('Light'),
              Radio<String>(
                value: 'heavy',
                groupValue: selectedVehicleCategory,
                onChanged: (value) {
                  setState(() {
                    selectedVehicleCategory = value!;
                  });
                },
              ),
              const Text('Heavy'),
              Radio<String>(
                value: 'motorBikes',
                groupValue: selectedVehicleCategory,
                onChanged: (value) {
                  setState(() {
                    selectedVehicleCategory = value!;
                  });
                },
              ),
              const Text('Motorbikes'),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await checkSpotReservation(widget.spotIndex);
            if (!isSpotReserved) {
              //_processPayment();
              _saveReservation();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => PaymentDetailsPage(
              //       startDate: startDate,
              //       startTime: startTime,
              //       endDate: endDate,
              //       endTime: endTime,
              //       areaId: widget.areaId,
              //     ),
              //   ),
              // );
              print('ABCD');
            } else {
              // Show a message indicating that the spot is already reserved
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Spot Already Reserved!'),
                  content: const Text('This spot is already reserved.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(); // Close the reservation dialog
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('Pay'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
