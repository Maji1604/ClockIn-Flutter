import 'package:equatable/equatable.dart';

class ActivityModel extends Equatable {
  final String id; // Changed from int to String to match backend
  final String empId;
  final String action;
  final String? timestamp;
  final String? details;
  final String? location;
  final String? attendanceId;

  const ActivityModel({
    required this.id,
    required this.empId,
    required this.action,
    this.timestamp,
    this.details,
    this.location,
    this.attendanceId,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id:
          json['id']
              as String, // Backend generates string IDs like "act-1731854198920-..."
      empId: json['emp_id'] as String,
      action: json['action'] as String,
      timestamp: json['timestamp'] as String?,
      details: json['details'] as String?,
      location: json['location'] as String?,
      attendanceId: json['attendance_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emp_id': empId,
      'action': action,
      'timestamp': timestamp,
      'details': details,
      'location': location,
      'attendance_id': attendanceId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    empId,
    action,
    timestamp,
    details,
    location,
    attendanceId,
  ];
}
