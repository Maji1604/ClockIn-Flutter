import 'package:flutter/material.dart';

enum SnackBarPosition { top, bottom }

/// Utility class for showing consistent snackbars across the app
class SnackBarUtil {
  // Keeps track of the currently displayed top overlay snackbar
  static OverlayEntry? _currentTopEntry;

  /// Show a snackbar with consistent styling and safe positioning
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSafeMargin = mediaQuery.viewPadding.bottom + 16;
    final topSafeMargin = mediaQuery.viewPadding.top + 16;

    // Clear any existing snackbars to avoid stacking
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: position == SnackBarPosition.bottom
            ? EdgeInsets.only(
                bottom: bottomSafeMargin, // Respect bottom safe area
                left: 16,
                right: 16,
              )
            : EdgeInsets.only(
                top: topSafeMargin, // Respect status bar (date/time) safe area
                left: 16,
                right: 16,
              ),
        dismissDirection: position == SnackBarPosition.top
            ? DismissDirection.up
            : DismissDirection.horizontal,
        action: action,
      ),
    );
  }

  /// Show a TOP snackbar using an Overlay so it truly appears at the top
  /// without hacking margins or obscuring the status bar.
  static void showTopSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topInset =
        mediaQuery.viewPadding.top + 12; // below status bar/date area

    // Remove any existing top entry first
    _currentTopEntry?.remove();
    _currentTopEntry = null;

    final overlay = Overlay.of(context);

    final controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 250),
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    _currentTopEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: topInset,
          left: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: _TopSnackBarContainer(
                  message: message,
                  backgroundColor:
                      backgroundColor ??
                      theme.colorScheme.surface.withOpacity(0.95),
                  textColor: theme.colorScheme.onSurface,
                  action: action,
                  onDismiss: () {
                    _currentTopEntry?.remove();
                    _currentTopEntry = null;
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_currentTopEntry!);
    controller.forward();

    // Auto remove after duration
    Future.delayed(duration).then((_) {
      if (_currentTopEntry != null) {
        controller.reverse().then((_) {
          _currentTopEntry?.remove();
          _currentTopEntry = null;
        });
      }
    });
  }

  /// Show a success snackbar (green background)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor: Colors.green.shade600,
        duration: duration,
      );
    } else {
      showSnackBar(
        context,
        message,
        backgroundColor: Colors.green.shade600,
        duration: duration,
        position: position,
      );
    }
  }

  /// Show an error snackbar (red background)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor: Colors.red.shade600,
        duration: duration,
      );
    } else {
      showSnackBar(
        context,
        message,
        backgroundColor: Colors.red.shade600,
        duration: duration,
        position: position,
      );
    }
  }

  /// Show an info snackbar (blue background)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor: Colors.blue.shade600,
        duration: duration,
      );
    } else {
      showSnackBar(
        context,
        message,
        backgroundColor: Colors.blue.shade600,
        duration: duration,
        position: position,
      );
    }
  }

  /// Show a warning snackbar (orange background)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor: Colors.orange.shade600,
        duration: duration,
      );
    } else {
      showSnackBar(
        context,
        message,
        backgroundColor: Colors.orange.shade600,
        duration: duration,
        position: position,
      );
    }
  }
}

/// Internal widget for the top snackbar overlay
class _TopSnackBarContainer extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final SnackBarAction? action;
  final VoidCallback onDismiss;

  const _TopSnackBarContainer({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.onDismiss,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey('top_snackbar'),
      direction: DismissDirection.up,
      onDismissed: (_) => onDismiss(),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(message, style: TextStyle(color: textColor)),
              ),
              if (action != null)
                TextButton(
                  onPressed: () {
                    action!.onPressed();
                    onDismiss();
                  },
                  child: Text(
                    action!.label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
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
