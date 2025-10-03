import 'package:flutter/material.dart';
import 'core/core.dart';
import 'features/clockin/presentation/pages/clockin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await AppEnvironment.initialize();

  // Initialize theme manager
  await ThemeManager().initialize();

  // Initialize logger (after environment is loaded)
  AppLogger.info(
    'Starting ${AppEnvironment.appName} v${AppEnvironment.appVersion}...',
    'MAIN',
  );
  AppLogger.info('Environment: ${AppEnvironment.appEnvironment}', 'MAIN');

  // Print environment variables in development mode
  if (AppEnvironment.isDevelopment) {
    AppEnvironment.printEnvironmentVariables();
  }

  // Initialize dependencies
  await initializeDependencies();

  runApp(const ClockInApp());
}

class ClockInApp extends StatelessWidget {
  const ClockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager(),
      builder: (context, child) {
        return MaterialApp(
          title: AppEnvironment.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeManager().themeMode,
          home: const ClockInScreen(),
        );
      },
    );
  }
}
