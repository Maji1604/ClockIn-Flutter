import 'package:equatable/equatable.dart';
import '../../domain/entities/company_registration_response.dart';

/// States for company registration BLoC
abstract class CompanyRegistrationState extends Equatable {
  const CompanyRegistrationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CompanyRegistrationInitial extends CompanyRegistrationState {
  const CompanyRegistrationInitial();

  @override
  String toString() => 'CompanyRegistrationInitial()';
}

/// Loading state during registration
class CompanyRegistrationLoading extends CompanyRegistrationState {
  const CompanyRegistrationLoading();

  @override
  String toString() => 'CompanyRegistrationLoading()';
}

/// Success state after registration
class CompanyRegistrationSuccess extends CompanyRegistrationState {
  final CompanyRegistrationResponse response;

  const CompanyRegistrationSuccess({required this.response});

  @override
  List<Object?> get props => [response];

  @override
  String toString() => 'CompanyRegistrationSuccess(response: $response)';
}

/// Failure state during registration
class CompanyRegistrationFailure extends CompanyRegistrationState {
  final String message;
  final String? code;

  const CompanyRegistrationFailure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'CompanyRegistrationFailure(message: $message, code: $code)';
}

/// Loading state during company name validation
class CompanyNameValidating extends CompanyRegistrationState {
  const CompanyNameValidating();

  @override
  String toString() => 'CompanyNameValidating()';
}

/// Success state for company name validation
class CompanyNameValidationSuccess extends CompanyRegistrationState {
  final String companyName;
  final bool isAvailable;

  const CompanyNameValidationSuccess({
    required this.companyName,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [companyName, isAvailable];

  @override
  String toString() => 'CompanyNameValidationSuccess(companyName: $companyName, isAvailable: $isAvailable)';
}

/// Failure state for company name validation
class CompanyNameValidationFailure extends CompanyRegistrationState {
  final String message;

  const CompanyNameValidationFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CompanyNameValidationFailure(message: $message)';
}