import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../../../core/core.dart';

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
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://clockin-backend.permasparkapp.workers.dev/api/employees',
        ),
        headers: {'Content-Type': 'application/json'},
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
    final passwordController = TextEditingController();
    final departmentController = TextEditingController();
    final designationController = TextEditingController();
    bool obscurePassword = true;
    bool isGeneratedPassword = false;

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
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    hintText: 'EMP004',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'Copy password',
                          ),
                      ],
                    ),
                  ),
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
                        onPressed: () async {
                          // Validate required fields
                          if (empIdController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Employee ID is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Full Name is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Validate password
                          final passwordError = _validatePassword(
                            passwordController.text,
                          );
                          if (passwordError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(passwordError),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          await _addEmployee(
                            empIdController.text.trim(),
                            nameController.text.trim(),
                            passwordController.text,
                            departmentController.text.trim(),
                            designationController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Add Employee'),
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

  Future<void> _addEmployee(
    String empId,
    String name,
    String password,
    String department,
    String designation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://clockin-backend.permasparkapp.workers.dev/api/employees',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empId': empId,
          'name': name,
          'password': password,
          'department': department,
          'designation': designation,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee added successfully'),
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
              content: Text(data['message'] ?? 'Failed to add employee'),
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
      final response = await http.delete(
        Uri.parse(
          'https://clockin-backend.permasparkapp.workers.dev/api/employees/$empId',
        ),
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
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteEmployee(
                          employee['emp_id'] ?? '',
                          employee['name'] ?? 'Unknown',
                        ),
                        tooltip: 'Delete Employee',
                      ),
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
