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
          Consumer<UserComplaintProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onSelected: (value) {
                  provider.setFilterStatus(value);
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const {'val': 'all', 'label': 'All'},
                    const {'val': 'pending', 'label': 'Pending'},
                    const {'val': 'in progress', 'label': 'In Progress'},
                    const {'val': 'resolved', 'label': 'Resolved'},
                  ].map((item) {
                    final status = item['val']!;
                    final label = item['label']!;
                    final isSelected = provider.filterStatus == status;
                    return PopupMenuItem<String>(
                      value: status,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label),
                          if (isSelected) const Icon(Icons.check, size: 18, color: AppColors.primaryTeal),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<UserComplaintProvider>(
        builder: (context, provider, child) {
          final list = provider.filteredComplaints;
          
          if (provider.isLoading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null && list.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: AppColors.warning),
              ),
            );
          } else if (list.isEmpty) {
            return const Center(child: Text('No active issues found.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyComplaints(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ComplaintCard(complaint: list[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
