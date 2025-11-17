import '../../data/datasources/employee_remote_data_source.dart';
import '../../data/models/employee_model.dart';

abstract class EmployeeRepository {
  Future<List<EmployeeModel>> getEmployees(String token);
  Future<EmployeeModel> addEmployee({
    required String token,
    required String name,
    required String email,
    required String password,
  });
  Future<void> deleteEmployee(String token, String empId);
}

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EmployeeModel>> getEmployees(String token) async {
    try {
      return await remoteDataSource.getEmployees(token);
    } catch (e) {
      throw Exception('Failed to fetch employees: ${e.toString()}');
    }
  }

  @override
  Future<EmployeeModel> addEmployee({
    required String token,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.addEmployee(
        token: token,
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to add employee: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEmployee(String token, String empId) async {
    try {
      await remoteDataSource.deleteEmployee(token, empId);
    } catch (e) {
      throw Exception('Failed to delete employee: ${e.toString()}');
    }
  }
}
