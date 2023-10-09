import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic onTap;

  const MyListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

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
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // Text color
          fontSize: 18, // Font size
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white70, // Subtitle text color
          fontSize: 14, // Subtitle font size
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward, color: Colors.white), // Trailing icon color
      onTap: onTap,
    );
  }
}
