import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/core/layout/page_scaffold.dart';
import '../../../../shared/widgets/core/layout/content_container.dart';
import '../../../../shared/widgets/core/buttons/primary_button.dart';
import '../../../../shared/widgets/core/buttons/secondary_button.dart';
import '../../../../shared/widgets/core/forms/input_field.dart';
import '../../domain/entities/login_request.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'company_selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyIdController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          // Show concise error with optional Details action to reveal full message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Details',
                textColor: Colors.white,
                onPressed: () {
                  // Log the full error message for more details (also available in logs)
                  AppLogger.debug(
                    'AuthError details: ${state.message}',
                    'LOGIN_PAGE',
                  );
                  // Optionally show a dialog with the message
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error details'),
                      content: SingleChildScrollView(
                        child: Text(state.message),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is AuthRequiresCompanySelection) {
          // Capture the bloc before the async gap to avoid using BuildContext afterwards
          final authBloc = context.read<AuthBloc>();

          // Ask the user to pick a company membership
          final chosenSlug = await Navigator.push<String?>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CompanySelectionPage(memberships: state.memberships),
            ),
          );

          // Avoid using BuildContext across async gaps; check mounted first
          if (!mounted) return;

          if (chosenSlug != null && chosenSlug.isNotEmpty) {
            // Re-submit the login with chosen company slug
            final request = LoginRequest(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              companySlug: chosenSlug,
            );
            // Use captured bloc instead of context after async gap
            authBloc.add(AuthLoginRequested(request: request));
          }
        } else if (state is AuthAuthenticated) {
          if (state.requiresPasswordChange) {
            Navigator.pushReplacementNamed(
              context,
              '/change-password',
              arguments: state.user,
            );
          } else {
            if (state.user.isAdmin) {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/employee-dashboard');
            }
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return PageScaffold(
            showAppBar: true,
            title: 'Sign In',
            body: SingleChildScrollView(
              child: ContentContainer(
                maxWidth: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(theme),
                      const SizedBox(height: 32),
                      InputField(
                        label: 'Company ID (optional)',
                        hint: 'Enter your company slug (e.g., my-company)',
                        controller: _companyIdController,
                        prefixIcon: Icons.business,
                        isRequired: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'This is the company slug provided during registration',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        isRequired: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password coming soon'),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Sign In',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleSignIn,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SecondaryButton(
                        text: 'Create Company Account',
                        icon: Icons.business,
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/company-registration',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Back to home',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textTertiary,
                            ),
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your ClockIn account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _handleSignIn() {
    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      // Normalize company slug to lowercase to match backend expectations
      companySlug: _companyIdController.text.trim().isEmpty
          ? null
          : _companyIdController.text.trim().toLowerCase(),
    );

    context.read<AuthBloc>().add(AuthLoginRequested(request: request));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _companyIdController.dispose();
    super.dispose();
  }
}
