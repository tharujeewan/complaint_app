import 'package:flutter/material.dart';

class Complaint {
  final String title;
  final String date;
  final String status;
  final IconData icon;

  const Complaint({
    required this.title,
    required this.date,
    required this.status,
    required this.icon,
  });
}
