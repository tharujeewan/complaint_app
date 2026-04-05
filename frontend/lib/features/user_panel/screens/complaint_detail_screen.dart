import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/models/complaint_model.dart';
import '../../../shared/widgets/complaint/complaint_status_badge.dart';
import '../../../shared/widgets/complaint/complaint_info_card.dart';
import '../../../shared/widgets/complaint/complaint_photo_section.dart';
import '../../../shared/widgets/complaint/complaint_timeline.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
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
                  ComplaintStatusBadge(status: complaint.status),
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

                  _buildTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
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
        date: activeStep >= 1 ? complaint.updatedAt : null, // Uses generic updated_at or in_progress_at if added to model
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