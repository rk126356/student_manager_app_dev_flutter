import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/students/edit_student_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/student_bills_screen.dart';

class InsideStudentScreen extends StatefulWidget {
  final String studentId;

  InsideStudentScreen({required this.studentId, Key? key}) : super(key: key);

  @override
  State<InsideStudentScreen> createState() => _InsideStudentScreenState();
}

class _InsideStudentScreenState extends State<InsideStudentScreen> {
  String studentName = "";
  String studentBatch = "";
  String joinedDate = "";
  bool isActive = false;
  int chargePerMonth = 0;

  void fetchStudentData() {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid!)
        .collection('students')
        .doc(widget.studentId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          studentName = doc['studentName'];
          studentBatch = doc['studentBatch'];
          joinedDate = doc['joinedDate'];
          isActive = doc['isActive'];
          chargePerMonth = doc['chargePerMonth'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchStudentData();
              setState(() {});
            },
          ),
        ],
        title: const Text('Student Details'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Student Name',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 24.0,
                    ),
                    const Text(
                      'Batch',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      studentBatch,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 24.0,
                    ),
                    const Text(
                      'Joined Date',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      joinedDate,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 24.0,
                    ),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          color: isActive ? Colors.green : Colors.red,
                          size: 24.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 24.0,
                    ),
                    const Text(
                      'Fee Per Month',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹$chargePerMonth',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditStudentScreen(studentId: widget.studentId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Student'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    elevation: 8.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentBillsScreen(
                          studentId: widget.studentId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.currency_rupee),
                  label: const Text('Payments'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    elevation: 8.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Show a confirmation dialog before deleting
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Student'),
                      content: const Text(
                          'Are you sure you want to delete this student?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            // Perform the deletion operation here
                            deleteStudentFromFirestore(widget.studentId);
                            Navigator.of(context)
                                .pop(); // Close the confirmation dialog
                            Navigator.of(context)
                                .pop(); // Close EditStudentScreen
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Student'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                elevation: 8.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteStudentFromFirestore(String studentId) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    // Create a document for the user with the provided UID
    DocumentReference userDocument = usersCollection.doc(user.uid);

    // Add a subcollection named 'students'
    CollectionReference studentsCollection =
        userDocument.collection('students');

    // Delete the document with the provided studentId
    await studentsCollection.doc(widget.studentId).delete();

    print('Student deleted from Firestore with ID: ${widget.studentId}');
  }
}
