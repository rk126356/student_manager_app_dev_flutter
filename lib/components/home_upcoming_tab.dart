import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/inside_upcoing_payments_screen.dart';
import 'package:student_manager_app_dev_flutter/utils/send_whatsapp_reminder.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomeUpcomingTab extends StatelessWidget {
  const HomeUpcomingTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var data = Provider.of<UserProvider>(context, listen: false);

    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    CollectionReference paymentsCollection1 = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    paymentsCollection1.get().then((QuerySnapshot querySnapshot) {
      int noOfUpcomingPayments = querySnapshot.size;
      data.setNoOfPayments(noOfUpcomingPayments);
    }).catchError((error) {
      print('Error getting upcoming payments: $error');
    });

    final currentDate = DateTime.now();
    final currentMonth = currentDate.month;
    final currentYear = currentDate.year;
    final firstDayOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final sevenDaysFromNow = currentDate.add(const Duration(days: 30));

    return StreamBuilder<QuerySnapshot>(
      stream: paymentsCollection.limit(15).snapshots(),
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
            final batchName = paymentData['studentBatch'];
            final chargePerMonth = paymentData['chargePerMonth'];
            final imageUrl = paymentData['studentImageURL'];

            // Format the nextBillDate to the desired format
            final formattedNextBillDate = DateFormat('MMM dd, yyyy').format(
              DateFormat('dd/MM/yy').parse(nextBillDate),
            );

            // Create a ListTile widget for each upcoming payment
            final upcomingPaymentTile = Card(
              elevation: 4, // Adjust the elevation as needed
              margin: const EdgeInsets.all(8), // Adjust the margin as needed
              child: ListTile(
                leading: CachedNetworkImage(
                  width: 60,
                  height: 60,
                  imageUrl: imageUrl,
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
                  batchName != null ? "$studentName - $batchName" : studentName,
                  style: const TextStyle(
                    fontSize: 16, // Adjust the font size as needed
                    fontWeight: FontWeight.bold, // Apply bold style if desired
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InsideUpcomingPaymentsScreen(
                        paymentData: paymentData,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                    onPressed: () {
                      sendWhatsAppReminder(
                        studentName: studentName,
                        studentPhoneNumber: paymentData['studentPhoneNumber'],
                        formattedNextBillDate: formattedNextBillDate,
                        chargePerMonth: chargePerMonth.toString(),
                      );
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blue,
                    )),
              ),
            );

            upcomingPayments.add(upcomingPaymentTile);
          }
        }

        if (upcomingPayments.isEmpty) {
          return const Center(
              child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'No upcoming payments.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ));
        }

        return Column(
          children: upcomingPayments,
        );
      },
    );
  }
}
