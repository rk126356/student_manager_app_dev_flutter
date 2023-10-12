import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/edit_payments_screen.dart';

class StudentBillsScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentBillsScreen(
      {Key? key, required this.studentId, required this.studentName})
      : super(key: key);

  @override
  State<StudentBillsScreen> createState() => _StudentBillsScreenState();
}

class _StudentBillsScreenState extends State<StudentBillsScreen> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.studentName} Bills"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('payments')
            .where('studentId', isEqualTo: widget.studentId)
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
                child: Text('No bills available for this date.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final billData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              final billAmount = billData['chargePerMonth'];
              final billDate = billData['billDate'];
              final isPaid = billData[
                  'isPaid']; // Assuming you have a field indicating payment status

              // Define colors for paid and unpaid bills
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

              final formattedDate =
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(billDate));

              return Card(
                color: cardColor,
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(icon, color: Colors.white),
                  title: Text(
                    'Amount: $billAmount',
                    style: titleTextStyle,
                  ),
                  subtitle: Text(
                    'Bill Date: $formattedDate',
                    style: subtitleTextStyle,
                  ),
                  trailing: const Icon(Icons.arrow_right, color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPaymentsScreen(
                            studentId: billData['studentId'],
                            studentName: billData['studentName'],
                            billDate: billData['billDate'],
                            userId: user.uid!),
                      ),
                    );
                  },
                  // Add more information as needed
                ),
              );
            },
          );
        },
      ),
    );
  }
}
