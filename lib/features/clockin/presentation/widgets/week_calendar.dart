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
    this.height = 44,
    this.horizontalPadding = 12,
    this.spacing = 6.0,
    this.borderRadius = 10,
    this.chipPadding = 2,
    this.dayNumberFontSize = 13,
    this.dayLabelFontSize = 9,
    this.textSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Make chips square: width = height
    final chipSize = height;

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, i) {
          final date = startOfWeek.add(Duration(days: i));
          return SizedBox(
            width: chipSize,
            height: chipSize,
            child: _DayChip(
              date: date,
              isSelected: _isSameDay(date, selectedDate),
              isFutureDate: date.isAfter(today),
              onTap: () {
                if (!date.isAfter(today) || _isSameDay(date, today)) {
                  onDateSelected?.call(date);
                }
              },
              height: chipSize,
              borderRadius: borderRadius,
              chipPadding: chipPadding,
              dayNumberFontSize: dayNumberFontSize,
              dayLabelFontSize: dayLabelFontSize,
              textSpacing: textSpacing,
            ),
          );
        },
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
              : Colors.white,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  date.day.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: dayNumberFontSize,
                    color: isFutureDate
                        ? AppColors.textSecondary.withValues(alpha: 0.4)
                        : isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (textSpacing > 0) SizedBox(height: textSpacing),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
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
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
