import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/company_registration_request.dart';
import '../entities/company_registration_response.dart';
import '../repositories/company_repository.dart';

/// Use case for registering a new company
class RegisterCompanyUseCase {
  final CompanyRepository repository;

  const RegisterCompanyUseCase(this.repository);

  /// Execute company registration
  Future<Either<Failure, CompanyRegistrationResponse>> call(
    CompanyRegistrationRequest request,
  ) async {
    // Validate input
    final validationResult = _validateRequest(request);
    if (validationResult != null) {
      return Left(ValidationFailure(message: validationResult));
    }

    // Execute registration
    return await repository.registerCompany(request);
  }

  /// Validate registration request
  String? _validateRequest(CompanyRegistrationRequest request) {
    if (request.companyName.trim().isEmpty) {
      return 'Company name is required';
    }

    if (request.companyName.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }

    if (request.adminFirstName.trim().isEmpty) {
      return 'Admin first name is required';
    }

    if (request.adminLastName.trim().isEmpty) {
      return 'Admin last name is required';
    }

    if (request.adminEmail.trim().isEmpty) {
      return 'Admin email is required';
    }

    if (!_isValidEmail(request.adminEmail)) {
      return 'Please enter a valid email address';
    }

    if (request.adminPassword.isEmpty) {
      return 'Admin password is required';
    }

    if (request.adminPassword.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (request.timezone.trim().isEmpty) {
      return 'Timezone is required';
    }

    return null;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}