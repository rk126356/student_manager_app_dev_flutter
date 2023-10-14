import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/utils/send_bill_whatsapp.dart';
import 'package:student_manager_app_dev_flutter/utils/send_whatsapp_reminder.dart';

class EditPaymentsScreen extends StatefulWidget {
  final String studentId;
  final String billDate;
  final String userId;
  final String studentName;

  EditPaymentsScreen({
    required this.studentId,
    required this.billDate,
    required this.userId,
    required this.studentName,
  });

  @override
  _EditPaymentsScreenState createState() => _EditPaymentsScreenState();
}

class _EditPaymentsScreenState extends State<EditPaymentsScreen> {
  String? paidDate;
  bool isPaid = false;

  String studentPhoneNumber = '';
  int chargePerMonth = 0;

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
          chargePerMonth = paymentData['chargePerMonth'];
          studentPhoneNumber = paymentData['studentPhoneNumber'];
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
          title: const Text('Delete Payment'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this payment?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deletePayment();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currency = Provider.of<UserProvider>(context).currency;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment Status'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Student Name: ${widget.studentName}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Amount: $currency$chargePerMonth",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPaid ? Colors.green : Colors.red,
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
                  isPaid ? Icons.check : Icons.cancel,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPaid ? 'Payment Received' : 'Payment Not Received',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Switch(
              value: isPaid,
              onChanged: (newValue) {
                updatePaymentStatus(newValue);
              },
              activeColor: Colors.green,
              inactiveTrackColor: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              "Bill Date: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(widget.billDate))}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            if (paidDate != null)
              Text(
                "Paid Date: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(paidDate!))}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            if (isPaid)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  sendWhatsappBill(
                    studentName: widget.studentName,
                    studentPhoneNumber: studentPhoneNumber,
                    formattedNextBillDate: DateFormat('dd MMMM yyyy')
                        .format(DateTime.parse(paidDate!)),
                    chargePerMonth: chargePerMonth.toString(),
                  );
                },
                child: const Text('Send Payment Bill WhatsApp'),
              ),
            if (!isPaid)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  sendWhatsAppReminder(
                    studentName: widget.studentName,
                    studentPhoneNumber: studentPhoneNumber,
                    formattedNextBillDate: DateFormat('dd MMMM yyyy')
                        .format(DateTime.parse(widget.billDate)),
                    chargePerMonth: chargePerMonth.toString(),
                  );
                },
                child: const Text('Send Reminder WhatsApp'),
              ),
            ElevatedButton(
              onPressed: () {
                showDeleteConfirmationDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
