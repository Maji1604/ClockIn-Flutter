import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Employee
import '../../features/employee/data/datasources/employee_remote_data_source.dart';
import '../../features/employee/domain/repositories/employee_repository.dart';
import '../../features/employee/presentation/bloc/employee_bloc.dart';

// Attendance
import '../../features/clockin/data/datasources/attendance_remote_data_source.dart';
import '../../features/clockin/domain/repositories/attendance_repository.dart';
import '../../features/clockin/presentation/bloc/attendance_bloc.dart';

// Leave
import '../../features/leave/data/datasources/leave_remote_data_source.dart';
import '../../features/leave/data/repositories/leave_repository_impl.dart';
import '../../features/leave/presentation/bloc/leave_bloc.dart';

// Holiday
import '../../features/holiday/data/datasources/holiday_remote_data_source.dart';
import '../../features/holiday/data/repositories/holiday_repository_impl.dart';
import '../../features/holiday/presentation/bloc/holiday_bloc.dart';

class ServiceLocator {
  static late http.Client _httpClient;
  static late FlutterSecureStorage _secureStorage;

  // Data Sources
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late EmployeeRemoteDataSource _employeeRemoteDataSource;
  static late AttendanceRemoteDataSource _attendanceRemoteDataSource;
  static late LeaveRemoteDataSource _leaveRemoteDataSource;
  static late HolidayRemoteDataSource _holidayRemoteDataSource;

  // Repositories
  static late AuthRepository _authRepository;
  static late EmployeeRepository _employeeRepository;
  static late AttendanceRepository _attendanceRepository;
  static late LeaveRepository _leaveRepository;
  static late HolidayRepository _holidayRepository;

  // BLoCs
  static late AuthBloc _authBloc;
  static late EmployeeBloc _employeeBloc;
  static late AttendanceBloc _attendanceBloc;
  static late LeaveBloc _leaveBloc;
  static late HolidayBloc _holidayBloc;

  static void setup() {
    // External dependencies
    _httpClient = http.Client();
    _secureStorage = const FlutterSecureStorage();

    // Data Sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(client: _httpClient);
    _authLocalDataSource = AuthLocalDataSourceImpl(
      secureStorage: _secureStorage,
    );
    _employeeRemoteDataSource = EmployeeRemoteDataSourceImpl(
      client: _httpClient,
    );
    _attendanceRemoteDataSource = AttendanceRemoteDataSourceImpl(
      client: _httpClient,
    );
    _leaveRemoteDataSource = LeaveRemoteDataSourceImpl(client: _httpClient);
    _holidayRemoteDataSource = HolidayRemoteDataSourceImpl(client: _httpClient);

    // Repositories
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _employeeRepository = EmployeeRepositoryImpl(
      remoteDataSource: _employeeRemoteDataSource,
    );
    _attendanceRepository = AttendanceRepositoryImpl(
      remoteDataSource: _attendanceRemoteDataSource,
    );
    _leaveRepository = LeaveRepository(
      remoteDataSource: _leaveRemoteDataSource,
    );
    _holidayRepository = HolidayRepository(
      remoteDataSource: _holidayRemoteDataSource,
    );

    // BLoCs
    _authBloc = AuthBloc(authRepository: _authRepository);
    _employeeBloc = EmployeeBloc(employeeRepository: _employeeRepository);
    _attendanceBloc = AttendanceBloc(
      attendanceRepository: _attendanceRepository,
    );
    _leaveBloc = LeaveBloc(repository: _leaveRepository);
    _holidayBloc = HolidayBloc(repository: _holidayRepository);
  }

  // Getters
  static AuthBloc get authBloc => _authBloc;
  static EmployeeBloc get employeeBloc => _employeeBloc;
  static AttendanceBloc get attendanceBloc => _attendanceBloc;
  static LeaveBloc get leaveBloc => _leaveBloc;
  static HolidayBloc get holidayBloc => _holidayBloc;
  static AuthRepository get authRepository => _authRepository;
}
