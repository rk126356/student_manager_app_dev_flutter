import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomeUpcomingTab extends StatelessWidget {
  const HomeUpcomingTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyListTile(
            title: "Abul", subtitle: "RS: 299 | 05/09/2023", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Babu", subtitle: "RS: 299 | 05/09/2023", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Rafikul", subtitle: "RS: 299 | 05/09/2023", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(
            title: "Hasan", subtitle: "RS: 299 | 05/09/2023", onTap: () {}),
      ],
    );
  }
}
