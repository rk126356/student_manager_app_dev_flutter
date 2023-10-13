import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/students/edit_student_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/inside_students_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/student_bills_screen.dart';
import 'package:student_manager_app_dev_flutter/widgets/students_list_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  void _performSearch(String query) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    // Query Firestore to search for students based on the query
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // Replace with your user ID
        .collection('students')
        .where('studentName', isGreaterThanOrEqualTo: query)
        .where('studentName', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        searchResults = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Students'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _performSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by student name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final studentDoc =
                    searchResults[index].data() as Map<String, dynamic>;
                return StudentListTile(
                  imageUrl: studentDoc['studentImageURL'] ?? '',
                  title: studentDoc['studentName'] ?? '',
                  subtitle:
                      '${studentDoc['studentBatch']} | Fee: ₹${studentDoc['chargePerMonth']}',
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
