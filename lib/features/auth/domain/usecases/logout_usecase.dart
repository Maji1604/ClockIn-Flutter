import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../repositories/auth_repository.dart';

/// Logout use case
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  /// Execute logout
  Future<Either<Failure, void>> call() async {
    try {
      AppLogger.info('Executing logout', 'LOGOUT_USECASE');

      final result = await repository.logout();

      return result.fold(
        (failure) {
          AppLogger.error('Logout failed: ${failure.message}', 'LOGOUT_USECASE');
          return Left(failure);
        },
        (success) {
          AppLogger.info('Logout successful', 'LOGOUT_USECASE');
          return const Right(null);
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error during logout: $e', 'LOGOUT_USECASE');
      return Left(ServerFailure(message: 'Unexpected error during logout: $e'));
    }
  }
}