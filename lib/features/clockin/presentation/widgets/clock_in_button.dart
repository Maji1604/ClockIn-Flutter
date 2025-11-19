import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// A simplified swipe button that only supports a single full swipe
/// to toggle clock-in / clock-out. Partial break logic removed per request.
class ClockInButton extends StatefulWidget {
  final bool isClockedIn;
  final bool isOnBreak;
  final VoidCallback onToggle;
  final VoidCallback? onBreak; // optional break action when clocked in
  final double trackHeight;
  final double thumbSize;
  final double horizontalInset;
  final double fullThreshold;
  final double borderRadius;
  final double thumbBorderRadius;
  final double bottomMargin;
  final double labelFontSize;
  final double iconSize;
  final double breakButtonSize;
  final String breakLabel;
  final Color? breakColor;
  final TextStyle? breakTextStyle;

  const ClockInButton({
    super.key,
    required this.isClockedIn,
    required this.isOnBreak,
    required this.onToggle,
    this.onBreak,
    this.trackHeight = 56,
    this.thumbSize = 48,
    this.horizontalInset = 4,
    this.fullThreshold = 0.88,
    this.borderRadius = 14,
    this.thumbBorderRadius = 12,
    this.bottomMargin = 20,
    this.labelFontSize = 16,
    this.iconSize = 18,
    this.breakButtonSize = 54,
    this.breakLabel = 'Take\nBreak',
    this.breakColor,
    this.breakTextStyle,
  });

  @override
  State<ClockInButton> createState() => _ClockInButtonState();
}

class _ClockInButtonState extends State<ClockInButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0; // 0 -> start, 1 -> end
  bool _isDragging = false;
  late AnimationController _resetController;

  @override
  void initState() {
    super.initState();
    _resetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 280),
        )..addListener(() {
          setState(() {
            _dragPosition = _resetController.value;
          });
        });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _handleDragEnd() {
    final pos = _dragPosition;
    if (pos >= widget.fullThreshold) {
      // Successful swipe
      setState(() => _dragPosition = 1);
      // brief settle animation / feedback window
      Future.delayed(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        widget.onToggle();
        // reset after toggling
        setState(() => _dragPosition = 0.0);
      });
    } else {
      // animate back
      _resetController
        ..value = pos
        ..reverse(from: pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClockedIn = widget.isClockedIn;
    final label = isClockedIn ? 'Swipe to clock out' : 'Swipe to clock in';
    final thumbIcon = isClockedIn ? Icons.logout : Icons.login;
    final showBreak = isClockedIn && widget.onBreak != null;

    // Swipe track widget extracted for reuse when break button visible.
    Widget buildSwipeTrack(BuildContext context) {
      return Container(
        height: widget.trackHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isClockedIn
                ? [AppColors.errorLight, AppColors.error]
                : [
                    AppColors.primary.withValues(alpha: 0.95),
                    AppColors.primary,
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final usableWidth =
                constraints.maxWidth -
                (widget.horizontalInset * 2) -
                widget.thumbSize;
            final dx = widget.horizontalInset + _dragPosition * usableWidth;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Center text
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: widget.labelFontSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          height: 1.1,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
                // Progress highlight
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (0.12 + _dragPosition * 0.88).clamp(
                            0.12,
                            1.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.textOnPrimary.withValues(
                                    alpha: 0.25,
                                  ),
                                  AppColors.textOnPrimary.withValues(
                                    alpha: 0.05,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Draggable thumb
                Positioned(
                  left: dx,
                  top: (widget.trackHeight - widget.thumbSize) / 2,
                  child: GestureDetector(
                    onHorizontalDragStart: (_) =>
                        setState(() => _isDragging = true),
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragPosition =
                            (_dragPosition + details.delta.dx / usableWidth)
                                .clamp(0.0, 1.0);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      setState(() => _isDragging = false);
                      _handleDragEnd();
                    },
                    child: AnimatedScale(
                      scale: _isDragging ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: widget.thumbSize,
                        height: widget.thumbSize,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            widget.thumbBorderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.10,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            thumbIcon,
                            size: widget.iconSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
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

    // New layout: when clocked in and break controls available, show a top row
    // of two rectangular buttons (Take Break / End Break) above the swipe track.
    // Only one is enabled at a time depending on isOnBreak state.
    if (showBreak) {
      return Container(
        margin: EdgeInsets.only(bottom: widget.bottomMargin),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _RectBreakButton(
                    label: 'Take Break',
                    enabled: !widget.isOnBreak,
                    primary: true,
                    onTap: !widget.isOnBreak ? widget.onBreak! : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RectBreakButton(
                    label: 'End Break',
                    enabled: widget.isOnBreak,
                    primary: false,
                    onTap: widget.isOnBreak ? widget.onBreak! : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            buildSwipeTrack(context),
          ],
        ),
      );
    }

    // Fallback layout (no break controls yet)
    return Container(
      margin: EdgeInsets.only(bottom: widget.bottomMargin),
      width: double.infinity,
      child: buildSwipeTrack(context),
    );
  }
}

class _RectBreakButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool primary; // differentiates styling of the two buttons
  final VoidCallback? onTap;

  const _RectBreakButton({
    required this.label,
    required this.enabled,
    required this.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = primary ? AppColors.accent : AppColors.error;
    final bgColor = enabled ? activeColor : theme.colorScheme.surfaceVariant;
    final fgColor = enabled
        ? AppColors.textOnPrimary
        : AppColors.textSecondary.withValues(alpha: 0.6);

    // Cup icon representing break actions.
    const IconData cupIcon = Icons.free_breakfast;
    final iconTint = enabled
        ? (primary ? AppColors.accent : AppColors.error).withValues(alpha: 0.95)
        : AppColors.textSecondary.withValues(alpha: 0.5);

    Widget leadingIconBox() {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(cupIcon, size: 20, color: iconTint)),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1.0 : 0.65,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (enabled)
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              leadingIconBox(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
