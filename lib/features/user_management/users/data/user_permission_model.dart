class UserPermission {
  UserPermission({
    required this.moduleId,
    this.subModuleId,
    this.canView = false,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  final String moduleId;
  final String? subModuleId;
  bool canView;
  bool canCreate;
  bool canEdit;
  bool canDelete;

  void setView(bool value) {
    canView = value;
    if (!value) {
      canCreate = false;
      canEdit = false;
      canDelete = false;
    }
  }

  void setCreate(bool value) {
    canCreate = value;
    if (value) {
      canView = true;
    }
  }

  void setEdit(bool value) {
    canEdit = value;
    if (value) {
      canView = true;
    }
  }

  void setDelete(bool value) {
    canDelete = value;
    if (value) {
      canView = true;
    }
  }

  bool get hasAny =>
      canView || canCreate || canEdit || canDelete;

  bool get hasAll =>
      canView && canCreate && canEdit && canDelete;

  UserPermission copyWith({
    bool? canView,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
  }) =>
      UserPermission(
        moduleId: moduleId,
        subModuleId: subModuleId,
        canView: canView ?? this.canView,
        canCreate: canCreate ?? this.canCreate,
        canEdit: canEdit ?? this.canEdit,
        canDelete: canDelete ?? this.canDelete,
      );

  Map<String, dynamic> toJson() => {
        'module_id': moduleId,
        'sub_module_id': subModuleId,
        'can_view': canView,
        'can_create': canCreate,
        'can_edit': canEdit,
        'can_delete': canDelete,
      };

  factory UserPermission.fromJson(Map<String, dynamic> json) =>
      UserPermission(
        moduleId: json['module_id'] as String,
        subModuleId: json['sub_module_id'] as String?,
        canView: json['can_view'] as bool? ?? false,
        canCreate: json['can_create'] as bool? ?? false,
        canEdit: json['can_edit'] as bool? ?? false,
        canDelete: json['can_delete'] as bool? ?? false,
      );
}
