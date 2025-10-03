import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class ActivityItem {
  final String action;
  final String time;
  final String date;
  final IconData icon;

  const ActivityItem({
    required this.action,
    required this.time,
    required this.date,
    required this.icon,
  });
}

class ActivitySection extends StatelessWidget {
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;

  const ActivitySection({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(
            context,
            activity.action,
            activity.time,
            activity.date,
            activity.icon,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String action,
    String time,
    String date,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}