import 'package:get_it/get_it.dart';
import '../utils/logger.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  AppLogger.info('Initializing dependencies...', 'DI');
  
  // Core dependencies will be registered here
  // Example:
  // sl.registerLazySingleton<HttpClient>(() => HttpClient());
  
  // Data layer dependencies
  // sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  
  // Repository dependencies  
  // sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  
  // Use case dependencies
  // sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase());
  
  // BLoC dependencies
  // sl.registerFactory<AuthBloc>(() => AuthBloc());
  
  AppLogger.info('Dependencies initialized successfully', 'DI');
}