import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomeUpcomingTab extends StatelessWidget {
  const HomeUpcomingTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    final currentDate = DateTime.now();
    final currentMonth = currentDate.month;
    final currentYear = currentDate.year;
    final firstDayOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final sevenDaysFromNow = currentDate.add(const Duration(days: 30));

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection
          .limit(20) // Limit the results to 20 payments
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

        final upcomingPayments = <Widget>[];

        for (final paymentDocument in snapshot.data!.docs) {
          final paymentData = paymentDocument.data() as Map<String, dynamic>;

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
            final chargePerMonth = paymentData['chargePerMonth'];

            // Format the nextBillDate to the desired format
            final formattedNextBillDate = DateFormat('MMM dd, yyyy').format(
              DateFormat('dd/MM/yy').parse(nextBillDate),
            );

            // Create a ListTile widget for each upcoming payment
            final upcomingPaymentTile = MyListTile(
              title: studentName,
              subtitle: 'RS: $chargePerMonth | $formattedNextBillDate',
              onTap: () {
                // Handle onTap for each payment if needed
              },
            );

            upcomingPayments.add(upcomingPaymentTile);
          }
        }

        if (upcomingPayments.isEmpty) {
          return const Center(child: Text('No upcoming payments.'));
        }

        return Column(
          children: upcomingPayments,
        );
      },
    );
  }
}
