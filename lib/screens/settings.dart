import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor:
            Colors.deepPurple, // Change the app bar color to your preference
      ),
      body: Container(
        color: Colors
            .grey.shade200, // Change the background color to your preference
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 5,
            ),
            _buildSettingItem(
              leadingIcon: Icons.description,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
            ),
            _buildSettingItem(
              leadingIcon: Icons.security,
              title: 'Terms and Conditions',
              subtitle: 'Read our terms and conditions',
            ),
            _buildSettingItem(
              leadingIcon: Icons.info,
              title: 'About',
              subtitle: 'Learn more about the app',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData leadingIcon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: Colors.deepPurple,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.keyboard_arrow_right, color: Colors.deepPurple),
        onTap: () {
          // Handle the tap on the setting
        },
      ),
    );
  }
}
