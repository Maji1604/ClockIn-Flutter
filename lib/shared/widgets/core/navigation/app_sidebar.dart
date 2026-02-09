import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            destinations: [
              NavigationRailDestination(
                icon: _buildSvgIcon(
                  AppIcons.menu,
                  false,
                  width: 20,
                  height: 14,
                ),
                selectedIcon: _buildSvgIcon(
                  AppIcons.menu,
                  true,
                  width: 20,
                  height: 14,
                ),
                label: const Text('Home'),
              ),
              NavigationRailDestination(
                icon: _buildSvgIcon(
                  AppIcons.group,
                  false,
                  width: 24,
                  height: 24,
                ),
                selectedIcon: _buildSvgIcon(
                  AppIcons.group,
                  true,
                  width: 24,
                  height: 24,
                ),
                label: const Text('People'),
              ),
              NavigationRailDestination(
                icon: _buildSvgIcon(
                  AppIcons.calendar,
                  false,
                  width: 22,
                  height: 24,
                ),
                selectedIcon: _buildSvgIcon(
                  AppIcons.calendar,
                  true,
                  width: 22,
                  height: 24,
                ),
                label: const Text('Time'),
              ),
              NavigationRailDestination(
                icon: _buildSvgIcon(
                  AppIcons.holiday,
                  false,
                  width: 24,
                  height: 24,
                ),
                selectedIcon: _buildSvgIcon(
                  AppIcons.holiday,
                  true,
                  width: 24,
                  height: 24,
                ),
                label: const Text('Requests'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: _buildSvgIcon(
                  AppIcons.setting,
                  false,
                  width: 22,
                  height: 22,
                ),
                selectedIcon: _buildSvgIcon(
                  AppIcons.setting,
                  true,
                  width: 22,
                  height: 22,
                ),
                label: const Text('Settings'),
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
                _buildDrawerItem(
                  context,
                  0,
                  AppIcons.menu,
                  'Home',
                  width: 20,
                  height: 14,
                ),
                _buildDrawerItem(
                  context,
                  1,
                  AppIcons.group,
                  'People',
                  width: 24,
                  height: 24,
                ),
                _buildDrawerItem(
                  context,
                  2,
                  AppIcons.calendar,
                  'Time',
                  width: 22,
                  height: 24,
                ),
                _buildDrawerItem(
                  context,
                  3,
                  AppIcons.holiday,
                  'Requests',
                  width: 24,
                  height: 24,
                ),
                _buildDrawerItemIcon(
                  context,
                  4,
                  Icons.bar_chart_outlined,
                  'Reports',
                ),
                _buildDrawerItem(
                  context,
                  5,
                  AppIcons.setting,
                  'Settings',
                  width: 22,
                  height: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSvgIcon(
    String assetPath,
    bool selected, {
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
        selected ? AppColors.primary : AppColors.textSecondary,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    int index,
    String iconPath,
    String label, {
    double? width,
    double? height,
  }) {
    final selected = index == selectedIndex;
    return ListTile(
      leading: SvgPicture.asset(
        iconPath,
        width: width,
        height: height,
        colorFilter: ColorFilter.mode(
          selected ? AppColors.primary : AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.maybePop(context);
        onSelect(index);
      },
    );
  }

  // Fallback for icons without SVG (Reports)
  Widget _buildDrawerItemIcon(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final selected = index == selectedIndex;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.maybePop(context);
        onSelect(index);
      },
    );
  }
}
