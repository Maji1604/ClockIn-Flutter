import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final String id; // Changed from int to String to match backend
  final String empId;
  final String? date;
  final String? clockInTime;
  final String? clockInLocation;
  final String? clockOutTime;
  final String? clockOutLocation;
  final double? totalWorkHours;
  final double? totalBreakHours;
  final String status;
  final int? completedBreaks;
  final int? activeBreaks;
  final String? activeBreakStart; // Added to track active break start time
  final String? createdAt;
  final String? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.empId,
    this.date,
    this.clockInTime,
    this.clockInLocation,
    this.clockOutTime,
    this.clockOutLocation,
    this.totalWorkHours,
    this.totalBreakHours,
    required this.status,
    this.completedBreaks,
    this.activeBreaks,
    this.activeBreakStart,
    this.createdAt,
    this.updatedAt,
  });

  bool get isClockedIn => clockInTime != null && clockOutTime == null;
  bool get isOnBreak => (activeBreaks ?? 0) > 0;
  bool get isClockedOut => clockOutTime != null;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // Handle both clock-in response format and full attendance record format
    final id = json['id'] as String? ?? json['attendanceId'] as String?;
    final empId = json['emp_id'] as String? ?? json['empId'] as String? ?? '';

    return AttendanceModel(
      id: id ?? '',
      empId: empId,
      date: json['date'] as String?,
      clockInTime:
          json['clock_in_time'] as String? ?? json['clockInTime'] as String?,
      clockInLocation:
          json['clock_in_location'] as String? ??
          json['clockInLocation'] as String?,
      clockOutTime:
          json['clock_out_time'] as String? ?? json['clockOutTime'] as String?,
      clockOutLocation:
          json['clock_out_location'] as String? ??
          json['clockOutLocation'] as String?,
      totalWorkHours:
          (json['total_work_hours'] as num?)?.toDouble() ??
          (json['totalWorkHours'] as num?)?.toDouble(),
      totalBreakHours:
          (json['total_break_hours'] as num?)?.toDouble() ??
          (json['totalBreakHours'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'present',
      completedBreaks:
          json['completed_breaks'] as int? ?? json['completedBreaks'] as int?,
      activeBreaks:
          json['active_breaks'] as int? ?? json['activeBreaks'] as int?,
      activeBreakStart:
          json['active_break_start'] as String? ??
          json['activeBreakStart'] as String?,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emp_id': empId,
      'date': date,
      'clock_in_time': clockInTime,
      'clock_in_location': clockInLocation,
      'clock_out_time': clockOutTime,
      'clock_out_location': clockOutLocation,
      'total_work_hours': totalWorkHours,
      'total_break_hours': totalBreakHours,
      'status': status,
      'completed_breaks': completedBreaks,
      'active_breaks': activeBreaks,
      'active_break_start': activeBreakStart,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    empId,
    date,
    clockInTime,
    clockInLocation,
    clockOutTime,
    clockOutLocation,
    totalWorkHours,
    totalBreakHours,
    status,
    completedBreaks,
    activeBreaks,
    activeBreakStart,
    createdAt,
    updatedAt,
  ];
}
