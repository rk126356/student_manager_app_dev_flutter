import 'package:flutter/material.dart';

class HomeStudentListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function() onTap;
  final VoidCallback onPaymentsTap;
  final VoidCallback onEditTap;

  HomeStudentListTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onPaymentsTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          onTap: onTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.payment,
                  color: Colors.blue, // Customize icon color
                ),
                onPressed: onPaymentsTap,
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.green, // Customize icon color
                ),
                onPressed: onEditTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
