import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';
import 'package:student_manager_app_dev_flutter/widgets/Dashboard_board_widget.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? startDate = DateTime(2023);
  DateTime? endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var currency = Provider.of<UserProvider>(context).currency;
    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    Query query = paymentsCollection;

    if (startDate != null) {
      query =
          query.where('billDate', isGreaterThanOrEqualTo: startDate.toString());
    }

    if (endDate != null) {
      // Convert endDate to a DateTime object
      DateTime endDateDateTime = DateTime.parse(endDate.toString());

      // Add +1 day
      endDateDateTime = endDateDateTime.add(Duration(days: 1));

      // Convert it back to a string if needed
      String endDatePlusOneDay = endDateDateTime.toLocal().toString();

      // Use the updated date in your query
      query = query.where('billDate', isLessThanOrEqualTo: endDatePlusOneDay);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        double totalPaidAmount = 0;
        int totalPaidFees = 0;
        double totalUnpaidAmount = 0;
        int totalUnpaidFees = 0;

        if (snapshot.hasData) {
          final documents = snapshot.data!.docs;
          for (var doc in documents) {
            final isPaid = doc['isPaid'];
            final amount = doc['chargePerMonth'];

            if (isPaid) {
              totalPaidAmount += amount;
              totalPaidFees++;
            } else {
              totalUnpaidAmount += amount;
              totalUnpaidFees++;
            }
          }
        }

        final formattedSelectedStartDate =
            DateFormat('yyyy-MM-dd').parse(startDate.toString());

        final formattedSelectedEndDate =
            DateFormat('yyyy-MM-dd').parse(endDate.toString());

        bool isWithinSelectedDateRange(DateTime date) {
          if (startDate != null && date.isBefore(startDate!)) {
            return false;
          }
          if (endDate != null && date.isAfter(endDate!)) {
            return false;
          }
          return true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Selected start date
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy')
                          .format(formattedSelectedStartDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Arrow icon to separate the dates
                  const Icon(
                    Icons.arrow_right_alt,
                    color: Colors.grey,
                    size: 36,
                  ),

                  // Selected end date
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy')
                          .format(formattedSelectedEndDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
              // Add Date Range Picker
              ElevatedButton(
                onPressed: () {
                  showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: startDate ?? DateTime(2023),
                      end: endDate ?? DateTime(2101),
                    ),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2024),
                  ).then((pickedDateRange) {
                    if (pickedDateRange != null) {
                      setState(() {
                        startDate = pickedDateRange.start;
                        endDate = pickedDateRange.end;
                      });
                    }
                  });
                },
                child: const Text('Select Date Range'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: DashboardBox(
                      title: 'Paid',
                      value: '$currency${totalPaidAmount.toStringAsFixed(2)}',
                    ),
                  ),
                  Expanded(
                    child: DashboardBox(
                      title: 'Unpaid',
                      value: '$currency${totalUnpaidAmount.toStringAsFixed(2)}',
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
              // Display payments
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: paymentsCollection
                      .orderBy('billDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No payments available.'));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final paymentData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        final studentName = paymentData['studentName'];
                        final studentBatch = paymentData['studentBatch'];
                        final chargePerMonth = paymentData['chargePerMonth'];
                        final isPaid = paymentData['isPaid'];
                        final billDate = paymentData['billDate'] as String;

                        final formattedDate =
                            DateFormat('yyyy-MM-dd').parse(billDate);

                        if (!isWithinSelectedDateRange(formattedDate)) {
                          return Container();
                        }

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
                            leading: CachedNetworkImage(
                              height: 60,
                              width: 60,
                              imageUrl: paymentData['studentImageUrl'],
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape
                                      .circle, // Makes it a circle (Avatar-like)
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit
                                        .cover, // You can use other BoxFit values
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            title: Text(
                              '$studentName - $studentBatch',
                              style: titleTextStyle,
                            ),
                            subtitle: Text(
                              'Fee: $currency$chargePerMonth | Bill Date: ${DateFormat('MMM dd, yyyy').format(formattedDate)}',
                              style: subtitleTextStyle,
                            ),
                            trailing: const Icon(Icons.arrow_right,
                                color: Colors.white),
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
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
