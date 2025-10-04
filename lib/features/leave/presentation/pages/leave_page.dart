import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class LeavePage extends StatefulWidget {
  final VoidCallback onBack;
  const LeavePage({super.key, required this.onBack});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  String _leaveType = 'CL';
  String _leavePeriod = 'Partial';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _showSuccessSheet();
  }

  Future<void> _showSuccessSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SuccessSheet(onDone: () => Navigator.of(context).pop());
      },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          _leavePeriod = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date Field
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
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
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),
                  // Leave Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Leave Description',
                      hintText: 'Description.....',
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
                      contentPadding: const EdgeInsets.all(12),
                    ),
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
                text: 'Apply Leave',
                onPressed: _submit,
              ),
            ),
          ),
        ),
      ],
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
              const SizedBox(height: 48),
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
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
