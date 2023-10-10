import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/components/NavBar.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/all_payments_tab.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/paid_payments_tab.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/unpaid_payments_tab.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
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
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: "All Payments",
            ),
            Tab(
              text: "Paid",
            ),
            Tab(
              text: "Unpaid",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // Display all payments here
          const AllPaymentsTab(),

          // Display paid payments here
          const PaidPaymentsTab(),

          // Display unpaid payments here
          const UnpaidPaymentsTab(),
        ],
      ),
    );
  }
}
