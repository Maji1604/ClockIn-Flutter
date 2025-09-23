import 'package:flutter/material.dart';

/// Responsive layout helper widget
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Spacer widget with consistent spacing
class AppSpacing extends StatelessWidget {
  const AppSpacing.small({super.key}) : size = 8;
  const AppSpacing.medium({super.key}) : size = 16;
  const AppSpacing.large({super.key}) : size = 24;
  const AppSpacing.extraLarge({super.key}) : size = 32;
  const AppSpacing.custom(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}

/// Horizontal spacer
class HorizontalSpacing extends StatelessWidget {
  const HorizontalSpacing.small({super.key}) : width = 8;
  const HorizontalSpacing.medium({super.key}) : width = 16;
  const HorizontalSpacing.large({super.key}) : width = 24;
  const HorizontalSpacing.custom(this.width, {super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}

/// Vertical spacer
class VerticalSpacing extends StatelessWidget {
  const VerticalSpacing.small({super.key}) : height = 8;
  const VerticalSpacing.medium({super.key}) : height = 16;
  const VerticalSpacing.large({super.key}) : height = 24;
  const VerticalSpacing.custom(this.height, {super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

/// Conditional wrapper widget
class ConditionalWrapper extends StatelessWidget {
  const ConditionalWrapper({
    super.key,
    required this.condition,
    required this.wrapper,
    required this.child,
  });

  final bool condition;
  final Widget Function(Widget child) wrapper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return condition ? wrapper(child) : child;
  }
}

/// Safe area wrapper with padding
class SafeAreaWrapper extends StatelessWidget {
  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Keyboard dismiss wrapper
class KeyboardDismissWrapper extends StatelessWidget {
  const KeyboardDismissWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
