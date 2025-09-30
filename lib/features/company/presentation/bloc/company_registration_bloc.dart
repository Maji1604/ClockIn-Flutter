import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../domain/usecases/register_company_usecase.dart';
import '../../domain/usecases/validate_company_name_usecase.dart';
import 'company_registration_event.dart';
import 'company_registration_state.dart';

/// BLoC for company registration
class CompanyRegistrationBloc extends Bloc<CompanyRegistrationEvent, CompanyRegistrationState> {
  final RegisterCompanyUseCase registerCompanyUseCase;
  final ValidateCompanyNameUseCase validateCompanyNameUseCase;

  CompanyRegistrationBloc({
    required this.registerCompanyUseCase,
    required this.validateCompanyNameUseCase,
  }) : super(const CompanyRegistrationInitial()) {
    on<RegisterCompanyRequested>(_onRegisterCompanyRequested);
    on<ValidateCompanyNameRequested>(_onValidateCompanyNameRequested);
    on<ResetCompanyRegistration>(_onResetCompanyRegistration);
  }

  /// Handle company registration request
  Future<void> _onRegisterCompanyRequested(
    RegisterCompanyRequested event,
    Emitter<CompanyRegistrationState> emit,
  ) async {
    AppLogger.info('Processing company registration request', 'COMPANY_BLOC');
    
    emit(const CompanyRegistrationLoading());

    final result = await registerCompanyUseCase(event.request);

    result.fold(
      (failure) {
        AppLogger.error('Company registration failed: ${failure.message}', 'COMPANY_BLOC');
        emit(CompanyRegistrationFailure(
          message: failure.message,
          code: failure.code,
        ));
      },
      (response) {
        AppLogger.info('Company registration successful', 'COMPANY_BLOC');
        emit(CompanyRegistrationSuccess(response: response));
      },
    );
  }

  /// Handle company name validation request
  Future<void> _onValidateCompanyNameRequested(
    ValidateCompanyNameRequested event,
    Emitter<CompanyRegistrationState> emit,
  ) async {
    AppLogger.debug('Processing company name validation', 'COMPANY_BLOC');
    
    emit(const CompanyNameValidating());

    final result = await validateCompanyNameUseCase(event.companyName);

    result.fold(
      (failure) {
        AppLogger.error('Company name validation failed: ${failure.message}', 'COMPANY_BLOC');
        emit(CompanyNameValidationFailure(message: failure.message));
      },
      (isAvailable) {
        AppLogger.debug('Company name validation completed: $isAvailable', 'COMPANY_BLOC');
        emit(CompanyNameValidationSuccess(
          companyName: event.companyName,
          isAvailable: isAvailable,
        ));
      },
    );
  }

  /// Handle reset registration state
  void _onResetCompanyRegistration(
    ResetCompanyRegistration event,
    Emitter<CompanyRegistrationState> emit,
  ) {
    AppLogger.debug('Resetting company registration state', 'COMPANY_BLOC');
    emit(const CompanyRegistrationInitial());
  }
}