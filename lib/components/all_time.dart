import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/widgets/Dashboard_board_widget.dart';

class AllTime extends StatelessWidget {
  const AllTime({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Calculate the total paid amount for all time
        double totalPaidAmount = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data!.docs;
          for (var doc in documents) {
            final isPaid = doc['isPaid'];
            final amount = doc['chargePerMonth'];
            if (isPaid) {
              totalPaidAmount += amount;
            }
          }
        }

        // Calculate the total number of paid fees for all time
        int totalPaidFees = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data!.docs;
          for (var doc in documents) {
            final isPaid = doc['isPaid'] as bool;
            if (isPaid) {
              totalPaidFees++;
            }
          }
        }

        // Calculate the total unpaid amount for all time
        double totalUnpaidAmount = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data!.docs;
          for (var doc in documents) {
            final isPaid = doc['isPaid'];
            final amount = doc['chargePerMonth'];
            if (!isPaid) {
              totalUnpaidAmount += amount;
            }
          }
        }

        // Calculate the total number of unpaid fees for all time
        int totalUnpaidFees = 0;
        if (snapshot.hasData) {
          final documents = snapshot.data!.docs;
          for (var doc in documents) {
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
                    value: '₹${totalPaidAmount.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: DashboardBox(
                    title: 'Unpaid',
                    value: '₹${totalUnpaidAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
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
