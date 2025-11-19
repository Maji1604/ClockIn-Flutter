import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final double height;
  final double horizontalPadding;
  final double spacing;
  final double borderRadius;
  final double chipPadding;
  final double dayNumberFontSize;
  final double dayLabelFontSize;
  final double textSpacing;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    this.onDateSelected,
    this.height = 52,
    this.horizontalPadding = 12,
    this.spacing = 6.0,
    this.borderRadius = 10,
    this.chipPadding = 4,
    this.dayNumberFontSize = 15,
    this.dayLabelFontSize = 10,
    this.textSpacing = 1,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (int i = 0; i < 7; i++) ...[
              Expanded(
                child: _DayChip(
                  date: startOfWeek.add(Duration(days: i)),
                  isSelected: _isSameDay(
                    startOfWeek.add(Duration(days: i)),
                    selectedDate,
                  ),
                  isFutureDate: startOfWeek
                      .add(Duration(days: i))
                      .isAfter(today),
                  onTap: () {
                    final selectedDay = startOfWeek.add(Duration(days: i));
                    // Only allow selecting today or past dates
                    if (!selectedDay.isAfter(today)) {
                      onDateSelected?.call(selectedDay);
                    }
                  },
                  height: height,
                  borderRadius: borderRadius,
                  chipPadding: chipPadding,
                  dayNumberFontSize: dayNumberFontSize,
                  dayLabelFontSize: dayLabelFontSize,
                  textSpacing: textSpacing,
                ),
              ),
              if (i != 6) SizedBox(width: spacing),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isFutureDate;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;
  final double chipPadding;
  final double dayNumberFontSize;
  final double dayLabelFontSize;
  final double textSpacing;

  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.isFutureDate,
    required this.onTap,
    required this.height,
    required this.borderRadius,
    required this.chipPadding,
    required this.dayNumberFontSize,
    required this.dayLabelFontSize,
    required this.textSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][date.weekday - 1];
    return GestureDetector(
      onTap: isFutureDate ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        decoration: BoxDecoration(
          color: isFutureDate
              ? AppColors.surfaceLight.withValues(alpha: 0.5)
              : isSelected
              ? AppColors.primary
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isFutureDate
                ? AppColors.borderLight.withValues(alpha: 0.5)
                : isSelected
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: chipPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                date.day.toString(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: dayNumberFontSize,
                  color: isFutureDate
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (textSpacing > 0) SizedBox(height: textSpacing),
            Flexible(
              child: Text(
                dayLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: dayLabelFontSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: isFutureDate
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
