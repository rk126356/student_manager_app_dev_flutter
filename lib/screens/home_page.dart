import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/components/NavBar.dart';
import 'package:student_manager_app_dev_flutter/components/all_time.dart';
import 'package:student_manager_app_dev_flutter/components/home_batches_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_paid_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_students_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_unpaid_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_upcoming_tab.dart';
import 'package:student_manager_app_dev_flutter/components/last_month.dart';
import 'package:student_manager_app_dev_flutter/components/this_month.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/utils/bill_generator.dart';
import 'package:student_manager_app_dev_flutter/widgets/tab_button_widget.dart';
import 'package:student_manager_app_dev_flutter/widgets/update_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMonthIndex = 0;
  int _selectedTabIndex = 0;
  bool _billGenerated = false;

  updateAppLaunched(user) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String currentVersion = packageInfo.version;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        // Check if the document exists
        Map<String, dynamic>? data = snapshot.data();
        if (data != null && data.containsKey('noOfTimeAppLaunched')) {
          int noOfTimeAppLaunched = data['noOfTimeAppLaunched'];

          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'noOfTimeAppLaunched': noOfTimeAppLaunched + 1,
            'appVersion': currentVersion,
          });
        } else {
          print('Field noOfTimeAppLaunched not found or is null.');
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'noOfTimeAppLaunched': 1,
            'appVersion': currentVersion,
          });
        }
      } else {
        print('Document does not exist.');
      }
    });

    FirebaseFirestore.instance
        .collection('appInfo')
        .doc('t24RkgPVXADO1i9wu3YJ')
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        // Check if the document exists
        Map<String, dynamic>? data = snapshot.data();
        if (data != null) {
          String version = data['version'];
          bool isUpdateAvailable = data['isUpdateAvailable'];
          String updateMessage = data['updateMessage'];
          String appLink = data['appLink'];
          bool isForceUpdate = data['isForceUpdate'];
          if (isUpdateAvailable && currentVersion != version) {
            void showUpdateDialog(BuildContext context) {
              showDialog(
                context: context,
                barrierDismissible: isForceUpdate,
                builder: (context) {
                  return UpdateDialog(
                    version: version,
                    description: updateMessage,
                    appLink: appLink,
                    allowDismissal: !isForceUpdate,
                  );
                },
              );
            }

            showUpdateDialog(context);
          }
        } else {
          print('Field version not found or is null.');
        }
      } else {
        print('Document does not exist.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var pvdata = Provider.of<UserProvider>(context, listen: false);

    if (pvdata.fetchNoOfStudents) {
      CollectionReference paymentsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(pvdata.userData.uid)
          .collection('students');

      paymentsCollection.get().then((QuerySnapshot querySnapshot) {
        int noOfStudents = querySnapshot.size;
        pvdata.setNoOfStudents(noOfStudents);

        FirebaseFirestore.instance
            .collection('users')
            .doc(pvdata.userData.uid)
            .update({
          'totalStudents': noOfStudents,
        });
      }).catchError((error) {
        print('Error getting no of students: $error');
      });
    }

    if (pvdata.isNewOpen) {
      updateAppLaunched(user);
      pvdata.setIsNewOpen(false);
    }

    if (!_billGenerated) {
      // BillGenerator.generateBills(user.uid!);
      generateBills(user.uid!);

      _billGenerated = true;
    }

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
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search-student');
            },
          ),
        ],
        title: const Text("Home"),
      ),
      drawer: const NavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 400),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "EARNINGS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          isSelected: [
                            _selectedMonthIndex == 0,
                            _selectedMonthIndex == 1,
                            _selectedMonthIndex == 2
                          ],
                          onPressed: (index) {
                            setState(() {
                              _selectedMonthIndex = index;
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "This Month",
                                style: TextStyle(
                                    color: _selectedMonthIndex == 0
                                        ? Colors.white
                                        : Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Last Month",
                                style: TextStyle(
                                    color: _selectedMonthIndex == 1
                                        ? Colors.white
                                        : Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "All Time",
                                style: TextStyle(
                                    color: _selectedMonthIndex == 2
                                        ? Colors.white
                                        : Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _selectedMonthIndex == 0
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ThisMonth(),
                          )
                        : _selectedMonthIndex == 1
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LastMonth(),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AllTime(),
                              ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "RECENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TabButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTabIndex = 0;
                                });
                              },
                              title: 'Upcoming',
                              colors: _selectedTabIndex == 0
                                  ? Colors.blue
                                  : Colors.grey,
                              icon: Icons.arrow_upward,
                            ),
                            const SizedBox(width: 10),
                            TabButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTabIndex = 1;
                                });
                              },
                              title: 'Paid',
                              colors: _selectedTabIndex == 1
                                  ? Colors.blue
                                  : Colors.grey,
                              icon: Icons.check_circle,
                            ),
                            const SizedBox(width: 10),
                            TabButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTabIndex = 2;
                                });
                              },
                              title: 'Unpaid',
                              colors: _selectedTabIndex == 2
                                  ? Colors.blue
                                  : Colors.grey,
                              icon: Icons.cancel,
                            ),
                            const SizedBox(width: 10),
                            TabButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTabIndex = 3;
                                });
                              },
                              title: 'Batches',
                              colors: _selectedTabIndex == 3
                                  ? Colors.blue
                                  : Colors.grey,
                              icon: Icons.school,
                            ),
                            const SizedBox(width: 10),
                            TabButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTabIndex = 4;
                                });
                              },
                              title: 'Students',
                              colors: _selectedTabIndex == 4
                                  ? Colors.blue
                                  : Colors.grey,
                              icon: Icons.person,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                    _selectedTabIndex == 0
                        ? const HomeUpcomingTab()
                        : _selectedTabIndex == 1
                            ? const HomePaidTab()
                            : _selectedTabIndex == 2
                                ? const HomeUnpaidTab()
                                : _selectedTabIndex == 3
                                    ? const HomeBatchesTab()
                                    : const HomeStudentsTab()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
