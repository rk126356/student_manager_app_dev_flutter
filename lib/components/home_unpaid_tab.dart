import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomeUnpaidTab extends StatelessWidget {
  const HomeUnpaidTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyListTile(
            title: "Abul", subtitle: "Unpaid ₹400 | 2 Months", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Babu", subtitle: "Unpaid ₹299 | 1 Months", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Rafikul", subtitle: "Unpaid ₹600 | 3 Months", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Hasan", subtitle: "Unpaid ₹299 | 1 Months", onTap: () {}),
      ],
    );
  }
}
