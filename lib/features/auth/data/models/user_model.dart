import '../../domain/entities/user.dart';

/// User model for API serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    super.companyId,
    super.companySlug,
    required super.mustChangePassword,
    required super.isFirstLogin,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      companyId: json['company_id'] as String?,
      companySlug: json['company_slug'] as String?,
      mustChangePassword: _parseBool(json['must_change_password']) ?? false,
      isFirstLogin: _parseBool(json['is_first_login']) ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'company_id': companyId,
      'company_slug': companySlug,
      'must_change_password': mustChangePassword,
      'is_first_login': isFirstLogin,
    };
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      companyId: user.companyId,
      companySlug: user.companySlug,
      mustChangePassword: user.mustChangePassword,
      isFirstLogin: user.isFirstLogin,
    );
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      companyId: companyId,
      companySlug: companySlug,
      mustChangePassword: mustChangePassword,
      isFirstLogin: isFirstLogin,
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