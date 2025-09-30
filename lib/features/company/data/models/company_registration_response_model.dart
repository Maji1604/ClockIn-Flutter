import '../../domain/entities/company_registration_response.dart';
import 'company_model.dart';
import 'admin_user_model.dart';

/// Company registration response model for API deserialization
class CompanyRegistrationResponseModel extends CompanyRegistrationResponse {
  const CompanyRegistrationResponseModel({
    required super.company,
    required super.admin,
    required super.token,
  });

  /// Create from JSON
  factory CompanyRegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return CompanyRegistrationResponseModel(
      company: CompanyModel.fromJson(data['company'] as Map<String, dynamic>),
      admin: AdminUserModel.fromJson(data['admin'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': true,
      'data': {
        'company': (company as CompanyModel).toJson(),
        'admin': (admin as AdminUserModel).toJson(),
        'token': token,
      },
    };
  }

  /// Create from domain entity
  factory CompanyRegistrationResponseModel.fromEntity(
    CompanyRegistrationResponse response,
  ) {
    return CompanyRegistrationResponseModel(
      company: CompanyModel.fromEntity(response.company),
      admin: AdminUserModel.fromEntity(response.admin),
      token: response.token,
    );
  }

  /// Convert to domain entity
  CompanyRegistrationResponse toEntity() {
    return CompanyRegistrationResponse(
      company: company,
      admin: admin,
      token: token,
    );
  }
}