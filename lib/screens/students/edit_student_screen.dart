import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditStudentScreen extends StatelessWidget {
  final String studentId;

  EditStudentScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
  bool isUnpaid = true;
  bool isPaid = false;
  bool _dataLoaded = false;
  File? selectedImageFile;
  String? studentPhoneNumber;
  String? studentImageURL;

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
    String studentPhoneNumber,
    File? studentImage,
  ) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    DocumentReference userDocument = usersCollection.doc(user.uid);

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
      'studentPhoneNumber': studentPhoneNumber,
      'studentImageURL': studentImage != null
          ? await uploadStudentImage(studentImage, widget.studentId)
          : studentImageURL
    });

    print('Student data updated in Firestore with ID: ${widget.studentId}');
  }

  Future<String> uploadStudentImage(File image, String studentId) async {
    // Upload the image to Firebase Storage
    final storageReference =
        FirebaseStorage.instance.ref().child('student_images/$studentId.jpg');
    await storageReference.putFile(image);

    // Get the download URL of the uploaded image
    String url = await storageReference.getDownloadURL();

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

    return "$modifiedUrl?alt=media";
  }

  Future<void> deleteStudentFromFirestore(String studentId) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    DocumentReference userDocument = usersCollection.doc(user.uid);

    CollectionReference studentsCollection =
        userDocument.collection('students');

    // Delete the document with the provided studentId
    await studentsCollection.doc(widget.studentId).delete();

    print('Student deleted from Firestore with ID: ${widget.studentId}');
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImageFile = File(pickedImage.path);
      });
    }
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

        if (!_dataLoaded) {
          var studentData = snapshot.data!.data() as Map<String, dynamic>;

          studentName = studentData['studentName'];
          studentBatch = studentData['studentBatch'];
          chargePerMonth = studentData['chargePerMonth'];
          joinedDate = studentData['joinedDate'];
          isActive = studentData['isActive'];
          isLeft = studentData['isLeft'];
          studentPhoneNumber = studentData['studentPhoneNumber'];
          studentImageURL = studentData['studentImageURL'];

          // Set the flag to true to indicate data has been loaded
          _dataLoaded = true;
        }

        Widget _buildImagePreview() {
          print(selectedImageFile);
          if (selectedImageFile != null) {
            return InkWell(
              onTap: () {
                _pickImage(); // Call the image picker function
                _buildImagePreview(); // Display the selected image preview
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(selectedImageFile!),
                  ),
                ),
              ),
            );
          } else {
            return InkWell(
              onTap: () {
                _pickImage(); // Call the image picker function
                _buildImagePreview(); // Display the selected image preview
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(studentImageURL!),
                  ),
                ),
              ),
            );
          }
        }

        return Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              ElevatedButton(
                onPressed: () {
                  _pickImage(); // Call the image picker function
                  _buildImagePreview(); // Display the selected image preview
                },
                child: const Text('Select Image'),
              ),
              SizedBox(
                height: 10,
              ),
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
                    chargePerMonth != null ? chargePerMonth.toString() : '',
                decoration: const InputDecoration(
                  labelText: 'Charge Per Month',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
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
                  _selectDate(context, true);
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
              TextFormField(
                initialValue: studentPhoneNumber,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value!.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  studentPhoneNumber = value;
                },
              ),
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
              const SizedBox(height: 10),
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
                      studentPhoneNumber!,
                      selectedImageFile,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update Student'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () {
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
                              deleteStudentFromFirestore(widget.studentId);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
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
