import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditPaymentsScreen extends StatefulWidget {
  final String studentId;
  final String billDate;
  final String userId;

  EditPaymentsScreen({
    required this.studentId,
    required this.billDate,
    required this.userId,
  });

  @override
  _EditPaymentsScreenState createState() => _EditPaymentsScreenState();
}

class _EditPaymentsScreenState extends State<EditPaymentsScreen> {
  String? paidDate; // To store the paid date
  bool isPaid = false; // To store the paid date

  @override
  void initState() {
    super.initState();
    fetchIsPaidStatus();
  }

  Future<void> fetchIsPaidStatus() async {
    try {
      final paymentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payments')
          .where('studentId', isEqualTo: widget.studentId)
          .where('billDate', isEqualTo: widget.billDate)
          .get();

      if (paymentDoc.docs.isNotEmpty) {
        final paymentData = paymentDoc.docs.first.data();
        print(paymentData);

        setState(() {
          isPaid = paymentData['isPaid'];
          final paidDateTimestamp = paymentData['paidDate'] as Timestamp?;
          if (paidDateTimestamp != null) {
            paidDate = paidDateTimestamp.toDate().toString();
          } else {
            paidDate = null;
          }
        });
      }
    } catch (error) {
      print('Error fetching payment status: $error');
    }
  }

  Future<void> updatePaymentStatus(bool newStatus) async {
    try {
      final paymentCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payments');

      if (newStatus) {
        // If marking as paid, add 'paidDate'
        final Timestamp timestamp = Timestamp.now();

        await paymentCollection
            .where('studentId', isEqualTo: widget.studentId)
            .where('billDate', isEqualTo: widget.billDate)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            doc.reference.update({'isPaid': true, 'paidDate': timestamp});
          });
        });

        setState(() {
          isPaid = true;
          paidDate = timestamp.toDate().toString();
        });
      } else {
        // If marking as unpaid, remove 'paidDate'
        await paymentCollection
            .where('studentId', isEqualTo: widget.studentId)
            .where('billDate', isEqualTo: widget.billDate)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            doc.reference.update({'isPaid': false, 'paidDate': null});
          });
        });

        setState(() {
          isPaid = false;
          paidDate = null;
        });
      }
    } catch (error) {
      print('Error updating payment status: $error');
    }
  }

  Future<void> deletePayment() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payments')
          .where('studentId', isEqualTo: widget.studentId)
          .where('billDate', isEqualTo: widget.billDate)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // After successful deletion, you can navigate back to the previous screen
      Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting payment: $error');
    }
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Payment'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this payment?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                deletePayment();
                Navigator.of(context).pop(); // Close the dialog
              },
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
        title: const Text('Edit Payment Status'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150, // Adjust the width as needed
              height: 150, // Adjust the height as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPaid! ? Colors.green : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isPaid! ? Icons.check : Icons.cancel,
                  color: Colors.white,
                  size: 64, // Adjust the icon size as needed
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPaid! ? 'Payment Received' : 'Payment Not Received',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isPaid! ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Switch(
              value: isPaid!,
              onChanged: (newValue) {
                updatePaymentStatus(newValue);
              },
              activeColor: Colors.green, // Color when the switch is on
              inactiveTrackColor: Colors.red
                  .withOpacity(0.5), // Track color when the switch is off
            ),
            const SizedBox(height: 20),
            Text(
              paidDate != null
                  ? "Paid Date: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(paidDate.toString()))}"
                  : "Dill Date: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(widget.billDate.toString()))}",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back when pressed
              },
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDeleteConfirmationDialog();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Set the button background color to red
              ),
              child: const Text(
                'Delete This Payment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
