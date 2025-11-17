import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AuthRepository {
  Future<UserModel> login(String username, String password);
  Future<void> logout();
  Future<String?> getToken();
  Future<UserModel?> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      AppLogger.info('=== AUTH REPOSITORY: login ===');
      final loginResponse = await remoteDataSource.login(username, password);
      AppLogger.debug('Remote login successful, saving token and user');
      await localDataSource.saveToken(loginResponse.token);
      await localDataSource.saveUser(loginResponse.user);
      AppLogger.info('Login completed successfully');
      return loginResponse.user;
    } catch (e, stackTrace) {
      AppLogger.error('Login failed in repository', e, stackTrace);
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
    await localDataSource.deleteUser();
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await localDataSource.getUser();
  }
}
