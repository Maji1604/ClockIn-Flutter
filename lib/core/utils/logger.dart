// ignore_for_file: avoid_print

/// Core logger utility with different log levels
/// Provides structured logging throughout the application
library;

enum LogLevel { debug, info, warning, error, critical }

class AppLogger {
  static const String _tag = 'CreoleapHRMS';

  // Private constructor for singleton pattern
  AppLogger._();
  static final AppLogger _instance = AppLogger._();
  factory AppLogger() => _instance;

  /// Log debug messages
  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  /// Log info messages
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  /// Log warning messages
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  /// Log error messages
  static void error(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      _log(LogLevel.error, 'Error: $error', tag);
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'StackTrace: $stackTrace', tag);
    }
  }

  /// Log critical messages
  static void critical(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.critical, message, tag);
    if (error != null) {
      _log(LogLevel.critical, 'Error: $error', tag);
    }
    if (stackTrace != null) {
      _log(LogLevel.critical, 'StackTrace: $stackTrace', tag);
    }
  }

  /// Internal log method
  static void _log(LogLevel level, String message, [String? tag]) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _tag;
    final levelString = level.name.toUpperCase().padRight(8);

    // Color codes for different log levels
    final colorCode = _getColorCode(level);
    final resetColor = '\x1B[0m';

    print('$colorCode[$timestamp] $levelString [$logTag]: $message$resetColor');
  }

  /// Get ANSI color code for log level
  static String _getColorCode(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[37m'; // White
      case LogLevel.info:
        return '\x1B[36m'; // Cyan
      case LogLevel.warning:
        return '\x1B[33m'; // Yellow
      case LogLevel.error:
        return '\x1B[31m'; // Red
      case LogLevel.critical:
        return '\x1B[35m'; // Magenta
    }
  }
}
