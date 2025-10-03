import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../widgets/user_header.dart';
import '../widgets/week_calendar.dart';
import '../widgets/time_card.dart';
import '../widgets/activity_section.dart';
import '../widgets/clock_in_button.dart';
import '../widgets/bottom_navigation.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  bool isClockedIn = false;
  String currentTime = "09:30 am";
  String workTime = "04:20 hrs";
  String breakTime = "00:30 mins";
  DateTime selectedDate = DateTime.now();
  int selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    // Update time every minute
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          currentTime =
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}";
        });
        _updateTime();
      }
    });
  }

  void _toggleClockIn() {
    setState(() {
      isClockedIn = !isClockedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activities = [
      const ActivityItem(
        action: 'Check In',
        time: '9:30 am',
        date: 'Oct 01, 2025',
        icon: Icons.login,
      ),
      const ActivityItem(
        action: 'Break In',
        time: '11:00 am',
        date: 'Oct 01, 2025',
        icon: Icons.coffee,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedNavIndex,
        onItemSelected: (index) {
          setState(() => selectedNavIndex = index);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            UserHeader(
              name: 'John Doe',
              role: 'App Developer',
              onNotificationTap: () {},
            ),
            // Calendar (enlarged) + reduced spacing below
            const SizedBox(height: 4),
            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) => setState(() => selectedDate = date),
            ),
            const SizedBox(height: 16),
            // Clock cards area (fixed height portion, not scrollable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TimeCard(
                          title: 'Clock In',
                          time: currentTime,
                          subtitle: 'Location',
                          icon: Icons.login,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TimeCard(
                          title: 'Clock Out',
                          time: '-- : --',
                          subtitle: 'Location',
                          icon: Icons.logout,
                          iconColor: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TimeCard(
                          title: 'Work Time',
                          time: workTime,
                          subtitle: 'Avg 8 hours',
                          icon: Icons.access_time,
                          iconColor: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TimeCard(
                          title: 'Break Time',
                          time: breakTime,
                          subtitle: 'Avg 1hr 20 mins',
                          icon: Icons.coffee,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Remaining space: scroll only activity & swipe button
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ActivitySection(activities: activities, onViewAll: () {}),
                    const SizedBox(height: 24),
                    ClockInButton(
                      isClockedIn: isClockedIn,
                      onPressed: _toggleClockIn,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
