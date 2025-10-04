import 'package:flutter/material.dart';
import '../widgets/holiday_list.dart';

class HolidayPage extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final List<HolidayItem>? customHolidays;

  const HolidayPage({
    super.key,
    required this.onBack,
    this.title = 'Holiday List',
    this.customHolidays,
  });

  List<HolidayItem> get _defaultHolidays => [
    HolidayItem(
      title: 'Saraswati Pooja',
      date: DateTime(2025, 10, 1),
      description: 'Saraswati Pooja',
      isHighlighted: false,
    ),
    HolidayItem(
      title: 'Saraswati Pooja',
      date: DateTime(2025, 10, 1),
      description: 'Saraswati Pooja',
      isHighlighted: false,
    ),
    HolidayItem(
      title: 'Saraswati Pooja',
      date: DateTime(2025, 10, 1),
      description: 'Saraswati Pooja',
      isHighlighted: false,
    ),
    HolidayItem(
      title: 'Saraswati Pooja',
      date: DateTime(2025, 10, 1),
      description: 'Saraswati Pooja',
      isHighlighted: true,
    ),
    HolidayItem(
      title: 'Saraswati Pooja',
      date: DateTime(2025, 10, 1),
      description: 'Saraswati Pooja',
      isHighlighted: true,
    ),
    HolidayItem(
      title: 'Saraswati Pooja',
      date: DateTime(2025, 10, 1),
      description: 'Saraswati Pooja',
      isHighlighted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: HolidayList(
            title: 'Holiday List',
            holidays: customHolidays ?? _defaultHolidays,
            onBack: onBack,
            itemSpacing: 6,
            horizontalPadding: 15,
            verticalPadding: 8,
            itemHeight: 82.5,
            dateFontSize: 14,
            descriptionFontSize: 12,
          ),
        ),
      ],
    );
  }
}
