import '../../domain/entities/company.dart';

/// Company model for API serialization
class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.companyCode,
    required super.timezone,
    required super.createdAt,
    required super.hasSampleData,
  });

  /// Create from JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      companyCode: json['company_code'] as String,
      timezone: json['timezone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      hasSampleData: _parseBool(json['has_sample_data']) ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'company_code': companyCode,
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'has_sample_data': hasSampleData,
    };
  }

  /// Create from domain entity
  factory CompanyModel.fromEntity(Company company) {
    return CompanyModel(
      id: company.id,
      name: company.name,
      slug: company.slug,
      companyCode: company.companyCode,
      timezone: company.timezone,
      createdAt: company.createdAt,
      hasSampleData: company.hasSampleData,
    );
  }

  /// Convert to domain entity
  Company toEntity() {
    return Company(
      id: id,
      name: name,
      slug: slug,
      companyCode: companyCode,
      timezone: timezone,
      createdAt: createdAt,
      hasSampleData: hasSampleData,
    );
  }

  /// Helper method to safely parse boolean values from API response
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }
}