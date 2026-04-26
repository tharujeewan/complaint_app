import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/models/complaint_model.dart';
import '../../../shared/widgets/complaint/complaint_status_badge.dart';
import '../../../shared/widgets/complaint/complaint_info_card.dart';
import '../../../shared/widgets/complaint/complaint_photo_section.dart';
import '../../../shared/widgets/complaint/complaint_timeline.dart';
import '../providers/admin_complaint_provider.dart';

class AdminComplaintScreen extends StatelessWidget {
  final ComplaintModel initialComplaint;

  const AdminComplaintScreen({super.key, required this.initialComplaint});

  @override
  Widget build(BuildContext context) {
    // Listen to the provider to get the updated complaint if status changes
    return Consumer<AdminComplaintProvider>(
      builder: (context, provider, child) {
        // Find the updated complaint from the list
        final complaint = provider.complaints.firstWhere(
          (c) => c.id == initialComplaint.id,
          orElse: () => initialComplaint,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Complaint Details'),
            backgroundColor: AppColors.primaryTeal,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ComplaintPhotoSection(photoFilename: complaint.photo),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ComplaintStatusBadge(status: complaint.status),
                          _buildStatusDropdown(context, complaint, provider),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        complaint.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Complaint #${complaint.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      ComplaintInfoCard(
                        icon: Icons.description_outlined,
                        title: 'Description',
                        child: Text(
                          complaint.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (complaint.location != null && complaint.location!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ComplaintInfoCard(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            child: Text(
                              complaint.location!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),

                      _buildTimeline(complaint),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context, ComplaintModel complaint, AdminComplaintProvider provider) {
    const statusList = ['pending', 'in progress', 'resolved'];
    final currentStatus = statusList.contains(complaint.status.toLowerCase())
        ? complaint.status.toLowerCase()
        : 'pending';

    return provider.isSubmitting
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
                items: statusList.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
              ),
            ),
          );
  }

  Widget _buildTimeline(ComplaintModel complaint) {
    int activeStep;
    switch (complaint.status.toLowerCase().trim()) {
      case 'resolved':
        activeStep = 2;
        break;
      case 'in progress':
      case 'in_progress':
        activeStep = 1;
        break;
      default:
        activeStep = 0;
    }

    final steps = [
      TimelineStepData(
        title: 'Pending',
        description: 'Complaint has been submitted and is awaiting review.',
        date: complaint.createdAt,
        color: const Color(0xFFE65100),
        isLast: false,
      ),
      TimelineStepData(
        title: 'In Progress',
        description: 'Your complaint is being looked into.',
        date: activeStep >= 1 ? complaint.updatedAt : null,
        color: AppColors.primaryTeal,
        isLast: false,
      ),
      TimelineStepData(
        title: 'Resolved',
        description: 'The issue has been resolved successfully.',
        date: activeStep >= 2 ? complaint.resolvedAt : null,
        color: const Color(0xFF2E7D32),
        isLast: true,
      ),
    ];

    return ComplaintTimeline(steps: steps, activeStepIndex: activeStep);
  }
}
