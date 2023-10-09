import 'package:flutter/material.dart';

ElevatedButton TabButton(
    {required onPressed,
    required Color colors,
    required String title,
    required IconData icon}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: colors,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    icon: Icon(
      icon,
      color: Colors.white,
    ),
    label: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  );
}
