import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class CreateStudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close the keyboard when tapped outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Student'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CreateStudentForm(), // Include the form on the screen
          ),
        ),
      ),
    );
  }
}

class CreateStudentForm extends StatefulWidget {
  @override
  _CreateStudentFormState createState() => _CreateStudentFormState();
}

class _CreateStudentFormState extends State<CreateStudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? studentName;
  String? studentBatch;
  String? lastPaidDate = '';
  bool? isActive = true;
  bool? isLeft = false;
  bool isUnpaid = true; // Default to Unpaid
  bool isPaid = false; // Default to Unpaid

  Future<void> addStudentToFirestore(
    String uid,
    String studentName,
    String studentBatch,
    bool isActive,
    bool isLeft,
    bool isUnpaid,
    bool isPaid,
  ) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Create a document for the user with the provided UID
    DocumentReference userDocument = usersCollection.doc(uid);

    // Add a subcollection named 'students'
    CollectionReference studentsCollection =
        userDocument.collection('students');

    // Generate a unique 8-digit ID for the student
    final String studentId = Uuid().v4().substring(0, 8);

    // Set the joined date to the current date
    final String currentJoinedDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    // Add a new document with student data and the generated ID
    await studentsCollection.doc(studentId).set({
      'studentId': studentId,
      'studentName': studentName,
      'studentBatch': studentBatch,
      'joinedDate': currentJoinedDate, // Set joinedDate to the current date
      'isActive': isActive,
      'isLeft': isLeft,
      'isUnpaid': isUnpaid,
      'isPaid': isPaid,
    });

    print('Student data added to Firestore with ID: $studentId');
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Student Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a student name';
              }
              return null;
            },
            onSaved: (value) {
              studentName = value;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Student Batch',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a student batch';
              }
              return null;
            },
            onSaved: (value) {
              studentBatch = value;
            },
          ),
          SizedBox(height: 10),
          CheckboxListTile(
            title: Text('Active'),
            value: isActive,
            onChanged: (value) {
              setState(() {
                isActive = value;
                isLeft = value;
                if (value!) {
                  isLeft = false;
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text('Left'),
            value: isLeft,
            onChanged: (value) {
              setState(() {
                isLeft = value;
                if (value!) {
                  isActive = false;
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text('Unpaid'),
            value: isUnpaid,
            onChanged: (value) {
              setState(() {
                isUnpaid = value!;
                if (value) {
                  // Unselect Paid if Unpaid is selected
                  isPaid = false;
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text('Paid'),
            value: isPaid,
            onChanged: (value) {
              setState(() {
                isPaid = value!;
                if (value) {
                  // Unselect Unpaid if Paid is selected
                  isUnpaid = false;
                }
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                addStudentToFirestore(user.uid!, studentName!, studentBatch!,
                    isActive!, isLeft!, isUnpaid, isPaid);
                // Trigger a rebuild of StudentsScreen
                Navigator.pop(context);
              }
            },
            child: Text('Create Student'),
          ),
        ],
      ),
    );
  }
}
