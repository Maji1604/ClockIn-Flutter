import '../../domain/entities/company_membership.dart';

/// Company membership model for API <-> domain conversion
class CompanyMembershipModel extends CompanyMembership {
  const CompanyMembershipModel({
    required super.companyId,
    required super.companyName,
    required super.companySlug,
    required super.role,
  });

  factory CompanyMembershipModel.fromJson(Map<String, dynamic> json) {
    return CompanyMembershipModel(
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      companySlug: json['company_slug'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'company_name': companyName,
      'company_slug': companySlug,
      'role': role,
    };
  }
}
