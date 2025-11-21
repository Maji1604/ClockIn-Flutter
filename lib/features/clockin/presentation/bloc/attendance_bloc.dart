import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

import '../../../../core/utils/app_logger.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository attendanceRepository;

  AttendanceBloc({required this.attendanceRepository})
    : super(AttendanceInitial()) {
    on<LoadTodayAttendance>(_onLoadTodayAttendance);
    on<ClockIn>(_onClockIn);
    on<ClockOut>(_onClockOut);
    on<StartBreak>(_onStartBreak);
    on<EndBreak>(_onEndBreak);
    on<LoadActivities>(_onLoadActivities);
  }

  Future<void> _onLoadTodayAttendance(
    LoadTodayAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    AppLogger.info('=== BLOC LOAD TODAY ATTENDANCE START ===');
    AppLogger.debug(
      'BLoC Load attendance - empId: ${event.empId}, date: ${event.date}',
    );
    emit(AttendanceLoading());
    try {
      AppLogger.debug('Fetching today attendance...');
      final attendance = await attendanceRepository.getTodayAttendance(
        event.token,
        event.empId,
        date: event.date,
      );
      AppLogger.debug('Today attendance result: $attendance');

      AppLogger.debug('Fetching activities...');
      final activities = await attendanceRepository.getActivities(
        event.token,
        event.empId,
        date: event.date,
      );
      AppLogger.debug('Activities fetched: ${activities.length} items');

      emit(AttendanceLoaded(attendance: attendance, activities: activities));
      AppLogger.info('=== LOAD TODAY ATTENDANCE SUCCESS ===');
    } catch (e, stackTrace) {
      AppLogger.info('=== BLOC LOAD ATTENDANCE ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onClockIn(ClockIn event, Emitter<AttendanceState> emit) async {
    AppLogger.info('=== BLOC CLOCK-IN EVENT START ===');
    AppLogger.debug('BLoC Clock-in - empId: ${event.empId}');
    emit(AttendanceLoading());
    try {
      AppLogger.debug('Calling repository clockIn method...');
      final attendance = await attendanceRepository.clockIn(
        event.token,
        event.empId,
      );
      AppLogger.debug('Repository clockIn successful, attendance: $attendance');
      emit(
        AttendanceOperationSuccess(
          message: 'Clocked in successfully',
          attendance: attendance,
        ),
      );
      AppLogger.debug('Emitted AttendanceOperationSuccess, reloading data...');
      // Reload data
      add(
        LoadTodayAttendance(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    } catch (e) {
      AppLogger.info('=== BLOC CLOCK-IN ERROR: ${e.runtimeType} ===');

      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      // Remove nested "Exception: " prefixes
      while (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }

      emit(AttendanceError(errorMessage));

      // Reload attendance data to sync UI state with backend
      AppLogger.debug('Reloading attendance data after error...');
      add(
        LoadTodayAttendance(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onClockOut(
    ClockOut event,
    Emitter<AttendanceState> emit,
  ) async {
    AppLogger.info('=== BLOC CLOCK-OUT EVENT START ===');
    AppLogger.debug('BLoC Clock-out - empId: ${event.empId}');
    emit(AttendanceLoading());
    try {
      AppLogger.debug('Calling repository clockOut method...');
      final attendance = await attendanceRepository.clockOut(
        event.token,
        event.empId,
      );
      AppLogger.debug(
        'Repository clockOut successful, attendance: $attendance',
      );
      emit(
        AttendanceOperationSuccess(
          message: 'Clocked out successfully',
          attendance: attendance,
        ),
      );
      AppLogger.debug('Emitted AttendanceOperationSuccess, reloading data...');
      // Reload data
      add(
        LoadTodayAttendance(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    } catch (e) {
      AppLogger.info('=== BLOC CLOCK-OUT ERROR: ${e.runtimeType} ===');

      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      // Remove nested "Exception: " prefixes
      while (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }

      emit(AttendanceError(errorMessage));

      // Reload attendance data to sync UI state with backend
      AppLogger.debug('Reloading attendance data after error...');
      add(
        LoadTodayAttendance(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(), // Explicitly pass today's date
        ),
      );
    }
  }

  Future<void> _onStartBreak(
    StartBreak event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await attendanceRepository.startBreak(
        event.token,
        event.empId,
      );
      emit(
        AttendanceOperationSuccess(
          message: 'Break started',
          attendance: attendance,
        ),
      );
      // Refresh activities
      add(
        LoadActivities(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      while (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      emit(AttendanceError(errorMessage));
      add(
        LoadTodayAttendance(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onEndBreak(
    EndBreak event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await attendanceRepository.endBreak(
        event.token,
        event.empId,
      );
      emit(
        AttendanceOperationSuccess(
          message: 'Break ended',
          attendance: attendance,
        ),
      );
      // Refresh only activities to avoid racing an attendance reload
      add(
        LoadActivities(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      while (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      emit(AttendanceError(errorMessage));
      // Keep attendance as-is on error; still refresh activities for visibility
      add(
        LoadActivities(
          token: event.token,
          empId: event.empId,
          date: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      AppLogger.info('=== BLOC LOAD ACTIVITIES START ===');
      final activities = await attendanceRepository.getActivities(
        event.token,
        event.empId,
        date: event.date,
      );
      AppLogger.debug('Activities loaded: ${activities.length} items');

      // Get attendance from current state
      final currentAttendance = state is AttendanceLoaded
          ? (state as AttendanceLoaded).attendance
          : (state is AttendanceOperationSuccess
                ? (state as AttendanceOperationSuccess).attendance
                : null);

      if (currentAttendance != null) {
        AppLogger.debug(
          'Emitting AttendanceLoaded with updated activities (current state: ${state.runtimeType})',
        );
        emit(
          AttendanceLoaded(
            attendance: currentAttendance,
            activities: activities,
          ),
        );
        AppLogger.info('=== BLOC: New AttendanceLoaded state emitted ===');
      } else {
        AppLogger.warning(
          'Cannot emit AttendanceLoaded: no attendance in current state (${state.runtimeType})',
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      while (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      emit(AttendanceError(errorMessage));
    }
  }
}
