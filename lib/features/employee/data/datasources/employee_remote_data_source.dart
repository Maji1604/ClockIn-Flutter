import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';
import '../../../../core/config/api_config.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees(String token);
  Future<EmployeeModel> addEmployee({
    required String token,
    required String name,
    required String email,
    required String password,
  });
  Future<void> deleteEmployee(String token, String empId);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final http.Client client;
  
  String get baseUrl => ApiConfig.baseUrl;

  EmployeeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<EmployeeModel>> getEmployees(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/employees'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> employeesJson = data['employees'];
        return employeesJson
            .map((json) => EmployeeModel.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch employees');
      }
    } else {
      throw Exception('Failed to fetch employees');
    }
  }

  @override
  Future<EmployeeModel> addEmployee({
    required String token,
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/employees'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return EmployeeModel.fromJson(data['employee']);
      } else {
        throw Exception(data['message'] ?? 'Failed to add employee');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add employee');
    }
  }

  @override
  Future<void> deleteEmployee(String token, String empId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/employees/$empId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete employee');
    }
  }
}
