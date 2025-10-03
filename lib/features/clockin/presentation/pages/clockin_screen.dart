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
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        child: BottomNavigation(
          selectedIndex: selectedNavIndex,
          onItemSelected: (index) {
            setState(() => selectedNavIndex = index);
          },
        ),
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
            // Calendar
            const SizedBox(height: 2),
            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) => setState(() => selectedDate = date),
              height: 72,
              horizontalPadding: 8,
              spacing: 8.0,
              borderRadius: 10,
              chipPadding: 18,
              dayNumberFontSize: 15,
              dayLabelFontSize: 10,
              textSpacing: 1,
            ),
            const SizedBox(height: 6),
            // Cards + Activity + Slider fit area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Rough base design height for this section
                  const baseHeight = 560.0; // tweakable
                  final scale = (constraints.maxHeight / baseHeight).clamp(
                    0.80,
                    1.0,
                  );
                  final gapSmall = 10.0 * scale;
                  final gapMedium = 14.0 * scale;
                  return Column(
                    children: [
                      // Time cards grid (fixed height portion)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
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
                                    compact: false,
                                    scale: scale,
                                    verticalPaddingNormal: 24,
                                    spacingBetweenTitleAndTime: 14,
                                    spacingBetweenTimeAndSubtitle: 10,
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: TimeCard(
                                    title: 'Clock Out',
                                    time: '-- : --',
                                    subtitle: 'Location',
                                    icon: Icons.logout,
                                    iconColor: AppColors.textSecondary,
                                    compact: false,
                                    scale: scale,
                                    verticalPaddingNormal: 24,
                                    spacingBetweenTitleAndTime: 14,
                                    spacingBetweenTimeAndSubtitle: 10,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: gapSmall),
                            Row(
                              children: [
                                Expanded(
                                  child: TimeCard(
                                    title: 'Work Time',
                                    time: workTime,
                                    subtitle: 'Avg 8 hours',
                                    icon: Icons.access_time,
                                    iconColor: AppColors.accent,
                                    compact: false,
                                    scale: scale,
                                    verticalPaddingNormal: 24,
                                    spacingBetweenTitleAndTime: 14,
                                    spacingBetweenTimeAndSubtitle: 10,
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: TimeCard(
                                    title: 'Break Time',
                                    time: breakTime,
                                    subtitle: 'Avg 1hr 20 mins',
                                    icon: Icons.coffee,
                                    iconColor: AppColors.warning,
                                    compact: false,
                                    scale: scale,
                                    verticalPaddingNormal: 24,
                                    spacingBetweenTitleAndTime: 14,
                                    spacingBetweenTimeAndSubtitle: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gapMedium),
                      // Scrollable activity list - increased size and dedicated scroll area
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.all(16 * scale),
                                child: ActivitySection(
                                  activities: activities,
                                  onViewAll: () {},
                                  scale: scale,
                                  iconContainerSize: 36,
                                  iconSize: 18,
                                  itemSpacing: 16,
                                  horizontalSpacing: 16,
                                  textSpacing: 4,
                                  actionFontSize: 16,
                                  dateFontSize: 12,
                                  timeFontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: gapSmall),
                      // Fixed slider at bottom - with proper spacing from navbar
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          0,
                          20 * scale,
                          20,
                        ),
                        child: ClockInButton(
                          isClockedIn: isClockedIn,
                          onToggle: _toggleClockIn,
                          onBreak: isClockedIn
                              ? () {
                                  // TODO: implement break logic (start/stop break)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Break button tapped'),
                                    ),
                                  );
                                }
                              : null,
                          bottomMargin: 0,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
