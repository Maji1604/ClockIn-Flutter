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
    return ProfileModel(
      empId: json['emp_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      companyEmail: json['company_email'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      address: json['address'] as String?,
      department: json['department'] as String,
      designation: json['designation'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
