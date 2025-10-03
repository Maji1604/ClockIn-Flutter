import "package:get_it/get_it.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../utils/logger.dart";

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  AppLogger.info("Initializing dependencies...", "DI");

  // Core dependencies
  await _initCoreDependencies();

  AppLogger.info("Dependencies initialized successfully", "DI");
}

/// Initialize core dependencies
Future<void> _initCoreDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}