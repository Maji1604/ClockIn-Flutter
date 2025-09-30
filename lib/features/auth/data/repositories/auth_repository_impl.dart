import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/login_response.dart';
import '../../domain/entities/password_change_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/password_change_request_model.dart';
import '../models/user_model.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LoginResponse>> login(LoginRequest request) async {
    try {
      AppLogger.info('Starting login process', 'AUTH_REPO');

      final requestModel = LoginRequestModel.fromEntity(request);
      final response = await remoteDataSource.login(requestModel);

      AppLogger.info('Login completed successfully', 'AUTH_REPO');
      return Right(response.toEntity());
    } on ServerException catch (e) {
      // Include server response (if any) in logs to aid debugging (403 payloads, errors)
      AppLogger.error(
        'Server error during login: ${e.message} (status: ${e.statusCode})',
        'AUTH_REPO',
      );
      // Surface message with status code for callers. Remote datasource should
      // include response body in the exception.message when available.
      final composedMessage =
          '${e.message}${e.statusCode != null ? ' (status: ${e.statusCode})' : ''}';
      return Left(
        ServerFailure(message: composedMessage, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      AppLogger.error('Network error during login', 'AUTH_REPO');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error during login: $e', 'AUTH_REPO', e);
      return Left(ServerFailure(message: 'Unexpected error during login'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String userId,
    PasswordChangeRequest request,
  ) async {
    try {
      AppLogger.info('Starting password change process', 'AUTH_REPO');

      final requestModel = PasswordChangeRequestModel.fromEntity(request);
      await remoteDataSource.changePassword(userId, requestModel);

      AppLogger.info('Password change completed successfully', 'AUTH_REPO');
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Server error during password change', 'AUTH_REPO');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error during password change', 'AUTH_REPO');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error(
        'Unexpected error during password change: $e',
        'AUTH_REPO',
        e,
      );
      return Left(
        ServerFailure(message: 'Unexpected error during password change'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      AppLogger.debug('Getting current user', 'AUTH_REPO');

      // Try to get from local storage first
      final localUser = await localDataSource.getStoredUser();
      if (localUser != null) {
        AppLogger.debug('User found in local storage', 'AUTH_REPO');
        return Right(localUser.toEntity());
      }

      // If not in local storage, get from remote
      final remoteUser = await remoteDataSource.getCurrentUser();

      // Store in local storage for future use
      await localDataSource.storeUser(remoteUser);

      AppLogger.debug(
        'User retrieved from remote and stored locally',
        'AUTH_REPO',
      );
      return Right(remoteUser.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('Server error getting current user', 'AUTH_REPO');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error getting current user', 'AUTH_REPO');
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      AppLogger.error('Cache error getting current user', 'AUTH_REPO');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error(
        'Unexpected error getting current user: $e',
        'AUTH_REPO',
        e,
      );
      return Left(
        ServerFailure(message: 'Unexpected error getting current user'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      AppLogger.info('Starting logout process', 'AUTH_REPO');

      // Try to logout from remote (best effort)
      try {
        await remoteDataSource.logout();
      } catch (e) {
        AppLogger.warning(
          'Remote logout failed, continuing with local cleanup: $e',
          'AUTH_REPO',
        );
      }

      // Always clear local data
      await localDataSource.clearStoredData();

      AppLogger.info('Logout completed successfully', 'AUTH_REPO');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Cache error during logout', 'AUTH_REPO');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error during logout: $e', 'AUTH_REPO', e);
      return Left(ServerFailure(message: 'Unexpected error during logout'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await localDataSource.isAuthenticated();
    } catch (e) {
      AppLogger.error(
        'Error checking authentication status: $e',
        'AUTH_REPO',
        e,
      );
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await localDataSource.getToken();
    } catch (e) {
      AppLogger.error('Error getting token: $e', 'AUTH_REPO', e);
      return null;
    }
  }

  @override
  Future<void> storeToken(String token) async {
    try {
      await localDataSource.storeToken(token);
    } catch (e) {
      AppLogger.error('Error storing token: $e', 'AUTH_REPO', e);
      throw CacheException(message: 'Failed to store token');
    }
  }

  @override
  Future<void> clearStoredData() async {
    try {
      await localDataSource.clearStoredData();
    } catch (e) {
      AppLogger.error('Error clearing stored data: $e', 'AUTH_REPO', e);
      throw CacheException(message: 'Failed to clear stored data');
    }
  }

  @override
  Future<void> storeUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await localDataSource.storeUser(userModel);
    } catch (e) {
      AppLogger.error('Error storing user: $e', 'AUTH_REPO', e);
      throw CacheException(message: 'Failed to store user');
    }
  }

  @override
  Future<User?> getStoredUser() async {
    try {
      final userModel = await localDataSource.getStoredUser();
      return userModel?.toEntity();
    } catch (e) {
      AppLogger.error('Error getting stored user: $e', 'AUTH_REPO', e);
      return null;
    }
  }
}
