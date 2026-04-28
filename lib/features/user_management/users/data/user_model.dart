import '../../shared/audit_fields.dart';

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
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
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
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  bool get isActive => status == UserStatus.active;

  static const Object _unset = Object();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final a = AuditFields.fromJson(json);
    final statusStr = json['status'] as String? ?? 'active';
    final status = UserStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => UserStatus.active,
    );
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      username: json['username'] as String,
      employeeId: json['employee_id'] as String?,
      departmentId: json['department_id'] as String? ?? '',
      departmentName: json['department_name'] as String? ?? '',
      roleId: json['role_id'] as String? ?? '',
      roleName: json['role_name'] as String? ?? '',
      status: status,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdBy: a.createdBy,
      createdAt: a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedBy: a.updatedBy,
      updatedAt: a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        'username': username,
        if (employeeId != null) 'employee_id': employeeId,
        'department_id': departmentId,
        'department_name': departmentName,
        'role_id': roleId,
        'role_name': roleName,
        'status': status.name,
        if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
        if (createdBy != null) 'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        if (updatedBy != null) 'updated_by': updatedBy,
        'updated_at': updatedAt.toIso8601String(),
      };

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
    Object? createdBy = _unset,
    DateTime? createdAt,
    Object? updatedBy = _unset,
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
