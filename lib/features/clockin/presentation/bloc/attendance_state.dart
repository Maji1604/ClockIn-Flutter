import 'package:equatable/equatable.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/activity_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final AttendanceModel? attendance;
  final List<ActivityModel> activities;

  const AttendanceLoaded({this.attendance, this.activities = const []});

  @override
  List<Object?> get props => [attendance, activities];
}

class AttendanceOperationSuccess extends AttendanceState {
  final String message;
  final AttendanceModel? attendance;

  const AttendanceOperationSuccess({required this.message, this.attendance});

  @override
  List<Object?> get props => [message, attendance];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
