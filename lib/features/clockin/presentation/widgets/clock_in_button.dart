import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// A simplified swipe button that only supports a single full swipe
/// to toggle clock-in / clock-out. Partial break logic removed per request.
class ClockInButton extends StatefulWidget {
  final bool isClockedIn;
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

    return Container(
      margin: EdgeInsets.only(bottom: widget.bottomMargin),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: buildSwipeTrack(context)),
          if (showBreak) ...[
            const SizedBox(width: 10),
            _BreakButton(
              size: widget.breakButtonSize,
              label: widget.breakLabel,
              onTap: widget.onBreak!,
              color: widget.breakColor ?? AppColors.accent,
              textStyle: widget.breakTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakButton extends StatelessWidget {
  final double size;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final TextStyle? textStyle;

  const _BreakButton({
    required this.size,
    required this.label,
    required this.onTap,
    required this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FittedBox(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style:
                textStyle ??
                theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ),
    );
  }
}
