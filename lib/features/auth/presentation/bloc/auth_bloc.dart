import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import '../../../../core/utils/app_logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    AppLogger.info('=== AUTH BLOC: Constructor ===');
    AppLogger.debug('AUTH BLOC: Registering event handlers...');
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    AppLogger.debug('AUTH BLOC: Event handlers registered');
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('=== AUTH BLOC: _onLoginRequested ===');
    AppLogger.debug('AUTH BLOC: Username: ${event.username}');
    AppLogger.debug('AUTH BLOC: Emitting AuthLoading...');
    emit(AuthLoading());
    try {
      AppLogger.debug('AUTH BLOC: Calling authRepository.login...');
      final user = await authRepository.login(event.username, event.password);
      AppLogger.debug('AUTH BLOC: Login successful, user: ${user.name}');
      AppLogger.debug('AUTH BLOC: Emitting AuthAuthenticated...');
      emit(AuthAuthenticated(user));
      AppLogger.debug('AUTH BLOC: AuthAuthenticated emitted');
    } catch (e, stackTrace) {
      AppLogger.info('=== AUTH BLOC LOGIN ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      AppLogger.debug('AUTH BLOC: Emitting AuthError...');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('=== AUTH BLOC: _onCheckAuthStatus ===');
    try {
      AppLogger.debug('AUTH BLOC: Checking for current user...');
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        AppLogger.debug(
          'AUTH BLOC: User found: ${user.name}, emitting AuthAuthenticated',
        );
        emit(AuthAuthenticated(user));
      } else {
        AppLogger.debug(
          'AUTH BLOC: No user found, emitting AuthUnauthenticated',
        );
        emit(AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      AppLogger.info('=== AUTH BLOC CHECK STATUS ERROR ===');
      AppLogger.debug('Error: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      emit(AuthUnauthenticated());
    }
  }
}
