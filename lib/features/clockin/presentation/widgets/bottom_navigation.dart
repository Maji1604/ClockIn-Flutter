import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/core.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom navigation bar with notch
          CustomPaint(
            painter: _NotchedBottomBarPainter(),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(AppIcons.menu, 0, width: 35, height: 35),
                  _buildNavItem(AppIcons.holiday, 1, width: 24, height: 24),
                  const SizedBox(width: 56), // Space for floating button
                  _buildNavItem(AppIcons.calendar, 2, width: 22, height: 24),
                  _buildNavItem(AppIcons.profile, 3, width: 18, height: 20),
                ],
              ),
            ),
          ),
          // Floating center button
          Positioned(
            top: -8,
            left: MediaQuery.of(context).size.width / 2 - 32,
            child: _buildFloatingButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String iconPath,
    int index, {
    double? width,
    double? height,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected?.call(index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: width,
            height: height,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.primary : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.group,
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            AppColors.textOnPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

// Custom painter for the notched bottom bar
class _NotchedBottomBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, 0);

    // Left side before notch
    final notchCenter = size.width / 2;
    final notchRadius = 36.0;
    final notchMargin = 8.0;

    path.lineTo(notchCenter - notchRadius - notchMargin, 0);

    // Create the notch curve
    path.arcToPoint(
      Offset(notchCenter + notchRadius + notchMargin, 0),
      radius: Radius.circular(notchRadius + notchMargin),
      clockwise: false,
    );

    // Right side after notch
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.1), 4.0, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
