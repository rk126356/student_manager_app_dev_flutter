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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBatchData();
  }

  Future<void> fetchBatchData() async {
    setState(() {
      isLoading = true;
    });
    var user = Provider.of<UserProvider>(context, listen: false).userData;

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

      double charge = 0.0;
      if (chargePerMonth is int) {
        charge = chargePerMonth.toDouble();
      } else if (chargePerMonth is double) {
        charge = chargePerMonth;
      }

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

    setState(() {
      isLoading = false;
    });
  }

  void editBatchName(String batchName, String newBatchName) async {
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

  void showEditBatchNameDialog(String batchName) {
    newBatchNameController.text = batchName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Batch Name'),
          content: TextField(
            controller: newBatchNameController,
            decoration: const InputDecoration(labelText: 'New Batch Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
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

  Future<void> deleteBatch(String batchName) async {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the batch "$batchName" and all its students?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid!)
          .collection('students')
          .where('studentBatch', isEqualTo: batchName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      Navigator.pushReplacementNamed(context, '/batches');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    }

    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/batches');
            },
          ),
        ],
        title: const Text('All Batches'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, '/home');
          return false;
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
                  'Total Students: ${studentCount ?? 0} | Value: ₹${totalCharge ?? 0.0}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showEditBatchNameDialog(batchName);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteBatch(batchName);
                      },
                    ),
                    const Icon(Icons.arrow_right, color: Colors.blue),
                  ],
                ),
                onTap: () {
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
