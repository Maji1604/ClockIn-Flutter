import '../../domain/entities/login_response.dart';
import 'user_model.dart';
import 'company_membership_model.dart';

/// Login response model for API deserialization
class LoginResponseModel extends LoginResponse {
  const LoginResponseModel({
    required super.user,
    super.token,
    required super.requiresPasswordChange,
    super.memberships,
  });

  /// Create from JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    // The API may return either a token + user OR a memberships list
    final token = data['token'] as String?;
    final membershipsJson = data['memberships'] as List<dynamic>?;

    final memberships = membershipsJson
        ?.map((m) => CompanyMembershipModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return LoginResponseModel(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: token,
      requiresPasswordChange:
          _parseBool(data['requires_password_change']) ?? false,
      memberships: memberships,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': true,
      'data': {
        'user': (user as UserModel).toJson(),
        'token': token,
        'requires_password_change': requiresPasswordChange,
        'memberships': (memberships ?? [])
            .map((m) => (m as CompanyMembershipModel).toJson())
            .toList(),
      },
    };
  }

  /// Create from domain entity
  factory LoginResponseModel.fromEntity(LoginResponse response) {
    return LoginResponseModel(
      user: UserModel.fromEntity(response.user),
      token: response.token,
      requiresPasswordChange: response.requiresPasswordChange,
      memberships: response.memberships
          ?.map(
            (m) => CompanyMembershipModel(
              companyId: m.companyId,
              companyName: m.companyName,
              companySlug: m.companySlug,
              role: m.role,
            ),
          )
          .toList(),
    );
  }

  /// Convert to domain entity
  LoginResponse toEntity() {
    return LoginResponse(
      user: user,
      token: token,
      requiresPasswordChange: requiresPasswordChange,
      memberships: memberships,
    );
  }

  /// Helper method to safely parse boolean values from API response
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }
}
