import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class DataExportsScreen extends StatefulWidget {
  @override
  State<DataExportsScreen> createState() => _DataExportsScreenState();
}

class _DataExportsScreenState extends State<DataExportsScreen> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Exports'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await fetchData(user);
              },
              child: Text('Export Data as CSV'),
            ),
          ],
        ),
      ),
    );
  }

  String exportDataAsCsv(QuerySnapshot snapshot) {
    String csv = "Name, Fee, Joined Date\n"; // CSV header

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String name = doc['studentName'];
      int fee = doc['chargePerMonth'];
      String joinedDate = doc['joinedDate'];

      String row = '$name, $fee, $joinedDate\n';

      csv += row;
    }

    return csv;
  }

  Future<void> saveCsvDataToFile(String csvData) async {
    try {
      Directory? directory = await getDownloadsDirectory();
      String filePath = '/storage/emulated/0/Download/student_data.csv';
      File file = File(filePath);

      await file.writeAsString(csvData);

      print('CSV data saved to $filePath');
    } catch (e) {
      print('Error saving CSV data: $e');
    }
  }

  Future<void> fetchData(user) async {
    try {
      CollectionReference studentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('students');

      QuerySnapshot snapshot = await studentRef
          .where('isActive', isEqualTo: true)
          .orderBy('joinedDate', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String csvData = exportDataAsCsv(snapshot);
        await saveCsvDataToFile(csvData);

        print('Saved csv file');
      } else {
        print('No active students available.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
