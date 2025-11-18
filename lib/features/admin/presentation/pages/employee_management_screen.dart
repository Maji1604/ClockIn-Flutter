import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../../../core/core.dart';
import '../../../../core/config/api_config.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final baseUrl = ApiConfig.baseUrl;

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/employees'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _employees = List<Map<String, dynamic>>.from(
              data['data']['employees'],
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showError(
          context,
          'Error loading employees: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddEmployeeDialog() async {
    final empIdController = TextEditingController();
    final nameController = TextEditingController();
    final companyEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final departmentController = TextEditingController();
    final designationController = TextEditingController();
    bool obscurePassword = true;
    bool isGeneratedPassword = false;
    bool isSubmitting = false;
    String? empIdError;
    String? nameError;
    String? emailError;
    String? passwordError;

    String _generateRandomPassword() {
      const length = 12;
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
      final random = Random.secure();
      return List.generate(
        length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    }

    String? _validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Password must contain at least one lowercase letter';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      }
      return null;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add New Employee',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: empIdController,
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                    hintText: 'EMP004',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: empIdError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: empIdError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: empIdError != null
                            ? Colors.red
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.badge,
                      color: empIdError != null ? Colors.red : null,
                    ),
                    errorText: empIdError,
                  ),
                  onChanged: (value) {
                    if (empIdError != null) {
                      setState(() => empIdError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: nameError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: nameError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: nameError != null
                            ? Colors.red
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: nameError != null ? Colors.red : null,
                    ),
                    errorText: nameError,
                  ),
                  onChanged: (value) {
                    if (nameError != null) {
                      setState(() => nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: companyEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Company Email *',
                    hintText: 'john.doe@company.com',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: emailError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: emailError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: emailError != null
                            ? Colors.red
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: emailError != null ? Colors.red : null,
                    ),
                    errorText: emailError,
                  ),
                  onChanged: (value) {
                    if (emailError != null) {
                      setState(() => emailError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: passwordError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: passwordError != null ? Colors.red : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? Colors.red
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: passwordError != null ? Colors.red : null,
                    ),
                    errorText: passwordError,
                    helperText: passwordError == null
                        ? 'Min 8 chars, 1 uppercase, 1 lowercase, 1 number'
                        : null,
                    helperMaxLines: 2,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          tooltip: obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: () {
                            final newPassword = _generateRandomPassword();
                            passwordController.text = newPassword;
                            setState(() {
                              isGeneratedPassword = true;
                              obscurePassword = false;
                              passwordError = null;
                            });
                          },
                          tooltip: 'Generate random password',
                        ),
                        if (isGeneratedPassword)
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: passwordController.text),
                              );
                              SnackBarUtil.showSuccess(
                                context,
                                'Password copied to clipboard',
                                duration: const Duration(seconds: 2),
                              );
                            },
                            tooltip: 'Copy password',
                          ),
                      ],
                    ),
                  ),
                  onChanged: (value) {
                    if (passwordError != null) {
                      setState(() => passwordError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    hintText: 'Engineering',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    hintText: 'Software Engineer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                // Clear previous errors
                                setState(() {
                                  empIdError = null;
                                  nameError = null;
                                  emailError = null;
                                  passwordError = null;
                                });

                                // Validate required fields
                                bool hasError = false;

                                if (empIdController.text.trim().isEmpty) {
                                  setState(() {
                                    empIdError = 'Employee ID is required';
                                  });
                                  hasError = true;
                                }

                                if (nameController.text.trim().isEmpty) {
                                  setState(() {
                                    nameError = 'Full Name is required';
                                  });
                                  hasError = true;
                                }

                                if (companyEmailController.text
                                    .trim()
                                    .isEmpty) {
                                  setState(() {
                                    emailError = 'Company Email is required';
                                  });
                                  hasError = true;
                                }

                                // Validate password
                                final passwordValidationError =
                                    _validatePassword(passwordController.text);
                                if (passwordValidationError != null) {
                                  setState(() {
                                    passwordError = passwordValidationError;
                                  });
                                  hasError = true;
                                }

                                if (hasError) return;

                                // Submit the form
                                setState(() => isSubmitting = true);

                                try {
                                  final baseUrl = ApiConfig.baseUrl;

                                  final response = await http.post(
                                    Uri.parse('$baseUrl/api/employees'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode({
                                      'empId': empIdController.text.trim(),
                                      'name': nameController.text.trim(),
                                      'password': passwordController.text,
                                      'company_email': companyEmailController
                                          .text
                                          .trim(),
                                      'department':
                                          departmentController.text
                                              .trim()
                                              .isNotEmpty
                                          ? departmentController.text.trim()
                                          : 'General',
                                      'designation':
                                          designationController.text
                                              .trim()
                                              .isNotEmpty
                                          ? designationController.text.trim()
                                          : 'Employee',
                                    }),
                                  );

                                  setState(() => isSubmitting = false);

                                  if (response.statusCode == 201) {
                                    if (context.mounted) {
                                      // Success - close dialog and reload
                                      Navigator.pop(context);
                                      SnackBarUtil.showSuccess(
                                        context,
                                        'Employee added successfully',
                                      );
                                      _loadEmployees();
                                    }
                                  } else {
                                    // Error from API
                                    final data = jsonDecode(response.body);
                                    final errorMessage =
                                        data['message'] ??
                                        'Failed to add employee';

                                    // Check if it's a duplicate employee ID error
                                    if (errorMessage.toLowerCase().contains(
                                          'already exists',
                                        ) ||
                                        errorMessage.toLowerCase().contains(
                                          'duplicate',
                                        ) ||
                                        errorMessage.toLowerCase().contains(
                                          'empid',
                                        )) {
                                      setState(() {
                                        empIdError = errorMessage;
                                      });
                                    } else if (errorMessage
                                        .toLowerCase()
                                        .contains('email')) {
                                      setState(() {
                                        emailError = errorMessage;
                                      });
                                    } else {
                                      // Generic error - show in snackbar
                                      if (context.mounted) {
                                        SnackBarUtil.showError(
                                          context,
                                          errorMessage,
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  setState(() => isSubmitting = false);
                                  if (context.mounted) {
                                    SnackBarUtil.showError(
                                      context,
                                      'Error: ${e.toString()}',
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Add Employee'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEmployeeDetails(Map<String, dynamic> employee) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    radius: 32,
                    child: Text(
                      employee['name']?.substring(0, 1).toUpperCase() ?? 'E',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          employee['emp_id'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow(
                      'Department',
                      employee['department'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Designation',
                      employee['designation'] ?? 'N/A',
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                      'Company Email',
                      employee['company_email'] ?? 'Not set',
                      Icons.business,
                    ),
                    if (employee['email'] != null &&
                        employee['email'].toString().isNotEmpty)
                      _buildDetailRow(
                        'Personal Email',
                        employee['email'],
                        Icons.email,
                      ),
                    if (employee['mobile_number'] != null &&
                        employee['mobile_number'].toString().isNotEmpty)
                      _buildDetailRow(
                        'Mobile Number',
                        employee['mobile_number'],
                        Icons.phone,
                      ),
                    if (employee['address'] != null &&
                        employee['address'].toString().isNotEmpty)
                      _buildDetailRow(
                        'Address',
                        employee['address'],
                        Icons.home,
                      ),
                    const Divider(height: 32),
                    _buildDetailRow(
                      'Created',
                      employee['created_at'] ?? 'N/A',
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditEmployeeDialog(employee);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteEmployee(
                          employee['emp_id'] ?? '',
                          employee['name'] ?? 'Unknown',
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditEmployeeDialog(Map<String, dynamic> employee) async {
    final nameController = TextEditingController(text: employee['name']);
    final companyEmailController = TextEditingController(
      text: employee['company_email'] ?? '',
    );
    final departmentController = TextEditingController(
      text: employee['department'],
    );
    final designationController = TextEditingController(
      text: employee['designation'],
    );
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool resetPassword = false;

    String _generateRandomPassword() {
      const length = 12;
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
      final random = Random.secure();
      return List.generate(
        length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit Employee',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: companyEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Company Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Reset Password'),
                  value: resetPassword,
                  onChanged: (value) {
                    setState(() {
                      resetPassword = value ?? false;
                      if (!resetPassword) {
                        passwordController.clear();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (resetPassword) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hintText: '••••••••',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      helperText:
                          'Min 8 chars, 1 uppercase, 1 lowercase, 1 number',
                      helperMaxLines: 2,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () {
                              final newPassword = _generateRandomPassword();
                              passwordController.text = newPassword;
                              setState(() {
                                obscurePassword = false;
                              });
                            },
                            tooltip: 'Generate password',
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              if (passwordController.text.isNotEmpty) {
                                Clipboard.setData(
                                  ClipboardData(text: passwordController.text),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password copied'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Name is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (resetPassword &&
                              passwordController.text.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password must be at least 8 characters',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          await _updateEmployee(
                            employee['emp_id'],
                            nameController.text.trim(),
                            companyEmailController.text.trim(),
                            departmentController.text.trim(),
                            designationController.text.trim(),
                            resetPassword ? passwordController.text : null,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Update Employee'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateEmployee(
    String empId,
    String name,
    String companyEmail,
    String department,
    String designation,
    String? password,
  ) async {
    try {
      final baseUrl = ApiConfig.baseUrl;

      final body = <String, dynamic>{
        'name': name,
        'company_email': companyEmail.isNotEmpty ? companyEmail : null,
        'department': department.isNotEmpty ? department : 'General',
        'designation': designation.isNotEmpty ? designation : 'Employee',
      };

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/employees/$empId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadEmployees();
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to update employee'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(String empId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final baseUrl = ApiConfig.baseUrl;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/employees/$empId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadEmployees();
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to delete employee'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Employee Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No employees yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddEmployeeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Employee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEmployees,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        radius: 28,
                        child: Text(
                          employee['name']?.substring(0, 1).toUpperCase() ??
                              'E',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        employee['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('ID: ${employee['emp_id'] ?? 'N/A'}'),
                          Text('Dept: ${employee['department'] ?? 'N/A'}'),
                          if (employee['designation'] != null)
                            Text('Role: ${employee['designation']}'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showEmployeeDetails(employee),
                    ),
                  );
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
