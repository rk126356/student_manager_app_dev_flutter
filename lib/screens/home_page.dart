import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/components/NavBar.dart';
import 'package:student_manager_app_dev_flutter/components/home_batches_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_paid_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_students_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_unpaid_tab.dart';
import 'package:student_manager_app_dev_flutter/components/home_upcoming_tab.dart';
import 'package:student_manager_app_dev_flutter/components/last_month.dart';
import 'package:student_manager_app_dev_flutter/components/this_month.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/utils/bill_generator.dart';
import 'package:student_manager_app_dev_flutter/widgets/tab_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String myString; // Declare a field to hold the string

  const HomeScreen({Key? key, this.myString = ""}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMonthIndex = 0; // 0 for "This Month", 1 for "Last Month"
  int _selectedTabIndex = 0;
  bool _billGenerated = false;

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;

    if (!_billGenerated) {
      BillGenerator.generateBills(user.uid!);
      print("Bill Generated");
      _billGenerated = true;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
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
                            _selectedMonthIndex == 1
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
                                    color: _selectedMonthIndex != 0
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
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: LastMonth(),
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
                              icon: Icons.currency_rupee,
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
                              icon: Icons.currency_rupee,
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
                              icon: Icons.currency_rupee,
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

class LISTtileDemo extends StatelessWidget {
  const LISTtileDemo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.blueGrey, // Background color
      leading: const CircleAvatar(
        // Use a circular avatar for the leading icon
        backgroundColor: Colors.white, // Circle background color
        child: Icon(Icons.person,
            color: Colors.blueGrey), // Icon inside the circle
      ),
      title: const Text(
        'John Doe',
        style: TextStyle(
          color: Colors.white, // Text color
          fontSize: 18, // Font size
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
      subtitle: const Text(
        'Student ID: 12345',
        style: TextStyle(
          color: Colors.white70, // Subtitle text color
          fontSize: 14, // Subtitle font size
        ),
      ),
      trailing: const Icon(Icons.arrow_forward,
          color: Colors.white), // Trailing icon color
      onTap: () {
        // Handle onTap action for this student
      },
    );
  }
}
