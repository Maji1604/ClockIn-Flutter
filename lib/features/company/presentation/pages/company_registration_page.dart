import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/core/layout/page_scaffold.dart';
import '../../../../shared/widgets/core/layout/content_container.dart';
import '../../../../shared/widgets/core/buttons/primary_button.dart';
import '../../../../shared/widgets/core/forms/input_field.dart';
import '../../domain/entities/company_registration_request.dart';
import '../bloc/company_registration_bloc.dart';
import '../bloc/company_registration_event.dart';
import '../bloc/company_registration_state.dart';
import 'company_registration_success_page.dart';

class CompanyRegistrationPage extends StatefulWidget {
  const CompanyRegistrationPage({super.key});

  @override
  State<CompanyRegistrationPage> createState() => _CompanyRegistrationPageState();
}

class _CompanyRegistrationPageState extends State<CompanyRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _adminFirstNameController = TextEditingController();
  final _adminLastNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  String _selectedTimezone = 'UTC';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PageScaffold(
      showAppBar: true,
      title: 'Create Company',
      body: BlocListener<CompanyRegistrationBloc, CompanyRegistrationState>(
        listener: (context, state) {
          if (state is CompanyRegistrationSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Company "${state.response.company.name}" created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // Navigate to success page with company information
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyRegistrationSuccessPage(
                  response: state.response,
                ),
              ),
            );
          } else if (state is CompanyRegistrationFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<CompanyRegistrationBloc, CompanyRegistrationState>(
          builder: (context, state) {
            final isLoading = state is CompanyRegistrationLoading;
            
            return SingleChildScrollView(
              child: ContentContainer(
                maxWidth: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Header
                      _buildHeader(theme),
                      
                      const SizedBox(height: 32),
                      
                      // Company Information Section
                      _buildSectionTitle(theme, 'Company Information'),
                      const SizedBox(height: 16),
                      
                      InputField(
                        label: 'Company Name',
                        hint: 'Enter your company name',
                        controller: _companyNameController,
                        prefixIcon: Icons.business,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Company name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Company name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Admin Account Section
                      _buildSectionTitle(theme, 'Admin Account'),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: InputField(
                              label: 'First Name',
                              hint: 'First name',
                              controller: _adminFirstNameController,
                              prefixIcon: Icons.person_outline,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'First name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InputField(
                              label: 'Last Name',
                              hint: 'Last name',
                              controller: _adminLastNameController,
                              prefixIcon: Icons.person_outline,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Last name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      InputField(
                        label: 'Email',
                        hint: 'admin@yourcompany.com',
                        controller: _adminEmailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Timezone Selector
                      _buildTimezoneSelector(theme),
                      
                      const SizedBox(height: 20),
                      
                      InputField(
                        label: 'Password',
                        hint: 'Create a strong password',
                        controller: _adminPasswordController,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        isRequired: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Terms and Conditions
                      _buildTermsCheckbox(theme),
                      
                      const SizedBox(height: 24),
                      
                      // Create Account Button
                      PrimaryButton(
                        text: 'Create Company Account',
                        isLoading: isLoading,
                        onPressed: _agreeToTerms && !isLoading ? _handleCreateAccount : null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sign In Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: Text(
                                'Sign in',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your company',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set up your ClockIn account in just 2 minutes',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTimezoneSelector(ThemeData theme) {
    final timezones = [
      'UTC',
      'America/New_York',
      'America/Chicago',
      'America/Denver',
      'America/Los_Angeles',
      'Europe/London',
      'Europe/Paris',
      'Europe/Berlin',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Asia/Kolkata',
      'Australia/Sydney',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timezone *',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimezone,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textTertiary),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
              dropdownColor: AppColors.surface,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimezone = newValue;
                  });
                }
              },
              items: timezones.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      const Icon(Icons.public, size: 20, color: AppColors.textTertiary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleCreateAccount() {
    if (!_formKey.currentState!.validate()) return;
    
    final request = CompanyRegistrationRequest(
      companyName: _companyNameController.text.trim(),
      adminFirstName: _adminFirstNameController.text.trim(),
      adminLastName: _adminLastNameController.text.trim(),
      adminEmail: _adminEmailController.text.trim(),
      adminPassword: _adminPasswordController.text,
      timezone: _selectedTimezone,
      createSampleData: true,
    );
    
    context.read<CompanyRegistrationBloc>().add(
      RegisterCompanyRequested(request: request),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }
}