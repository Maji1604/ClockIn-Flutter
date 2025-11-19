import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../clockin/presentation/pages/clockin_screen.dart';
import '../../../admin/presentation/pages/admin_dashboard.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'splash_screen.dart';
import 'unified_login_page.dart';

/// AuthGuard checks authentication status and routes to appropriate screen
class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  String? _token;
  bool _splashComplete = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
    // Show splash for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _splashComplete = true;
        });
      }
    });
  }

  Future<void> _loadToken() async {
    final token = await ServiceLocator.authRepository.getToken();
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        AppLogger.info('=== AUTH GUARD: State changed ===');
        AppLogger.debug('AUTH GUARD: New state: ${state.runtimeType}');

        // When user logs out, ensure we're on the role selection page
        if (state is AuthUnauthenticated) {
          AppLogger.debug(
            'AUTH GUARD: User unauthenticated, should show role selection',
          );
        }

        // Reload token when authentication state changes
        if (state is AuthAuthenticated) {
          _loadToken();
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          AppLogger.debug(
            'AUTH GUARD: Building with state: ${state.runtimeType}',
          );

          if (state is AuthLoading ||
              state is AuthInitial ||
              !_splashComplete) {
            // Show splash screen while checking auth or during 3-second delay
            return const SplashScreen();
          }

          if (state is AuthAuthenticated) {
            // User is authenticated, route to appropriate screen
            if (state.user.isAdmin) {
              return AdminDashboard(
                adminData: {
                  'id': state.user.id,
                  'name': state.user.name,
                  'role': state.user.role,
                },
              );
            } else {
              AppLogger.debug(
                'AUTH GUARD: Creating ClockInScreen with token: ${_token != null ? "present" : "missing"}',
              );
              return ClockInScreen(
                key: const ValueKey(
                  'clockin_screen',
                ), // Add key to prevent recreation
                userData: {
                  'id': state.user.id,
                  'name': state.user.name,
                  'employee_id': state.user.employeeId,
                },
                token: _token,
              );
            }
          }

          // User is not authenticated, show login page
          return const UnifiedLoginPage();
        },
      ),
    );
  }
}
