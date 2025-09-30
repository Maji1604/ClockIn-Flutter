import 'package:equatable/equatable.dart';

/// Password change request entity
class PasswordChangeRequest extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool isFirstTime;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.isFirstTime,
  });

  @override
  List<Object?> get props => [
        currentPassword,
        newPassword,
        confirmPassword,
        isFirstTime,
      ];
}