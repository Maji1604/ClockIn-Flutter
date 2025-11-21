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
  final double scale;
  final double iconContainerSize;
  final double iconSize;
  final double iconBorderRadius;
  final double itemSpacing;
  final double horizontalSpacing;
  final double textSpacing;
  final double emptyStatePadding;
  final double actionFontSize;
  final double dateFontSize;
  final double timeFontSize;
  final bool showOnlyLast;

  const ActivitySection({
    super.key,
    required this.activities,
    this.onViewAll,
    this.scale = 1.0,
    this.iconContainerSize = 28,
    this.iconSize = 14,
    this.iconBorderRadius = 8,
    this.itemSpacing = 10,
    this.horizontalSpacing = 12,
    this.textSpacing = 2,
    this.emptyStatePadding = 8,
    this.actionFontSize = 14,
    this.dateFontSize = 10,
    this.timeFontSize = 12,
    this.showOnlyLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayActivities = showOnlyLast && activities.isNotEmpty
        ? [activities.last]
        : activities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity items
        for (int i = 0; i < displayActivities.length; i++) ...[
          _buildActivityItem(context, displayActivities[i], theme),
          if (i != displayActivities.length - 1)
            SizedBox(height: itemSpacing * scale),
        ],
        if (activities.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: emptyStatePadding * scale),
            child: Text(
              'No activity yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize:
                    (theme.textTheme.bodySmall?.fontSize ?? timeFontSize) *
                    scale,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    ActivityItem item,
    ThemeData theme,
  ) {
    final iconSide = iconContainerSize * scale;
    final scaledIconSize = (iconSize * scale).clamp(10, iconSize).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSide,
          height: iconSide,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.withOpacity(AppColors.primary, 0.1),
            borderRadius: BorderRadius.circular(iconBorderRadius),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            child: Icon(
              item.icon,
              size: scaledIconSize,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: horizontalSpacing * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.action,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize:
                      (theme.textTheme.bodyMedium?.fontSize ?? actionFontSize) *
                      scale,
                ),
              ),
              SizedBox(height: textSpacing * scale),
              Text(
                item.date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: (dateFontSize * scale).clamp(9, dateFontSize),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: horizontalSpacing * scale),
        Text(
          item.time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize:
                (theme.textTheme.bodySmall?.fontSize ?? timeFontSize) * scale,
          ),
        ),
      ],
    );
  }
}
