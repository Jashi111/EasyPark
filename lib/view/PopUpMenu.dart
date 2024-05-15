import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark/view/reservationDialog.dart';

class PopUpMenu extends StatefulWidget {
  final String? areaId;

  const PopUpMenu({super.key, required this.areaId});

  @override
  _PopUpMenuState createState() => _PopUpMenuState();
}

class _PopUpMenuState extends State<PopUpMenu> {
  int? numberOfSpots;
  bool isLocationClicked = false;
  List<int> reservedSpots = [];

  @override
  void initState() {
    super.initState();
    // Fetch the number of spots from Firebase
    if (widget.areaId != null) {
      _getNumberOfSpots(widget.areaId!); // Use ! to assert that widget.areaId is not null
      _fetchReservedSpots(widget.areaId!);
    }
  }

  // Future<void> _getNumberOfSpots() async {
  //   try {
  //     final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('parkingSpot').get();
  //     final List<int> spotsList = [];
  //
  //     querySnapshot.docs.forEach((doc) {
  //       if (doc.exists) {
  //         int numberOfSpots = doc.get('NumberofSpots');
  //         spotsList.add(numberOfSpots);
  //       }
  //     });
  //
  //     setState(() {
  //       print('Number of spots retrieved from all documents: $spotsList');
  //     });
  //   } catch (e) {
  //     print('Error fetching number of spots: $e');
  //   }
  // }
  // Future<void> _getNumberOfSpots() async {
  //   try {
  //     final DocumentSnapshot snapshot =
  //     await FirebaseFirestore.instance.collection('parkingSpot').doc('numberOfSpots').get(); // document name changed
  //     setState(() {
  //       numberOfSpots = snapshot.exists ? snapshot['numberOfSpots'] : 0; // field name changed
  //     });
  //     print('Number of spots retrieved: $numberOfSpots');
  //   } catch (e) {
  //     print('Error fetching number of spots: $e');
  //   }
  // }

  // Future<void> _getNumberOfSpots() async {
  //   try {
  //     final DocumentSnapshot snapshot =
  //     await FirebaseFirestore.instance.collection('parkingSpot').doc('NumberOfSpots').get();
  //     if (snapshot.exists) {
  //       final int numberOfSpots = snapshot['NumberofSpots'];
  //       setState(() {
  //         print('Number of spots retrieved: $numberOfSpots');
  //       });
  //     } else {
  //       print('Document "numberOfSpots" not found.');
  //     }
  //   } catch (e) {
  //     print('Error fetching number of spots: $e');
  //   }
  // }

  // Future<void> _getNumberOfSpots() async {
  //   try {
  //     const String documentId = '0cwA2I8G7wkpXR7IUJCa'; // Replace with your document ID
  //     final DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('parkingSpot').doc(documentId).get();
  //     setState(() {
  //       numberOfSpots = snapshot.exists ? snapshot['NumberofSpots'] : 0;
  //     });
  //     print('Number of spots retrieved: $numberOfSpots');
  //   } catch (e) {
  //     print('Error fetching number of spots: $e');
  //   }
  // }

  Future<void> _fetchReservedSpots(String areaId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('parkingReserve')
          .where('areaId', isEqualTo: areaId)
          .get();

      setState(() {
        reservedSpots = snapshot.docs.map((doc) => doc['spotIndex']).cast<int>().toList();
      });
    } catch (e) {
      print('Error fetching reserved spots: $e');
    }
  }


  Future<void> _getNumberOfSpots(String areaId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('parkingSpot')
          .where('areaId', isEqualTo: areaId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          numberOfSpots = snapshot.docs.first.get('NumberofSpots');
        });
        print('Number of spots retrieved: $numberOfSpots');
      } else {
        print('Document not found for areaId: $areaId');
      }
    } catch (e) {
      print('Error fetching number of spots: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Reservation'),
      ),
      body: numberOfSpots == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numberOfSpots! >= 3 ? 3 : 1, // Adjust the number of columns based on numberOfSpots
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: numberOfSpots,
        itemBuilder: (context, index) {
          final isReserved = reservedSpots.contains(index + 1);
          final spotText = isReserved ? 'Reserved' : 'Spot ${index + 1}';
          final spotColor = isReserved ? Colors.red : Colors.blue;

          return GestureDetector(
            onTap: () async {
              if (!isReserved) {
                // Show reservation dialog for the selected spot
                final result = await showDialog(
                  context: context,
                  builder: (context) => ReservationDialog(
                    spotIndex: index + 1,
                    areaId: widget.areaId ?? '',
                  ),
                );

                // Handle reservation details (if any) returned by the dialog
                if (result != null) {
                  // Process reservation details (e.g., spotIndex, date, time) from result object
                  print('Reservation details: $result');
                  // Update reserved spots after a successful reservation
                  setState(() {
                    reservedSpots.add(result['spotIndex']);
                  });
                }
              } else {
                // Display a message indicating that the spot is already reserved
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This spot is already reserved.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                color: spotColor, // Change color if spot is reserved
                child: Center(
                  child: Text(
                    spotText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// void main() {
//   runApp(const MaterialApp(
//     home: PopUpMenu(),
//   ));
// }
