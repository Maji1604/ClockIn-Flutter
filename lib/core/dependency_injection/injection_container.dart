import "package:shared_preferences/shared_preferences.dart";

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core dependencies
  await _initCoreDependencies();
}

/// Initialize core dependencies
Future<void> _initCoreDependencies() async {
  // Initialize shared preferences for theme persistence
  await SharedPreferences.getInstance();
}
