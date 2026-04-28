import '../../shared/audit_fields.dart';

enum RoleStatus {
  active,
  inactive,
}

enum RoleType {
  system,
  custom,
}

class RoleModel {
  const RoleModel({
    required this.id,
    required this.name,
    required this.level,
    this.description,
    required this.type,
    required this.usersCount,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int level;
  final String? description;
  final RoleType type;
  final int usersCount;
  final RoleStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  bool get isActive => status == RoleStatus.active;

  bool get isSystemRole => type == RoleType.system;

  bool get canDelete => type == RoleType.custom && usersCount == 0;

  static String labelForLevel(int level) {
    switch (level.clamp(0, 3)) {
      case 0:
        return 'Admin';
      case 1:
        return 'Power User';
      case 2:
        return 'Project User';
      case 3:
        return 'Viewer';
      default:
        return 'Viewer';
    }
  }

  static const Object _unset = Object();

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final a = AuditFields.fromJson(json);
    final statusStr = json['status'] as String? ?? 'active';
    final status = RoleStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => RoleStatus.active,
    );
    final typeStr = json['type'] as String? ?? 'system';
    final type = RoleType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => RoleType.system,
    );
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      level: (json['level'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      type: type,
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
        'level': level,
        if (description != null) 'description': description,
        'type': type.name,
        'users_count': usersCount,
        'status': status.name,
        if (createdBy != null) 'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        if (updatedBy != null) 'updated_by': updatedBy,
        'updated_at': updatedAt.toIso8601String(),
      };

  RoleModel copyWith({
    String? id,
    String? name,
    int? level,
    Object? description = _unset,
    RoleType? type,
    int? usersCount,
    RoleStatus? status,
    Object? createdBy = _unset,
    DateTime? createdAt,
    Object? updatedBy = _unset,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      type: type ?? this.type,
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
