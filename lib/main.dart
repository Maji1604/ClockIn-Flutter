import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'features/auth/presentation/pages/auth_landing_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/company/presentation/pages/company_registration_page.dart';
import 'features/company/presentation/bloc/company_registration_bloc.dart';
import 'features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'features/dashboard/presentation/pages/employee_dashboard_page.dart';

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
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) =>
                  sl<AuthBloc>()..add(const AuthCheckRequested()),
            ),
          ],
          child: MaterialApp(
            title: AppEnvironment.appName,
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeManager().themeMode,

            // Routes
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => BlocProvider.value(
                value: BlocProvider.of<AuthBloc>(context),
                child: const LoginPage(),
              ),
              '/change-password': (context) {
                final user =
                    ModalRoute.of(context)?.settings.arguments as User?;
                return BlocProvider.value(
                  value: BlocProvider.of<AuthBloc>(context),
                  child: ChangePasswordPage(user: user!),
                );
              },
              '/company-registration': (context) => BlocProvider(
                create: (context) => sl<CompanyRegistrationBloc>(),
                child: const CompanyRegistrationPage(),
              ),
              '/admin-dashboard': (context) => BlocProvider.value(
                value: BlocProvider.of<AuthBloc>(context),
                child: const AdminDashboardPage(),
              ),
              '/employee-dashboard': (context) => BlocProvider.value(
                value: BlocProvider.of<AuthBloc>(context),
                child: const EmployeeDashboardPage(),
              ),
            },
          ),
        );
      },
    );
  }
}

/// Wrapper to handle initial authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          if (state.requiresPasswordChange) {
            return ChangePasswordPage(user: state.user);
          }

          // Navigate to appropriate dashboard
          if (state.user.isAdmin) {
            return const AdminDashboardPage();
          } else {
            return const EmployeeDashboardPage();
          }
        }

        // Default to landing page for unauthenticated users
        return const AuthLandingPage();
      },
    );
  }
}
