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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int level;
  final String? description;
  final RoleType type;
  final int usersCount;
  final RoleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == RoleStatus.active;

  bool get canDelete =>
      type == RoleType.custom && usersCount == 0;

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

  RoleModel copyWith({
    String? id,
    String? name,
    int? level,
    Object? description = _unset,
    RoleType? type,
    int? usersCount,
    RoleStatus? status,
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
