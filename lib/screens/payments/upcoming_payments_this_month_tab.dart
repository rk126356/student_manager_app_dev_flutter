import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class UpcomingPaymentsThisMonthTab extends StatelessWidget {
  const UpcomingPaymentsThisMonthTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection
          .orderBy('nextBillDate',
              descending: false) // Sort payments by date in ascending order
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No upcoming payments for this month.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final paymentData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            final studentName = paymentData['studentName'];
            final studentBatch = paymentData['studentBatch'];
            final chargePerMonth = paymentData['chargePerMonth'];
            final nextBillDate = paymentData['nextBillDate'];

            // Convert the nextBillDate string to a DateTime object
            final nextBillDateTime = DateFormat('dd/MM/yy').parse(nextBillDate);

            // Format the nextBillDate to the desired format
            final formattedNextBillDate =
                DateFormat('MMM dd, yyyy').format(nextBillDateTime);

            return ListTile(
              title: Text('$studentName - Batch: $studentBatch'),
              subtitle: Text(
                  'Charge: $chargePerMonth - Date: $formattedNextBillDate'),
              // Add more payment details as needed
            );
          },
        );
      },
    );
  }
}
