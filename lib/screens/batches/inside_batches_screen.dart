import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/students/inside_students_screen.dart';

class InsideBatchesScreen extends StatefulWidget {
  final String batchName;

  InsideBatchesScreen({required this.batchName, Key? key}) : super(key: key);

  @override
  State<InsideBatchesScreen> createState() => _InsideBatchesScreenState();
}

class _InsideBatchesScreenState extends State<InsideBatchesScreen> {
  var user;

  // Function to refresh the page
  void refreshPage() {
    // You can re-fetch data or re-load the page here
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Call the refresh function here
              refreshPage();
            },
          ),
        ],
        title: Text('Batch: ${widget.batchName}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid!)
            .collection('students')
            .where('studentBatch', isEqualTo: widget.batchName)
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
                child: Text('No students available in this batch.'));
          }

          final studentList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: studentList.length,
            itemBuilder: (context, index) {
              final studentData =
                  studentList[index].data() as Map<String, dynamic>;
              final studentName = studentData['studentName'] ?? '';
              final chargePerMonth = studentData['chargePerMonth'] ?? 0.0;
              final studentId = studentData['studentId'];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Batch: ${widget.batchName} | Fee: $chargePerMonth',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InsideStudentScreen(studentId: studentId),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.red,
                          ),
                        ),
                        onPressed: () {
                          showRemoveDialog(studentId);
                        },
                        child: const Text("Remove"),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InsideStudentScreen(studentId: studentId),
                            ),
                          );
                        },
                        child: const Text("Info"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to delete a student from Firestore
  void deleteStudent(String studentId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid!)
        .collection('students')
        .doc(studentId)
        .delete()
        .then((_) {
      // Student deleted successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted successfully.'),
        ),
      );
    }).catchError((error) {
      // Error occurred while deleting student
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student: $error'),
        ),
      );
    });
  }

  // Function to open a popup for removing a student from the batch
  void showRemoveDialog(String studentId) {
    String newBatchName = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter new batch name for removal:'),
              TextField(
                onChanged: (value) {
                  newBatchName = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Remove student from current batch and update batch name
                removeStudent(studentId, newBatchName);
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  // Function to remove a student from the current batch and update batch name
  void removeStudent(String studentId, String newBatchName) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid!)
        .collection('students')
        .doc(studentId)
        .update({
      'studentBatch': newBatchName,
    }).then((_) {
      // Student removed from the current batch and batch name updated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student removed from batch.'),
        ),
      );
    }).catchError((error) {
      // Error occurred while removing student
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing student: $error'),
        ),
      );
    });
  }
}
