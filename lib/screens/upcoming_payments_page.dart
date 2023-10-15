import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/components/NavBar.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/upcoming_payments_in_seven_days_tab.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/upcoming_payments_this_month_tab.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/upcoming_payments_today_tab.dart';

class UpcomingPaymentsScreen extends StatefulWidget {
  const UpcomingPaymentsScreen({super.key});

  @override
  State<UpcomingPaymentsScreen> createState() => _UpcomingPaymentsScreenState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _UpcomingPaymentsScreenState extends State<UpcomingPaymentsScreen>
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
        title: const Text('Upcoming Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: "In 30 Days",
            ),
            Tab(
              text: "In 1-2 Days",
            ),
            Tab(
              text: "In 7 Days",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          Center(
            child: UpcomingPaymentsThisMonthTab(),
          ),
          Center(
            child: UpcomingPaymentsTodayTab(),
          ),
          Center(
            child: UpcomingPaymentsSevenDaysTab(),
          ),
        ],
      ),
    );
  }
}
