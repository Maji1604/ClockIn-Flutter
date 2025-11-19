import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../clockin/presentation/pages/clockin_screen.dart';
import '../../../admin/presentation/pages/admin_dashboard.dart';
import '../../../profile/presentation/pages/onboarding_password_reset_page.dart';
import '../../../profile/presentation/pages/onboarding_profile_completion_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/models/user_model.dart';

import '../../../../core/utils/app_logger.dart';

class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info('=== UNIFIED LOGIN PAGE: initState ===');
    AppLogger.debug('UnifiedLoginPage initialized');
  }

  @override
  void dispose() {
    AppLogger.info('=== UNIFIED LOGIN PAGE: dispose ===');
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
    AppLogger.debug('UnifiedLoginPage disposed');
  }

  void _handleLogin(BuildContext context) {
    AppLogger.info('=== UNIFIED LOGIN PAGE: _handleLogin ===');
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppLogger.debug('LOGIN: Form validation failed');
      return;
    }

    AppLogger.debug('LOGIN: Form validated, dispatching LoginRequested event');
    AppLogger.debug('LOGIN: Username: ${_identifierController.text.trim()}');
    try {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _identifierController.text.trim(),
          password: _passwordController.text,
        ),
      );
      AppLogger.debug('LOGIN: Event dispatched successfully');
    } catch (e, stackTrace) {
      AppLogger.info('=== LOGIN HANDLER ERROR ===');
      AppLogger.debug('Error: $e');
      AppLogger.debug('Stack trace: $stackTrace');
    }
  }

  Future<void> _handleOnboarding(
    BuildContext context,
    UserModel user,
    String token,
  ) async {
    AppLogger.debug('ONBOARDING: Starting onboarding flow');

    if (!context.mounted) {
      AppLogger.debug('ONBOARDING: Context not mounted at start');
      return;
    }

    // Step 1: Password reset if required
    if (user.requiresPasswordReset) {
      AppLogger.debug('ONBOARDING: Requires password reset');
      final passwordResetResult = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => OnboardingPasswordResetPage(token: token),
        ),
      );

      AppLogger.debug(
        'ONBOARDING: Password reset result: $passwordResetResult',
      );

      if (!context.mounted) {
        AppLogger.debug('ONBOARDING: Context not mounted after password reset');
        return;
      }

      if (passwordResetResult != true) {
        AppLogger.debug('ONBOARDING: Password reset cancelled or failed');
        SnackBarUtil.showWarning(
          context,
          'Password reset is required to continue',
        );
        return;
      }
      AppLogger.debug('ONBOARDING: Password reset successful');
    }

    // Step 2: Profile completion (mobile + address) if missing
    final needsMobile = user.mobileNumber == null || user.mobileNumber!.isEmpty;
    final needsAddress = user.address == null || user.address!.isEmpty;

    if (needsMobile || needsAddress) {
      AppLogger.debug(
        'ONBOARDING: Requires profile completion (mobile: $needsMobile, address: $needsAddress)',
      );

      if (!context.mounted) {
        AppLogger.debug(
          'ONBOARDING: Context not mounted before profile completion',
        );
        return;
      }

      final profileCompletionResult = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => OnboardingProfileCompletionPage(
            token: token,
            empId: user.employeeId!,
            hasMobileNumber: !needsMobile,
            hasAddress: !needsAddress,
          ),
        ),
      );

      AppLogger.debug(
        'ONBOARDING: Profile completion result: $profileCompletionResult',
      );

      if (!context.mounted) {
        AppLogger.debug(
          'ONBOARDING: Context not mounted after profile completion',
        );
        return;
      }

      if (profileCompletionResult != true) {
        AppLogger.debug('ONBOARDING: Profile completion skipped');
      } else {
        AppLogger.debug('ONBOARDING: Profile completion successful');
      }
    }

    // Step 3: Navigate to main app
    AppLogger.debug('ONBOARDING: Navigating to ClockInScreen');

    if (!context.mounted) {
      AppLogger.debug(
        'ONBOARDING: Context not mounted before final navigation',
      );
      return;
    }

    AppLogger.debug(
      'ONBOARDING: Using token passed from login: ${token != null ? "present" : "null"}',
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ClockInScreen(
          userData: {
            'id': user.id,
            'name': user.name,
            'employee_id': user.employeeId,
          },
          token: token,
        ),
      ),
      (route) => false, // Remove all previous routes
    );
    AppLogger.debug('ONBOARDING: Navigation complete');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        AppLogger.info('=== UNIFIED LOGIN PAGE: BlocListener state change ===');
        AppLogger.debug('New state: ${state.runtimeType}');

        if (state is AuthAuthenticated) {
          AppLogger.debug('LOGIN: User authenticated - ${state.user.name}');

          // Show success message
          SnackBarUtil.showSuccess(context, 'Welcome back ${state.user.name}!');

          // Check if employee needs onboarding
          if (state.user.isEmployee && state.user.needsOnboarding) {
            AppLogger.debug('LOGIN: Employee needs onboarding');
            AppLogger.debug(
              'LOGIN: requiresPasswordReset=${state.user.requiresPasswordReset}',
            );
            AppLogger.debug('LOGIN: mobileNumber=${state.user.mobileNumber}');
            AppLogger.debug('LOGIN: address=${state.user.address}');

            // Get token from BLoC's repository
            AppLogger.debug('LOGIN: Getting token from BLoC repository...');
            final authBloc = context.read<AuthBloc>();
            final token = await authBloc.authRepository.getToken();
            AppLogger.debug(
              'LOGIN: Token retrieved: ${token != null ? "YES" : "NO"}',
            );

            if (!context.mounted) {
              AppLogger.debug('LOGIN: Context not mounted, returning');
              return;
            }

            if (token == null) {
              AppLogger.debug('LOGIN: Token is null, showing error');
              SnackBarUtil.showError(
                context,
                'Authentication error. Please login again.',
              );
              return;
            }

            // Navigate to onboarding flow
            AppLogger.debug('LOGIN: Calling _handleOnboarding...');
            await _handleOnboarding(context, state.user, token);
            AppLogger.debug('LOGIN: _handleOnboarding completed');
            return;
          }

          // Get token for navigation
          AppLogger.debug('LOGIN: Getting token for direct navigation...');
          final authBloc2 = context.read<AuthBloc>();
          final navigationToken = await authBloc2.authRepository.getToken();
          AppLogger.debug(
            'LOGIN: Navigation token retrieved: ${navigationToken != null ? "YES" : "NO"}',
          );

          if (!context.mounted) {
            AppLogger.debug(
              'LOGIN: Context not mounted before direct navigation',
            );
            return;
          }

          // Navigate to appropriate screen based on role
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => state.user.isAdmin
                  ? AdminDashboard(
                      adminData: {
                        'id': state.user.id,
                        'name': state.user.name,
                        'role': state.user.role,
                      },
                    )
                  : ClockInScreen(
                      userData: {
                        'id': state.user.id,
                        'name': state.user.name,
                        'employee_id': state.user.employeeId,
                      },
                      token: navigationToken,
                    ),
            ),
            (route) => false, // Remove all previous routes
          );
        } else if (state is AuthError) {
          // Show error message
          SnackBarUtil.showError(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          AppLogger.debug(
            'LOGIN: BlocBuilder rebuilding with state: ${state.runtimeType}',
          );
          final isLoading = state is AuthLoading;
          AppLogger.debug('LOGIN: isLoading = $isLoading');

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 40),
                      // Title
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email or employee ID to continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Identifier Field (Email or Employee ID)
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Email or Employee ID',
                          hintText: 'admin@company.com or EMP001',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or employee ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _handleLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.6),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Helper Text
                      Center(
                        child: Text(
                          'Use email for admin login or employee ID for employee login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
