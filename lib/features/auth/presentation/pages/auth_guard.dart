import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../clockin/presentation/bloc/attendance_bloc.dart';
import '../../../clockin/presentation/bloc/attendance_event.dart';
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
  bool _initialAuthCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
    // Show splash for 3 seconds minimum
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

      // Pre-fetch attendance data while splash is showing
      final authState = context.read<AuthBloc>().state;
      if (token != null && authState is AuthAuthenticated) {
        final empId = authState.user.employeeId;
        if (empId != null) {
          AppLogger.info('AUTH GUARD: Pre-fetching attendance data...');
          context.read<AttendanceBloc>().add(
            LoadTodayAttendance(
              token: token,
              empId: empId,
              date: DateTime.now(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        AppLogger.info('=== AUTH GUARD: State changed ===');
        AppLogger.debug('AUTH GUARD: New state: ${state.runtimeType}');

        // Mark initial auth check complete when we get a definitive state
        if (!_initialAuthCheckComplete &&
            (state is AuthAuthenticated || state is AuthUnauthenticated)) {
          setState(() {
            _initialAuthCheckComplete = true;
          });
        }

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

          // CASE 1: During initial app startup
          // Show splash until BOTH splash timer completes AND initial auth check resolves
          // This prevents any glimpse of login screen for authenticated users
          if (!_initialAuthCheckComplete) {
            // Keep showing splash while checking auth
            return const SplashScreen();
          }

          // CASE 2: Splash timer hasn't completed but auth is resolved
          // Still show splash to complete the 3-second animation
          if (!_splashComplete) {
            return const SplashScreen();
          }

          // CASE 3: After initial auth check, if user initiates login
          // AuthLoading here means user is logging in from login page
          // Don't show splash - let login page handle its own loading state
          // (state is AuthLoading here is fine - fall through to show login page)

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

          // User is not authenticated (or logging in), show login page
          return const UnifiedLoginPage();
        },
      ),
    );
  }
}
