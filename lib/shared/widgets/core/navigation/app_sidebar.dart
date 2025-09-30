import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Responsive sidebar/navigation rail used across the admin UI
class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use NavigationRail on wide screens and Drawer-like ListView on small screens
        if (constraints.maxWidth > 800) {
          return NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: AppColors.primary,
                        child: const Center(
                          child: Text(
                            'CI',
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                label: Text('People'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.access_time_outlined),
                label: Text('Time'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_alt_outlined),
                label: Text('Requests'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
              ),
            ],
          );
        }

        // Drawer-like column for small screens
        return Drawer(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'CI',
                          style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ClockIn',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDrawerItem(context, 0, Icons.home_outlined, 'Home'),
                _buildDrawerItem(context, 1, Icons.people_outline, 'People'),
                _buildDrawerItem(context, 2, Icons.access_time_outlined, 'Time'),
                _buildDrawerItem(context, 3, Icons.list_alt_outlined, 'Requests'),
                _buildDrawerItem(context, 4, Icons.bar_chart_outlined, 'Reports'),
                _buildDrawerItem(context, 5, Icons.settings_outlined, 'Settings'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, int index, IconData icon, String label) {
    final selected = index == selectedIndex;
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary)),
      selected: selected,
      onTap: () {
        Navigator.maybePop(context);
        onSelect(index);
      },
    );
  }
}
