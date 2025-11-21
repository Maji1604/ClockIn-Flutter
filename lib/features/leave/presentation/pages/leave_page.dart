import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../bloc/leave_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../shared/widgets/outlined_label_text_field.dart';

class LeavePage extends StatefulWidget {
  final VoidCallback onBack;
  final Map<String, dynamic> userData;

  const LeavePage({super.key, required this.onBack, required this.userData});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  String _leaveType = 'CL';
  String _leavePeriod = 'Full Day';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_startDate);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Opens a date range picker. User can choose a single date (start==end)
  /// or a range. If a single date is chosen, `_endDate` will be null and
  /// the request will be treated as a single-day leave.
  Future<void> _selectDateRange() async {
    final first = DateTime.now();
    final last = DateTime.now().add(const Duration(days: 365));

    // For Partial and Half Day, only allow single date selection
    if (_leavePeriod != 'Full Day') {
      final picked = await showDatePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDate: _startDate,
      );

      if (picked != null) {
        setState(() {
          _selectedRange = null;
          _startDate = picked;
          _endDate = null;
          _dateController.text = _formatDate(picked);
        });
      }

      return;
    }

    // Full Day: allow picking a range
    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange:
          _selectedRange ?? DateTimeRange(start: _startDate, end: _startDate),
      saveText: 'Select',
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _startDate = picked.start;
        if (picked.start == picked.end) {
          _endDate = null;
          _dateController.text = _formatDate(picked.start);
        } else {
          _endDate = picked.end;
          _dateController.text =
              '${_formatDate(picked.start)} - ${_formatDate(picked.end)}';
        }
      });
    }
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Get token and empId from userData
    final token = await ServiceLocator.authRepository.getToken();
    final empId = widget.userData['employee_id'] as String;

    if (token == null) {
      SnackBarUtil.showError(
        context,
        'Authentication error. Please login again.',
      );
      return;
    }

    // Prevent duplicate leave applications: fetch existing leaves and ensure
    // there's no overlapping leave (unless that leave is 'rejected').
    try {
      final leaves = await context
          .read<LeaveBloc>()
          .repository
          .getEmployeeLeaves(token, empId);

      // Candidate range
      final candidateStart = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
      );
      final candidateEnd = _endDate != null
          ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
          : candidateStart;

      for (final leave in leaves) {
        final status = leave.status.toLowerCase();
        if (status == 'rejected') continue; // rejected leaves don't block

        DateTime leaveStart;
        DateTime leaveEnd;
        try {
          leaveStart = DateTime.parse(leave.startDate).toLocal();
        } catch (e) {
          // If parsing fails, skip this leave
          continue;
        }

        if (leave.endDate == null || (leave.endDate?.trim().isEmpty ?? true)) {
          leaveEnd = DateTime(
            leaveStart.year,
            leaveStart.month,
            leaveStart.day,
          );
        } else {
          try {
            leaveEnd = DateTime.parse(leave.endDate!).toLocal();
          } catch (e) {
            leaveEnd = DateTime(
              leaveStart.year,
              leaveStart.month,
              leaveStart.day,
            );
          }
        }

        // Normalize to dates (ignore time)
        leaveStart = DateTime(
          leaveStart.year,
          leaveStart.month,
          leaveStart.day,
        );
        leaveEnd = DateTime(leaveEnd.year, leaveEnd.month, leaveEnd.day);

        final overlaps =
            !(candidateEnd.isBefore(leaveStart) ||
                candidateStart.isAfter(leaveEnd));
        if (overlaps) {
          SnackBarUtil.showError(
            context,
            'A leave already exists for the selected date(s) (status: ${leave.status}). You cannot apply again unless it was rejected.',
          );
          return;
        }
      }
    } catch (e, st) {
      AppLogger.debug(
        'LEAVE: failed to validate existing leaves before submit: $e',
      );
      AppLogger.debug('Stack: $st');
      // If fetching leaves failed, allow submission to continue (server will validate too)
    }

    AppLogger.info('=== LEAVE SUBMISSION START ===');
    AppLogger.debug('Employee ID: $empId');
    AppLogger.debug('Leave Type: $_leaveType');
    AppLogger.debug('Leave Period: $_leavePeriod');
    AppLogger.debug('Start Date: ${_formatDateForApi(_startDate)}');
    AppLogger.debug(
      'End Date: ${_endDate != null ? _formatDateForApi(_endDate!) : 'null'}',
    );
    AppLogger.debug('Reason: ${_descriptionController.text}');

    // Dispatch submit leave event
    context.read<LeaveBloc>().add(
      SubmitLeaveEvent(
        token: token,
        empId: empId,
        leaveType: _leaveType,
        leavePeriod: _leavePeriod,
        startDate: _formatDateForApi(_startDate),
        endDate: _endDate != null ? _formatDateForApi(_endDate!) : null,
        reason: _descriptionController.text.trim(),
      ),
    );
  }

  void _handleBackButton() {
    // Dismiss keyboard first to prevent render overflow
    FocusScope.of(context).unfocus();

    // Small delay to ensure keyboard is dismissed before navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onBack();
    });
  }

  void _showLeaveHistorySheet() async {
    final token = await ServiceLocator.authRepository.getToken();
    final empId = widget.userData['employee_id'] as String;

    if (token == null) {
      SnackBarUtil.showError(
        context,
        'Authentication error. Please login again.',
      );
      return;
    }

    // Fetch leaves
    context.read<LeaveBloc>().add(
      FetchEmployeeLeavesEvent(token: token, empId: empId),
    );

    // Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LeaveHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LeaveBloc, LeaveState>(
      listener: (context, state) {
        AppLogger.info('=== LEAVE PAGE: BlocListener state change ===');
        AppLogger.debug('New state: ${state.runtimeType}');

        if (state is LeaveSubmitSuccess) {
          AppLogger.debug('LEAVE: Submission successful');

          // Clear form
          _descriptionController.clear();
          _startDate = DateTime.now();
          _endDate = null;
          _dateController.text = _formatDate(_startDate);
          _leaveType = 'CL';
          _leavePeriod = 'Full Day';

          // Show success sheet
          _showSuccessSheet();
        } else if (state is LeaveError) {
          AppLogger.debug('LEAVE: Error - ${state.message}');
          SnackBarUtil.showError(context, state.message);
        }
      },
      child: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          AppLogger.debug(
            'LEAVE: BlocBuilder rebuilding with state: ${state.runtimeType}',
          );
          final isLoading = state is LeaveLoading;
          AppLogger.debug('LEAVE: isLoading = $isLoading');

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SizedBox(
                  height: 36,
                  child: Stack(
                    children: [
                      // Back button on the left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: _handleBackButton,
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
                      ),
                      // Centered title
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Apply Leave',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // History button on the right
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _showLeaveHistorySheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.history_rounded,
                              size: 20,
                              color: AppColors.textPrimary.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Leave Type Dropdown
                        DropdownButtonFormField<String>(
                          value: _leaveType,
                          decoration: InputDecoration(
                            labelText: 'Leave Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'CL', child: Text('CL')),
                            DropdownMenuItem(value: 'SL', child: Text('SL')),
                            DropdownMenuItem(value: 'PL', child: Text('PL')),
                            DropdownMenuItem(value: 'ML', child: Text('ML')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _leaveType = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Leave Period Dropdown
                        DropdownButtonFormField<String>(
                          value: _leavePeriod,
                          decoration: InputDecoration(
                            labelText: 'Leave Period',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Full Day',
                              child: Text('Full Day'),
                            ),
                            DropdownMenuItem(
                              value: 'Partial',
                              child: Text('Partial'),
                            ),
                            DropdownMenuItem(
                              value: 'Half Day',
                              child: Text('Half Day'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                // Update leave period and ensure date selection mode matches
                                _leavePeriod = value;
                                // If switched to a non-full-day period, collapse any selected range
                                if (_leavePeriod != 'Full Day') {
                                  if (_selectedRange != null) {
                                    _startDate = _selectedRange!.start;
                                  }
                                  _selectedRange = null;
                                  _endDate = null;
                                  _dateController.text = _formatDate(
                                    _startDate,
                                  );
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Date Field (single or range)
                        OutlinedLabelTextField(
                          label: 'Date',
                          hintText: 'Tap to select date or range',
                          controller: _dateController,
                          readOnly: true,
                          onTap: _selectDateRange,
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Leave Description
                        OutlinedLabelTextField(
                          label: 'Leave Description',
                          hintText: 'Description.....',
                          controller: _descriptionController,
                          maxLines: 3,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter description'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom button
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _PrimaryGradientButton(
                      text: isLoading ? 'Submitting...' : 'Apply Leave',
                      onPressed: isLoading ? () {} : _submit,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSuccessSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SuccessSheet(
          onDone: () {
            Navigator.of(context).pop();
            // Optionally navigate to leave history or refresh
          },
        );
      },
    );
  }
}

class _PrimaryGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _PrimaryGradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: AppColors.textOnPrimary,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessSheet extends StatefulWidget {
  final VoidCallback onDone;
  const _SuccessSheet({required this.onDone});

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _checkController;
  late AnimationController _rippleController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkRotationAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rippleOpacityAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _buttonSlideAnimation;
  late Animation<Offset> _buttonOffsetAnimation;

  @override
  void initState() {
    super.initState();

    // Main controller for orchestrating animations
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Check animation controller
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Ripple animation controller
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Check circle animations
    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _checkRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack),
    );

    // Ripple animations
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _rippleOpacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Text fade animations with staggered timing
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Button slide up animation
    _buttonSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _buttonOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
          ),
        );

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _checkController.forward();
        _mainController.forward();
        // Start ripple effect after check animation completes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _rippleController.repeat();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _checkController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.45,
      maxChildSize: 0.65,
      builder: (context, controller) {
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
              const SizedBox(height: 24),
              // Animated checkmark circle with ripple effect
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple circles
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // First ripple circle
                            Container(
                              width: 80 + (80 * _rippleAnimation.value),
                              height: 80 + (80 * _rippleAnimation.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4A90E2).withValues(
                                    alpha: (_rippleOpacityAnimation.value * 0.4)
                                        .clamp(0.0, 1.0),
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Second ripple circle (delayed)
                            Container(
                              width: 80 + (60 * _rippleAnimation.value),
                              height: 80 + (60 * _rippleAnimation.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4A90E2).withValues(
                                    alpha: (_rippleOpacityAnimation.value * 0.6)
                                        .clamp(0.0, 1.0),
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Third ripple circle (innermost)
                            Container(
                              width: 80 + (40 * _rippleAnimation.value),
                              height: 80 + (40 * _rippleAnimation.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4A90E2).withValues(
                                    alpha: (_rippleOpacityAnimation.value * 0.8)
                                        .clamp(0.0, 1.0),
                                  ),
                                  width: 1,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // Main checkmark circle
                    AnimatedBuilder(
                      animation: _checkController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _checkScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _checkRotationAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4A90E2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4A90E2,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 36,
                                  weight: 600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Animated title
              AnimatedBuilder(
                animation: _titleFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleFadeAnimation.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        20 * (1 - _titleFadeAnimation.value.clamp(0.0, 1.0)),
                      ),
                      child: const Text(
                        'Leave Applied Successfully',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Animated subtitle
              AnimatedBuilder(
                animation: _subtitleFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _subtitleFadeAnimation.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        20 * (1 - _subtitleFadeAnimation.value.clamp(0.0, 1.0)),
                      ),
                      child: const Text(
                        'Your leave has been applied\nsuccessfully',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Animated button
              AnimatedBuilder(
                animation: _buttonSlideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _buttonOffsetAnimation,
                    child: Opacity(
                      opacity: _buttonSlideAnimation.value.clamp(0.0, 1.0),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          0,
                          24,
                          32 + MediaQuery.of(context).viewPadding.bottom,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: widget.onDone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Leave History Bottom Sheet Widget
class _LeaveHistorySheet extends StatelessWidget {
  const _LeaveHistorySheet();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
      default:
        return Icons.access_time_rounded;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String _getLeaveTypeLabel(String type) {
    switch (type) {
      case 'CL':
        return 'Casual Leave';
      case 'SL':
        return 'Sick Leave';
      case 'PL':
        return 'Privilege Leave';
      case 'ML':
        return 'Maternity Leave';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Leave History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: BlocBuilder<LeaveBloc, LeaveState>(
              builder: (context, state) {
                if (state is LeaveLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                } else if (state is LeavesLoadSuccess) {
                  if (state.leaves.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No leave history found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.leaves.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final leave = state.leaves[index];
                      final statusColor = _getStatusColor(leave.status);
                      final statusIcon = _getStatusIcon(leave.status);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusIcon,
                                        size: 14,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        leave.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getLeaveTypeLabel(leave.leaveType),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Date row
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(leave.startDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (leave.endDate != null) ...[
                                  Text(
                                    ' - ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _formatDate(leave.endDate!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    leave.leavePeriod,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Reason
                            Text(
                              leave.reason,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Admin comments if available
                            if (leave.adminComments != null &&
                                leave.adminComments!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.comment_rounded,
                                      size: 14,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        leave.adminComments!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[900],
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Applied date
                            const SizedBox(height: 8),
                            Text(
                              'Applied: ${_formatDate(leave.createdAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is LeaveError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load leave history',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
