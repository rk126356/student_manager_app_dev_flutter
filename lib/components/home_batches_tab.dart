import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/batches/inside_batches_screen.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomeBatchesTab extends StatefulWidget {
  const HomeBatchesTab({
    super.key,
  });

  @override
  State<HomeBatchesTab> createState() => _HomeBatchesTabState();
}

class _HomeBatchesTabState extends State<HomeBatchesTab> {
  @override
  void initState() {
    super.initState();
    // Call a function to fetch and calculate batch data
    fetchBatchData();
  }

  List<String> batchNames = [];
  Map<String, int> batchCounts = {};
  Map<String, double> batchTotalCharge = {};
  Future<void> fetchBatchData() async {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    // Assuming you have a Firestore collection named 'students'
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid!)
        .collection('students')
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      final studentBatch = document['studentBatch'] as String;
      final chargePerMonth = document['chargePerMonth'];

      // Check if chargePerMonth is a double or can be converted to a double
      double charge = 0.0;
      if (chargePerMonth is int) {
        // Convert int to double
        charge = chargePerMonth.toDouble();
      } else if (chargePerMonth is double) {
        charge = chargePerMonth;
      }

      // Count the students in each batch
      if (!batchCounts.containsKey(studentBatch)) {
        batchNames.add(studentBatch);
        batchCounts[studentBatch] = 1;
        batchTotalCharge[studentBatch] = charge;
      } else {
        batchCounts[studentBatch] = batchCounts[studentBatch]! + 1;
        batchTotalCharge[studentBatch] =
            batchTotalCharge[studentBatch]! + charge;
      }
    }

    // Update the state to rebuild the widget with the batch data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var currency = Provider.of<UserProvider>(context).currency;
    if (batchCounts.isEmpty) {
      return const Center(
          child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            'No Batch available.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
    }
    return Column(
      children: [
        for (var batchName in batchNames)
          Column(
            children: [
              MyListTile(
                title: batchName,
                subtitle:
                    'Total Students: ${batchCounts[batchName] ?? 0} | Batch Value: $currency${batchTotalCharge[batchName] ?? 0.0}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InsideBatchesScreen(batchName: batchName),
                    ),
                  );
                },
              ),
              const Divider(
                color: Colors.white24,
              ),
            ],
          ),
      ],
    );
  }
}
