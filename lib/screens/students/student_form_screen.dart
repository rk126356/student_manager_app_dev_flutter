import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class CreateStudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Student'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CreateStudentForm(),
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
  File? selectedImageFile;
  String? studentPhoneNumber;
  String selectedCountryCode = '+91';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
    String studentPhoneNumber,
    File? studentImage,
  ) async {
    setState(() {
      isLoading = true;
    });
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    DocumentReference userDocument = usersCollection.doc(uid);
    CollectionReference studentsCollection =
        userDocument.collection('students');
    final String studentId = const Uuid().v4().substring(0, 8);
    final DateTime parsedJoinedDate =
        DateFormat('dd/MM/yyyy').parse(joinedDate);
    final DateTime nextBillDate =
        parsedJoinedDate.add(const Duration(days: 30));

    // Create a storage reference for the student's image
    final storageReference =
        FirebaseStorage.instance.ref().child('student_images/$studentId.jpg');

    String url = '';

    // Upload the image to Firebase Storage
    if (studentImage != null) {
      await storageReference.putFile(studentImage);
      url = await storageReference.getDownloadURL();
    }

    Uri originalUri = Uri.parse(url);

// Create a new URI with the scheme, host, and the modified last segment
    Uri modifiedUri = Uri(
      scheme: originalUri.scheme,
      host: originalUri.host,
      path: originalUri.path.replaceRange(originalUri.path.lastIndexOf('/') + 1,
          originalUri.path.length, "student_images%2F${studentId}_200x200.png"),
    );

// Get the modified URL as a string
    String modifiedUrl = modifiedUri.toString();

    // Add student data to Firestore
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
      'studentPhoneNumber': studentPhoneNumber.trim(),
      'studentImageURL': studentImage != null
          ? "$modifiedUrl?alt=media"
          : "https://firebasestorage.googleapis.com/v0/b/student-manager-ac339.appspot.com/o/pngtree-vector-male-student-icon-png-image_558702-removebg-preview.png?alt=media&token=6205bbaf-fa94-4794-aa97-0e41581f5ed2&_gl=1*10lebqg*_ga*MTUxOTk0NjEwMC4xNjk2NzU3OTg2*_ga_CW55HF8NVT*MTY5NzAzODg0MS4yMy4xLjE2OTcwNDY0NjkuNjAuMC4w", // Get image URL
    });

    print('Student data added to Firestore with ID: $studentId');

    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var data = Provider.of<UserProvider>(context, listen: false);

    CollectionReference paymentsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    paymentsCollection.get().then((QuerySnapshot querySnapshot) {
      int noOfStudents = querySnapshot.size;
      data.setNoOfPayments(noOfStudents);

      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'totalStudents': noOfStudents,
      });
    }).catchError((error) {
      print('Error getting upcoming payments: $error');
    });

    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (pickedImage != null) {
      setState(() {
        selectedImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickImageCamers() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 30);

    if (pickedImage != null) {
      setState(() {
        selectedImageFile = File(pickedImage.path);
      });
    }
  }

  Widget _buildImagePreview() {
    print(selectedImageFile);
    if (selectedImageFile != null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(selectedImageFile!),
          ),
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/user.png'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    var currency = Provider.of<UserProvider>(context).currency;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildImagePreview(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _pickImage(); // Call the image picker function
                  _buildImagePreview(); // Display the selected image preview
                },
                icon: const Icon(Icons.image, size: 15),
                label: const Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: () {
                  _pickImageCamers(); // Call the image picker function
                  _buildImagePreview(); // Display the selected image preview
                },
                icon: const Icon(Icons.camera_alt, size: 15),
                label: const Text('Open Camera'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
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
            decoration: InputDecoration(
              labelText: '$currency Fee Per Month',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the fee per month';
              }
              return null;
            },
            onSaved: (value) {
              chargePerMonth = int.parse(value!);
            },
          ),
          const SizedBox(height: 15),
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
          const SizedBox(height: 15),
          TextFormField(
            initialValue: "+91",
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty || value.length <= 5) {
                return 'Please enter a phone number';
              }
              return null;
            },
            onSaved: (value) {
              studentPhoneNumber = value;
            },
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                addStudentToFirestore(
                  user.uid!,
                  studentName!,
                  studentBatch!,
                  joinedDate!,
                  isActive!,
                  isLeft!,
                  chargePerMonth!,
                  studentPhoneNumber!,
                  selectedImageFile,
                );
              }
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add), // Add an icon to the button
                SizedBox(width: 8), // Add some space between the icon and text
                Text('Create Student'),
              ],
            ),
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
