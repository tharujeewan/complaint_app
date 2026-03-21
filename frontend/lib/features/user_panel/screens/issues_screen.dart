import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/models/complaint_model.dart';
import '../widgets/complaint_card.dart';
import '../services/complaint_service.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  late Future<List<ComplaintModel>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = ComplaintService.getComplaints();
  }

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
      body: FutureBuilder<List<ComplaintModel>>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading complaints',
                style: TextStyle(color: AppColors.warning),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No complaints found.'),
            );
          }
          
          final complaints = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              return ComplaintCard(complaint: complaints[index]);
            },
          );
        },
      ),
    );
  }
}
