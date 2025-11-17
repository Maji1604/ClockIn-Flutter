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
    AppLogger.debug('BLoC Load attendance - empId: ${event.empId}, date: ${event.date}');
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
      add(LoadTodayAttendance(token: event.token, empId: event.empId));
    } catch (e, stackTrace) {
      AppLogger.info('=== BLOC CLOCK-IN ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      emit(AttendanceError(e.toString()));
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
      AppLogger.debug('Repository clockOut successful, attendance: $attendance');
      emit(
        AttendanceOperationSuccess(
          message: 'Clocked out successfully',
          attendance: attendance,
        ),
      );
      AppLogger.debug('Emitted AttendanceOperationSuccess, reloading data...');
      // Reload data
      add(LoadTodayAttendance(token: event.token, empId: event.empId));
    } catch (e, stackTrace) {
      AppLogger.info('=== BLOC CLOCK-OUT ERROR ===');
      AppLogger.debug('Error type: ${e.runtimeType}');
      AppLogger.debug('Error message: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onStartBreak(
    StartBreak event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      await attendanceRepository.startBreak(event.token, event.empId);
      emit(const AttendanceOperationSuccess(message: 'Break started'));
      // Reload data
      add(LoadTodayAttendance(token: event.token, empId: event.empId));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onEndBreak(
    EndBreak event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      await attendanceRepository.endBreak(event.token, event.empId);
      emit(const AttendanceOperationSuccess(message: 'Break ended'));
      // Reload data
      add(LoadTodayAttendance(token: event.token, empId: event.empId));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final activities = await attendanceRepository.getActivities(
        event.token,
        event.empId,
        date: event.date,
      );
      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        emit(
          AttendanceLoaded(
            attendance: currentState.attendance,
            activities: activities,
          ),
        );
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
