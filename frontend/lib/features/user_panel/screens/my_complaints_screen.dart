import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../providers/user_complaint_provider.dart';
import '../widgets/complaint_card.dart';
import '../../auth/providers/user_profile_provider.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<UserComplaintProvider, UserProfileProvider>(
        builder: (context, provider, profileProvider, child) {
          final currentUser = profileProvider.user;
          final complaints = provider.complaints
              .where((c) => c.userId == currentUser?.id)
              .toList();

          if (provider.isLoading && complaints.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && complaints.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (complaints.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchMyComplaints(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: complaints.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ComplaintCard(complaint: complaints[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
