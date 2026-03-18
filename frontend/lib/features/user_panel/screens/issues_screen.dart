import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/complaint_model.dart';
import '../widgets/complaint_card.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  // Sample issues data (filtered/all complaints)
  static const List<Complaint> _allIssues = [
    Complaint(
      title: 'Massive Pothole on Main Road',
      date: 'Jul 17, 2025',
      status: 'PENDING',
      icon: Icons.warning_amber_rounded,
    ),
    Complaint(
      title: 'Garbage on Sidewalk',
      date: 'Jul 17, 2025',
      status: 'IN PROGRESS',
      icon: Icons.delete_outline,
    ),
    Complaint(
      title: 'Broken Streetlight near Chowk',
      date: 'Jul 19, 2025',
      status: 'RESOLVED',
      icon: Icons.lightbulb_outline,
    ),
    Complaint(
      title: 'Issues: Pothole on Road',
      date: 'Jul 17, 2025',
      status: 'PENDING',
      icon: Icons.report_problem_outlined,
    ),
    Complaint(
      title: 'Water Pipeline Leaking',
      date: 'Aug 02, 2025',
      status: 'IN PROGRESS',
      icon: Icons.water_drop_outlined,
    ),
    Complaint(
      title: 'Drainage Blockage',
      date: 'Sep 10, 2025',
      status: 'PENDING',
      icon: Icons.water_drop_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'All Issues',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allIssues.length,
        itemBuilder: (context, index) {
          return ComplaintCard(complaint: _allIssues[index]);
        },
      ),
    );
  }
}
