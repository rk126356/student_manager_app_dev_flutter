import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/utils/send_whatsapp_reminder.dart';

class InsideUpcomingPaymentsScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const InsideUpcomingPaymentsScreen({
    required this.paymentData,
  }) : super();

  @override
  _InsideUpcomingPaymentsScreenState createState() =>
      _InsideUpcomingPaymentsScreenState();
}

class _InsideUpcomingPaymentsScreenState
    extends State<InsideUpcomingPaymentsScreen> {
  late DateTime nextBillDate;

  @override
  void initState() {
    super.initState();
    nextBillDate = widget.paymentData['nextBillDate'] != null
        ? DateFormat('dd/MM/yy').parse(widget.paymentData['nextBillDate'])
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.paymentData['studentName'];
    final studentBatch = widget.paymentData['studentBatch'];
    final chargePerMonth = widget.paymentData['chargePerMonth'];
    final imageUrl = widget.paymentData['studentImageURL'];
    final studentId = widget.paymentData['studentId'];
    final phoneNumber = widget.paymentData['studentPhoneNumber'];

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    void _showDatePicker() async {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: nextBillDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 1),
      );

      if (selectedDate != null) {
        setState(() {
          nextBillDate = selectedDate;
        });

        // Update the nextBillDate in Firebase Firestore
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final paymentDocumentReference = firestore
            .collection('users')
            .doc(user.uid) // Replace with the actual user ID
            .collection('students')
            .doc(studentId); // Replace with the actual student document ID

        final DateTime newLastBillDate =
            nextBillDate.subtract(const Duration(days: 30));

        await paymentDocumentReference.update({
          'nextBillDate': DateFormat('dd/MM/yyyy').format(selectedDate!),
          'lastBillDate': DateFormat('dd/MM/yyyy').format(newLastBillDate!),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Next bill date updated successfully!'),
          ),
        );
      }
    }

    final formattedNextBillDate =
        DateFormat('MMM dd, yyyy').format(nextBillDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Name: $studentName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Batch: $studentBatch',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Next Bill Date: $formattedNextBillDate',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Phone Number: $phoneNumber',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.blue,
              //     onPrimary: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   onPressed: () => _showDatePicker(),
              //   child: const Text('Edit Next Bill Date'),
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  sendWhatsAppReminder(
                    studentName: studentName,
                    studentPhoneNumber: phoneNumber,
                    formattedNextBillDate: formattedNextBillDate,
                    chargePerMonth: chargePerMonth.toString(),
                  );
                },
                child: const Text('Send Reminder WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
