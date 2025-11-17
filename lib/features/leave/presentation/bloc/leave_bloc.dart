import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/leave_repository_impl.dart';
import 'leave_event.dart';

export 'leave_event.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository repository;

  LeaveBloc({required this.repository}) : super(LeaveInitial()) {
    on<SubmitLeaveEvent>(_onSubmitLeave);
    on<FetchEmployeeLeavesEvent>(_onFetchEmployeeLeaves);
    on<FetchPendingLeavesEvent>(_onFetchPendingLeaves);
    on<FetchAllLeavesEvent>(_onFetchAllLeaves);
    on<ApproveLeaveEvent>(_onApproveLeave);
    on<RejectLeaveEvent>(_onRejectLeave);
  }

  Future<void> _onSubmitLeave(
    SubmitLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leave = await repository.submitLeave(
        token: event.token,
        empId: event.empId,
        leaveType: event.leaveType,
        leavePeriod: event.leavePeriod,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
      );
      emit(LeaveSubmitSuccess(leave: leave));
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }

  Future<void> _onFetchEmployeeLeaves(
    FetchEmployeeLeavesEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leaves = await repository.getEmployeeLeaves(
        event.token,
        event.empId,
      );
      emit(LeavesLoadSuccess(leaves: leaves));
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }

  Future<void> _onFetchPendingLeaves(
    FetchPendingLeavesEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leaves = await repository.getPendingLeaves(event.token);
      emit(LeavesLoadSuccess(leaves: leaves));
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }

  Future<void> _onFetchAllLeaves(
    FetchAllLeavesEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leaves = await repository.getAllLeaves(
        event.token,
        status: event.status,
        empId: event.empId,
      );
      emit(LeavesLoadSuccess(leaves: leaves));
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }

  Future<void> _onApproveLeave(
    ApproveLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leave = await repository.approveLeave(
        event.token,
        event.leaveId,
        event.adminId,
        event.comments,
      );
      emit(
        LeaveActionSuccess(
          leave: leave,
          message: 'Leave approved successfully',
        ),
      );
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }

  Future<void> _onRejectLeave(
    RejectLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leave = await repository.rejectLeave(
        event.token,
        event.leaveId,
        event.adminId,
        event.comments,
      );
      emit(
        LeaveActionSuccess(
          leave: leave,
          message: 'Leave rejected successfully',
        ),
      );
    } catch (e) {
      emit(LeaveError(message: e.toString()));
    }
  }
}
