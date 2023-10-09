import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomePaidTab extends StatelessWidget {
  const HomePaidTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection
          .where('isPaid', isEqualTo: true) // Filter only paid payments
          .orderBy('billDate',
              descending: true) // Sort payments by date in descending order
          .limit(20) // Limit the results to 20 payments
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No paid payments available.'));
        }

        final paidPayments = <Widget>[];

        for (final paymentDocument in snapshot.data!.docs) {
          final paymentData = paymentDocument.data() as Map<String, dynamic>;

          final studentName = paymentData['studentName'];
          final studentBatch = paymentData['studentBatch'];
          final chargePerMonth = paymentData['chargePerMonth'];
          final paymentDateString = paymentData['billDate'];
          final formattedDate = DateFormat('MMM dd, yyyy')
              .format(DateTime.parse(paymentDateString));

          final paidPaymentTile = MyListTile(
            title: studentName,
            subtitle: 'Paid ₹$chargePerMonth | $formattedDate',
            onTap: () {
              // Handle onTap for each paid payment if needed
            },
          );

          paidPayments.add(paidPaymentTile);
        }

        if (paidPayments.isEmpty) {
          return Center(child: Text('No paid payments available.'));
        }

        return Column(
          children: paidPayments,
        );
      },
    );
  }
}
