enum ModuleStatus {
  active,
  inactive,
}

class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    required this.route,
    required this.icon,
    required this.sortOrder,
    required this.showInNavigation,
    required this.permissionEnabled,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.usedInPermissions = false,
  });

  final String id;
  final String name;
  final String code;
  final String? parentId;
  final String route;
  final String icon;
  final int sortOrder;
  final bool showInNavigation;
  final bool permissionEnabled;
  final ModuleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Reserved for future permission-matrix linkage; when true, delete is blocked.
  final bool usedInPermissions;

  bool get isActive => status == ModuleStatus.active;

  bool hasChildrenAmong(List<ModuleModel> all) =>
      all.any((m) => m.parentId == id);

  /// True when this row is a parent of at least one other module in [all].
  bool isParentAmong(List<ModuleModel> all) => hasChildrenAmong(all);

  bool canDeleteAmong(List<ModuleModel> all) =>
      !hasChildrenAmong(all) && !usedInPermissions;

  static const Object _unset = Object();

  ModuleModel copyWith({
    String? id,
    String? name,
    String? code,
    Object? parentId = _unset,
    String? route,
    String? icon,
    int? sortOrder,
    bool? showInNavigation,
    bool? permissionEnabled,
    ModuleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? usedInPermissions,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      parentId: identical(parentId, _unset)
          ? this.parentId
          : parentId as String?,
      route: route ?? this.route,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      showInNavigation: showInNavigation ?? this.showInNavigation,
      permissionEnabled: permissionEnabled ?? this.permissionEnabled,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usedInPermissions: usedInPermissions ?? this.usedInPermissions,
    );
  }
}
