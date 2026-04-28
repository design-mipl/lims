import '../../shared/audit_fields.dart';

enum ModuleStatus {
  active,
  inactive,
}

class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.name,
    this.parentId,
    this.parentName,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
    this.usedInPermissions = false,
  });

  final String id;
  final String name;
  final String? parentId;
  final String? parentName;
  final ModuleStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  /// Reserved for future permission-matrix linkage; when true, delete is blocked.
  final bool usedInPermissions;

  bool get isActive => status == ModuleStatus.active;

  bool hasChildrenAmong(List<ModuleModel> all) =>
      all.any((m) => m.parentId == id);

  bool isParentAmong(List<ModuleModel> all) => hasChildrenAmong(all);

  bool canDeleteAmong(List<ModuleModel> all) =>
      !hasChildrenAmong(all) && !usedInPermissions;

  static const Object _unset = Object();

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final a = AuditFields.fromJson(json);
    final statusStr = json['status'] as String? ?? 'active';
    final status = ModuleStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => ModuleStatus.active,
    );
    return ModuleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parent_id'] as String?,
      parentName: json['parent_name'] as String?,
      status: status,
      createdBy: a.createdBy,
      createdAt: a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedBy: a.updatedBy,
      updatedAt: a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      usedInPermissions: json['used_in_permissions'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (parentId != null) 'parent_id': parentId,
        if (parentName != null) 'parent_name': parentName,
        'status': status.name,
        'used_in_permissions': usedInPermissions,
        if (createdBy != null) 'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        if (updatedBy != null) 'updated_by': updatedBy,
        'updated_at': updatedAt.toIso8601String(),
      };

  ModuleModel copyWith({
    String? id,
    String? name,
    Object? parentId = _unset,
    Object? parentName = _unset,
    ModuleStatus? status,
    Object? createdBy = _unset,
    DateTime? createdAt,
    Object? updatedBy = _unset,
    DateTime? updatedAt,
    bool? usedInPermissions,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: identical(parentId, _unset)
          ? this.parentId
          : parentId as String?,
      parentName: identical(parentName, _unset)
          ? this.parentName
          : parentName as String?,
      status: status ?? this.status,
      createdBy: identical(createdBy, _unset)
          ? this.createdBy
          : createdBy as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: identical(updatedBy, _unset)
          ? this.updatedBy
          : updatedBy as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      usedInPermissions: usedInPermissions ?? this.usedInPermissions,
    );
  }
}
