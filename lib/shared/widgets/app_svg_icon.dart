import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable SVG icon widget with custom sizing support
class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppSvgIcon(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  /// Creates an icon with equal width and height
  const AppSvgIcon.square(
    this.assetPath, {
    super.key,
    double? size,
    this.color,
    this.fit = BoxFit.contain,
  }) : width = size,
       height = size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
