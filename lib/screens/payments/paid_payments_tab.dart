import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class PaidPaymentsTab extends StatelessWidget {
  const PaidPaymentsTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    // Reference to the Firestore collection where payments are stored
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    return StreamBuilder<QuerySnapshot>(
      // Stream to listen for changes in the payments collection
      stream: paymentsCollection
          .where('isPaid', isEqualTo: true) // Filter only paid payments
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for data, show a loading indicator
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // If there's an error, display an error message
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // If there are no paid payments, display a message
          return Center(child: Text('No paid payments available.'));
        }

        // If data is available, build a list of paid payment items
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // Extract payment data from the snapshot
            final paymentData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            // Customize the display of payment data here
            final studentName = paymentData['studentName'];
            final studentBatch = paymentData['studentBatch'];
            final chargePerMonth = paymentData['chargePerMonth'];
            final paymentDate = paymentData['billDate'];

            // Parse the Firestore date string to a DateTime
            final formattedDate = DateTime.parse(paymentDate);

            // Format the DateTime using a desired date format
            final formattedDateString =
                DateFormat('MMM dd, yyyy').format(formattedDate);

            return ListTile(
              title: Text('$studentName - Batch: $studentBatch'),
              subtitle:
                  Text('Charge: $chargePerMonth - Date: $formattedDateString'),
              // Add more payment details as needed
            );
          },
        );
      },
    );
  }
}
