import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/models/complaint_model.dart';
import '../providers/admin_complaint_provider.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminComplaintProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.complaints.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null && provider.complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
              ],
            ),
          );
        }

        final all = provider.complaints;
        final pending = all.where((c) => c.status.toLowerCase() == 'pending').toList();
        final inProgress = all.where((c) => c.status.toLowerCase() == 'in progress').toList();
        final resolved = all.where((c) => c.status.toLowerCase() == 'resolved').toList();

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              // Stats Banner
              _StatsBanner(total: all.length, pending: pending.length, resolved: resolved.length),

              // TabBar
              Container(
                color: Colors.white,
                child: TabBar(
                  isScrollable: false,
                  labelColor: AppColors.primaryTeal,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryTeal,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'All (${all.length})'),
                    Tab(text: 'Pending (${pending.length})'),
                    Tab(text: 'Progress (${inProgress.length})'),
                    Tab(text: 'Resolved (${resolved.length})'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _ComplaintList(complaints: all, provider: provider),
                    _ComplaintList(complaints: pending, provider: provider),
                    _ComplaintList(complaints: inProgress, provider: provider),
                    _ComplaintList(complaints: resolved, provider: provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Stats Banner ─────────────────────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final int total, pending, resolved;
  const _StatsBanner({required this.total, required this.pending, required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatChip(label: 'Total', count: total, color: AppColors.info),
          _StatChip(label: 'Pending', count: pending, color: AppColors.warning),
          _StatChip(label: 'Resolved', count: resolved, color: AppColors.success),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

// ── Complaint List ────────────────────────────────────────────────────────────
class _ComplaintList extends StatelessWidget {
  final List<ComplaintModel> complaints;
  final AdminComplaintProvider provider;

  const _ComplaintList({required this.complaints, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No complaints here.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchAllComplaints,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) => _AdminComplaintCard(
          complaint: complaints[index],
          provider: provider,
        ),
      ),
    );
  }
}

// ── Complaint Card ────────────────────────────────────────────────────────────
class _AdminComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final AdminComplaintProvider provider;

  const _AdminComplaintCard({required this.complaint, required this.provider});

  static const _statusList = ['pending', 'in progress', 'resolved'];

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppColors.success;
      case 'in progress':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _statusList.contains(complaint.status.toLowerCase())
        ? complaint.status.toLowerCase()
        : 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(currentStatus).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${complaint.id}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor(currentStatus)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              complaint.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (complaint.location != null && complaint.location!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      complaint.location!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      complaint.createdAt != null
                          ? '${complaint.createdAt!.day}/${complaint.createdAt!.month}/${complaint.createdAt!.year}'
                          : '—',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                // Status dropdown
                provider.isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentStatus,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryTeal, size: 18),
                            style: const TextStyle(
                              color: AppColors.primaryTealDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            onChanged: (String? newVal) {
                              if (newVal != null && newVal != currentStatus && complaint.id != null) {
                                provider.updateStatus(id: complaint.id!, status: newVal);
                              }
                            },
                            items: _statusList.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
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
}
