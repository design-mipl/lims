/// Shared audit metadata (backend snake_case JSON).
class AuditFields {
  const AuditFields({
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  final String? createdBy;
  final DateTime? createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  factory AuditFields.fromJson(Map<String, dynamic> json) {
    return AuditFields(
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (createdBy != null) 'created_by': createdBy,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedBy != null) 'updated_by': updatedBy,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}
