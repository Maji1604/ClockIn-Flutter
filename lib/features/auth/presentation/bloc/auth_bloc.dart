import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/login_request.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.changePasswordUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthPasswordChangeRequested>(_onAuthPasswordChangeRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthGetCurrentUserRequested>(_onAuthGetCurrentUserRequested);
  }

  /// Handle authentication check
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Checking authentication status', 'AUTH_BLOC');
      emit(const AuthLoading());

      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final userResult = await getCurrentUserUseCase();

        userResult.fold(
          (failure) {
            AppLogger.error(
              'Failed to get current user: ${failure.message}',
              'AUTH_BLOC',
            );
            emit(const AuthUnauthenticated());
          },
          (user) {
            AppLogger.info('User is authenticated: ${user.email}', 'AUTH_BLOC');
            emit(
              AuthAuthenticated(
                user: user,
                requiresPasswordChange: user.mustChangePassword,
              ),
            );
          },
        );
      } else {
        AppLogger.info('User is not authenticated', 'AUTH_BLOC');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      AppLogger.error('Error checking authentication: $e', 'AUTH_BLOC', e);
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Processing login request', 'AUTH_BLOC');
      emit(const AuthLoading());

      final result = await loginUseCase(event.request);

      result.fold(
        (failure) async {
          AppLogger.error('Login failed: ${failure.message}', 'AUTH_BLOC');

          // If the backend returned 403 and the request included a company slug,
          // attempt a fallback login without the company identifier (global
          // email/password lookup). This helps when the user supplied a wrong
          // company identifier but can still be resolved by email alone.
          if (failure is ServerFailure && failure.statusCode == 403) {
            AppLogger.info('Received 403 during login', 'AUTH_BLOC');

            if (event.request.companySlug != null &&
                event.request.companySlug!.isNotEmpty) {
              AppLogger.info(
                'Retrying login without company identifier',
                'AUTH_BLOC',
              );
              final retryRequest = LoginRequest(
                email: event.request.email,
                password: event.request.password,
                companySlug: null,
              );

              final retryResult = await loginUseCase(retryRequest);

              retryResult.fold(
                (retryFailure) {
                  AppLogger.error(
                    'Retry without slug failed: ${retryFailure.message}',
                    'AUTH_BLOC',
                  );
                  if (retryFailure is ServerFailure &&
                      retryFailure.statusCode == 403) {
                    emit(
                      const AuthError(
                        message: 'Login rejected: No company membership found.',
                      ),
                    );
                  } else {
                    emit(AuthError(message: retryFailure.message));
                  }
                },
                (retryResponse) {
                  AppLogger.info('Retry without slug succeeded', 'AUTH_BLOC');
                  if ((retryResponse.memberships ?? []).isNotEmpty &&
                      (retryResponse.token == null ||
                          retryResponse.token!.isEmpty)) {
                    emit(
                      AuthRequiresCompanySelection(
                        memberships: retryResponse.memberships!,
                      ),
                    );
                    return;
                  }

                  emit(
                    AuthAuthenticated(
                      user: retryResponse.user,
                      requiresPasswordChange:
                          retryResponse.requiresPasswordChange,
                    ),
                  );
                },
              );

              return;
            }

            emit(
              const AuthError(
                message: 'Login rejected: No company membership found.',
              ),
            );
            return;
          }

          // Other failures
          emit(AuthError(message: failure.message));
        },
        (response) {
          AppLogger.info('Login successful', 'AUTH_BLOC');

          // If backend returned memberships (and no token), ask client to select one
          if ((response.memberships ?? []).isNotEmpty &&
              (response.token == null || response.token!.isEmpty)) {
            AppLogger.info(
              'Multiple memberships returned, requiring selection',
              'AUTH_BLOC',
            );
            emit(
              AuthRequiresCompanySelection(memberships: response.memberships!),
            );
            return;
          }

          // Otherwise proceed as authenticated
          emit(
            AuthAuthenticated(
              user: response.user,
              requiresPasswordChange: response.requiresPasswordChange,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error during login: $e', 'AUTH_BLOC', e);
      emit(const AuthError(message: 'Unexpected error during login'));
    }
  }

  /// Handle password change request
  Future<void> _onAuthPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Processing password change request', 'AUTH_BLOC');
      emit(const AuthLoading());

      final result = await changePasswordUseCase(event.userId, event.request);

      result.fold(
        (failure) {
          AppLogger.error(
            'Password change failed: ${failure.message}',
            'AUTH_BLOC',
          );
          emit(AuthError(message: failure.message));
        },
        (_) {
          AppLogger.info('Password change successful', 'AUTH_BLOC');
          emit(const AuthPasswordChangeSuccess());

          // After successful password change, get updated user
          add(const AuthGetCurrentUserRequested());
        },
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error during password change: $e',
        'AUTH_BLOC',
        e,
      );
      emit(const AuthError(message: 'Unexpected error during password change'));
    }
  }

  /// Handle logout request
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Processing logout request', 'AUTH_BLOC');
      emit(const AuthLoading());

      final result = await logoutUseCase();

      result.fold(
        (failure) {
          AppLogger.error('Logout failed: ${failure.message}', 'AUTH_BLOC');
          // Even if logout fails, clear local state
          emit(const AuthUnauthenticated());
        },
        (_) {
          AppLogger.info('Logout successful', 'AUTH_BLOC');
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error during logout: $e', 'AUTH_BLOC', e);
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle get current user request
  Future<void> _onAuthGetCurrentUserRequested(
    AuthGetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.debug('Getting current user', 'AUTH_BLOC');

      final result = await getCurrentUserUseCase();

      result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get current user: ${failure.message}',
            'AUTH_BLOC',
          );
          emit(AuthError(message: failure.message));
        },
        (user) {
          AppLogger.debug('Current user retrieved: ${user.email}', 'AUTH_BLOC');
          emit(
            AuthAuthenticated(
              user: user,
              requiresPasswordChange: user.mustChangePassword,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error getting current user: $e',
        'AUTH_BLOC',
        e,
      );
      emit(const AuthError(message: 'Unexpected error getting current user'));
    }
  }
}
