import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
          title: const Text('Create Student'),
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
  int? chargePerMonth;
  String? joinedDate;
  bool? isActive = true;
  bool? isLeft = false;

  @override
  void initState() {
    super.initState();
    // Initialize joinedDate with the current date
    final currentDate = DateTime.now();
    joinedDate = "${currentDate.day}/${currentDate.month}/${currentDate.year}";
  }

  Future<void> addStudentToFirestore(
    String uid,
    String studentName,
    String studentBatch,
    String joinedDate,
    bool isActive,
    bool isLeft,
    int chargePerMonth,
  ) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Create a document for the user with the provided UID
    DocumentReference userDocument = usersCollection.doc(uid);

    // Add a subcollection named 'students'
    CollectionReference studentsCollection =
        userDocument.collection('students');

    // Generate a unique 8-digit ID for the student
    final String studentId = const Uuid().v4().substring(0, 8);

    // Parse the joinedDate string into a DateTime
    final DateTime parsedJoinedDate =
        DateFormat('dd/MM/yyyy').parse(joinedDate);

    // Calculate the nextBillDate based on joinedDate and chargePerMonth
    final DateTime nextBillDate = parsedJoinedDate.add(Duration(days: 30));

    // Add a new document with student data and the generated ID
    await studentsCollection.doc(studentId).set({
      'studentId': studentId,
      'studentName': studentName,
      'studentBatch': studentBatch,
      'joinedDate': joinedDate,
      'lastBillDate': joinedDate,
      'nextBillDate': DateFormat('dd/MM/yyyy').format(nextBillDate),
      'isActive': isActive,
      'isLeft': isLeft,
      'chargePerMonth': chargePerMonth,
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
            decoration: const InputDecoration(
              labelText: 'Fee Per Month',
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
          InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Joined Date',
                border: OutlineInputBorder(),
              ),
              child: Text(joinedDate ?? ''),
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text('Active'),
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
            title: const Text('Left'),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                addStudentToFirestore(
                    user.uid!,
                    studentName!,
                    studentBatch!,
                    joinedDate!,
                    isActive!,
                    isLeft!,
                    chargePerMonth!); // Pass chargePerMonth to the function
                // Trigger a rebuild of StudentsScreen
                Navigator.pop(context);
              }
            },
            child: const Text('Create Student'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime firstDateOfMonth =
        DateTime(currentDate.year, currentDate.month, 1);
    DateTime lastDateOfMonth =
        DateTime(currentDate.year, currentDate.month + 1, 0);

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDateOfMonth,
      lastDate: lastDateOfMonth,
    );

    if (selectedDate != null) {
      final formattedDate =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      setState(() {
        joinedDate = formattedDate;
      });
    }
  }
}
