import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class HolidayItem {
  final String title;
  final DateTime date;
  final String? description;
  final bool isHighlighted;

  const HolidayItem({
    required this.title,
    required this.date,
    this.description,
    this.isHighlighted = false,
  });
}

class HolidayList extends StatelessWidget {
  final String title;
  final List<HolidayItem> holidays;
  final VoidCallback? onBack;
  final double itemHeight;
  final double itemSpacing;
  final double horizontalPadding;
  final double verticalPadding;
  final double titleFontSize;
  final double dateFontSize;
  final double descriptionFontSize;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? itemBackgroundColor;
  final Color? highlightColor;

  const HolidayList({
    super.key,
    required this.title,
    required this.holidays,
    this.onBack,
    this.itemHeight = 68,
    this.itemSpacing = 8,
    this.horizontalPadding = 16,
    this.verticalPadding = 12,
    this.titleFontSize = 20,
    this.dateFontSize = 14,
    this.descriptionFontSize = 12,
    this.borderRadius = 12,
    this.backgroundColor,
    this.itemBackgroundColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header with optional back button and title
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: Row(
            children: [
              if (onBack != null) ...[
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Holiday items list (no outer card border, each item styled individually)
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              verticalPadding,
            ),
            itemCount: holidays.length,
            separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
            itemBuilder: (context, index) {
              final holiday = holidays[index];
              return _HolidayCard(
                holiday: holiday,
                minHeight: itemHeight,
                dateFontSize: dateFontSize,
                descriptionFontSize: descriptionFontSize,
                borderRadius: borderRadius,
                highlightColor: highlightColor ?? AppColors.primary,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HolidayCard extends StatelessWidget {
  final HolidayItem holiday;
  final double minHeight;
  final double dateFontSize;
  final double descriptionFontSize;
  final double borderRadius;
  final Color highlightColor;

  const _HolidayCard({
    required this.holiday,
    required this.minHeight,
    required this.dateFontSize,
    required this.descriptionFontSize,
    required this.borderRadius,
    required this.highlightColor,
  });

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final double railHeight = (minHeight - 30).clamp(28.0, minHeight - 20);
    const double railLeftInset = 12; // left inset inside the tile
    const double railWidth = 10; // pill thickness with rounded ends
    const double railToIconGap = 0; // cut side on the right, icon sits flush

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Left accent pill bar (grey for normal, blue for highlighted)
          Padding(
            padding: const EdgeInsets.only(left: railLeftInset),
            child: SizedBox(
              height: railHeight,
              width: railWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: holiday.isHighlighted
                      ? highlightColor
                      : cs.outlineVariant.withValues(alpha: 0.5),
                  // Half-cut oval: round only the left side, flat on the right
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(railWidth / 2),
                    bottomLeft: Radius.circular(railWidth / 2),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
              ),
            ),
          ),

          // Calendar icon
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(left: railToIconGap, right: 12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outlineVariant),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(holiday.date),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: dateFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    holiday.description ?? holiday.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: descriptionFontSize,
                      color: AppColors.textTertiary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Day of week
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              _formatDayOfWeek(holiday.date),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: descriptionFontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
