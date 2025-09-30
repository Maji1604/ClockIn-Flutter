import 'package:dio/dio.dart';
import '../../../../core/core.dart';
import '../models/company_registration_request_model.dart';
import '../models/company_registration_response_model.dart';

/// Remote data source for company operations
abstract class CompanyRemoteDataSource {
  /// Register a new company
  Future<CompanyRegistrationResponseModel> registerCompany(
    CompanyRegistrationRequestModel request,
  );

  /// Validate company name availability
  Future<bool> validateCompanyName(String companyName);
}

/// Implementation of company remote data source
class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final Dio httpClient;

  const CompanyRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<CompanyRegistrationResponseModel> registerCompany(
    CompanyRegistrationRequestModel request,
  ) async {
    try {
      AppLogger.info('Registering company: ${request.companyName}', 'COMPANY_API');
      
      final response = await httpClient.post(
        '/api/companies/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        AppLogger.info('Company registration successful', 'COMPANY_API');
        return CompanyRegistrationResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to register company',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Company registration failed: ${e.message}',
        'COMPANY_API',
        e,
      );
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Registration failed';
        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const NetworkException(
          message: 'Network error during company registration',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error during company registration: $e',
        'COMPANY_API',
        e,
      );
      throw ServerException(
        message: 'Unexpected error during registration: $e',
      );
    }
  }

  @override
  Future<bool> validateCompanyName(String companyName) async {
    try {
      AppLogger.debug('Validating company name: $companyName', 'COMPANY_API');
      
      final response = await httpClient.post(
        '/api/companies/validate-name',
        data: {'name': companyName},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final isAvailable = data['available'] as bool? ?? false;
        
        AppLogger.debug(
          'Company name validation result: $isAvailable',
          'COMPANY_API',
        );
        
        return isAvailable;
      } else {
        throw ServerException(
          message: 'Failed to validate company name',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Company name validation failed: ${e.message}',
        'COMPANY_API',
        e,
      );
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Validation failed';
        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const NetworkException(
          message: 'Network error during company name validation',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error during company name validation: $e',
        'COMPANY_API',
        e,
      );
      throw ServerException(
        message: 'Unexpected error during validation: $e',
      );
    }
  }
}