import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date parsing
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/widgets/Dashboard_board_widget.dart';

class ThisMonth extends StatelessWidget {
  const ThisMonth({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var currency = Provider.of<UserProvider>(context).currency;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    // Get the start and end date for the current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection
          .where('billDate',
              isGreaterThanOrEqualTo: firstDayOfMonth.toUtc().toIso8601String())
          .where('billDate',
              isLessThanOrEqualTo: lastDayOfMonth.toUtc().toIso8601String())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Display loading indicator while data is loading.
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Calculate the total paid amount
        double totalPaidAmount = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data?.docs;
          for (var doc in documents!) {
            final isPaid = doc['isPaid'] as bool;
            final amount = doc['chargePerMonth'];
            if (isPaid) {
              totalPaidAmount += amount;
            }
          }
        }

        // Calculate the total number of paid fees
        int totalPaidFees = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data?.docs;
          for (var doc in documents!) {
            final isPaid = doc['isPaid'] as bool;
            if (isPaid) {
              totalPaidFees++;
            }
          }
        }

        // Calculate the total unpaid amount
        double totalUnpaidAmount = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data?.docs;
          for (var doc in documents!) {
            final isPaid = doc['isPaid'] as bool;
            final amount = doc['chargePerMonth'];
            if (!isPaid) {
              totalUnpaidAmount += amount;
            }
          }
        }

        // Calculate the total number of unpaid fees
        int totalUnpaidFees = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data?.docs;
          for (var doc in documents!) {
            final isPaid = doc['isPaid'] as bool;
            if (!isPaid) {
              totalUnpaidFees++;
            }
          }
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DashboardBox(
                    title: 'Paid',
                    value: '$currency${totalPaidAmount.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: DashboardBox(
                    title: 'Unpaid',
                    value: '$currency${totalUnpaidAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DashboardBox(
                    title: 'Fees Paid',
                    value: totalPaidFees.toString(),
                  ),
                ),
                Expanded(
                  child: DashboardBox(
                    title: 'Fees Unpaid',
                    value: totalUnpaidFees.toString(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
