import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class UserHeader extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback? onNotificationTap;

  const UserHeader({
    super.key,
    required this.name,
    required this.role,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: AppColors.textOnPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                role,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotificationTap ?? () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }
}
