import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_formatter.dart';
import 'complaint_info_card.dart';

class TimelineStepData {
  final String title;
  final String description;
  final DateTime? date;
  final Color color;
  final bool isLast;

  const TimelineStepData({
    required this.title,
    required this.description,
    required this.color,
    required this.isLast,
    this.date,
  });
}

class ComplaintTimeline extends StatelessWidget {
  final List<TimelineStepData> steps;
  final int activeStepIndex;

  const ComplaintTimeline({
    super.key,
    required this.steps,
    required this.activeStepIndex,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ComplaintInfoCard(
        icon: Icons.timeline,
        title: 'Status Updates',
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 8),
          child: Column(
            children: List.generate(steps.length, (index) {
              return _TimelineStep(
                stepIndex: index,
                activeStep: activeStepIndex,
                data: steps[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final int stepIndex;
  final int activeStep;
  final TimelineStepData data;

  const _TimelineStep({
    required this.stepIndex,
    required this.activeStep,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = stepIndex < activeStep;
    final bool isCurrent = stepIndex == activeStep;
    final bool isActive = isCompleted || isCurrent;

    final Color dotColor = isActive ? data.color : Colors.grey.shade300;
    final Color lineColor = isCompleted ? data.color : Colors.grey.shade300;
    final Color textColor = isActive
        ? AppColors.textPrimary
        : AppColors.textSecondary.withOpacity(0.5);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot + Line ──────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 18 : 14,
                  height: isCurrent ? 18 : 14,
                  decoration: BoxDecoration(
                    color: isActive ? dotColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isCurrent ? 3 : 2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: dotColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                if (!data.isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Content ───────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: data.isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (isActive && data.date != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatDate(data.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? AppColors.textSecondary
                                : AppColors.textSecondary.withOpacity(0.4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive ? data.description : 'Waiting...',
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withOpacity(0.4),
                      height: 1.4,
                    ),
                  ),
                  if (isActive && data.date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDateTime(data.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
