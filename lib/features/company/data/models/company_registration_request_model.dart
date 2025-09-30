import '../../domain/entities/company_registration_request.dart';

/// Company registration request model for API serialization
class CompanyRegistrationRequestModel extends CompanyRegistrationRequest {
  const CompanyRegistrationRequestModel({
    required super.companyName,
    super.companyCode,
    required super.adminFirstName,
    required super.adminLastName,
    required super.adminEmail,
    required super.adminPassword,
    required super.timezone,
    super.createSampleData = true,
  });

  /// Create from domain entity
  factory CompanyRegistrationRequestModel.fromEntity(
    CompanyRegistrationRequest request,
  ) {
    return CompanyRegistrationRequestModel(
      companyName: request.companyName,
      companyCode: request.companyCode,
      adminFirstName: request.adminFirstName,
      adminLastName: request.adminLastName,
      adminEmail: request.adminEmail,
      adminPassword: request.adminPassword,
      timezone: request.timezone,
      createSampleData: request.createSampleData,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = {
      'company_name': companyName,
      'admin_first_name': adminFirstName,
      'admin_last_name': adminLastName,
      'admin_email': adminEmail,
      'admin_password': adminPassword,
      'timezone': timezone,
      'create_sample_data': createSampleData,
    };
    
    // Add company_code only if provided
    if (companyCode != null && companyCode!.isNotEmpty) {
      json['company_code'] = companyCode!;
    }
    
    return json;
  }

  /// Convert to domain entity
  CompanyRegistrationRequest toEntity() {
    return CompanyRegistrationRequest(
      companyName: companyName,
      companyCode: companyCode,
      adminFirstName: adminFirstName,
      adminLastName: adminLastName,
      adminEmail: adminEmail,
      adminPassword: adminPassword,
      timezone: timezone,
      createSampleData: createSampleData,
    );
  }
}