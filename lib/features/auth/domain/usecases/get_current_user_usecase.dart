import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Get current user use case
class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  /// Execute get current user
  Future<Either<Failure, User>> call() async {
    try {
      AppLogger.debug('Getting current user', 'USER_USECASE');

      final result = await repository.getCurrentUser();

      return result.fold(
        (failure) {
          AppLogger.error('Get current user failed: ${failure.message}', 'USER_USECASE');
          return Left(failure);
        },
        (user) {
          AppLogger.debug('Current user retrieved: ${user.email}', 'USER_USECASE');
          return Right(user);
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error getting current user: $e', 'USER_USECASE');
      return Left(ServerFailure(message: 'Unexpected error getting current user: $e'));
    }
  }
}