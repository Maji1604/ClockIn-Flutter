import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await AppEnvironment.initialize();

  // Initialize theme manager
  await ThemeManager().initialize();

  // Initialize logger
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
  // await initializeDependencies();

  runApp(const CreoleapHRMSApp());
}

class CreoleapHRMSApp extends StatelessWidget {
  const CreoleapHRMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO: Add BLoC providers here when dependencies are implemented
        // BlocProvider<AuthBloc>(
        //   create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        // ),
      ],
      child: AnimatedBuilder(
        animation: ThemeManager(),
        builder: (context, child) {
          return MaterialApp(
            title: AppEnvironment.appName,
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeManager().themeMode,

            // TODO: Add proper routing when pages are ready
            home: const SplashPage(),
            // routes: {
            //   LoginPage.routeName: (context) => const LoginPage(),
            //   RegisterPage.routeName: (context) => const RegisterPage(),
            // },
          );
        },
      ),
    );
  }
}

/// Temporary splash page to show the app structure
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppEnvironment.appName),
        centerTitle: true,
        actions: [
          // Theme toggle button
          AnimatedBuilder(
            animation: ThemeManager(),
            builder: (context, child) {
              return PopupMenuButton<ThemeMode>(
                icon: Icon(ThemeManager().getThemeIcon()),
                tooltip: 'Change Theme',
                onSelected: (ThemeMode mode) {
                  ThemeManager().setThemeMode(mode);
                },
                itemBuilder: (BuildContext context) {
                  return ThemeManager().availableThemes.entries.map((entry) {
                    return PopupMenuItem<ThemeMode>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(
                            _getThemeIcon(entry.key),
                            color: ThemeManager().themeMode == entry.key
                                ? theme.colorScheme.primary
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: ThemeManager().themeMode == entry.key
                                  ? theme.colorScheme.primary
                                  : null,
                              fontWeight: ThemeManager().themeMode == entry.key
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.largeBorderRadius,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.business,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              Text(
                'Welcome to Creoleap HRMS',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),

              Text(
                'BLoC Architecture with Light/Dark Mode',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.extraLargePadding),

              _buildFeatureCard(
                context,
                '🏗️ Framework Structure Created',
                'Complete BLoC architecture with Clean Architecture patterns',
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              _buildFeatureCard(
                context,
                '🎨 Theme System Ready',
                'Light & Dark themes with automatic system detection',
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              _buildFeatureCard(
                context,
                '📁 Features: Auth Module',
                'Authentication with Clean Architecture (Domain, Data, Presentation)',
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              _buildFeatureCard(
                context,
                '🔧 Core Infrastructure',
                'Logger, Network Client, DI Container, Environment Config',
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              _buildFeatureCard(
                context,
                '🎯 BLoC State Management',
                'Events, States, Business Logic with type-safe architecture',
              ),

              const SizedBox(height: AppConstants.extraLargePadding),

              // Theme demonstration
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Text(
                      'Current: ${isDark ? 'Dark' : 'Light'} Theme',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
