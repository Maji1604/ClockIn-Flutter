import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/user_model.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import 'package:http/http.dart' as http;
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

      var user = loginResponse.user;

      // Fetch profile data for employees to get designation and department
      if (user.isEmployee && user.employeeId != null) {
        try {
          AppLogger.debug('Fetching profile data for employee...');
          final profileDataSource = ProfileRemoteDataSourceImpl(
            client: http.Client(),
          );
          final profile = await profileDataSource.getProfile(
            user.employeeId!,
            loginResponse.token,
          );

          // Merge profile data into user model
          user = UserModel(
            id: user.id,
            name: user.name,
            role: user.role,
            employeeId: user.employeeId,
            requiresPasswordReset: user.requiresPasswordReset,
            email: user.email,
            mobileNumber: profile.mobileNumber ?? user.mobileNumber,
            address: profile.address ?? user.address,
            designation: profile.designation,
            department: profile.department,
            companyEmail: profile.companyEmail,
          );
          AppLogger.debug('Profile data merged successfully');
        } catch (e) {
          AppLogger.debug(
            'Failed to fetch profile data, continuing with basic user data',
          );
        }
      }

      await localDataSource.saveToken(loginResponse.token);
      await localDataSource.saveUser(user);
      AppLogger.info('Login completed successfully');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Login failed in repository', e, stackTrace);
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    AppLogger.info('=== AUTH REPOSITORY: logout ===');
    AppLogger.debug('AUTH REPOSITORY: Deleting token...');
    await localDataSource.deleteToken();
    AppLogger.debug('AUTH REPOSITORY: Deleting user...');
    await localDataSource.deleteUser();
    AppLogger.debug('AUTH REPOSITORY: Logout complete');
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Check if token is expired
      final isExpired = await localDataSource.isTokenExpired();
      if (isExpired) {
        AppLogger.debug('Token expired, clearing stored data');
        await logout();
        return null;
      }

      // Token is valid, return stored user
      final user = await localDataSource.getUser();
      if (user != null) {
        AppLogger.debug('Valid token found, user: ${user.name}');
      }
      return user;
    } catch (e) {
      AppLogger.error('Error getting current user', e, StackTrace.current);
      return null;
    }
  }
}
