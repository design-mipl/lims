import '../../shared/audit_fields.dart';

enum DepartmentStatus {
  active,
  inactive,
}

class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.usersCount,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String code;
  final String? description;
  final int usersCount;
  final DepartmentStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  bool get isActive => status == DepartmentStatus.active;

  bool get canDelete => usersCount == 0;

  static const Object _unset = Object();

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    final a = AuditFields.fromJson(json);
    final statusStr = json['status'] as String? ?? 'active';
    final status = DepartmentStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => DepartmentStatus.active,
    );
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      usersCount: (json['users_count'] as num?)?.toInt() ?? 0,
      status: status,
      createdBy: a.createdBy,
      createdAt: a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedBy: a.updatedBy,
      updatedAt: a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        if (description != null) 'description': description,
        'users_count': usersCount,
        'status': status.name,
        if (createdBy != null) 'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        if (updatedBy != null) 'updated_by': updatedBy,
        'updated_at': updatedAt.toIso8601String(),
      };

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? code,
    Object? description = _unset,
    int? usersCount,
    DepartmentStatus? status,
    Object? createdBy = _unset,
    DateTime? createdAt,
    Object? updatedBy = _unset,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      usersCount: usersCount ?? this.usersCount,
      status: status ?? this.status,
      createdBy: identical(createdBy, _unset)
          ? this.createdBy
          : createdBy as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: identical(updatedBy, _unset)
          ? this.updatedBy
          : updatedBy as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
