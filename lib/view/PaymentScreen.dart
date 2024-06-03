import 'package:easypark/view/QrCodePage.dart';
import 'package:easypark/view/home_screen.dart';
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
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage()));
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
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Select Card Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: RadioListTile(
                        title: const Text('Visa'),
                        value: "Visa",
                        groupValue: _cardType,
                        onChanged: _onCardTypeSelected,
                        activeColor: Colors.teal,
                      ),
                    ),
                    Flexible(
                      child: RadioListTile(
                        title: const Text('MasterCard'),
                        value: "MasterCard",
                        groupValue: _cardType,
                        onChanged: _onCardTypeSelected,
                        activeColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
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
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Month (MM)',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
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
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Year (YYYY)',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
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
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveReservation();
                        _formKey.currentState!.reset();
                      }
                    },
                    child: const Text('Proceed to Pay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
