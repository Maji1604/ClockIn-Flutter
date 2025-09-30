import '../../domain/entities/password_change_request.dart';

/// Password change request model for API serialization
class PasswordChangeRequestModel extends PasswordChangeRequest {
  const PasswordChangeRequestModel({
    required super.currentPassword,
    required super.newPassword,
    required super.confirmPassword,
    required super.isFirstTime,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
      'is_first_time': isFirstTime,
    };
  }

  /// Create from domain entity
  factory PasswordChangeRequestModel.fromEntity(PasswordChangeRequest request) {
    return PasswordChangeRequestModel(
      currentPassword: request.currentPassword,
      newPassword: request.newPassword,
      confirmPassword: request.confirmPassword,
      isFirstTime: request.isFirstTime,
    );
  }

  /// Convert to domain entity
  PasswordChangeRequest toEntity() {
    return PasswordChangeRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      isFirstTime: isFirstTime,
    );
  }
}