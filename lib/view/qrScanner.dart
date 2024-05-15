import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              // Set height and width
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Handle scanned QR code data
      _handleQRCodeData(scanData.code);
    });
  }

  void _handleQRCodeData(String? qrData) async {
    if (qrData != null) {
      // Fetch reservation data from Firebase using the reservation ID
      try {
        DocumentSnapshot reservationSnapshot = await FirebaseFirestore.instance
            .collection('reservations') // Change 'reservations' to your Firestore collection name
            .doc(qrData) // Assuming reservation ID is the document ID
            .get();

        if (reservationSnapshot.exists) {
          // Reservation found, extract data and update UI
          Map<String, dynamic> reservationData = reservationSnapshot.data() as Map<String, dynamic>;
          // Update UI with reservation data, e.g., show user details, parking spot information, etc.
          print('Reservation Data: $reservationData');
        } else {
          // Reservation not found for the scanned QR code
          print('No reservation found for QR code: $qrData');
        }
      } catch (e) {
        // Error fetching reservation data
        print('Error fetching reservation data: $e');
      }
    } else {
      // Handle case when qrData is null
      print('QR data is null');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: QRCodeScannerPage(),
  ));
}
