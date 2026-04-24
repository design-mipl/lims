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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String code;
  final String? description;
  final int usersCount;
  final DepartmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == DepartmentStatus.active;

  bool get canDelete => usersCount == 0;

  static const Object _unset = Object();

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? code,
    Object? description = _unset,
    int? usersCount,
    DepartmentStatus? status,
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
