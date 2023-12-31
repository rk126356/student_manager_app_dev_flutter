import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/students/inside_students_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/student_bills_screen.dart';
import 'package:student_manager_app_dev_flutter/widgets/students_list_widget.dart';

class HomeStudentsTab extends StatelessWidget {
  const HomeStudentsTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var currency = Provider.of<UserProvider>(context).currency;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user
              .uid) // Replace 'uid' with the actual UID you want to fetch data for
          .collection('students')
          .orderBy('joinedDate',
              descending: false) // Order by JoinedDate in descending order
          .limit(15) // Limit to the latest 15 records
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while data is being fetched
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'No students available.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ));
        }
        final studentList = snapshot.data!.docs;
        return Column(
          children: [
            for (var studentDoc in studentList)
              Column(
                children: [
                  StudentListTile(
                    title: studentDoc['studentName'] ?? '',
                    imageUrl: studentDoc['studentImageURL'] ?? '',
                    subtitle:
                        '${studentDoc['studentBatch']} | Fee: $currency${studentDoc['chargePerMonth']}',
                    onTap: () {
                      // Handle onTap action for each student
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InsideStudentScreen(
                              studentId: studentDoc['studentId']),
                        ),
                      );
                    },
                    onPaymentsTap: () {
                      // Handle "Payments" button tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentBillsScreen(
                            studentId: studentDoc['studentId'],
                            studentName: studentDoc['studentName'],
                          ),
                        ),
                      );
                    },
                    onEditTap: () {
                      // Handle "Edit" button tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InsideStudentScreen(
                              studentId: studentDoc['studentId']),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
