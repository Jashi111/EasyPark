import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';


class QRDisplayPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  const QRDisplayPage({super.key, required this.reservationData}); // Accept reservationData as Map

  @override
  Widget build(BuildContext context) {
    final String qrData = reservationData.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveQRCode(context, qrData),
              child: const Text('Download QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveQRCode(BuildContext context, String qrData) async {
    try {
      final qrImageData = await _generateQRImageData(qrData);
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(qrImageData),
        quality: 100,
      );
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR Code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Uint8List> _generateQRImageData(String qrData) async {
    // Use QrImageProvider to generate QR code image data
    final qrImageData = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(200); // Change the size as needed
    return qrImageData!.buffer.asUint8List();
  }
}
