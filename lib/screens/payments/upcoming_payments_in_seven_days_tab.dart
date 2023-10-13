import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class UpcomingPaymentsSevenDaysTab extends StatelessWidget {
  const UpcomingPaymentsSevenDaysTab({Key? key});

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
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No upcoming payments.'));
        }

        final currentDate = DateTime.now();
        final sevenDaysFromNow = currentDate.add(const Duration(days: 7));

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
                    .isBefore(sevenDaysFromNow)) {
              final studentName = paymentData['studentName'];
              final studentBatch = paymentData['studentBatch'];
              final chargePerMonth = paymentData['chargePerMonth'];
              final imageUrl = paymentData['studentImageURL'];

              // Format the nextBillDate to the desired format
              final formattedNextBillDate = DateFormat('MMM dd, yyyy').format(
                DateFormat('dd/MM/yy').parse(nextBillDate),
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CachedNetworkImage(
                    width: 60,
                    height: 60,
                    imageUrl: imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape:
                            BoxShape.circle, // Makes it a circle (Avatar-like)
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Fee: ₹$chargePerMonth - Bill Date: $formattedNextBillDate',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  // Add more payment details as needed
                ),
              );
            } else {
              // Skip payments with nextBillDate outside of the 7-day window
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
