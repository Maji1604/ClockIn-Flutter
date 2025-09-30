import '../../domain/entities/login_request.dart';

/// Login request model for API serialization
class LoginRequestModel extends LoginRequest {
  const LoginRequestModel({
    required super.email,
    required super.password,
    super.companySlug,
  });

  /// Convert to JSON - supports email-only and company-specific login
  Map<String, dynamic> toJson() {
    final json = {'email': email, 'password': password};

    // Add company identifier only if provided (for company-specific login)
    if (companySlug != null && companySlug!.trim().isNotEmpty) {
      // Normalize to lowercase and trimmed value to match backend expectations
      json['company_identifier'] = companySlug!.trim().toLowerCase();
    }

    return json;
  }

  /// Get headers
  Map<String, String> getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  /// Create from domain entity
  factory LoginRequestModel.fromEntity(LoginRequest request) {
    return LoginRequestModel(
      email: request.email,
      password: request.password,
      companySlug: request.companySlug,
    );
  }

  /// Convert to domain entity
  LoginRequest toEntity() {
    return LoginRequest(
      email: email,
      password: password,
      companySlug: companySlug,
    );
  }
}
