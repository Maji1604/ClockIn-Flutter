import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';
import '../models/activity_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel?> getTodayAttendance(
    String token,
    String empId, {
    DateTime? date,
  });
  Future<AttendanceModel> clockIn(String token, String empId);
  Future<AttendanceModel> clockOut(String token, String empId);
  Future<void> startBreak(String token, String empId);
  Future<void> endBreak(String token, String empId);
  Future<List<ActivityModel>> getActivities(
    String token,
    String empId, {
    DateTime? date,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final http.Client client;

  String get baseUrl => ApiConfig.baseUrl;

  AttendanceRemoteDataSourceImpl({required this.client});

  @override
  Future<AttendanceModel?> getTodayAttendance(
    String token,
    String empId, {
    DateTime? date,
  }) async {
    AppLogger.info('=== FETCH TODAY ATTENDANCE START ===');
    AppLogger.debug('Fetch attendance - empId: $empId, date: $date');

    final queryParams = <String, String>{};
    if (date != null) {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      queryParams['date'] = dateStr;
    }

    final uri = Uri.parse(
      '$baseUrl/api/attendance/today/$empId',
    ).replace(queryParameters: queryParams);
    AppLogger.debug('API URL: $uri');

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug(
        'Fetch attendance response status: ${response.statusCode}',
      );
      AppLogger.debug('Fetch attendance response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Fetch attendance decoded response: $data');

        if (data['success'] == true && data['data']?['attendance'] != null) {
          AppLogger.debug('Attendance found: ${data["data"]["attendance"]}');
          return AttendanceModel.fromJson(data['data']['attendance']);
        }
        AppLogger.debug('No attendance record found for today');
        return null;
      } else {
        AppLogger.debug(
          'Failed to fetch attendance - status: ${response.statusCode}',
        );
        throw Exception('Failed to fetch attendance');
      }
    } catch (e, stackTrace) {
      AppLogger.info('=== FETCH ATTENDANCE ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<AttendanceModel> clockIn(String token, String empId) async {
    AppLogger.info('=== FRONTEND CLOCK-IN START ===');
    AppLogger.debug('Clock-in request - empId: $empId');
    AppLogger.debug('API URL: $baseUrl/api/attendance/clock-in');
    AppLogger.debug('Request body: ${jsonEncode({'empId': empId})}');

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/attendance/clock-in'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'empId': empId}),
      );

      AppLogger.debug('Clock-in response status: ${response.statusCode}');
      AppLogger.debug('Clock-in response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Clock-in decoded response: $data');

        if (data['success'] == true) {
          AppLogger.info('=== CLOCK-IN SUCCESS ===');
          return AttendanceModel.fromJson(data['data']);
        } else {
          AppLogger.debug('Clock-in failed - server returned success=false');
          throw Exception(data['message'] ?? 'Failed to clock in');
        }
      } else {
        AppLogger.debug(
          'Clock-in failed - status code: ${response.statusCode}',
        );
        final errorData = jsonDecode(response.body);
        AppLogger.debug('Clock-in error data: $errorData');
        throw Exception(errorData['message'] ?? 'Failed to clock in');
      }
    } catch (e, stackTrace) {
      AppLogger.info('=== CLOCK-IN ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<AttendanceModel> clockOut(String token, String empId) async {
    AppLogger.info('=== FRONTEND CLOCK-OUT START ===');
    AppLogger.debug('Clock-out request - empId: $empId');
    AppLogger.debug('API URL: $baseUrl/api/attendance/clock-out');
    AppLogger.debug('Request body: ${jsonEncode({'empId': empId})}');

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/attendance/clock-out'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'empId': empId}),
      );

      AppLogger.debug('Clock-out response status: ${response.statusCode}');
      AppLogger.debug('Clock-out response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Clock-out decoded response: $data');

        if (data['success'] == true) {
          AppLogger.info('=== CLOCK-OUT SUCCESS ===');
          return AttendanceModel.fromJson(data['data']);
        } else {
          AppLogger.debug('Clock-out failed - server returned success=false');
          throw Exception(data['message'] ?? 'Failed to clock out');
        }
      } else {
        AppLogger.debug(
          'Clock-out failed - status code: ${response.statusCode}',
        );
        final errorData = jsonDecode(response.body);
        AppLogger.debug('Clock-out error data: $errorData');
        throw Exception(errorData['message'] ?? 'Failed to clock out');
      }
    } catch (e, stackTrace) {
      AppLogger.info('=== CLOCK-OUT ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> startBreak(String token, String empId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/attendance/break-start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'emp_id': empId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to start break');
    }
  }

  @override
  Future<void> endBreak(String token, String empId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/attendance/break-end'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'emp_id': empId}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to end break');
    }
  }

  @override
  Future<List<ActivityModel>> getActivities(
    String token,
    String empId, {
    DateTime? date,
  }) async {
    AppLogger.info('=== FETCH ACTIVITIES START ===');
    AppLogger.debug('Fetch activities - empId: $empId, date: $date');

    final queryParams = <String, String>{};
    if (date != null) {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      queryParams['date'] = dateStr;
    }

    final uri = Uri.parse(
      '$baseUrl/api/attendance/activities/$empId',
    ).replace(queryParameters: queryParams);
    AppLogger.debug('Activities API URL: $uri');

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug('Activities response status: ${response.statusCode}');
      AppLogger.debug('Activities response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Activities decoded response: $data');

        if (data['success'] == true) {
          // Backend returns: { success: true, data: { activities: [...], date: "..." } }
          final activitiesData = data['data'];
          if (activitiesData == null) {
            AppLogger.debug('No data field in response, returning empty list');
            return [];
          }

          final activitiesJson = activitiesData['activities'];
          if (activitiesJson == null) {
            AppLogger.debug(
              'No activities field in data, returning empty list',
            );
            return [];
          }

          final List<dynamic> activitiesList = activitiesJson as List<dynamic>;
          AppLogger.debug('Found ${activitiesList.length} activities');

          return activitiesList
              .map((json) => ActivityModel.fromJson(json))
              .toList();
        } else {
          AppLogger.debug(
            'Activities fetch failed - server returned success=false',
          );
          throw Exception(data['message'] ?? 'Failed to fetch activities');
        }
      } else {
        AppLogger.debug(
          'Activities fetch failed - status code: ${response.statusCode}',
        );
        throw Exception('Failed to fetch activities');
      }
    } catch (e, stackTrace) {
      AppLogger.info('=== FETCH ACTIVITIES ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
