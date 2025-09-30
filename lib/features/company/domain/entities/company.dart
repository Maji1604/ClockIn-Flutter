import 'package:equatable/equatable.dart';

/// Company entity representing a registered company
class Company extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String companyCode; // New field for company code
  final String timezone;
  final DateTime createdAt;
  final bool hasSampleData;

  const Company({
    required this.id,
    required this.name,
    required this.slug,
    required this.companyCode,
    required this.timezone,
    required this.createdAt,
    required this.hasSampleData,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        companyCode,
        timezone,
        createdAt,
        hasSampleData,
      ];

  @override
  String toString() {
    return 'Company(id: $id, name: $name, slug: $slug, companyCode: $companyCode)';
  }
}