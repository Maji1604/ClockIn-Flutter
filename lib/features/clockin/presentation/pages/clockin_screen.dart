import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../../core/core.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/user_header.dart';
import '../widgets/week_calendar.dart';
import '../widgets/time_card.dart';
import '../widgets/activity_section.dart';
import '../widgets/clock_in_button.dart';
import '../widgets/bottom_navigation.dart';
import 'holiday_page.dart';
import '../../../leave/presentation/pages/leave_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../holiday/presentation/bloc/holiday_bloc.dart';
import '../../../holiday/data/repositories/holiday_repository_impl.dart';
import '../../../holiday/data/datasources/holiday_remote_data_source.dart';

import '../../../../core/utils/app_logger.dart';

class ClockInScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? token;

  const ClockInScreen({super.key, this.userData, this.token});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  bool isClockedIn = false;
  bool isOnBreak = false;
  String currentTime = "09:30 am";
  String clockInTime = "-- : --";
  String clockOutTime = "-- : --";
  String workTime = "00:00 hrs";
  String breakTime = "00:00 mins";
  DateTime selectedDate = DateTime.now();
  int selectedNavIndex = 0;
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;
  String? attendanceId;
  Timer? _timer;
  Timer? _workTimer;
  Timer? _breakTimer;
  DateTime? _clockInDateTime;
  DateTime? _breakStartDateTime;
  double _totalBreakMinutes = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadAttendance(DateTime.now());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workTimer?.cancel();
    _breakTimer?.cancel();
    super.dispose();
  }

  void _loadAttendance(DateTime date) {
    AppLogger.info(
      '=== CLOCKIN_SCREEN: Loading attendance for date: $date ===',
    );

    // Stop timers when loading different date
    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    if (!isToday) {
      _workTimer?.cancel();
      _breakTimer?.cancel();
    }

    final empId =
        widget.userData?['emp_id'] ?? widget.userData?['empId'] ?? 'EMP001';
    final token = widget.token ?? '';

    AppLogger.debug('CLOCKIN_SCREEN: empId = $empId, date = $date');

    // Dispatch BLoC event instead of HTTP call
    context.read<AttendanceBloc>().add(
      LoadTodayAttendance(token: token, empId: empId, date: date),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  String _formatHours(double hours) {
    final totalSeconds = (hours * 3600).round();
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} hrs';
  }

  String _formatMinutes(double minutes) {
    final totalSeconds = (minutes * 60).round();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} mins';
  }

  void _startWorkTimer() {
    _workTimer?.cancel();
    _workTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_clockInDateTime != null && mounted && isClockedIn) {
        setState(() {
          final now = DateTime.now();
          final workDuration = now.difference(_clockInDateTime!);
          final workHours = workDuration.inSeconds / 3600;
          final netWorkHours = workHours - (_totalBreakMinutes / 60);
          workTime = _formatHours(netWorkHours);
        });
      }
    });
  }

  void _startBreakTimer() {
    _breakTimer?.cancel();
    _breakStartDateTime = DateTime.now();
    final startingBreakMinutes = _totalBreakMinutes; // Capture current total
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_breakStartDateTime != null && mounted && isOnBreak) {
        setState(() {
          final now = DateTime.now();
          final breakDuration = now.difference(_breakStartDateTime!);
          final currentBreakMinutes = breakDuration.inSeconds / 60;
          breakTime = _formatMinutes(
            startingBreakMinutes + currentBreakMinutes,
          );
        });
      }
    });
  }

  void _stopBreakTimer() {
    _breakTimer?.cancel();
    _breakStartDateTime = null;
  }

  void _stopWorkTimer() {
    _workTimer?.cancel();
    _clockInDateTime = null;
  }

  void _handleClockIn() {
    AppLogger.info('=== CLOCKIN_SCREEN: Handle Clock In ===');
    final empId =
        widget.userData?['emp_id'] ?? widget.userData?['empId'] ?? 'EMP001';
    final token = widget.token ?? '';
    AppLogger.debug('CLOCKIN_SCREEN ClockIn: empId = $empId');

    // Dispatch BLoC event
    context.read<AttendanceBloc>().add(ClockIn(token: token, empId: empId));
  }

  void _handleClockOut() {
    AppLogger.info('=== CLOCKIN_SCREEN: Handle Clock Out ===');
    final empId =
        widget.userData?['emp_id'] ?? widget.userData?['empId'] ?? 'EMP001';
    final token = widget.token ?? '';
    AppLogger.debug('CLOCKIN_SCREEN ClockOut: empId = $empId');

    // Dispatch BLoC event
    context.read<AttendanceBloc>().add(ClockOut(token: token, empId: empId));
  }

  void _handleBreak() {
    final empId =
        widget.userData?['emp_id'] ?? widget.userData?['empId'] ?? 'EMP001';
    final token = widget.token ?? '';

    if (isOnBreak) {
      // End break - Dispatch BLoC event
      AppLogger.info('=== CLOCKIN_SCREEN: Ending break ===');
      context.read<AttendanceBloc>().add(EndBreak(token: token, empId: empId));
    } else {
      // Start break - Dispatch BLoC event
      AppLogger.info('=== CLOCKIN_SCREEN: Starting break ===');
      context.read<AttendanceBloc>().add(
        StartBreak(token: token, empId: empId),
      );
    }
  }

  void _updateTime() {
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          currentTime =
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}";
        });
      }
    });

    // Set initial time
    final now = DateTime.now();
    currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}";
  }

  void _toggleClockIn() {
    if (isClockedIn) {
      _handleClockOut();
    } else {
      _handleClockIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        // Handle operation success
        if (state is AttendanceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Update UI based on successful operation
          if (state.attendance != null) {
            setState(() {
              final attendance = state.attendance!;
              attendanceId = attendance.id.toString();
              isClockedIn = attendance.isClockedIn;
              isOnBreak = attendance.isOnBreak;

              if (attendance.clockInTime != null) {
                _clockInDateTime = DateTime.parse(attendance.clockInTime!);
                clockInTime = _formatTime(_clockInDateTime!);
                // Start work timer if clocked in
                if (isClockedIn) {
                  _startWorkTimer();
                }
              }

              if (attendance.clockOutTime != null) {
                final clockOutDateTime = DateTime.parse(
                  attendance.clockOutTime!,
                );
                clockOutTime = _formatTime(clockOutDateTime);
                _stopWorkTimer();
              }

              // Calculate break and work time from hours
              final totalWorkHours = attendance.totalWorkHours ?? 0.0;
              final totalBreakHours = attendance.totalBreakHours ?? 0.0;
              workTime = _formatHours(totalWorkHours);
              _totalBreakMinutes = totalBreakHours * 60;
              breakTime = _formatMinutes(_totalBreakMinutes);
            });
          }
        }

        // Handle errors
        if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        // Handle loaded state
        if (state is AttendanceLoaded) {
          setState(() {
            isLoading = false;

            // Check if viewing today
            final isToday =
                selectedDate.year == DateTime.now().year &&
                selectedDate.month == DateTime.now().month &&
                selectedDate.day == DateTime.now().day;

            if (state.attendance != null) {
              final attendance = state.attendance!;
              attendanceId = attendance.id.toString();
              isClockedIn = attendance.isClockedIn;
              isOnBreak = attendance.isOnBreak;

              if (attendance.clockInTime != null) {
                _clockInDateTime = DateTime.parse(attendance.clockInTime!);
                clockInTime = _formatTime(_clockInDateTime!);
                // Start work timer only if viewing today and clocked in
                if (isClockedIn && isToday) {
                  _startWorkTimer();
                }
              }

              if (attendance.clockOutTime != null) {
                final clockOutDateTime = DateTime.parse(
                  attendance.clockOutTime!,
                );
                clockOutTime = _formatTime(clockOutDateTime);
              }

              // Calculate break and work time from hours
              final totalWorkHours = attendance.totalWorkHours ?? 0.0;
              final totalBreakHours = attendance.totalBreakHours ?? 0.0;
              workTime = _formatHours(totalWorkHours);
              _totalBreakMinutes = totalBreakHours * 60;
              breakTime = _formatMinutes(_totalBreakMinutes);
            } else {
              // No attendance for this date
              attendanceId = null;
              isClockedIn = false;
              isOnBreak = false;
              clockInTime = '-- : --';
              clockOutTime = '-- : --';
              workTime = '00:00 hrs';
              breakTime = '00:00 mins';
              _clockInDateTime = null;
              _totalBreakMinutes = 0;
            }

            // Update activities from state
            activities = state.activities
                .map(
                  (activity) => {
                    'action': activity.action,
                    'timestamp':
                        activity.timestamp ?? DateTime.now().toIso8601String(),
                    'details': activity.details ?? '',
                  },
                )
                .toList();
          });
        }
      },
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          // Show loading indicator
          if (state is AttendanceLoading && isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return _buildMainContent();
        },
      ),
    );
  }

  Widget _buildMainContent() {
    // Convert activities from API to ActivityItem widgets
    final activityItems = activities.map((activity) {
      IconData icon;
      String action = activity['action'] ?? '';

      switch (action) {
        case 'check_in':
          icon = Icons.login;
          action = 'Check In';
          break;
        case 'check_out':
          icon = Icons.logout;
          action = 'Check Out';
          break;
        case 'break_start':
          icon = Icons.coffee;
          action = 'Break Start';
          break;
        case 'break_end':
          icon = Icons.coffee_outlined;
          action = 'Break End';
          break;
        default:
          icon = Icons.circle;
      }

      final timestamp = activity['timestamp'] != null
          ? DateTime.parse(activity['timestamp']).toLocal()
          : DateTime.now();

      return ActivityItem(
        action: action,
        time: _formatTime(timestamp),
        date:
            '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}/${timestamp.year}',
        icon: icon,
      );
    }).toList();

    // Determine body per bottom nav index
    final Widget pageBody;
    if (selectedNavIndex == 1) {
      pageBody = SafeArea(
        child: LeavePage(
          onBack: () => setState(() => selectedNavIndex = 0),
          userData: widget.userData ?? {},
        ),
      );
    } else if (selectedNavIndex == 2) {
      pageBody = SafeArea(
        child: BlocProvider(
          create: (context) => HolidayBloc(
            repository: HolidayRepository(
              remoteDataSource: HolidayRemoteDataSourceImpl(
                client: http.Client(),
              ),
            ),
          ),
          child: HolidayPage(
            title: 'Holiday List',
            onBack: () {
              setState(() => selectedNavIndex = 0);
            },
          ),
        ),
      );
    } else if (selectedNavIndex == 3) {
      pageBody = SafeArea(
        child: ProfilePage(onBack: () => setState(() => selectedNavIndex = 0)),
      );
    } else {
      // Home icon (index 0) -> Clock-in screen
      pageBody = SafeArea(
        child: Column(
          children: [
            // Header
            UserHeader(
              name: widget.userData?['name'] ?? 'Employee',
              role:
                  widget.userData?['designation'] ??
                  widget.userData?['department'] ??
                  'Staff',
              onNotificationTap: () {},
            ),
            // Calendar
            const SizedBox(height: 2),
            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() => selectedDate = date);
                _loadAttendance(date);
              },
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
                                    time: clockInTime,
                                    subtitle: 'Mobile App',
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
                                    time: clockOutTime,
                                    subtitle: 'Mobile App',
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.all(16 * scale),
                                child: ActivitySection(
                                  activities: activityItems,
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
                          isOnBreak: isOnBreak,
                          onToggle: _toggleClockIn,
                          onBreak: isClockedIn ? _handleBreak : null,
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
      );
    }

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
      body: pageBody,
    );
  }
}
