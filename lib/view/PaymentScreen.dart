import 'package:easypark/view/QrCodePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark/view/ReservationDialog.dart';

class PaymentScreen extends StatefulWidget {
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;
  final String areaId;
  final String reservationId;
  final String vehicleType;
  final int spotIndex;
  final double totalCost;

  const PaymentScreen({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.areaId,
    required this.reservationId,
    required this.vehicleType,
    required this.spotIndex,
    required this.totalCost,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _cardType = ""; // Track selected card type (Visa/MasterCard)
  String _cardHolderName = "";
  String _cardNumber = "";
  String _expiryMonth = "";
  String _expiryYear = "";
  String _cvv = "";
  String _amount = "";

  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void initState() {
    super.initState();
    // Hard code card details
    _cardHolderName = "Jashitha Rashmitha";
    _cardNumber = "1234567890123456";
    _expiryMonth = "12";
    _expiryYear = "2024";
    _cvv = "123";
    _amount = (widget.totalCost).toString();
  }

  void _onCardTypeSelected(String? type) {
    if (type != null) {
      setState(() => _cardType = type);
    }
  }

  Future<void> saveReservation() async {
    final reservation = {
      'startDate': widget.startDate.toIso8601String(), // Convert DateTime to ISO 8601 string
      'startTime': _formatTimeOfDay(widget.startTime), // Convert TimeOfDay to string
      'endDate': widget.endDate.toIso8601String(),
      'endTime': _formatTimeOfDay(widget.endTime),
      'areaId': widget.areaId,
      'reservationId': widget.reservationId,
      'vehicleType': widget.vehicleType,
      'spotIndex': widget.spotIndex,
      'totalCost': widget.totalCost,
      'Paid': true,
    };

    try {
      final reservationRef = FirebaseFirestore.instance.collection('parkingReserve').doc();
      await reservationRef.set({
        ...reservation,
        'reservationId': reservationRef.id,
      });
      print('Reservation saved successfully with ID: ${reservationRef.id}');

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Reservation saved successfully.'),
      //   ),
      // );
      _showQRCodeDialog(reservation);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reservation: $e'),
        ),
      );
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    // Format TimeOfDay as HH:MM AM/PM
    final hours = timeOfDay.hourOfPeriod.toString().padLeft(2, '0');
    final minutes = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hours:$minutes $period';
  }

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
              Navigator.of(context).popUntil((route) => route.isFirst);
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

  void _navigateToQRDisplayPage(Map<String, dynamic> reservationData) { // Accept reservationData as Map
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRDisplayPage(reservationData: reservationData), // Pass reservationData
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Card type selection using RadioListTile for better UX
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 150, // Adjust width as needed
                  child: RadioListTile(
                    title: const Text('Visa'),
                    value: "Visa",
                    groupValue: _cardType,
                    onChanged: _onCardTypeSelected,
                  ),
                ),
                SizedBox(
                  width: 150, // Adjust width as needed
                  child: RadioListTile(
                    title: const Text('MasterCard'),
                    value: "MasterCard",
                    groupValue: _cardType,
                    onChanged: _onCardTypeSelected,
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Card Holder Name',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
              onSaved: (value) => _cardHolderName = value!,
              initialValue: _cardHolderName,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter card number';
                }
                // Add more robust validation based on card type (e.g., length)
                return null;
              },
              onSaved: (value) => _cardNumber = value!,
              initialValue: _cardNumber,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Month (MM)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter expiry month';
                      }
                      int month = int.tryParse(value) ?? 0;
                      if (month < 1 || month > 12) {
                        return 'Invalid month (1-12)';
                      }
                      return null;
                    },
                    onSaved: (value) => _expiryMonth = value!,
                    initialValue: _expiryMonth,
                    maxLength: 2,
                  ),
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Year (YYYY)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter expiry year';
                      }
                      int year = int.tryParse(value) ?? 0;
                      if (year < DateTime.now().year) {
                        return 'Invalid year (must be future)';
                      }
                      return null;
                    },
                    onSaved: (value) => _expiryYear = value!,
                    initialValue: _expiryYear,
                    maxLength: 4,
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'CVV',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter CVV';
                }
                // Add more robust validation based on card type (e.g., length)
                return null;
              },
              onSaved: (value) => _cvv = value!,
              initialValue: _cvv,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter amount';
                }
                // Add more validation if required
                return null;
              },
              onSaved: (value) => _amount = value!,
              initialValue: _amount, // Set initial value
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // if (_formKey.currentState!.validate()) {
                //   // Send payment details to secure payment gateway (simulate here)
                //   // **IMPORTANT: Never store sensitive card information directly!**
                //   // Use a secure payment gateway or service for tokenization/encryption.
                //   print("Payment details (for simulation only, do not store!): "
                //       "$_cardType, $_cardHolderName, $_cardNumber, $_expiryMonth/$_expiryYear, $_cvv");
                //   // Show success or error message based on gateway response (simulated)
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text(
                //         'Payment processing simulated. Please check gateway response.',
                //       ),
                //     ),
                //   );
                // }

                  if (_formKey.currentState!.validate()) {
                    saveReservation();
                    _formKey.currentState!.reset();
                  }
                },
              child: const Text('Proceed to Pay'),
            ),
          ],
        ),
      ),
    );
  }
}

// void main() {
//   runApp(const MaterialApp(
//     home: PaymentScreen(),
//   ));
// }
