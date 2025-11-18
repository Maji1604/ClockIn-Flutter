import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/core.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/role_selection_page.dart';
import 'employee_management_screen.dart';
import 'admin_leave_management_screen.dart';
import '../../../holiday/presentation/pages/admin_holiday_management_page.dart';
import '../../../holiday/presentation/bloc/holiday_bloc.dart';
import '../../../holiday/data/repositories/holiday_repository_impl.dart';
import '../../../holiday/data/datasources/holiday_remote_data_source.dart';

class AdminDashboard extends StatelessWidget {
  final Map<String, dynamic>? adminData;

  const AdminDashboard({super.key, this.adminData});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        AppLogger.info('=== ADMIN DASHBOARD: AuthBloc state changed ===');
        AppLogger.debug('ADMIN DASHBOARD: New state: ${state.runtimeType}');
        
        if (state is AuthUnauthenticated) {
          AppLogger.info('=== ADMIN DASHBOARD: User logged out, navigating to role selection ===');
          // Navigate to role selection page and clear navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              AppLogger.info('=== ADMIN DASHBOARD: Logout button pressed ===');
              // Show logout confirmation dialog
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        AppLogger.debug('ADMIN DASHBOARD: Logout cancelled');
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        AppLogger.info('=== ADMIN DASHBOARD: Logout confirmed ===');
                        Navigator.of(dialogContext).pop();
                        // Dispatch logout event
                        AppLogger.debug('ADMIN DASHBOARD: Dispatching LogoutRequested event...');
                        context.read<AuthBloc>().add(LogoutRequested());
                        AppLogger.debug('ADMIN DASHBOARD: LogoutRequested event dispatched');
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your organization',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _DashboardCard(
                    icon: Icons.people_rounded,
                    title: 'Employees',
                    description: 'Manage employees',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.access_time_rounded,
                    title: 'Attendance',
                    description: 'View attendance',
                    color: AppColors.accent,
                    onTap: () {
                      // TODO: Navigate to attendance screen
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.event_note_rounded,
                    title: 'Leaves',
                    description: 'Manage leaves',
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AdminLeaveManagementScreen(
                            adminData: adminData ?? {},
                          ),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Holidays',
                    description: 'Manage holidays',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => HolidayBloc(
                              repository: HolidayRepository(
                                remoteDataSource: HolidayRemoteDataSourceImpl(
                                  client: http.Client(),
                                ),
                              ),
                            ),
                            child: AdminHolidayManagementPage(
                              onBack: () => Navigator.of(context).pop(),
                              userData: adminData ?? {},
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.insert_chart_rounded,
                    title: 'Reports',
                    description: 'Generate reports',
                    color: const Color(0xFF9333EA),
                    onTap: () {
                      // TODO: Navigate to reports screen
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    description: 'App settings',
                    color: const Color(0xFF64748B),
                    onTap: () {
                      // TODO: Navigate to settings screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ), // End of BlocListener child (Scaffold)
    ); // End of BlocListener
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
