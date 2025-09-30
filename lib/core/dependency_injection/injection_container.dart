import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/http_client.dart';
import '../utils/logger.dart';
import '../../features/company/data/datasources/company_remote_datasource.dart';
import '../../features/company/data/repositories/company_repository_impl.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/domain/usecases/register_company_usecase.dart';
import '../../features/company/domain/usecases/validate_company_name_usecase.dart';
import '../../features/company/presentation/bloc/company_registration_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  AppLogger.info('Initializing dependencies...', 'DI');
  
  // Core dependencies
  await _initCoreDependencies();
  
  // Feature dependencies
  _initCompanyDependencies();
  _initAuthDependencies();
  
  AppLogger.info('Dependencies initialized successfully', 'DI');
}

/// Initialize core dependencies
Future<void> _initCoreDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // HTTP Client
  sl.registerLazySingleton(() => HttpClient.instance);
}

/// Initialize company feature dependencies
void _initCompanyDependencies() {
  // Data sources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(httpClient: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => RegisterCompanyUseCase(sl()));
  sl.registerLazySingleton(() => ValidateCompanyNameUseCase(sl()));
  
  // BLoC
  sl.registerFactory(
    () => CompanyRegistrationBloc(
      registerCompanyUseCase: sl(),
      validateCompanyNameUseCase: sl(),
    ),
  );
}

/// Initialize authentication feature dependencies
void _initAuthDependencies() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpClient: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  
  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      changePasswordUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );
}