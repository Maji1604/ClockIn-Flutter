import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../repositories/company_repository.dart';

/// Use case for validating company name availability
class ValidateCompanyNameUseCase {
  final CompanyRepository repository;

  const ValidateCompanyNameUseCase(this.repository);

  /// Execute company name validation
  Future<Either<Failure, bool>> call(String companyName) async {
    // Validate input
    if (companyName.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Company name is required'));
    }

    if (companyName.trim().length < 2) {
      return const Left(ValidationFailure(
        message: 'Company name must be at least 2 characters',
      ));
    }

    // Execute validation
    return await repository.validateCompanyName(companyName.trim());
  }
}