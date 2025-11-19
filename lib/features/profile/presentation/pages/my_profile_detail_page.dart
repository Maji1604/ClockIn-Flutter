import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../../shared/widgets/outlined_label_text_field.dart';
import '../bloc/profile_bloc.dart';

class MyProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MyProfileDetailPage({super.key, required this.userData});

  @override
  State<MyProfileDetailPage> createState() => _MyProfileDetailPageState();
}

class _MyProfileDetailPageState extends State<MyProfileDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  // Professional tab controllers
  final _employeeIdController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  void _loadProfile() async {
    final token = await ServiceLocator.authRepository.getToken();
    final empId = widget.userData['employee_id'] as String;

    if (token != null && empId.isNotEmpty) {
      if (!mounted) return;
      context.read<ProfileBloc>().add(
        FetchProfileEvent(empId: empId, token: token),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    _companyEmailController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _populateControllers(profile) {
    _nameController.text = profile.name ?? '';
    _mobileController.text = profile.mobileNumber ?? '';
    _addressController.text = profile.address ?? '';
    _employeeIdController.text = profile.empId ?? '';
    _companyEmailController.text = profile.companyEmail ?? '';
    _designationController.text = profile.designation ?? '';
    _departmentController.text = profile.department ?? '';
  }

  void _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await ServiceLocator.authRepository.getToken();
    final empId = widget.userData['employee_id'] as String;

    if (token != null && empId.isNotEmpty) {
      if (!mounted) return;
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          empId: empId,
          token: token,
          mobileNumber: _mobileController.text.trim(),
          address: _addressController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _populateControllers(state.profile);
        } else if (state is ProfileError) {
          SnackBarUtil.showError(context, state.message);
        } else if (state is ProfileUpdated) {
          SnackBarUtil.showSuccess(context, 'Profile updated successfully');
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isLoading = state is ProfileLoading || state is ProfileUpdating;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Tab Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: false,
                            labelColor: Colors.white,
                            unselectedLabelColor: const Color(0xFF6B7280),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            indicator: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.all(2),
                            tabs: const [
                              Tab(text: 'Personal'),
                              Tab(text: 'Professional'),
                              Tab(text: 'Documents'),
                            ],
                          ),
                        ),
                      ),
                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPersonalTab(),
                            _buildProfessionalTab(),
                            _buildDocumentsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildTextField(
                        label: 'Name',
                        controller: _nameController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Mobile',
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Address',
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleUpdateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Employee Id',
            controller: _employeeIdController,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Company Email',
            controller: _companyEmailController,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Designation',
            controller: _designationController,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Department',
            controller: _departmentController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDocumentItem('Offer Letter'),
          _buildDocumentItem('Appointment Letter'),
          _buildDocumentItem('Employment Letter'),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          // Document Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF2196F3),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Document title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Download button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.file_download_outlined,
              size: 18,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return OutlinedLabelTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      labelTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4B5563),
        letterSpacing: 0.2,
      ),
    );
  }
}
