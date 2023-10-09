import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/widgets/Dashboard_board_widget.dart';

class ThisMonth extends StatelessWidget {
  const ThisMonth({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: DashboardBox(
                title: 'Paid',
                value: '₹1,500',
              ),
            ),
            Expanded(
              child: DashboardBox(
                title: 'Unpaid',
                value: '₹2,000',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: DashboardBox(
                title: 'Fees Paid',
                value: '5',
              ),
            ),
            Expanded(
              child: DashboardBox(
                title: 'Fees Unpaid',
                value: '22',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
