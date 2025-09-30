import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/core/layout/page_scaffold.dart';
import '../../../../shared/widgets/core/layout/content_container.dart';
import '../../../../shared/widgets/core/buttons/primary_button.dart';
import '../../../../shared/widgets/core/buttons/secondary_button.dart';
import '../../domain/entities/company_registration_response.dart';

class CompanyRegistrationSuccessPage extends StatelessWidget {
  final CompanyRegistrationResponse response;

  const CompanyRegistrationSuccessPage({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageScaffold(
      showAppBar: false,
      body: SingleChildScrollView(
        child: ContentContainer(
          maxWidth: 900,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // Success Icon + Title Row (responsive)
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated Icon
                        _buildAnimatedSuccessIcon(),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Company Created Successfully!',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Welcome to ClockIn! Your company "${response.company.name}" is ready to use.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    const SizedBox(height: 12),
                    _buildAnimatedSuccessIcon(),
                    const SizedBox(height: 20),
                    Text(
                      'Company Created Successfully!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to ClockIn! Your company "${response.company.name}" has been set up and is ready to use.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Two-column layout on wide screens: Left = ID + Info + Next Steps, Right = CTAs
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildCompanyIdCard(context, theme),
                              const SizedBox(height: 20),
                              _buildCompanyInfoCard(theme),
                              const SizedBox(height: 20),
                              _buildNextSteps(theme),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [_buildActionButtons(context)],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildCompanyIdCard(context, theme),
                    const SizedBox(height: 16),
                    _buildCompanyInfoCard(theme),
                    const SizedBox(height: 16),
                    _buildNextSteps(theme),
                    const SizedBox(height: 20),
                    _buildActionButtons(context),
                  ],

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSuccessIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(48),
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 56),
    );
  }

  Widget _buildCompanyIdCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.key, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              // Allow the important title to wrap on small screens by
              // placing it inside an Expanded so it doesn't overflow.
              Expanded(
                child: Text(
                  'IMPORTANT: Save Your Company ID',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Company ID:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        response.company.companyCode,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  onPressed: () {
                    // Copy the company slug (normalized) which is the expected
                    // company_identifier for login. Use lowercase to be safe.
                    final slug = response.company.slug.toLowerCase();
                    Clipboard.setData(ClipboardData(text: slug));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Company slug "$slug" copied!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  tooltip: 'Copy Company ID',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your employees can login with just email + password, or use this Company Slug for company-specific login.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Company Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow('Company Name', response.company.name),
            const SizedBox(height: 8),
            _buildInfoRow('Admin Email', response.admin.email),
            const SizedBox(height: 8),
            _buildInfoRow('Timezone', response.company.timezone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextSteps(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'What\'s Next?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildNextStep(
            '1',
            'Login as Administrator',
            'Use your email and Company ID to access your dashboard',
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            '2',
            'Set up Departments & Teams',
            'Organize your company structure',
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            '3',
            'Invite Employees',
            'Add your team members to start tracking time',
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary CTA - Go to Login
        PrimaryButton(
          text: 'Login as Administrator',
          icon: Icons.login,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),

        const SizedBox(height: 12),

        // Secondary CTA - Copy Company ID Again
        SecondaryButton(
          text: 'Copy Company Slug',
          icon: Icons.copy,
          onPressed: () {
            final slug = response.company.slug.toLowerCase();
            Clipboard.setData(ClipboardData(text: slug));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Company slug "$slug" copied to clipboard!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ],
    );
  }
}
