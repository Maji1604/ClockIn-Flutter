import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.empId,
    required super.name,
    super.email,
    super.companyEmail,
    super.mobileNumber,
    super.address,
    required super.department,
    super.designation,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: avoid direct `as String` casts which throw if value is null
    final empId = json['emp_id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final email = json['email']?.toString();
    final companyEmail = json['company_email']?.toString();
    final mobileNumber = json['mobile_number']?.toString();
    final address = json['address']?.toString();
    final department = json['department']?.toString() ?? '';
    final designation = json['designation']?.toString();
    DateTime createdAt;
    try {
      final createdAtStr = json['created_at']?.toString();
      createdAt = createdAtStr != null && createdAtStr.isNotEmpty
          ? DateTime.parse(createdAtStr)
          : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    return ProfileModel(
      empId: empId,
      name: name,
      email: email,
      companyEmail: companyEmail,
      mobileNumber: mobileNumber,
      address: address,
      department: department,
      designation: designation,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_id': empId,
      'name': name,
      'email': email,
      'company_email': companyEmail,
      'mobile_number': mobileNumber,
      'address': address,
      'department': department,
      'designation': designation,
    };
  }

  ProfileModel copyWith({
    String? empId,
    String? name,
    String? email,
    String? companyEmail,
    String? mobileNumber,
    String? address,
    String? department,
    String? designation,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      empId: empId ?? this.empId,
      name: name ?? this.name,
      email: email ?? this.email,
      companyEmail: companyEmail ?? this.companyEmail,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
