import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/components/NavBar.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/students/inside_students_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/student_bills_screen.dart';
import 'package:student_manager_app_dev_flutter/widgets/students_list_widget.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var currency = Provider.of<UserProvider>(context).currency;

    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-student');
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          primary: Colors.blue,
          padding: const EdgeInsets.all(20),
          elevation: 8,
          shadowColor: Colors.blueAccent,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      drawer: const NavBar(),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search-student');
            },
          ),
        ],
        title: const Text('Students'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: "All Students",
            ),
            Tab(
              text: "Active",
            ),
            Tab(
              text: "Left",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('students')
                    .orderBy('joinedDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text('No students available.'),
                      ],
                    );
                  }
                  final studentList = snapshot.data!.docs;
                  return Column(
                    children: [
                      for (var studentDoc in studentList)
                        Column(
                          children: [
                            StudentListTile(
                              imageUrl: studentDoc['studentImageURL'] ?? '',
                              title: studentDoc['studentName'] ?? '',
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
                                      studentName: studentDoc['studentName'],
                                      studentId: studentDoc['studentId'],
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
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('students')
                    .where('isActive', isEqualTo: true)
                    .orderBy('joinedDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text('No active students available.'),
                      ],
                    );
                  }
                  final activeStudentList = snapshot.data!.docs;
                  return Column(
                    children: [
                      for (var studentDoc in activeStudentList)
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
                                      studentName: studentDoc['studentName'],
                                      studentId: studentDoc['studentId'],
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
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('students')
                    .where('isLeft', isEqualTo: true)
                    .orderBy('joinedDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text('No left students available.'),
                      ],
                    );
                  }
                  final leftStudentList = snapshot.data!.docs;
                  return Column(
                    children: [
                      for (var studentDoc in leftStudentList)
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
                                      studentName: studentDoc['studentName'],
                                      studentId: studentDoc['studentId'],
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
