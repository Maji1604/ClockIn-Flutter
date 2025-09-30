import 'package:equatable/equatable.dart';

/// Company membership entity for multi-company users
class CompanyMembership extends Equatable {
  final String companyId;
  final String companyName;
  final String companySlug;
  final String role;

  const CompanyMembership({
    required this.companyId,
    required this.companyName,
    required this.companySlug,
    required this.role,
  });

  @override
  List<Object?> get props => [companyId, companyName, companySlug, role];
}