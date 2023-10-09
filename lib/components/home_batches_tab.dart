import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/widgets/my_list_tile_widget.dart';

class HomeBatchesTab extends StatelessWidget {
  const HomeBatchesTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyListTile(
            title: "Morning Class", subtitle: "Students: 23", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(title: "Evening", subtitle: "Students: 44", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(title: "Class 11", subtitle: "Students: 11", onTap: () {}),
        const Divider(
          color: Colors.white24,
        ),
        MyListTile(title: "NEW", subtitle: "Students: 25", onTap: () {}),
      ],
    );
  }
}
