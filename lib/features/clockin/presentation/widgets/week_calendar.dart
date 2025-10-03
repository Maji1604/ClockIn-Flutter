import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final date = startOfWeek.add(Duration(days: i));
            final selected = _isSameDay(date, selectedDate);
            return _DayChip(
              date: date,
              isSelected: selected,
              onTap: () => onDateSelected?.call(date),
            );
        }),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;
  const _DayChip({required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday-1];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 74,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}