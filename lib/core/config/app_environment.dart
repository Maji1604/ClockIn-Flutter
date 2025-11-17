/// Simple app configuration without API dependencies
class AppEnvironment {
  // Basic app info
  static const String appName = 'ClockIn HRMS';
  static const String appVersion = '1.0.0';
  static const String appEnvironment = 'development';

  /// Initialize method for compatibility (does nothing now)
  static Future<void> initialize() async {
    // No environment loading needed for UI-only app
  }

  /// Environment checks
  static bool get isProduction => appEnvironment == 'production';
  static bool get isDevelopment => appEnvironment == 'development';
  static bool get isStaging => appEnvironment == 'staging';

  /// Print environment info (for debugging)
  static void printEnvironmentVariables() {
    // No environment variables to print
  }
}
