import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/password_change_request.dart';
import '../repositories/auth_repository.dart';

/// Change password use case
class ChangePasswordUseCase {
  final AuthRepository repository;

  const ChangePasswordUseCase(this.repository);

  /// Execute password change
  Future<Either<Failure, void>> call(
    String userId,
    PasswordChangeRequest request,
  ) async {
    try {
      AppLogger.info('Executing password change for user: $userId', 'PASSWORD_USECASE');

      // Validate passwords match
      if (request.newPassword != request.confirmPassword) {
        return const Left(ValidationFailure(message: 'Passwords do not match'));
      }

      // Validate password strength
      if (request.newPassword.length < 8) {
        return const Left(ValidationFailure(
          message: 'Password must be at least 8 characters long',
        ));
      }

      final result = await repository.changePassword(userId, request);

      return result.fold(
        (failure) {
          AppLogger.error('Password change failed: ${failure.message}', 'PASSWORD_USECASE');
          return Left(failure);
        },
        (success) {
          AppLogger.info('Password change successful', 'PASSWORD_USECASE');
          return const Right(null);
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error during password change: $e', 'PASSWORD_USECASE');
      return Left(ServerFailure(message: 'Unexpected error during password change: $e'));
    }
  }
}