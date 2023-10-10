import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class EditStudentScreen extends StatelessWidget {
  final String studentId;

  EditStudentScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close the keyboard when tapped outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Student'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EditStudentForm(studentId: studentId),
          ),
        ),
      ),
    );
  }
}

class EditStudentForm extends StatefulWidget {
  final String studentId;

  EditStudentForm({required this.studentId});

  @override
  _EditStudentFormState createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<EditStudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? studentName;
  String? studentBatch;
  int? chargePerMonth;
  String? joinedDate;
  bool? isActive;
  bool? isLeft;
  bool isUnpaid = true; // Default to Unpaid
  bool isPaid = false; // Default to Unpaid
  bool _dataLoaded = false; // Add this flag

  Future<void> _selectDate(BuildContext context, bool isJoinedDate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isJoinedDate) {
          joinedDate =
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
        }
      });
    }
  }

  Future<void> updateStudentInFirestore(
    String studentId,
    String studentName,
    String studentBatch,
    int chargePerMonth,
    String joinedDate,
    bool isActive,
    bool isLeft,
  ) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    // Create a document for the user with the provided UID
    DocumentReference userDocument = usersCollection.doc(user.uid);

    // Add a subcollection named 'students'
    CollectionReference studentsCollection =
        userDocument.collection('students');

    // Update the document with the provided studentId
    await studentsCollection.doc(widget.studentId).update({
      'studentName': studentName,
      'studentBatch': studentBatch,
      'chargePerMonth': chargePerMonth,
      'joinedDate': joinedDate,
      'isActive': isActive,
      'isLeft': isLeft,
    });

    print('Student data updated in Firestore with ID: ${widget.studentId}');
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

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid!)
          .collection('students')
          .doc(widget.studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        // Load data only once
        if (!_dataLoaded) {
          var studentData = snapshot.data!.data() as Map<String, dynamic>;

          studentName = studentData['studentName'];
          studentBatch = studentData['studentBatch'];
          chargePerMonth = studentData['chargePerMonth'];
          joinedDate = studentData['joinedDate'];
          isActive = studentData['isActive'];
          isLeft = studentData['isLeft'];

          // Set the flag to true to indicate data has been loaded
          _dataLoaded = true;
        }

        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: studentName,
                decoration: const InputDecoration(
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
              const SizedBox(height: 10),
              TextFormField(
                initialValue: studentBatch,
                decoration: const InputDecoration(
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
              const SizedBox(height: 10),
              TextFormField(
                initialValue:
                    chargePerMonth != null ? chargePerMonth.toString() : "",
                decoration: const InputDecoration(
                  labelText: 'Charge Per Month',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee), // Rupee icon
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the charge per month';
                  }
                  return null;
                },
                onSaved: (value) {
                  chargePerMonth = int.parse(value!);
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Active'),
                value: isActive ?? false,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                    if (value!) {
                      isLeft = false;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Left'),
                value: isLeft ?? false,
                onChanged: (value) {
                  setState(() {
                    isLeft = value;
                    if (value!) {
                      isActive = false;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    updateStudentInFirestore(
                      widget.studentId,
                      studentName!,
                      studentBatch!,
                      chargePerMonth!,
                      joinedDate!,
                      isActive!,
                      isLeft!,
                    );
                    // Trigger a rebuild of StudentsScreen
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update Student'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors
                      .red), // Change the color to your desired background color
                ),
                onPressed: () {
                  // Show a confirmation dialog before deleting
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Student'),
                        content: Text(
                            'Are you sure you want to delete this student?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete'),
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
                child: Text(
                  'Delete Student',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
