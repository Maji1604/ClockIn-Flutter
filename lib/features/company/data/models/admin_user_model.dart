import '../../domain/entities/admin_user.dart';

/// Admin user model for API serialization
class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.mustChangePassword,
  });

  /// Create from JSON
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      mustChangePassword: _parseBool(json['must_change_password']) ?? true,
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
      'must_change_password': mustChangePassword,
    };
  }

  /// Create from domain entity
  factory AdminUserModel.fromEntity(AdminUser user) {
    return AdminUserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      mustChangePassword: user.mustChangePassword,
    );
  }

  /// Convert to domain entity
  AdminUser toEntity() {
    return AdminUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      mustChangePassword: mustChangePassword,
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