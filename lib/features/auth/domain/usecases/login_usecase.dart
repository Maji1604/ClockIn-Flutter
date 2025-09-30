import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/login_request.dart';
import '../entities/login_response.dart';
import '../repositories/auth_repository.dart';

/// Login use case
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  /// Execute login
  Future<Either<Failure, LoginResponse>> call(LoginRequest request) async {
    try {
      AppLogger.info('Executing login for: ${request.email}', 'LOGIN_USECASE');

      final result = await repository.login(request);

      return result.fold(
        (failure) {
          AppLogger.error('Login failed: ${failure.message}', 'LOGIN_USECASE');
          return Left(failure);
        },
        (response) async {
          AppLogger.info('Login successful', 'LOGIN_USECASE');

          // If the backend returned a token, store it. Otherwise, the API
          // likely returned a memberships list requiring the client to choose.
          if (response.token != null && response.token!.isNotEmpty) {
            await repository.storeToken(response.token!);
          }

          // Store user regardless
          await repository.storeUser(response.user);

          return Right(response);
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error during login: $e', 'LOGIN_USECASE');
      return Left(ServerFailure(message: 'Unexpected error during login: $e'));
    }
  }
}
