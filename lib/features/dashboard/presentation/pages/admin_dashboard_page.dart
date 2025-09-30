import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/core/layout/page_scaffold.dart';
import '../../../../shared/widgets/core/layout/content_container.dart';
import '../../../../shared/widgets/core/navigation/app_sidebar.dart';
import '../../../../shared/widgets/core/cards/stat_card.dart';
import '../../../../shared/widgets/core/cards/quick_action_card.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            // Use a two-column layout with a persistent sidebar on wide screens
            return Scaffold(
              body: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar / NavigationRail
                    SizedBox(
                      width: 88,
                      child: AppSidebar(
                        selectedIndex: 0,
                        onSelect: (index) {
                          // For now, keep navigation simple; later wire routes
                          AppLogger.info('Sidebar selected: $index', 'ADMIN_DASH');
                        },
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        child: ContentContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildHeaderWithActions(context, theme, state.user),
                              const SizedBox(height: 24),

                              // KPI row
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 900) {
                                    return Row(
                                      children: const [
                                        Expanded(
                                          child: StatCard(
                                            title: 'Employees online',
                                            value: '12',
                                            icon: Icons.people,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: StatCard(
                                            title: 'Today clock-ins',
                                            value: '93',
                                            icon: Icons.login,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: StatCard(
                                            title: 'Pending approvals',
                                            value: '3',
                                            icon: Icons.pending,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: const [
                                      StatCard(
                                        title: 'Employees online',
                                        value: '12',
                                        icon: Icons.people,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(height: 12),
                                      StatCard(
                                        title: 'Today clock-ins',
                                        value: '93',
                                        icon: Icons.login,
                                        color: AppColors.accent,
                                      ),
                                      SizedBox(height: 12),
                                      StatCard(
                                        title: 'Pending approvals',
                                        value: '3',
                                        icon: Icons.pending,
                                        color: AppColors.warning,
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Quick Actions grid
                              Text(
                                'Quick Actions',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: 340,
                                    child: QuickActionCard(
                                      icon: Icons.login,
                                      title: 'Clock In',
                                      subtitle: 'Manual clock-in for employees',
                                      accent: AppColors.primary,
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Clock In action')),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 340,
                                    child: QuickActionCard(
                                      icon: Icons.logout,
                                      title: 'Clock Out',
                                      subtitle: 'Manual clock-out for employees',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Clock Out action')),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 340,
                                    child: QuickActionCard(
                                      icon: Icons.person_add,
                                      title: 'Add Employee',
                                      subtitle: 'Invite new team members',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Add Employee')),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 340,
                                    child: QuickActionCard(
                                      icon: Icons.approval,
                                      title: 'Approvals',
                                      subtitle: 'Approve leave & timesheets',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Approvals')),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Recent Activity (kept minimal)
                              _buildRecentActivity(theme),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const PageScaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  // _buildWelcomeHeader removed during refactor; header is now built by
  // _buildHeaderWithActions which includes actions and avatar.

  Widget _buildHeaderWithActions(BuildContext context, ThemeData theme, user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${user.firstName}!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Here\'s what\'s happening in your organization today.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
              icon: const Icon(Icons.logout),
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(user.firstName.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.textOnPrimary)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.inbox,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Activity will appear here once you start using the system.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}