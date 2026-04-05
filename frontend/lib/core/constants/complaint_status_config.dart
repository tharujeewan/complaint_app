import 'package:flutter/material.dart';
import 'colors.dart';

class StatusStyle {
  final Color color;
  final IconData icon;

  const StatusStyle({required this.color, required this.icon});
}

/// A central configuration map for complaint statuses to satisfy the Open/Closed Principle.
/// Adding a new status like 'CANCELLED' only requires a new entry here,
/// and it instantly updates badges worldwide.
class ComplaintStatusConfig {
  static const Map<String, StatusStyle> styles = {
    'PENDING': StatusStyle(
      color: Color(0xFFE65100), // Dark Orange
      icon: Icons.warning_amber_rounded,
    ),
    'IN PROGRESS': StatusStyle(
      color: AppColors.primaryTeal,
      icon: Icons.construction,
    ),
    'IN_PROGRESS': StatusStyle(
      color: AppColors.primaryTeal,
      icon: Icons.construction,
    ),
    'RESOLVED': StatusStyle(
      color: Color(0xFF2E7D32), // Dark Green
      icon: Icons.check_circle_outline,
    ),
    'CANCELLED': StatusStyle(
      color: Colors.red,
      icon: Icons.cancel_outlined,
    ),
  };

  /// Fallback getter that returns a grey status if it's unknown.
  static StatusStyle getStyle(String status) {
    final key = status.trim().toUpperCase();
    return styles[key] ?? const StatusStyle(
      color: Colors.grey,
      icon: Icons.info_outline,
    );
  }
}
