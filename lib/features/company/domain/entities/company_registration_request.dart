import 'package:equatable/equatable.dart';

/// Company registration request entity
class CompanyRegistrationRequest extends Equatable {
  final String companyName;
  final String? companyCode; // Optional custom company code
  final String adminFirstName;
  final String adminLastName;
  final String adminEmail;
  final String adminPassword;
  final String timezone;
  final bool createSampleData;

  const CompanyRegistrationRequest({
    required this.companyName,
    this.companyCode, // Optional
    required this.adminFirstName,
    required this.adminLastName,
    required this.adminEmail,
    required this.adminPassword,
    required this.timezone,
    this.createSampleData = true,
  });

  @override
  List<Object?> get props => [
        companyName,
        companyCode,
        adminFirstName,
        adminLastName,
        adminEmail,
        adminPassword,
        timezone,
        createSampleData,
      ];

  @override
  String toString() {
    return 'CompanyRegistrationRequest(companyName: $companyName, adminEmail: $adminEmail)';
  }
}