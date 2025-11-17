import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holiday_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/utils/app_logger.dart';

abstract class HolidayRemoteDataSource {
  Future<List<HolidayModel>> getHolidays(String token, {String? year});
  Future<HolidayModel> getHolidayById(String token, String id);
  Future<HolidayModel> createHoliday({
    required String token,
    required String title,
    required String date,
    String? description,
    bool isRecurring = false,
  });
  Future<HolidayModel> updateHoliday({
    required String token,
    required String id,
    String? title,
    String? date,
    String? description,
    bool? isRecurring,
  });
  Future<void> deleteHoliday(String token, String id);
}

class HolidayRemoteDataSourceImpl implements HolidayRemoteDataSource {
  final http.Client client;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  HolidayRemoteDataSourceImpl({required this.client});

  @override
  Future<List<HolidayModel>> getHolidays(String token, {String? year}) async {
    AppLogger.info('=== FETCHING HOLIDAYS ===');
    if (year != null) {
      AppLogger.debug('Year filter: $year');
    }

    try {
      final uri = year != null
          ? Uri.parse('$baseUrl/api/holidays?year=$year')
          : Uri.parse('$baseUrl/api/holidays');

      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      AppLogger.debug('Response status: ${response.statusCode}');
      AppLogger.debug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final holidays = (data['data']['holidays'] as List)
            .map((holiday) => HolidayModel.fromJson(holiday))
            .toList();

        AppLogger.info(
          'Holidays fetched successfully: ${holidays.length} records',
        );
        return holidays;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch holidays');
      }
    } catch (e) {
      AppLogger.error('Error fetching holidays: $e');
      rethrow;
    }
  }

  @override
  Future<HolidayModel> getHolidayById(String token, String id) async {
    AppLogger.info('=== FETCHING HOLIDAY BY ID ===');
    AppLogger.debug('Holiday ID: $id');

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/holidays/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      AppLogger.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final holiday = HolidayModel.fromJson(data['data']['holiday']);
        AppLogger.info('Holiday fetched successfully');
        return holiday;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch holiday');
      }
    } catch (e) {
      AppLogger.error('Error fetching holiday: $e');
      rethrow;
    }
  }

  @override
  Future<HolidayModel> createHoliday({
    required String token,
    required String title,
    required String date,
    String? description,
    bool isRecurring = false,
  }) async {
    AppLogger.info('=== CREATING HOLIDAY ===');
    AppLogger.debug('Title: $title, Date: $date');

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/holidays'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'date': date,
          'description': description,
          'isRecurring': isRecurring,
        }),
      );

      AppLogger.debug('Response status: ${response.statusCode}');
      AppLogger.debug('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final holiday = HolidayModel.fromJson(data['data']['holiday']);
        AppLogger.info('Holiday created successfully');
        return holiday;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create holiday');
      }
    } catch (e) {
      AppLogger.error('Error creating holiday: $e');
      rethrow;
    }
  }

  @override
  Future<HolidayModel> updateHoliday({
    required String token,
    required String id,
    String? title,
    String? date,
    String? description,
    bool? isRecurring,
  }) async {
    AppLogger.info('=== UPDATING HOLIDAY ===');
    AppLogger.debug('Holiday ID: $id');

    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (date != null) body['date'] = date;
      if (description != null) body['description'] = description;
      if (isRecurring != null) body['isRecurring'] = isRecurring;

      final response = await client.put(
        Uri.parse('$baseUrl/api/holidays/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      AppLogger.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final holiday = HolidayModel.fromJson(data['data']['holiday']);
        AppLogger.info('Holiday updated successfully');
        return holiday;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update holiday');
      }
    } catch (e) {
      AppLogger.error('Error updating holiday: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHoliday(String token, String id) async {
    AppLogger.info('=== DELETING HOLIDAY ===');
    AppLogger.debug('Holiday ID: $id');

    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/api/holidays/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      AppLogger.debug('Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete holiday');
      }

      AppLogger.info('Holiday deleted successfully');
    } catch (e) {
      AppLogger.error('Error deleting holiday: $e');
      rethrow;
    }
  }
}
