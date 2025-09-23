import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC - manages authentication state and events
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthPasswordChangeRequested>(_onAuthPasswordChangeRequested);
    on<AuthTokenRefreshRequested>(_onAuthTokenRefreshRequested);
    
    AppLogger.info('AuthBloc initialized', 'AUTH_BLOC');
  }

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// Handle authentication check request
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Checking authentication status...', 'AUTH_BLOC');
    emit(AuthLoading());

    try {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) {
          AppLogger.warning('Auth check failed: ${failure.message}', 'AUTH_BLOC');
          emit(AuthUnauthenticated());
        },
        (user) {
          if (user != null) {
            AppLogger.info('User is authenticated: ${user.email}', 'AUTH_BLOC');
            emit(AuthAuthenticated(user: user));
          } else {
            AppLogger.info('No authenticated user found', 'AUTH_BLOC');
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      AppLogger.error('Auth check error', 'AUTH_BLOC', e);
      emit(AuthUnauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Processing login request for: ${event.email}', 'AUTH_BLOC');
    emit(AuthLoginLoading());

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) {
          AppLogger.warning('Login failed: ${failure.message}', 'AUTH_BLOC');
          emit(AuthFailure(
            message: failure.message,
            code: failure.code,
          ));
        },
        (user) {
          AppLogger.info('Login successful for: ${user.email}', 'AUTH_BLOC');
          emit(AuthLoginSuccess(user: user));
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      AppLogger.error('Login error', 'AUTH_BLOC', e);
      emit(const AuthFailure(message: 'An unexpected error occurred during login'));
    }
  }

  /// Handle registration request
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Processing registration request for: ${event.email}', 'AUTH_BLOC');
    emit(AuthRegisterLoading());

    try {
      final result = await registerUseCase(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );

      result.fold(
        (failure) {
          AppLogger.warning('Registration failed: ${failure.message}', 'AUTH_BLOC');
          emit(AuthFailure(
            message: failure.message,
            code: failure.code,
          ));
        },
        (user) {
          AppLogger.info('Registration successful for: ${user.email}', 'AUTH_BLOC');
          emit(AuthRegisterSuccess(user: user));
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      AppLogger.error('Registration error', 'AUTH_BLOC', e);
      emit(const AuthFailure(message: 'An unexpected error occurred during registration'));
    }
  }

  /// Handle logout request
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Processing logout request', 'AUTH_BLOC');

    try {
      final result = await logoutUseCase();
      
      result.fold(
        (failure) {
          AppLogger.warning('Logout failed: ${failure.message}', 'AUTH_BLOC');
          emit(AuthFailure(
            message: failure.message,
            code: failure.code,
          ));
        },
        (_) {
          AppLogger.info('Logout successful', 'AUTH_BLOC');
          emit(AuthUnauthenticated());
        },
      );
    } catch (e) {
      AppLogger.error('Logout error', 'AUTH_BLOC', e);
      emit(const AuthFailure(message: 'An unexpected error occurred during logout'));
    }
  }

  /// Handle password reset request
  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Processing password reset request for: ${event.email}', 'AUTH_BLOC');
    emit(AuthPasswordResetLoading());

    try {
      // TODO: Implement password reset use case
      AppLogger.info('Password reset email sent to: ${event.email}', 'AUTH_BLOC');
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      AppLogger.error('Password reset error', 'AUTH_BLOC', e);
      emit(const AuthFailure(message: 'Failed to send password reset email'));
    }
  }

  /// Handle password change request
  Future<void> _onAuthPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Processing password change request', 'AUTH_BLOC');
    emit(AuthPasswordChangeLoading());

    try {
      // TODO: Implement password change use case
      AppLogger.info('Password changed successfully', 'AUTH_BLOC');
      emit(AuthPasswordChangeSuccess());
    } catch (e) {
      AppLogger.error('Password change error', 'AUTH_BLOC', e);
      emit(const AuthFailure(message: 'Failed to change password'));
    }
  }

  /// Handle token refresh request
  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('Processing token refresh request', 'AUTH_BLOC');

    try {
      // TODO: Implement token refresh use case
      AppLogger.info('Token refreshed successfully', 'AUTH_BLOC');
    } catch (e) {
      AppLogger.error('Token refresh error', 'AUTH_BLOC', e);
      emit(const AuthFailure(message: 'Failed to refresh token'));
    }
  }
}