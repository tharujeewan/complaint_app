import 'package:flutter/material.dart';
import '../../../core/constants/complaint_status_config.dart';

class ComplaintStatusBadge extends StatelessWidget {
  final String status;

  const ComplaintStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final style = ComplaintStatusConfig.getStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 18, color: style.color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: style.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
