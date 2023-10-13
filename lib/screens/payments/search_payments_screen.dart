import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';

class SearchPaymentsScreen extends StatefulWidget {
  const SearchPaymentsScreen({Key? key});

  @override
  State<SearchPaymentsScreen> createState() => _SearchPaymentsScreenState();
}

class _SearchPaymentsScreenState extends State<SearchPaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  void _performSearch(String query) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    // Query Firestore to search for students based on the query
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // Replace with your user ID
        .collection('payments')
        .where('studentName', isGreaterThanOrEqualTo: query)
        .where('studentName', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        searchResults = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Payments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _performSearch(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search payments by student name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final paymentData =
                    searchResults[index].data() as Map<String, dynamic>;

                final studentName = paymentData['studentName'];
                final studentBatch = paymentData['studentBatch'];
                final chargePerMonth = paymentData['chargePerMonth'];
                final isPaid = paymentData['isPaid'];
                final billDate = paymentData['billDate'] as String;
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

                final formattedDate = DateFormat('yyyy-MM-dd').parse(billDate);

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
                            fit:
                                BoxFit.cover, // You can use other BoxFit values
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    title: Text(
                      '$studentName - Batch: $studentBatch',
                      style: titleTextStyle,
                    ),
                    subtitle: Text(
                      'Fee: ₹$chargePerMonth | Bill Date: ${DateFormat('MMM dd, yyyy').format(formattedDate)}',
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
            ),
          ),
        ],
      ),
    );
  }
}
