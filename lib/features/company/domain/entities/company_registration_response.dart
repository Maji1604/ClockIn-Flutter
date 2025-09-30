import 'package:equatable/equatable.dart';
import 'company.dart';
import 'admin_user.dart';

/// Company registration response entity
class CompanyRegistrationResponse extends Equatable {
  final Company company;
  final AdminUser admin;
  final String token;

  const CompanyRegistrationResponse({
    required this.company,
    required this.admin,
    required this.token,
  });

  @override
  List<Object?> get props => [company, admin, token];

  @override
  String toString() {
    return 'CompanyRegistrationResponse(company: ${company.name}, admin: ${admin.email})';
  }
}