import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/models/complaint_model.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForStatus(complaint.status),
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Title + Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Reported ${_formatDate(complaint.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          _buildStatusBadge(complaint.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bgColor = AppColors.warning.withOpacity(0.15);
        textColor = const Color(0xFFE65100);
        break;
      case 'IN PROGRESS':
        bgColor = AppColors.primaryTeal.withOpacity(0.15);
        textColor = AppColors.primaryTealDark;
        break;
      case 'RESOLVED':
        bgColor = AppColors.success.withOpacity(0.15);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    if (status.isEmpty) return Icons.report_problem_outlined;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.warning_amber_rounded;
      case 'IN PROGRESS':
        return Icons.construction;
      case 'RESOLVED':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    return '${date.day}/${date.month}/${date.year}';
  }
}
