import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../../domain/entities/company_registration_request.dart';
import '../../domain/entities/company_registration_response.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';
import '../models/company_registration_request_model.dart';

/// Implementation of company repository
class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  const CompanyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CompanyRegistrationResponse>> registerCompany(
    CompanyRegistrationRequest request,
  ) async {
    try {
      AppLogger.info('Starting company registration process', 'COMPANY_REPO');
      
      final requestModel = CompanyRegistrationRequestModel.fromEntity(request);
      final responseModel = await remoteDataSource.registerCompany(requestModel);
      
      AppLogger.info('Company registration completed successfully', 'COMPANY_REPO');
      return Right(responseModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('Server error during company registration', 'COMPANY_REPO', e);
      return Left(ServerFailure(
        message: e.message,
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      AppLogger.error('Network error during company registration', 'COMPANY_REPO', e);
      return Left(NetworkFailure(
        message: e.message,
      ));
    } catch (e) {
      AppLogger.error('Unexpected error during company registration', 'COMPANY_REPO', e);
      return Left(ServerFailure(
        message: 'An unexpected error occurred during registration',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> validateCompanyName(String companyName) async {
    try {
      AppLogger.debug('Starting company name validation', 'COMPANY_REPO');
      
      final isAvailable = await remoteDataSource.validateCompanyName(companyName);
      
      AppLogger.debug('Company name validation completed', 'COMPANY_REPO');
      return Right(isAvailable);
    } on ServerException catch (e) {
      AppLogger.error('Server error during company name validation', 'COMPANY_REPO', e);
      return Left(ServerFailure(
        message: e.message,
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      AppLogger.error('Network error during company name validation', 'COMPANY_REPO', e);
      return Left(NetworkFailure(
        message: e.message,
      ));
    } catch (e) {
      AppLogger.error('Unexpected error during company name validation', 'COMPANY_REPO', e);
      return Left(ServerFailure(
        message: 'An unexpected error occurred during validation',
      ));
    }
  }
}