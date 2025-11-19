import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/activity_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceModel?> getTodayAttendance(
    String token,
    String empId, {
    DateTime? date,
  });
  Future<AttendanceModel> clockIn(String token, String empId);
  Future<AttendanceModel> clockOut(String token, String empId);
  Future<AttendanceModel> startBreak(String token, String empId);
  Future<AttendanceModel> endBreak(String token, String empId);
  Future<List<ActivityModel>> getActivities(
    String token,
    String empId, {
    DateTime? date,
  });
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AttendanceModel?> getTodayAttendance(
    String token,
    String empId, {
    DateTime? date,
  }) async {
    try {
      return await remoteDataSource.getTodayAttendance(
        token,
        empId,
        date: date,
      );
    } catch (e) {
      throw Exception('Failed to fetch attendance: ${e.toString()}');
    }
  }

  @override
  Future<AttendanceModel> clockIn(String token, String empId) async {
    try {
      return await remoteDataSource.clockIn(token, empId);
    } on AlreadyClockedInException {
      rethrow; // Preserve the specific exception type
    } catch (e) {
      throw Exception('Failed to clock in: ${e.toString()}');
    }
  }

  @override
  Future<AttendanceModel> clockOut(String token, String empId) async {
    try {
      return await remoteDataSource.clockOut(token, empId);
    } catch (e) {
      rethrow; // Let the original error bubble up
    }
  }

  @override
  Future<AttendanceModel> startBreak(String token, String empId) async {
    try {
      return await remoteDataSource.startBreak(token, empId);
    } catch (e) {
      rethrow; // Let the original error bubble up
    }
  }

  @override
  Future<AttendanceModel> endBreak(String token, String empId) async {
    try {
      return await remoteDataSource.endBreak(token, empId);
    } catch (e) {
      rethrow; // Let the original error bubble up
    }
  }

  @override
  Future<List<ActivityModel>> getActivities(
    String token,
    String empId, {
    DateTime? date,
  }) async {
    try {
      return await remoteDataSource.getActivities(token, empId, date: date);
    } catch (e) {
      rethrow; // Let the original error bubble up
    }
  }
}
