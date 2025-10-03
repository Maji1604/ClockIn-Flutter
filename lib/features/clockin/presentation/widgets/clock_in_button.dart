import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class ClockInButton extends StatefulWidget {
  final bool isClockedIn;
  final VoidCallback onPressed; // Triggered after successful swipe

  const ClockInButton({
    super.key,
    required this.isClockedIn,
    required this.onPressed,
  });

  @override
  State<ClockInButton> createState() => _ClockInButtonState();
}

class _ClockInButtonState extends State<ClockInButton> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0; // 0 -> start, 1 -> end
  bool _isDragging = false;
  late AnimationController _resetController;

  static const double _trackHeight = 56;
  static const double _thumbSize = 48; // smaller than track for visual padding
  static const double _horizontalInset = 4; // outer padding inside track

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
      ..addListener(() {
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

  void _handleDragUpdate(double dx, double maxWidth) {
    setState(() {
      _dragPosition = (dx / maxWidth).clamp(0.0, 1.0);
    });
  }

  void _handleDragEnd() {
    final reachedEnd = _dragPosition > 0.82; // threshold
    if (reachedEnd) {
      // Snap to end visually then trigger callback
      setState(() => _dragPosition = 1.0);
      Future.delayed(const Duration(milliseconds: 120), widget.onPressed);
    } else {
      // Animate back
      _resetController
        ..value = _dragPosition
        ..reverse(from: _dragPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClockedIn = widget.isClockedIn;
    final label = isClockedIn ? 'Swipe to clock out' : 'Swipe to clock in';
    final iconData = isClockedIn ? Icons.logout : Icons.arrow_forward_ios;

    return Container(
      width: double.infinity,
      height: _trackHeight,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.95),
            AppColors.primary,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final usableWidth = constraints.maxWidth - (_horizontalInset * 2) - _thumbSize;
          final dx = _horizontalInset + _dragPosition * usableWidth;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Centered label text (always centered, improved typography)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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

              // Drag Track highlight (subtle progress)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (0.12 + _dragPosition * 0.88).clamp(0.12, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.05),
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

              // Draggable Thumb
              Positioned(
                left: dx,
                top: (_trackHeight - _thumbSize) / 2,
                child: GestureDetector(
                  onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx / usableWidth).clamp(0.0, 1.0);
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
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: 18,
                          color: AppColors.primary,
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
}