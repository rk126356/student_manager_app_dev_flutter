import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/components/NavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/batches/inside_batches_screen.dart';

class BatchesScreen extends StatefulWidget {
  const BatchesScreen({Key? key});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  List<String> batchNames = [];
  Map<String, int> batchCounts = {};
  Map<String, double> batchTotalCharge = {};

  @override
  void initState() {
    super.initState();
    // Call a function to fetch and calculate batch data
    fetchBatchData();
  }

  Future<void> fetchBatchData() async {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    // Assuming you have a Firestore collection named 'students'
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid!)
        .collection('students')
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      final studentBatch = document['studentBatch'] as String;
      final chargePerMonth = document['chargePerMonth'];

      // Check if chargePerMonth is a double or can be converted to a double
      double charge = 0.0;
      if (chargePerMonth is int) {
        // Convert int to double
        charge = chargePerMonth.toDouble();
      } else if (chargePerMonth is double) {
        charge = chargePerMonth;
      }

      // Count the students in each batch
      if (!batchCounts.containsKey(studentBatch)) {
        batchNames.add(studentBatch);
        batchCounts[studentBatch] = 1;
        batchTotalCharge[studentBatch] = charge;
      } else {
        batchCounts[studentBatch] = batchCounts[studentBatch]! + 1;
        batchTotalCharge[studentBatch] =
            batchTotalCharge[studentBatch]! + charge;
      }
    }

    // Update the state to rebuild the widget with the batch data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Call the refresh function here
              Navigator.pushReplacementNamed(context, '/batches');
            },
          ),
        ],
        title: const Text('All Batches'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Navigate back to '/home' when the back button is pressed
          Navigator.pushReplacementNamed(context, '/home');
          return false; // Return false to prevent default back behavior
        },
        child: ListView.builder(
          itemCount: batchNames.length,
          itemBuilder: (BuildContext context, int index) {
            final batchName = batchNames[index];
            final studentCount = batchCounts[batchName];
            final totalCharge = batchTotalCharge[batchName];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  '$batchName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Total Students: ${studentCount ?? 0} | Batch Value: ₹${totalCharge ?? 0.0}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(Icons.arrow_right, color: Colors.black),
                onTap: () {
                  // Navigate to InsideBatchesScreen and pass batchName as a parameter
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InsideBatchesScreen(batchName: batchName),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
