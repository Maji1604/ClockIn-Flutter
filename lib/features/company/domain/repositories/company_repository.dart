import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/company_registration_request.dart';
import '../entities/company_registration_response.dart';

/// Abstract repository for company operations
abstract class CompanyRepository {
  /// Register a new company with admin user
  Future<Either<Failure, CompanyRegistrationResponse>> registerCompany(
    CompanyRegistrationRequest request,
  );

  /// Validate company name availability
  Future<Either<Failure, bool>> validateCompanyName(String companyName);
}