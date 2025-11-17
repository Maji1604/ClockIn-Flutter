import '../datasources/leave_remote_data_source.dart';
import '../models/leave_model.dart';

class LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;

  LeaveRepository({required this.remoteDataSource});

  Future<LeaveModel> submitLeave({
    required String token,
    required String empId,
    required String leaveType,
    required String leavePeriod,
    required String startDate,
    String? endDate,
    required String reason,
  }) async {
    return await remoteDataSource.submitLeave(
      token: token,
      empId: empId,
      leaveType: leaveType,
      leavePeriod: leavePeriod,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  Future<List<LeaveModel>> getEmployeeLeaves(String token, String empId) async {
    return await remoteDataSource.getEmployeeLeaves(token, empId);
  }

  Future<List<LeaveModel>> getPendingLeaves(String token) async {
    return await remoteDataSource.getPendingLeaves(token);
  }

  Future<List<LeaveModel>> getAllLeaves(
    String token, {
    String? status,
    String? empId,
  }) async {
    return await remoteDataSource.getAllLeaves(
      token,
      status: status,
      empId: empId,
    );
  }

  Future<LeaveModel> approveLeave(
    String token,
    String leaveId,
    String adminId,
    String? comments,
  ) async {
    return await remoteDataSource.approveLeave(
      token,
      leaveId,
      adminId,
      comments,
    );
  }

  Future<LeaveModel> rejectLeave(
    String token,
    String leaveId,
    String adminId,
    String comments,
  ) async {
    return await remoteDataSource.rejectLeave(
      token,
      leaveId,
      adminId,
      comments,
    );
  }
}
