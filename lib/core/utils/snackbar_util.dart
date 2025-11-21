import 'package:flutter/material.dart';

enum SnackBarPosition { top, bottom }

/// Utility class for showing consistent snackbars across the app
class SnackBarUtil {
  // Keeps track of the currently displayed top overlay snackbar
  static OverlayEntry? _currentTopEntry;
  static OverlayEntry? _currentBottomEntry;

  /// Show a snackbar with consistent styling and safe positioning
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    // safe area insets available via MediaQuery when needed in specific handlers

    // Use overlay-based snackbars so we can control sizing and centering
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor:
            backgroundColor ??
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
        duration: duration,
        action: action,
      );
    } else {
      showBottomSnackBar(
        context,
        message,
        backgroundColor:
            backgroundColor ??
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
        duration: duration,
        action: action,
      );
    }
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

    _currentTopEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: topInset,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topCenter,
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
        );
      },
    );

    overlay.insert(_currentTopEntry!);

    // Auto remove after duration (no animation controller to avoid needing a TickerProvider)
    Future.delayed(duration).then((_) {
      if (_currentTopEntry != null) {
        _currentTopEntry?.remove();
        _currentTopEntry = null;
      }
    });
  }

  /// Show a BOTTOM snackbar using an Overlay so it is centered and sized
  /// to its content.
  static void showBottomSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewPadding.bottom + 12;

    // Remove any existing bottom entry first
    _currentBottomEntry?.remove();
    _currentBottomEntry = null;

    final overlay = Overlay.of(context);

    _currentBottomEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          bottom: bottomInset,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _TopSnackBarContainer(
                message: message,
                backgroundColor:
                    backgroundColor ??
                    theme.colorScheme.surface.withOpacity(0.95),
                textColor: theme.colorScheme.onSurface,
                action: action,
                onDismiss: () {
                  _currentBottomEntry?.remove();
                  _currentBottomEntry = null;
                },
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_currentBottomEntry!);

    // Auto remove after duration
    Future.delayed(duration).then((_) {
      if (_currentBottomEntry != null) {
        _currentBottomEntry?.remove();
        _currentBottomEntry = null;
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
    // Use a very light green for success snackbars (paler, not solid)
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor: Colors.green.shade200,
        duration: duration,
      );
    } else {
      showSnackBar(
        context,
        message,
        backgroundColor: Colors.green.shade200,
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
    // Use a light red for error snackbars (so it's not a heavy solid color)
    if (position == SnackBarPosition.top) {
      showTopSnackBar(
        context,
        message,
        backgroundColor: Colors.red.shade200,
        duration: duration,
      );
    } else {
      showSnackBar(
        context,
        message,
        backgroundColor: Colors.red.shade200,
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
      direction: DismissDirection.vertical,
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
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(color: textColor),
                  textAlign: TextAlign.center,
                ),
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
