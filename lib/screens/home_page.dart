import 'package:currency_picker/currency_picker.dart';
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

// Call the delayedCode function somewhere in your code to initiate the 5-second delay.

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
                              icon: Icons.upcoming,
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
                              icon: Icons.done,
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
                              icon: Icons.dangerous,
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
