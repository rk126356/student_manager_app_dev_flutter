import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';

class UnpaidPaymentsTab extends StatelessWidget {
  const UnpaidPaymentsTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection
          .where('isPaid', isEqualTo: false) // Filter only paid payments
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
          return const Center(child: Text('No paid payments available.'));
        }

        // Extract and group payments by months
        final paymentsByMonth = groupPaymentsByMonth(snapshot.data!.docs);

        return ListView.builder(
          itemCount: paymentsByMonth.length,
          itemBuilder: (context, index) {
            final monthYear = paymentsByMonth.keys.elementAt(index);
            final payments = paymentsByMonth[monthYear];

            return Column(
              children: payments!.map((paymentData) {
                final studentName = paymentData['studentName'];
                final studentBatch = paymentData['studentBatch'];
                final chargePerMonth = paymentData['chargePerMonth'];
                final paymentDateString = paymentData['billDate'];
                final formattedDate = DateFormat('MMM dd, yyyy')
                    .format(DateTime.parse(paymentDateString));

                return Card(
                  color: Colors.red, // You can customize the color
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.cancel, color: Colors.white),
                    title: Text(
                      '$studentName - Batch: $studentBatch',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Fee: $chargePerMonth | Bill Date: $formattedDate',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    trailing:
                        const Icon(Icons.arrow_right, color: Colors.white),
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
              }).toList(),
            );
          },
        );
      },
    );
  }

  Map<String, List<DocumentSnapshot>> groupPaymentsByMonth(
      List<DocumentSnapshot> payments) {
    Map<String, List<DocumentSnapshot>> groupedPayments = {};

    for (DocumentSnapshot payment in payments) {
      final paymentData = payment.data() as Map<String, dynamic>;
      final paymentDate = paymentData['billDate'];
      final monthYear =
          DateFormat('MMM yyyy').format(DateTime.parse(paymentDate));

      if (!groupedPayments.containsKey(monthYear)) {
        groupedPayments[monthYear] = [];
      }

      groupedPayments[monthYear]!.add(payment);
    }

    return groupedPayments;
  }
}
