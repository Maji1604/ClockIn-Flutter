import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class TimeCard extends StatelessWidget {
  final String title;
  final String time;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final double scale;
  final bool compact;
  final double borderRadius;
  final double iconContainerRadius;
  final double iconSizeNormal;
  final double iconSizeCompact;
  final double containerSizeNormal;
  final double containerSizeCompact;
  final double horizontalPadding;
  final double verticalPaddingNormal;
  final double verticalPaddingCompact;
  final double spacingBetweenIconAndTitle;
  final double spacingBetweenTitleAndTime;
  final double spacingBetweenTimeAndSubtitle;
  final double timeFontSizeNormal;
  final double timeFontSizeCompact;
  final double subtitleFontSizeNormal;
  final double subtitleFontSizeCompact;

  const TimeCard({
    super.key,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.scale = 1.0,
    this.compact = false,
    this.borderRadius = 14,
    this.iconContainerRadius = 8,
    this.iconSizeNormal = 18,
    this.iconSizeCompact = 16,
    this.containerSizeNormal = 30,
    this.containerSizeCompact = 26,
    this.horizontalPadding = 12,
    this.verticalPaddingNormal = 10,
    this.verticalPaddingCompact = 6,
    this.spacingBetweenIconAndTitle = 10,
    this.spacingBetweenTitleAndTime = 6,
    this.spacingBetweenTimeAndSubtitle = 4,
    this.timeFontSizeNormal = 18,
    this.timeFontSizeCompact = 16,
    this.subtitleFontSizeNormal = 10,
    this.subtitleFontSizeCompact = 9,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Defensive icon sizing: keep icon comfortably inside its container.
    double iconBaseSize =
        (compact ? iconSizeCompact : iconSizeNormal) * scale.clamp(0.8, 1.0);
    final containerSide =
        (compact ? containerSizeCompact : containerSizeNormal) * scale;
    // Leave at least 6 logical px padding total.
    final maxAllowed = (containerSide - 6).clamp(8, containerSide);
    final iconSize = iconBaseSize.clamp(8, maxAllowed);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding * scale,
          (compact ? verticalPaddingCompact : verticalPaddingNormal) * scale,
          horizontalPadding * scale,
          (compact ? verticalPaddingCompact : verticalPaddingNormal) * scale,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: containerSide,
                  height: containerSide,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(iconContainerRadius),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: iconSize.toDouble(),
                    ),
                  ),
                ),
                SizedBox(width: spacingBetweenIconAndTitle * scale),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      fontSize: compact
                          ? (theme.textTheme.bodyMedium?.fontSize ?? 14) * 0.9
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacingBetweenTitleAndTime * scale),
            Text(
              time,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: compact
                    ? (timeFontSizeCompact * scale).clamp(
                        13,
                        timeFontSizeCompact,
                      )
                    : (timeFontSizeNormal * scale).clamp(
                        14,
                        timeFontSizeNormal,
                      ),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: spacingBetweenTimeAndSubtitle * scale),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontSize: compact
                    ? (subtitleFontSizeCompact * scale).clamp(
                        8.5,
                        subtitleFontSizeCompact + 0.5,
                      )
                    : (subtitleFontSizeNormal * scale).clamp(
                        9,
                        subtitleFontSizeNormal,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
