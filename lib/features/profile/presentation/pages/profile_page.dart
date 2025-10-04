import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onBack;
  const ProfilePage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            height: 36,
            child: Stack(
              children: [
                // Back button on the left
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Profile content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate 30% of available height for profile section
              final profileSectionHeight = constraints.maxHeight * 0.30;
              
              return Column(
                children: [
                  // Profile section - exactly 30% of screen
                  SizedBox(
                    height: profileSectionHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile avatar with camera icon
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            // Camera icon for changing profile picture
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4A90E2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Name
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Role/Designation
                        Text(
                          'App Developer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit Profile Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle edit profile
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit Profile tapped')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Menu items - wrapped in Expanded to prevent overflow
                  Expanded(
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'settings',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        // Log out
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Log out',
                          onTap: () {},
                          isLogout: true,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isLogout ? const Color(0xFFFF6B6B) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? const Color(0xFFFF6B6B) : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (!isLogout)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }
}