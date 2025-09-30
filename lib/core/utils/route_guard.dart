import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/auth_landing_page.dart';

/// Route guard to protect authenticated routes
class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool requiresAuth;
  final bool requiresAdmin;

  const RouteGuard({
    super.key,
    required this.child,
    this.requiresAuth = true,
    this.requiresAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // If authentication is not required, show the child
        if (!requiresAuth) {
          return child;
        }

        // If loading, show loading indicator
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If not authenticated, redirect to landing page
        if (state is! AuthAuthenticated) {
          return const AuthLandingPage();
        }

        // If admin is required but user is not admin, show access denied
        if (requiresAdmin && !state.user.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You do not have permission to access this page.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // If password change is required, handle it in the main app
        return child;
      },
    );
  }
}