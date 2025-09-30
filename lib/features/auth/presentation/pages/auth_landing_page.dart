import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/core/layout/page_scaffold.dart';
import '../../../../shared/widgets/core/layout/content_container.dart';
import '../../../../shared/widgets/core/buttons/primary_button.dart';
import '../../../../shared/widgets/core/buttons/secondary_button.dart';

class AuthLandingPage extends StatefulWidget {
  const AuthLandingPage({super.key});

  @override
  State<AuthLandingPage> createState() => _AuthLandingPageState();
}

class _AuthLandingPageState extends State<AuthLandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return PageScaffold(
      body: SingleChildScrollView(
        child: ContentContainer(
          maxWidth: 480,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.08),
                  
                  // Logo & Brand
                  _buildBrandSection(theme),
                  
                  SizedBox(height: size.height * 0.06),
                  
                  // Hero Message
                  _buildHeroSection(theme),
                  
                  const SizedBox(height: 48),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 32),
                  
                  // Features
                  _buildFeatures(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Trust Signal
                  _buildTrustSignal(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection(ThemeData theme) {
    return Column(
      children: [
        // Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.schedule,
            color: AppColors.textOnPrimary,
            size: 32,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Brand Name
        Text(
          'ClockIn',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Simple time tracking\nfor modern teams',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Get started in 2 minutes. No credit card required.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary CTA - Company Registration
        PrimaryButton(
          text: 'Create Company Account',
          icon: Icons.business,
          onPressed: () {
            Navigator.pushNamed(context, '/company-registration');
          },
        ),
        
        const SizedBox(height: 16),
        
        // Secondary CTA - Login
        SecondaryButton(
          text: 'Sign in to existing account',
          icon: Icons.login,
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget _buildFeatures(ThemeData theme) {
    final features = [
      {'icon': Icons.location_on, 'text': 'GPS tracking'},
      {'icon': Icons.security, 'text': 'Secure'},
      {'icon': Icons.analytics, 'text': 'Reports'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Expanded(
          child: Column(
            children: [
              Icon(
                feature['icon'] as IconData,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                feature['text'] as String,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrustSignal(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user,
            color: AppColors.success,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Trusted by 500+ companies',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}