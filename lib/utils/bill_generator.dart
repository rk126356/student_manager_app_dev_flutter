import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillGenerator {
  static Future<void> generateBills(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference usersCollection = firestore.collection('users');
    final CollectionReference studentsCollection =
        usersCollection.doc(userId).collection('students');
    final CollectionReference feesCollection =
        usersCollection.doc(userId).collection('payments');

    final QuerySnapshot studentQuerySnapshot = await studentsCollection.get();

    for (final QueryDocumentSnapshot studentDoc in studentQuerySnapshot.docs) {
      final String studentId = studentDoc['studentId'];
      final String studentName = studentDoc['studentName'];
      final String studentBatch = studentDoc['studentBatch'];
      final int chargePerMonth = studentDoc['chargePerMonth'];
      final String joinedDate = studentDoc['joinedDate'];
      final int totalUnpaidBills = studentDoc['totalUnpaidBills'];
      final int nextBillInDays = studentDoc['nextBillInDays']!;

      try {
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        final DateTime parsedDate = dateFormat.parse(joinedDate);

        // Calculate the next bill due date (30 days from the last bill)
        final DateTime nextBillDate = parsedDate;
        print(nextBillDate);

        // Check if the next bill date is in the future
        if (nextBillInDays <= 0) {
          // Check if a bill for the student with the same billDate exists
          final QuerySnapshot existingBillQuerySnapshot = await feesCollection
              .where('studentId', isEqualTo: studentId)
              .where('billDate', isEqualTo: nextBillDate.toIso8601String())
              .get();

          // If no existing bill is found, create a new one
          if (existingBillQuerySnapshot.docs.isEmpty) {
            final String billId =
                UniqueKey().toString(); // Generate a unique ID
            await feesCollection.doc(billId).set({
              'studentId': studentId,
              'studentName': studentName,
              'studentBatch': studentBatch,
              'chargePerMonth': chargePerMonth,
              'billDate': nextBillDate.toIso8601String(),
              'isPaid': false,
            });

            // Update the student's last bill date
            await studentsCollection.doc(studentId).update({
              'lastBillDate': nextBillDate.toIso8601String(),
              totalUnpaidBills: totalUnpaidBills + 1
            });

            print('Generated bill for $studentName (Batch: $studentBatch)');
          } else {
            print(
                'Bill for $studentName (Batch: $studentBatch) already exists');
          }
        }
      } catch (e) {
        print('Error parsing date: $joinedDate');
        // Handle the error here, e.g., set a default date
      }
    }
  }
}
