import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class UpcomingPaymentsTodayTab extends StatelessWidget {
  const UpcomingPaymentsTodayTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No upcoming payments.'));
        }

        final currentDate = DateTime.now();
        final currentMonth = currentDate.month;
        final currentYear = currentDate.year;
        final firstDayOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
        final sevenDaysFromNow = currentDate.add(Duration(days: 1));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final paymentData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            final nextBillDate = paymentData['nextBillDate'];

            // Check if the nextBillDate is within the next 7 days
            if (nextBillDate != null &&
                nextBillDate is String &&
                DateFormat('dd/MM/yy')
                    .parse(nextBillDate)
                    .isAfter(firstDayOfCurrentMonth) &&
                DateFormat('dd/MM/yy')
                    .parse(nextBillDate)
                    .isBefore(sevenDaysFromNow)) {
              final studentName = paymentData['studentName'];
              final studentBatch = paymentData['studentBatch'];
              final chargePerMonth = paymentData['chargePerMonth'];

              // Format the nextBillDate to the desired format
              final formattedNextBillDate = DateFormat('MMM dd, yyyy').format(
                DateFormat('dd/MM/yy').parse(nextBillDate),
              );

              return ListTile(
                title: Text('$studentName - Batch: $studentBatch'),
                subtitle: Text(
                    'Charge: $chargePerMonth - Date: $formattedNextBillDate'),
                // Add more payment details as needed
              );
            } else {
              // Skip payments with nextBillDate outside of the 7-day window
              return SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
