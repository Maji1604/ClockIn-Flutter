import 'package:equatable/equatable.dart';
import '../../domain/entities/company_registration_request.dart';

/// Events for company registration BLoC
abstract class CompanyRegistrationEvent extends Equatable {
  const CompanyRegistrationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to register a new company
class RegisterCompanyRequested extends CompanyRegistrationEvent {
  final CompanyRegistrationRequest request;

  const RegisterCompanyRequested({required this.request});

  @override
  List<Object?> get props => [request];

  @override
  String toString() => 'RegisterCompanyRequested(request: $request)';
}

/// Event to validate company name
class ValidateCompanyNameRequested extends CompanyRegistrationEvent {
  final String companyName;

  const ValidateCompanyNameRequested({required this.companyName});

  @override
  List<Object?> get props => [companyName];

  @override
  String toString() => 'ValidateCompanyNameRequested(companyName: $companyName)';
}

/// Event to reset the registration state
class ResetCompanyRegistration extends CompanyRegistrationEvent {
  const ResetCompanyRegistration();

  @override
  String toString() => 'ResetCompanyRegistration()';
}