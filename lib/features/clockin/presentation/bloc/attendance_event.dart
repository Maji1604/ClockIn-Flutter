import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayAttendance extends AttendanceEvent {
  final String token;
  final String empId;
  final DateTime? date;

  const LoadTodayAttendance({
    required this.token,
    required this.empId,
    this.date,
  });

  @override
  List<Object?> get props => [token, empId, date];
}

class ClockIn extends AttendanceEvent {
  final String token;
  final String empId;

  const ClockIn({required this.token, required this.empId});

  @override
  List<Object?> get props => [token, empId];
}

class ClockOut extends AttendanceEvent {
  final String token;
  final String empId;

  const ClockOut({required this.token, required this.empId});

  @override
  List<Object?> get props => [token, empId];
}

class StartBreak extends AttendanceEvent {
  final String token;
  final String empId;

  const StartBreak({required this.token, required this.empId});

  @override
  List<Object?> get props => [token, empId];
}

class EndBreak extends AttendanceEvent {
  final String token;
  final String empId;

  const EndBreak({required this.token, required this.empId});

  @override
  List<Object?> get props => [token, empId];
}

class LoadActivities extends AttendanceEvent {
  final String token;
  final String empId;
  final DateTime? date;

  const LoadActivities({required this.token, required this.empId, this.date});

  @override
  List<Object?> get props => [token, empId, date];
}
