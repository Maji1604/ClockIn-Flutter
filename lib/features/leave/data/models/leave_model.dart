import 'package:equatable/equatable.dart';

class LeaveModel extends Equatable {
  final String id;
  final String empId;
  final String leaveType;
  final String leavePeriod;
  final String startDate;
  final String? endDate;
  final String reason;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? reviewedBy;
  final String? reviewedAt;
  final String? adminComments;
  final String? employeeName;
  final String? employeeDepartment;
  final String? reviewedByEmail;

  const LeaveModel({
    required this.id,
    required this.empId,
    required this.leaveType,
    required this.leavePeriod,
    required this.startDate,
    this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.adminComments,
    this.employeeName,
    this.employeeDepartment,
    this.reviewedByEmail,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] as String,
      empId: json['emp_id'] as String,
      leaveType: json['leave_type'] as String,
      leavePeriod: json['leave_period'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      adminComments: json['admin_comments'] as String?,
      employeeName: json['employee_name'] as String?,
      employeeDepartment: json['employee_department'] as String?,
      reviewedByEmail: json['reviewed_by_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emp_id': empId,
      'leave_type': leaveType,
      'leave_period': leavePeriod,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt,
      'admin_comments': adminComments,
      'employee_name': employeeName,
      'employee_department': employeeDepartment,
      'reviewed_by_email': reviewedByEmail,
    };
  }

  @override
  List<Object?> get props => [
    id,
    empId,
    leaveType,
    leavePeriod,
    startDate,
    endDate,
    reason,
    status,
    createdAt,
    updatedAt,
    reviewedBy,
    reviewedAt,
    adminComments,
    employeeName,
    employeeDepartment,
    reviewedByEmail,
  ];
}
