import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../providers/user_complaint_provider.dart';
import '../widgets/complaint_card.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<UserComplaintProvider>().fetchMyComplaints();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<UserComplaintProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.complaints.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null && provider.complaints.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: AppColors.warning),
              ),
            );
          } else if (provider.complaints.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyComplaints(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.complaints.length,
              itemBuilder: (context, index) {
                return ComplaintCard(complaint: provider.complaints[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
