import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';

class PaidPaymentsTab extends StatefulWidget {
  const PaidPaymentsTab({Key? key});

  @override
  _PaidPaymentsTabState createState() => _PaidPaymentsTabState();
}

class _PaidPaymentsTabState extends State<PaidPaymentsTab> {
  DateTime? selectedStartDate = DateTime(2023);
  DateTime selectedEndDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    final formattedSelectedStartDate =
        DateFormat('yyyy-MM-dd').parse(selectedStartDate.toString());

    final formattedSelectedEndDate =
        DateFormat('yyyy-MM-dd').parse(selectedEndDate.toString());

    var currency = Provider.of<UserProvider>(context).currency;

    return Column(
      children: [
        // Date range filter
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _selectDateRange(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    DateFormat('MMM dd, yyyy').format(formattedSelectedEndDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                // Date Range button
                ElevatedButton(
                  onPressed: () {
                    _selectDateRange(context);
                  },
                  child: const Text(
                    'Change Range',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Display payments
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: paymentsCollection
                .where('isPaid', isEqualTo: true)
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
                  final isPaid = paymentData['isPaid'];
                  final billDate = paymentData['billDate'] as String;

                  final formattedDate =
                      DateFormat('yyyy-MM-dd').parse(billDate);

                  if (!_isWithinSelectedDateRange(formattedDate)) {
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
                        width: 60,
                        height: 60,
                        imageUrl: paymentData['studentImageUrl'],
                        imageBuilder: (context, imageProvider) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
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
                      trailing:
                          const Icon(Icons.arrow_right, color: Colors.white),
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
    );
  }

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedDates = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: selectedStartDate ?? DateTime(2023),
        end: selectedEndDate ?? DateTime(2101),
      ),
    );

    if (pickedDates != null) {
      setState(() {
        selectedStartDate = pickedDates.start;
        selectedEndDate = pickedDates.end;
      });
    }
  }

  bool _isWithinSelectedDateRange(DateTime date) {
    if (selectedStartDate != null && date.isBefore(selectedStartDate!)) {
      return false;
    }
    if (selectedEndDate != null && date.isAfter(selectedEndDate!)) {
      return false;
    }
    return true;
  }
}
