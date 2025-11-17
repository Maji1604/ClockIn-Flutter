import 'package:equatable/equatable.dart';
import '../../data/models/leave_model.dart';

// Events
abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class SubmitLeaveEvent extends LeaveEvent {
  final String token;
  final String empId;
  final String leaveType;
  final String leavePeriod;
  final String startDate;
  final String? endDate;
  final String reason;

  const SubmitLeaveEvent({
    required this.token,
    required this.empId,
    required this.leaveType,
    required this.leavePeriod,
    required this.startDate,
    this.endDate,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    token,
    empId,
    leaveType,
    leavePeriod,
    startDate,
    endDate,
    reason,
  ];
}

class FetchEmployeeLeavesEvent extends LeaveEvent {
  final String token;
  final String empId;

  const FetchEmployeeLeavesEvent({required this.token, required this.empId});

  @override
  List<Object?> get props => [token, empId];
}

class FetchPendingLeavesEvent extends LeaveEvent {
  final String token;

  const FetchPendingLeavesEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class FetchAllLeavesEvent extends LeaveEvent {
  final String token;
  final String? status;
  final String? empId;

  const FetchAllLeavesEvent({required this.token, this.status, this.empId});

  @override
  List<Object?> get props => [token, status, empId];
}

class ApproveLeaveEvent extends LeaveEvent {
  final String token;
  final String leaveId;
  final String adminId;
  final String? comments;

  const ApproveLeaveEvent({
    required this.token,
    required this.leaveId,
    required this.adminId,
    this.comments,
  });

  @override
  List<Object?> get props => [token, leaveId, adminId, comments];
}

class RejectLeaveEvent extends LeaveEvent {
  final String token;
  final String leaveId;
  final String adminId;
  final String comments;

  const RejectLeaveEvent({
    required this.token,
    required this.leaveId,
    required this.adminId,
    required this.comments,
  });

  @override
  List<Object?> get props => [token, leaveId, adminId, comments];
}

// States
abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveSubmitSuccess extends LeaveState {
  final LeaveModel leave;

  const LeaveSubmitSuccess({required this.leave});

  @override
  List<Object?> get props => [leave];
}

class LeavesLoadSuccess extends LeaveState {
  final List<LeaveModel> leaves;

  const LeavesLoadSuccess({required this.leaves});

  @override
  List<Object?> get props => [leaves];
}

class LeaveActionSuccess extends LeaveState {
  final LeaveModel leave;
  final String message;

  const LeaveActionSuccess({required this.leave, required this.message});

  @override
  List<Object?> get props => [leave, message];
}

class LeaveError extends LeaveState {
  final String message;

  const LeaveError({required this.message});

  @override
  List<Object?> get props => [message];
}
