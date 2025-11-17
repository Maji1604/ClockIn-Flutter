import 'package:flutter/material.dart';
import 'core/core.dart';
import 'features/auth/presentation/pages/role_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme manager
  await ThemeManager().initialize();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const ClockInApp());
}

class ClockInApp extends StatelessWidget {
  const ClockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppEnvironment.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const RoleSelectionPage(),
    );
  }
}
