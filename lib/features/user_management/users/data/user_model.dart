enum UserStatus {
  active,
  inactive,
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.username,
    this.employeeId,
    required this.departmentId,
    required this.departmentName,
    required this.roleId,
    required this.roleName,
    required this.status,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String username;
  final String? employeeId;
  final String departmentId;
  final String departmentName;
  final String roleId;
  final String roleName;
  final UserStatus status;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == UserStatus.active;

  static const Object _unset = Object();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    Object? phone = _unset,
    String? username,
    Object? employeeId = _unset,
    String? departmentId,
    String? departmentName,
    String? roleId,
    String? roleName,
    UserStatus? status,
    Object? lastLogin = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: identical(phone, _unset) ? this.phone : phone as String?,
      username: username ?? this.username,
      employeeId: identical(employeeId, _unset)
          ? this.employeeId
          : employeeId as String?,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      status: status ?? this.status,
      lastLogin: identical(lastLogin, _unset)
          ? this.lastLogin
          : lastLogin as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
