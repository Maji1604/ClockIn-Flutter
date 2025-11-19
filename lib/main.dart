import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'core/config/api_config.dart';
import 'core/dependency_injection/service_locator.dart';
import 'features/auth/presentation/pages/auth_guard.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  // Catch all errors at the Flutter framework level
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Set up error handlers
      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.error('Flutter Error: ${details.exception}');
        AppLogger.debug('Stack trace: ${details.stack}');
      };

      // Initialize API configuration
      await ApiConfig.initialize();

      // Initialize theme manager
      await ThemeManager().initialize();

      // Initialize dependencies
      await initializeDependencies();

      // Setup service locator for BLoC
      ServiceLocator.setup();

      runApp(const ClockInApp());
    },
    (error, stack) {
      // Catch all Dart errors
      AppLogger.error('Uncaught error: $error');
      AppLogger.debug('Stack trace: $stack');
    },
  );
}

class ClockInApp extends StatelessWidget {
  const ClockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => ServiceLocator.authBloc..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => ServiceLocator.leaveBloc),
        BlocProvider(create: (context) => ServiceLocator.attendanceBloc),
      ],
      child: MaterialApp(
        title: AppEnvironment.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const AuthGuard(),
      ),
    );
  }
}
