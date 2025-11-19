import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';
import '../models/activity_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

// Custom exception for "already clocked in" scenario
class AlreadyClockedInException implements Exception {
  final String message;
  AlreadyClockedInException(this.message);
  @override
  String toString() => message;
}

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel?> getTodayAttendance(
    String token,
    String empId, {
    DateTime? date,
  });
  Future<AttendanceModel> clockIn(String token, String empId);
  Future<AttendanceModel> clockOut(String token, String empId);
  Future<AttendanceModel> startBreak(String token, String empId);
  Future<AttendanceModel> endBreak(String token, String empId);
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
      AppLogger.debug('Making HTTP GET request...');
      final response = await client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              AppLogger.debug('Request timed out after 30 seconds');
              throw Exception(
                'Connection timeout - please check your internet connection',
              );
            },
          );

      AppLogger.debug(
        'Fetch attendance response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          AppLogger.debug('Response body is empty');
          throw Exception('Empty response from server');
        }

        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['data']?['attendance'] != null) {
            return AttendanceModel.fromJson(data['data']['attendance']);
          } else {
            AppLogger.debug('No attendance record found for today');
            return null;
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch attendance');
        }
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

      // Provide more specific error messages
      if (e.toString().contains('timeout') ||
          e.toString().contains('Connection timeout')) {
        throw Exception(
          'Connection timeout - please check your internet connection',
        );
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Network error - please check your internet connection',
        );
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response format from server');
      } else if (e.toString().contains('HandshakeException')) {
        throw Exception(
          'SSL/TLS error - please check your network security settings',
        );
      }

      rethrow;
    }
  }

  @override
  Future<AttendanceModel> clockIn(String token, String empId) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    AppLogger.info('=== FRONTEND CLOCK-IN START ===');
    AppLogger.debug('Clock-in request - empId: $empId, date: $today');
    AppLogger.debug('API URL: $baseUrl/api/attendance/clock-in');
    AppLogger.debug(
      'Request body: ${jsonEncode({'empId': empId, 'date': today})}',
    );

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/attendance/clock-in'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'empId': empId, 'date': today}),
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
      } else if (response.statusCode == 409) {
        // Handle "Already clocked in" case
        final errorData = jsonDecode(response.body);
        AppLogger.debug('Clock-in conflict (409): $errorData');
        final message = errorData['message'] ?? 'Already clocked in today';
        throw AlreadyClockedInException(message);
      } else {
        AppLogger.debug(
          'Clock-in failed - status code: ${response.statusCode}',
        );
        final errorData = jsonDecode(response.body);
        AppLogger.debug('Clock-in error data: $errorData');
        final message = errorData['message'] ?? 'Failed to clock in';
        throw Exception(message);
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
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    AppLogger.info('=== FRONTEND CLOCK-OUT START ===');
    AppLogger.debug('Clock-out request - empId: $empId, date: $today');
    AppLogger.debug('API URL: $baseUrl/api/attendance/clock-out');
    AppLogger.debug(
      'Request body: ${jsonEncode({'empId': empId, 'date': today})}',
    );

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/attendance/clock-out'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'empId': empId, 'date': today}),
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
  Future<AttendanceModel> startBreak(String token, String empId) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    AppLogger.info('=== START BREAK API CALL ===');
    AppLogger.debug('Start break - empId: $empId, date: $today');

    final response = await client.post(
      Uri.parse('$baseUrl/api/attendance/break-start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'empId': empId, 'date': today}),
    );

    AppLogger.debug('Start break response status: ${response.statusCode}');
    AppLogger.debug('Start break response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data']['attendance'] != null) {
        return AttendanceModel.fromJson(data['data']['attendance']);
      }
      // Fallback if attendance not in response (shouldn't happen with new backend)
      throw Exception('Break started but attendance data missing');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to start break');
    }
  }

  @override
  Future<AttendanceModel> endBreak(String token, String empId) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    AppLogger.info('=== END BREAK API CALL ===');
    AppLogger.debug('End break - empId: $empId, date: $today');

    final response = await client.post(
      Uri.parse('$baseUrl/api/attendance/break-end'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'empId': empId, 'date': today}),
    );

    AppLogger.debug('End break response status: ${response.statusCode}');
    AppLogger.debug('End break response body: ${response.body}');

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to end break');
    }

    // Parse and return updated attendance from response
    final responseData = jsonDecode(response.body);
    if (responseData['data'] != null &&
        responseData['data']['attendance'] != null) {
      return AttendanceModel.fromJson(responseData['data']['attendance']);
    }
    throw Exception('Invalid response format from end break');
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
