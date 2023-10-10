import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';

class AllPaymentsTab extends StatelessWidget {
  const AllPaymentsTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection
          .orderBy('billDate',
              descending: true) // Sort payments by date in descending order
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No payments available.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final paymentData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final studentName = paymentData['studentName'];
            final studentBatch = paymentData['studentBatch'];
            final chargePerMonth = paymentData['chargePerMonth'];
            final paymentDateString = paymentData['billDate'];
            final isPaid = paymentData[
                'isPaid']; // Assuming you have a field indicating payment status

            final formattedDate = DateFormat('MMM dd, yyyy')
                .format(DateTime.parse(paymentDateString));

            // Set the background color, icon, and text style based on payment status
            final cardColor = isPaid ? Colors.green : Colors.red;
            final icon = isPaid ? Icons.check_circle : Icons.cancel;
            const titleTextStyle = TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            );
            const subtitleTextStyle = TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            );

            return Card(
              color: cardColor,
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Icon(icon, color: Colors.white),
                title: Text(
                  '$studentName - Batch: $studentBatch',
                  style: titleTextStyle,
                ),
                subtitle: Text(
                  'Fee: $chargePerMonth - Due Date: $formattedDate',
                  style: subtitleTextStyle,
                ),
                trailing: const Icon(Icons.arrow_right, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPaymentsScreen(
                          studentId: paymentData['studentId'],
                          billDate: paymentData['billDate'],
                          userId: user.uid!),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
