import 'package:flutter/material.dart';

/// Utility class for showing consistent snackbars across the app
class SnackBarUtil {
  /// Show a snackbar with custom styling and top-center positioning
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
          top: 60, // Add top margin to avoid status bar
        ),
        action: action,
      ),
    );
  }

  /// Show a success snackbar (green background)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green.shade600,
      duration: duration,
    );
  }

  /// Show an error snackbar (red background)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      duration: duration,
    );
  }

  /// Show an info snackbar (blue background)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue.shade600,
      duration: duration,
    );
  }

  /// Show a warning snackbar (orange background)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange.shade600,
      duration: duration,
    );
  }
}
