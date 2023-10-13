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
  TextEditingController newBatchNameController = TextEditingController();

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

  void editBatchName(String batchName, String newBatchName) async {
    // Implement your logic to change the studentBatch name here
    // Example: You can update the 'studentBatch' field in Firestore for all students in the batch.
    // You should run a batch update to update multiple documents at once.
    // Replace 'students' with your actual Firestore collection name.
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid!)
        .collection('students')
        .where('studentBatch', isEqualTo: batchName)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'studentBatch': newBatchName});
      });
    });
    Navigator.pushReplacementNamed(context, '/batches');
  }

  // Function to show the batch name edit dialog
  void showEditBatchNameDialog(String batchName) {
    newBatchNameController.text =
        batchName; // Initialize the input with the current batch name
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Batch Name'),
          content: TextField(
            controller: newBatchNameController,
            decoration: InputDecoration(labelText: 'New Batch Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                String newBatchName = newBatchNameController.text;
                editBatchName(batchName, newBatchName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue), // Edit icon
                      onPressed: () {
                        showEditBatchNameDialog(batchName);
                      },
                    ),
                    const Icon(Icons.arrow_right, color: Colors.blue),
                  ],
                ),
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
