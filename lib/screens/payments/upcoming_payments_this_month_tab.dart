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
      stream: paymentsCollection.snapshots(),
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
        final currentMonth = currentDate.month;
        final currentYear = currentDate.year;
        final firstDayOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
        final sevenDaysFromNow = currentDate.add(const Duration(days: 30));

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
              final imageUrl = paymentData['studentImageURL'];

              // Format the nextBillDate to the desired format
              final formattedNextBillDate = DateFormat('MMM dd, yyyy').format(
                DateFormat('dd/MM/yy').parse(nextBillDate),
              );

              return Card(
                elevation: 4, // Adjust the elevation as needed
                margin: const EdgeInsets.all(8), // Adjust the margin as needed
                child: ListTile(
                  leading: Container(
                    // New leading container for the image
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            imageUrl), // Load the image from imageUrl
                      ),
                    ),
                  ),
                  title: Text(
                    studentBatch != null
                        ? "$studentName - Batch: $studentBatch"
                        : studentName,
                    style: const TextStyle(
                      fontSize: 16, // Adjust the font size as needed
                      fontWeight:
                          FontWeight.bold, // Apply bold style if desired
                    ),
                  ),
                  subtitle: Text(
                    'Fee: ₹$chargePerMonth | $formattedNextBillDate',
                    style: const TextStyle(
                      fontSize: 14, // Adjust the font size as needed
                      // You can customize other text styles here, e.g., color
                    ),
                  ),
                  onTap: () {
                    // Handle onTap for each payment if needed
                  },
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
