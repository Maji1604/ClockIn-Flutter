import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leave_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

abstract class LeaveRemoteDataSource {
  Future<LeaveModel> submitLeave({
    required String token,
    required String empId,
    required String leaveType,
    required String leavePeriod,
    required String startDate,
    String? endDate,
    required String reason,
  });

  Future<List<LeaveModel>> getEmployeeLeaves(String token, String empId);
  Future<List<LeaveModel>> getPendingLeaves(String token);
  Future<List<LeaveModel>> getAllLeaves(
    String token, {
    String? status,
    String? empId,
  });
  Future<LeaveModel> approveLeave(
    String token,
    String leaveId,
    String adminId,
    String? comments,
  );
  Future<LeaveModel> rejectLeave(
    String token,
    String leaveId,
    String adminId,
    String comments,
  );
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final http.Client client;
  
  String get baseUrl => ApiConfig.baseUrl;

  LeaveRemoteDataSourceImpl({required this.client});

  @override
  Future<LeaveModel> submitLeave({
    required String token,
    required String empId,
    required String leaveType,
    required String leavePeriod,
    required String startDate,
    String? endDate,
    required String reason,
  }) async {
    AppLogger.info('=== SUBMIT LEAVE REQUEST START ===');
    AppLogger.debug(
      'Employee ID: $empId, Leave Type: $leaveType, Period: $leavePeriod',
    );
    AppLogger.debug('Start Date: $startDate, End Date: $endDate');
    AppLogger.debug(
      'Reason: ${reason.substring(0, reason.length > 50 ? 50 : reason.length)}...',
    );

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/leaves/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'emp_id': empId,
          'leave_type': leaveType,
          'leave_period': leavePeriod,
          'start_date': startDate,
          'end_date': endDate,
          'reason': reason,
        }),
      );

      AppLogger.debug('Submit leave response status: ${response.statusCode}');
      AppLogger.debug('Submit leave response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Leave submitted successfully');
        AppLogger.info('=== SUBMIT LEAVE REQUEST END ===');
        return LeaveModel.fromJson(data['data']['leave']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to submit leave request');
      }
    } catch (e) {
      AppLogger.debug('Submit leave error: $e');
      AppLogger.info('=== SUBMIT LEAVE REQUEST END ===');
      rethrow;
    }
  }

  @override
  Future<List<LeaveModel>> getEmployeeLeaves(String token, String empId) async {
    AppLogger.info('=== FETCH EMPLOYEE LEAVES START ===');
    AppLogger.debug('Employee ID: $empId');

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/leaves/$empId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug('Fetch leaves response status: ${response.statusCode}');
      AppLogger.debug('Fetch leaves response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final leavesJson = data['data']['leaves'] as List;
        AppLogger.debug('Found ${leavesJson.length} leaves');
        AppLogger.info('=== FETCH EMPLOYEE LEAVES END ===');
        return leavesJson.map((json) => LeaveModel.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch leaves');
      }
    } catch (e) {
      AppLogger.debug('Fetch leaves error: $e');
      AppLogger.info('=== FETCH EMPLOYEE LEAVES END ===');
      rethrow;
    }
  }

  @override
  Future<List<LeaveModel>> getPendingLeaves(String token) async {
    AppLogger.info('=== FETCH PENDING LEAVES START ===');

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/leaves/pending/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug(
        'Fetch pending leaves response status: ${response.statusCode}',
      );
      AppLogger.debug('Fetch pending leaves response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final leavesJson = data['data']['leaves'] as List;
        AppLogger.debug('Found ${leavesJson.length} pending leaves');
        AppLogger.info('=== FETCH PENDING LEAVES END ===');
        return leavesJson.map((json) => LeaveModel.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch pending leaves');
      }
    } catch (e) {
      AppLogger.debug('Fetch pending leaves error: $e');
      AppLogger.info('=== FETCH PENDING LEAVES END ===');
      rethrow;
    }
  }

  @override
  Future<List<LeaveModel>> getAllLeaves(
    String token, {
    String? status,
    String? empId,
  }) async {
    AppLogger.info('=== FETCH ALL LEAVES START ===');
    AppLogger.debug('Filters - Status: $status, Employee ID: $empId');

    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (empId != null) queryParams['empId'] = empId;

      final uri = Uri.parse(
        '$baseUrl/api/leaves/all/list',
      ).replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug(
        'Fetch all leaves response status: ${response.statusCode}',
      );
      AppLogger.debug('Fetch all leaves response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final leavesJson = data['data']['leaves'] as List;
        AppLogger.debug('Found ${leavesJson.length} leaves');
        AppLogger.info('=== FETCH ALL LEAVES END ===');
        return leavesJson.map((json) => LeaveModel.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch all leaves');
      }
    } catch (e) {
      AppLogger.debug('Fetch all leaves error: $e');
      AppLogger.info('=== FETCH ALL LEAVES END ===');
      rethrow;
    }
  }

  @override
  Future<LeaveModel> approveLeave(
    String token,
    String leaveId,
    String adminId,
    String? comments,
  ) async {
    AppLogger.info('=== APPROVE LEAVE START ===');
    AppLogger.debug('Leave ID: $leaveId, Admin ID: $adminId');
    AppLogger.debug(
      'Comments: ${comments?.substring(0, comments.length > 50 ? 50 : comments.length) ?? 'None'}',
    );

    try {
      final response = await client.put(
        Uri.parse('$baseUrl/api/leaves/$leaveId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'admin_id': adminId, 'comments': comments}),
      );

      AppLogger.debug('Approve leave response status: ${response.statusCode}');
      AppLogger.debug('Approve leave response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Leave approved successfully');
        AppLogger.info('=== APPROVE LEAVE END ===');
        return LeaveModel.fromJson(data['data']['leave']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to approve leave');
      }
    } catch (e) {
      AppLogger.debug('Approve leave error: $e');
      AppLogger.info('=== APPROVE LEAVE END ===');
      rethrow;
    }
  }

  @override
  Future<LeaveModel> rejectLeave(
    String token,
    String leaveId,
    String adminId,
    String comments,
  ) async {
    AppLogger.info('=== REJECT LEAVE START ===');
    AppLogger.debug('Leave ID: $leaveId, Admin ID: $adminId');
    AppLogger.debug(
      'Comments: ${comments.substring(0, comments.length > 50 ? 50 : comments.length)}...',
    );

    try {
      final response = await client.put(
        Uri.parse('$baseUrl/api/leaves/$leaveId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'admin_id': adminId, 'comments': comments}),
      );

      AppLogger.debug('Reject leave response status: ${response.statusCode}');
      AppLogger.debug('Reject leave response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Leave rejected successfully');
        AppLogger.info('=== REJECT LEAVE END ===');
        return LeaveModel.fromJson(data['data']['leave']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reject leave');
      }
    } catch (e) {
      AppLogger.debug('Reject leave error: $e');
      AppLogger.info('=== REJECT LEAVE END ===');
      rethrow;
    }
  }
}
