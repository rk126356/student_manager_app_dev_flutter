import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomePaidTab extends StatelessWidget {
  const HomePaidTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyListTile(
            title: "Abul", subtitle: "Paid ₹299 | 05/09/2023", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Babu", subtitle: "Paid ₹299 | 05/09/2023", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Rafikul", subtitle: "Paid ₹299 | 05/09/2023", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Hasan", subtitle: "Paid ₹299 | 05/09/2023", onTap: () {}),
      ],
    );
  }
}
