import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/models/complaint_model.dart';
import '../../user_panel/services/complaint_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/routes.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<ComplaintModel>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _complaintsFuture = ComplaintService.getComplaints();
    });
  }

  Future<void> _updateStatus(int? complaintId, String newStatus) async {
    if (complaintId == null) return;
    try {
      final success = await ComplaintService.updateComplaintStatus(complaintId, newStatus);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchData(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<ComplaintModel>>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading complaints: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No complaints found on the network.'));
          }

          final complaints = snapshot.data!;
          final total = complaints.length;
          final pending = complaints.where((c) => c.status.toLowerCase() == 'pending').length;
          final resolved = complaints.where((c) => c.status.toLowerCase() == 'resolved').length;

          return Column(
            children: [
              _buildStatsRow(total, pending, resolved),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    return _buildAdminComplaintCard(complaints[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(int total, int pending, int resolved) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatIndicator('Total', total, Colors.blue),
          _buildStatIndicator('Pending', pending, AppColors.warning),
          _buildStatIndicator('Resolved', resolved, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStatIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminComplaintCard(ComplaintModel complaint) {
    final statusList = ['pending', 'in progress', 'resolved'];
    String currentStatus = complaint.status.toLowerCase();
    
    // Safety check just in case backend has a rogue variable
    if (!statusList.contains(currentStatus)) {
      currentStatus = 'pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'ID: #${complaint.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(complaint.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentStatus,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryTealDark),
                      elevation: 16,
                      style: const TextStyle(
                        color: AppColors.primaryTealDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != currentStatus) {
                          _updateStatus(complaint.id, newValue);
                        }
                      },
                      items: statusList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    return '${date.day}/${date.month}/${date.year}';
  }
}
