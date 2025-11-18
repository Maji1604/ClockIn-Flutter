import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/core.dart';
import '../../../../core/config/api_config.dart';
import '../../../../shared/widgets/outlined_label_text_field.dart';

class OnboardingProfileCompletionPage extends StatefulWidget {
  final String token;
  final String empId;
  final bool hasMobileNumber;
  final bool hasAddress;

  const OnboardingProfileCompletionPage({
    Key? key,
    required this.token,
    required this.empId,
    required this.hasMobileNumber,
    required this.hasAddress,
  }) : super(key: key);

  @override
  State<OnboardingProfileCompletionPage> createState() =>
      _OnboardingProfileCompletionPageState();
}

class _OnboardingProfileCompletionPageState
    extends State<OnboardingProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // If both fields already exist, skip directly
    if (widget.hasMobileNumber && widget.hasAddress) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = <String, dynamic>{};

      if (!widget.hasMobileNumber && _mobileController.text.isNotEmpty) {
        body['mobile_number'] = _mobileController.text;
      }

      if (!widget.hasAddress && _addressController.text.isNotEmpty) {
        body['address'] = _addressController.text;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/profile/${widget.empId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        if (mounted) {
          // Profile completed, return true
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          SnackBarUtil.showError(
            context,
            data['message'] ?? 'Failed to update profile',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If both fields exist, auto-complete
    if (widget.hasMobileNumber && widget.hasAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please provide your mobile number and address to complete your profile.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (!widget.hasMobileNumber) ...[
                  OutlinedLabelTextField(
                    label: 'Mobile Number',
                    controller: _mobileController,
                    hintText: 'Enter your mobile number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (!widget.hasAddress) ...[
                  OutlinedLabelTextField(
                    label: 'Address',
                    controller: _addressController,
                    hintText: 'Enter your address',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
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
                      : const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Skip for now, allow access
                          Navigator.of(context).pop(true);
                        },
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
