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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
  bool _isLoadingAttendance = false; // Flag to prevent duplicate loads
  String? attendanceId;
  Timer? _timer;
  Timer? _workTimer;
  Timer? _breakTimer;
  DateTime? _clockInDateTime;
  DateTime? _breakStartDateTime;
  double _totalBreakMinutes = 0;
  bool _isProcessingBreak = false;

  @override
  void initState() {
    super.initState();
    _updateTime();

    // Wrap in try-catch to prevent crashes
    try {
      // Add a small delay to ensure widget is fully mounted
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _loadAttendance(DateTime.now());
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error in initState: $e');
      AppLogger.debug('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workTimer?.cancel();
    _breakTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAttendance(DateTime date) async {
    // Prevent duplicate loads
    if (_isLoadingAttendance) {
      AppLogger.debug(
        'CLOCKIN_SCREEN: Already loading attendance, skipping...',
      );
      return;
    }

    _isLoadingAttendance = true;

    try {
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

      AppLogger.debug('CLOCKIN_SCREEN: userData = ${widget.userData}');
      final empId =
          widget.userData?['employee_id'] ??
          widget.userData?['emp_id'] ??
          widget.userData?['empId'];

      // Try to get token from widget parameter, or fallback to AuthBloc repository
      String? token = widget.token;
      if (token == null || token.isEmpty) {
        AppLogger.debug(
          'CLOCKIN_SCREEN: Token not provided, retrieving from storage...',
        );
        try {
          final authBloc = context.read<AuthBloc>();
          token = await authBloc.authRepository.getToken();
          AppLogger.debug(
            'CLOCKIN_SCREEN: Token retrieved from storage: ${token != null ? "YES" : "NO"}',
          );
        } catch (e) {
          AppLogger.error(
            'CLOCKIN_SCREEN: Failed to retrieve token from storage',
            e,
          );
        }
      }

      if (empId == null) {
        AppLogger.error('CLOCKIN_SCREEN: No employee ID found in userData!');
        _isLoadingAttendance = false;
        if (mounted) {
          SnackBarUtil.showError(context, 'Error: Employee ID not found');
        }
        return;
      }

      if (token == null || token.isEmpty) {
        AppLogger.error('CLOCKIN_SCREEN: No token found!');
        _isLoadingAttendance = false;
        if (mounted) {
          SnackBarUtil.showError(
            context,
            'Authentication error - please login again',
          );
        }
        return;
      }

      AppLogger.debug('CLOCKIN_SCREEN: empId = $empId, date = $date');

      // Dispatch BLoC event instead of HTTP call
      context.read<AttendanceBloc>().add(
        LoadTodayAttendance(token: token, empId: empId, date: date),
      );

      // Reset flag after a short delay to allow new loads if needed
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoadingAttendance = false;
          });
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error in _loadAttendance: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      _isLoadingAttendance = false;
      if (mounted) {
        SnackBarUtil.showError(context, 'Error loading attendance data');
      }
    }
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
          // Also subtract currently active break duration (not yet included in _totalBreakMinutes)
          double activeBreakMinutes = 0;
          if (isOnBreak && _breakStartDateTime != null) {
            activeBreakMinutes =
                now.difference(_breakStartDateTime!).inSeconds / 60;
          }
          final netWorkHours =
              workHours - ((_totalBreakMinutes + activeBreakMinutes) / 60);
          workTime = _formatHours(netWorkHours);
        });
      }
    });
  }

  void _startBreakTimer() {
    // If timer already running, do nothing (preserve start time for continuity)
    if (_breakTimer != null) return;
    // Preserve existing _breakStartDateTime if we already captured it on break start
    _breakStartDateTime ??= DateTime.now();
    AppLogger.debug(
      'BREAK_TIMER_START start=${_breakStartDateTime!.toIso8601String()} total_before=${_totalBreakMinutes.toStringAsFixed(2)}m',
    );
    final startingBreakMinutes =
        _totalBreakMinutes; // completed breaks before current active break
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_breakStartDateTime != null && mounted && isOnBreak) {
        final now = DateTime.now();
        final breakDuration = now.difference(_breakStartDateTime!);
        final currentBreakMinutes = breakDuration.inSeconds / 60;
        setState(() {
          breakTime = _formatMinutes(
            startingBreakMinutes + currentBreakMinutes,
          );
        });
      }
    });
  }

  void _stopBreakTimer() {
    if (_breakStartDateTime != null) {
      final now = DateTime.now();
      final active = now.difference(_breakStartDateTime!).inSeconds / 60;
      AppLogger.debug(
        'BREAK_TIMER_STOP start=${_breakStartDateTime!.toIso8601String()} active=${active.toStringAsFixed(2)}m total_before=${_totalBreakMinutes.toStringAsFixed(2)}m',
      );
    } else {
      AppLogger.debug(
        'BREAK_TIMER_STOP no-active total_before=${_totalBreakMinutes.toStringAsFixed(2)}m',
      );
    }
    _breakTimer?.cancel();
    _breakStartDateTime = null;
    _breakTimer = null;
  }

  void _stopWorkTimer() {
    _workTimer?.cancel();
    _clockInDateTime = null;
  }

  void _handleClockIn() {
    AppLogger.info('=== CLOCKIN_SCREEN: Handle Clock In ===');
    final empId =
        widget.userData?['employee_id'] ??
        widget.userData?['emp_id'] ??
        widget.userData?['empId'];
    final token = widget.token ?? '';

    if (empId == null) {
      AppLogger.error('CLOCKIN_SCREEN: No employee ID found for clock in!');
      return;
    }
    AppLogger.debug('CLOCKIN_SCREEN ClockIn: empId = $empId');

    // Dispatch BLoC event
    context.read<AttendanceBloc>().add(ClockIn(token: token, empId: empId));
  }

  void _handleClockOut() {
    AppLogger.info('=== CLOCKIN_SCREEN: Handle Clock Out ===');
    final empId =
        widget.userData?['employee_id'] ??
        widget.userData?['emp_id'] ??
        widget.userData?['empId'];
    final token = widget.token ?? '';

    if (empId == null) {
      AppLogger.error('CLOCKIN_SCREEN: No employee ID found for clock out!');
      return;
    }

    AppLogger.debug('CLOCKIN_SCREEN ClockOut: empId = $empId');

    // Dispatch BLoC event
    context.read<AttendanceBloc>().add(ClockOut(token: token, empId: empId));
  }

  void _handleBreak() {
    final empId =
        widget.userData?['employee_id'] ??
        widget.userData?['emp_id'] ??
        widget.userData?['empId'];
    final token = widget.token ?? '';

    if (empId == null) {
      AppLogger.error(
        'CLOCKIN_SCREEN: No employee ID found for break operation!',
      );
      return;
    }

    // Prevent double taps while processing
    if (_isProcessingBreak) return;
    _isProcessingBreak = true;

    if (isOnBreak) {
      // Optimistic UI: stop break timer and mark as not on break
      AppLogger.info('=== CLOCKIN_SCREEN: Ending break ===');
      setState(() {
        isOnBreak = false;
        _stopBreakTimer();
      });
      // Dispatch BLoC event (server will return updated totals)
      context.read<AttendanceBloc>().add(EndBreak(token: token, empId: empId));
    } else {
      // Optimistic UI: pause work display and start break timer immediately
      AppLogger.info('=== CLOCKIN_SCREEN: Starting break ===');
      setState(() {
        isOnBreak = true;
        _breakStartDateTime ??= DateTime.now();
        _startBreakTimer();
      });
      // Dispatch BLoC event
      context.read<AttendanceBloc>().add(
        StartBreak(token: token, empId: empId),
      );
    }
  }

  void _showActivityHistorySheet(
    BuildContext context,
    List<ActivityItem> activities,
    double scale,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Activity History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Activity list
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.withOpacity(
                                AppColors.primary,
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              activity.icon,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.action,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activity.date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            activity.time,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 16,
                ),
              ],
            ),
          );
        },
      ),
    );
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
          if (mounted) {
            SnackBarUtil.showSuccess(context, state.message);

            // Update UI based on successful operation
            if (state.attendance != null) {
              setState(() {
                final attendance = state.attendance!;
                attendanceId = attendance.id.toString();
                isClockedIn = attendance.isClockedIn;
                isOnBreak = attendance.isOnBreak;

                if (attendance.clockInTime != null) {
                  _clockInDateTime = DateTime.parse(
                    attendance.clockInTime!,
                  ).toLocal();
                  clockInTime = _formatTime(_clockInDateTime!);
                  // Start work timer if clocked in
                  if (isClockedIn) {
                    _startWorkTimer();
                  }
                }

                if (attendance.clockOutTime != null) {
                  final clockOutDateTime = DateTime.parse(
                    attendance.clockOutTime!,
                  ).toLocal();
                  clockOutTime = _formatTime(clockOutDateTime);
                  _stopWorkTimer();
                }

                // Calculate break and work time from hours
                final totalWorkHours = attendance.totalWorkHours ?? 0.0;
                final totalBreakHours = attendance.totalBreakHours ?? 0.0;
                _totalBreakMinutes =
                    totalBreakHours * 60; // completed breaks only
                breakTime = _formatMinutes(_totalBreakMinutes);
                AppLogger.debug(
                  'ATTENDANCE_APPLY opSuccess id=${attendance.id} isOnBreak=${attendance.isOnBreak} totalBreakHours=${totalBreakHours.toStringAsFixed(4)}h totalBreakMinutes=${_totalBreakMinutes.toStringAsFixed(2)}m totalWorkHours=${totalWorkHours.toStringAsFixed(4)}h activeBreakStart=${attendance.activeBreakStart}',
                );
                // Only overwrite workTime with backend value if user clocked out (backend finalized)
                if (attendance.clockOutTime != null) {
                  workTime = _formatHours(totalWorkHours);
                }

                // Manage break timer when operation success updates isOnBreak
                if (isOnBreak) {
                  // Resume break timer from server's active break start time if available
                  if (attendance.activeBreakStart != null) {
                    _breakStartDateTime = DateTime.parse(
                      attendance.activeBreakStart!,
                    );
                  }
                  _startBreakTimer();
                } else {
                  _stopBreakTimer();
                }

                // Clear processing flag after applying server truth
                _isProcessingBreak = false;
              });
            } else {
              // Even if no attendance payload (e.g., break start/end), clear processing flag
              setState(() {
                _isProcessingBreak = false;
              });
            }
          }
        }

        // Handle errors
        if (state is AttendanceError) {
          if (mounted) {
            SnackBarUtil.showError(context, state.message);
            // Reset loading flag on error
            setState(() {
              _isLoadingAttendance = false;
              isLoading = false;
              _isProcessingBreak = false;
            });
            // Reload to reconcile optimistic UI with server truth
            _loadAttendance(selectedDate);
          }
        }

        // Handle loaded state
        if (state is AttendanceLoaded) {
          AppLogger.info(
            '=== CLOCKIN_SCREEN: AttendanceLoaded state received ===',
          );
          AppLogger.debug('Activities count: ${state.activities.length}');
          if (mounted) {
            setState(() {
              isLoading = false;
              _isLoadingAttendance = false; // Reset loading flag

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
                  _clockInDateTime = DateTime.parse(
                    attendance.clockInTime!,
                  ).toLocal();
                  clockInTime = _formatTime(_clockInDateTime!);
                  // Start work timer only if viewing today and clocked in
                  if (isClockedIn && isToday) {
                    _startWorkTimer();
                  }
                }

                if (attendance.clockOutTime != null) {
                  final clockOutDateTime = DateTime.parse(
                    attendance.clockOutTime!,
                  ).toLocal();
                  clockOutTime = _formatTime(clockOutDateTime);
                }

                // Calculate break and work time from hours
                final totalWorkHours = attendance.totalWorkHours ?? 0.0;
                final totalBreakHours = attendance.totalBreakHours ?? 0.0;
                _totalBreakMinutes =
                    totalBreakHours * 60; // completed breaks only
                breakTime = _formatMinutes(_totalBreakMinutes);
                AppLogger.debug(
                  'ATTENDANCE_APPLY loaded id=${attendance.id} isOnBreak=${attendance.isOnBreak} totalBreakHours=${totalBreakHours.toStringAsFixed(4)}h totalBreakMinutes=${_totalBreakMinutes.toStringAsFixed(2)}m totalWorkHours=${totalWorkHours.toStringAsFixed(4)}h activeBreakStart=${attendance.activeBreakStart}',
                );
                // Only overwrite workTime if clocked out; otherwise live timer continues
                if (attendance.clockOutTime != null) {
                  workTime = _formatHours(totalWorkHours);
                }

                // Start or stop break timer based on current break status only for today
                if (isToday && isOnBreak) {
                  // Resume break timer from server's active break start time if available
                  if (attendance.activeBreakStart != null) {
                    _breakStartDateTime = DateTime.parse(
                      attendance.activeBreakStart!,
                    ).toLocal();
                  }
                  _startBreakTimer();
                } else {
                  _stopBreakTimer();
                }
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

              // Always update activities from state (even if just activities changed)
              activities = state.activities
                  .map(
                    (activity) => {
                      'action': activity.action,
                      'timestamp':
                          activity.timestamp ??
                          DateTime.now().toIso8601String(),
                      'details': activity.details ?? '',
                    },
                  )
                  .toList();
              AppLogger.debug('Activities updated: ${activities.length} items');
            });
          }
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
    // Convert activities from API to ActivityItem widgets and reverse to show newest first
    final activityItems = activities
        .map((activity) {
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
        })
        .toList()
        .reversed
        .toList();

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
        child: ProfilePage(
          onBack: () => setState(() => selectedNavIndex = 0),
          userData: widget.userData ?? {},
        ),
      );
    } else {
      // Home icon (index 0) -> Clock-in screen
      pageBody = SafeArea(
        child: Column(
          children: [
            // Header
            Builder(
              builder: (context) {
                final authState = context.watch<AuthBloc>().state;
                final designation = authState is AuthAuthenticated
                    ? authState.user.designation ?? 'Staff'
                    : 'Staff';
                return UserHeader(
                  name: widget.userData?['name'] ?? 'Employee',
                  role: designation,
                  onNotificationTap: () {},
                );
              },
            ),
            // Calendar
            const SizedBox(height: 2),
            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() => selectedDate = date);
                _loadAttendance(date);
              },
              height: 60,
              horizontalPadding: 12,
              spacing: 12.0,
              borderRadius: 12,
              chipPadding: 8,
              dayNumberFontSize: 32,
              dayLabelFontSize: 16,
              textSpacing: 6,
            ),
            const SizedBox(height: 6),
            // Cards + Activity area (scrollable)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Rough base design height for this section
                  const baseHeight = 600.0; // tweakable
                  final scale = (constraints.maxHeight / baseHeight).clamp(
                    0.75,
                    1.0,
                  );
                  final gapSmall = 10.0 * scale;
                  final gapMedium = 14.0 * scale;
                  return SingleChildScrollView(
                    child: Column(
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
                        // Activity header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Activity',
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (activityItems.length > 1)
                                GestureDetector(
                                  onTap: () => _showActivityHistorySheet(
                                    context,
                                    activityItems,
                                    scale,
                                  ),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        // Activity list container
                        Padding(
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
                            padding: EdgeInsets.all(16 * scale),
                            child: ActivitySection(
                              activities: activityItems,
                              onViewAll: () => _showActivityHistorySheet(
                                context,
                                activityItems,
                                scale,
                              ),
                              scale: scale,
                              iconContainerSize: 36,
                              iconSize: 18,
                              itemSpacing: 16,
                              horizontalSpacing: 16,
                              textSpacing: 4,
                              actionFontSize: 16,
                              dateFontSize: 12,
                              timeFontSize: 14,
                              showOnlyLast: true,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Fixed slider at bottom - always visible above navbar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClockInButton(
                isClockedIn: isClockedIn,
                isOnBreak: isOnBreak,
                onToggle: _toggleClockIn,
                onBreak: isClockedIn ? _handleBreak : null,
                bottomMargin: 0,
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
