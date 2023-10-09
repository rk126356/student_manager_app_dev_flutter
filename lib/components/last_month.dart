import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/widgets/Dashboard_board_widget.dart';

class LastMonth extends StatelessWidget {
  const LastMonth({super.key});

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
                value: '₹1,00',
              ),
            ),
            Expanded(
              child: DashboardBox(
                title: 'Unpaid',
                value: '₹2,666',
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
                value: '9',
              ),
            ),
            Expanded(
              child: DashboardBox(
                title: 'Fees Unpaid',
                value: '77',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
