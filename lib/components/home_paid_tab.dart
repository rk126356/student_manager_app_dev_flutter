import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';
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
          .limit(15) // Limit the results to 15 payments
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

          final paidPaymentTile = Card(
            color: Colors.green, // You can customize the color
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CachedNetworkImage(
                width: 60,
                height: 60,
                imageUrl: paymentData['studentImageUrl'],
                imageBuilder: (context, imageProvider) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Makes it a circle (Avatar-like)
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover, // You can use other BoxFit values
                    ),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
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
              trailing: const Icon(Icons.arrow_right, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPaymentsScreen(
                        studentId: paymentData['studentId'],
                        studentName: paymentData['studentName'],
                        billDate: paymentData['billDate'],
                        userId: user.uid!),
                  ),
                );
              },
            ),
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
