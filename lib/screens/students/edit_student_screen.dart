import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

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
  bool isLoading = false;
  String? lastBillDate;

  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();
    lastBillDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
  }

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
    setState(() {
      isLoading = true;
    });
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    DocumentReference userDocument = usersCollection.doc(user.uid);

    CollectionReference studentsCollection =
        userDocument.collection('students');

    final DateTime parsedJoinedDate =
        DateFormat('dd/MM/yyyy').parse(lastBillDate!);
    final DateTime nextBillDate =
        parsedJoinedDate.add(const Duration(days: 30));

    studentsCollection.doc(widget.studentId).get().then((doc) async {
      if (doc.exists) {
        if (isActive != doc['isActive'] && isLeft != doc['isLeft']) {
          bool searverActive = doc['isActive'];
          print("$isActive and $searverActive");

          await studentsCollection.doc(widget.studentId).update({
            'nextBillDate': DateFormat('dd/MM/yyyy').format(nextBillDate),
            'lastBillDate': lastBillDate,
          });
        }
      }
    });

    // Update the document with the provided studentId
    await studentsCollection.doc(widget.studentId).update({
      'studentName': studentName,
      'studentBatch': studentBatch,
      'chargePerMonth': chargePerMonth,
      'joinedDate': joinedDate,
      'isActive': isActive,
      'isLeft': isLeft,
      'studentPhoneNumber': studentPhoneNumber.trim(),
      'studentImageURL': studentImage != null
          ? await uploadStudentImage(studentImage, widget.studentId)
          : studentImageURL
    });

    print('Student data updated in Firestore with ID: ${widget.studentId}');
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Future<String> uploadStudentImage(File image, String studentId) async {
    final String imgId = const Uuid().v4().substring(0, 8);

    // Upload the image to Firebase Storage
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('student_images/$studentId/$imgId.jpg');
    await storageReference.putFile(image);

    // Get the download URL of the uploaded image
    String url = await storageReference.getDownloadURL();

    Uri originalUri = Uri.parse(url);

// Create a new URI with the scheme, host, and the modified last segment
    Uri modifiedUri = Uri(
      scheme: originalUri.scheme,
      host: originalUri.host,
      path: originalUri.path.replaceRange(
          originalUri.path.lastIndexOf('/') + 1,
          originalUri.path.length,
          "student_images%2F$studentId%2F${imgId}_200x200.png"),
    );

// Get the modified URL as a string
    String modifiedUrl = modifiedUri.toString();

    return "$modifiedUrl?alt=media";
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
            return CachedNetworkImage(
              imageUrl: studentImageURL!,
              imageBuilder: (context, imageProvider) => Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Makes it a circle (Avatar-like)
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover, // You can use other BoxFit values
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          }
        }

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var currencyIo = Provider.of<UserProvider>(context).currency;

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
                height: 20,
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
              const SizedBox(height: 15),
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
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: chargePerMonth != null
                          ? chargePerMonth.toString()
                          : '',
                      decoration: InputDecoration(
                        labelText: '$currencyIo Fee Per Month',
                        border: OutlineInputBorder(),
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
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
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
                  ),
                ],
              ),
              const SizedBox(height: 15),
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
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
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
                  ),
                  Expanded(
                    child: CheckboxListTile(
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
                  ),
                ],
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
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Update Student'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
