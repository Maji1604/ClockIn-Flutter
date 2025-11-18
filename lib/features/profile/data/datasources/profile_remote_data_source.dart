import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String empId, String token);
  Future<ProfileModel> updateProfile({
    required String empId,
    required String token,
    String? mobileNumber,
    String? address,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSourceImpl({required this.client});

  String get baseUrl => ApiConfig.baseUrl;

  @override
  Future<ProfileModel> getProfile(String empId, String token) async {
    final url = Uri.parse('$baseUrl/api/profile/$empId');

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return ProfileModel.fromJson(jsonResponse['data']['profile']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch profile');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Profile not found');
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to fetch profile');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String empId,
    required String token,
    String? mobileNumber,
    String? address,
  }) async {
    final url = Uri.parse('$baseUrl/api/profile/$empId');

    final body = <String, dynamic>{};
    if (mobileNumber != null) body['mobile_number'] = mobileNumber;
    if (address != null) body['address'] = address;

    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return ProfileModel.fromJson(jsonResponse['data']['profile']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to update profile');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Profile not found');
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to update profile');
    }
  }
}
