import '../../domain/entities/user.dart';

/// User model for data layer - extends User entity
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.profilePicture,
    super.role,
    super.department,
    super.isActive,
  });

  /// Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      role: json['role'] as String?,
      department: json['department'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'role': role,
      'department': department,
      'is_active': isActive,
    };
  }

  /// Factory constructor to create UserModel from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      profilePicture: user.profilePicture,
      role: user.role,
      department: user.department,
      isActive: user.isActive,
    );
  }

  /// Convert UserModel to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      profilePicture: profilePicture,
      role: role,
      department: department,
      isActive: isActive,
    );
  }
}
