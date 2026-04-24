import 'user_model.dart';

/// In-memory mock API for users (no backend).
class UsersApi {
  UsersApi() {
    final t = DateTime.utc(2024, 1, 1);
    final recent = DateTime.utc(2024, 6, 15, 9, 30);
    _items = [
      UserModel(
        id: 'user-adm',
        name: 'Admin User',
        email: 'admin@ultralabs.example',
        phone: '+1 555-0100',
        username: 'admin',
        employeeId: 'EMP-001',
        departmentId: 'dept-adm',
        departmentName: 'Admin',
        roleId: 'role-admin',
        roleName: 'Admin',
        status: UserStatus.active,
        lastLogin: recent,
        createdAt: t,
        updatedAt: t,
      ),
      UserModel(
        id: 'user-lab-exec',
        name: 'Lab Executive',
        email: 'lab.exec@ultralabs.example',
        phone: '+1 555-0101',
        username: 'labexec',
        employeeId: 'EMP-102',
        departmentId: 'dept-lab',
        departmentName: 'Lab',
        roleId: 'role-power',
        roleName: 'Power User',
        status: UserStatus.active,
        lastLogin: DateTime.utc(2024, 6, 14, 16, 45),
        createdAt: t,
        updatedAt: t,
      ),
      UserModel(
        id: 'user-acc-mgr',
        name: 'Accounts Manager',
        email: 'accounts@ultralabs.example',
        phone: '+1 555-0102',
        username: 'acctmgr',
        employeeId: 'EMP-205',
        departmentId: 'dept-acc',
        departmentName: 'Accounts',
        roleId: 'role-project',
        roleName: 'Project User',
        status: UserStatus.active,
        lastLogin: DateTime.utc(2024, 6, 10, 11, 0),
        createdAt: t,
        updatedAt: t,
      ),
      UserModel(
        id: 'user-sales-exec',
        name: 'Sales Executive',
        email: 'sales@ultralabs.example',
        phone: '+1 555-0103',
        username: 'salesexec',
        employeeId: null,
        departmentId: 'dept-sal',
        departmentName: 'Sales',
        roleId: 'role-viewer',
        roleName: 'Viewer',
        status: UserStatus.inactive,
        lastLogin: DateTime.utc(2024, 5, 1, 8, 15),
        createdAt: t,
        updatedAt: t,
      ),
    ];
  }

  late final List<UserModel> _items;
  int _idSeq = 0;

  Future<List<UserModel>> fetchAll() async {
    return List<UserModel>.unmodifiable(_items);
  }

  Future<UserModel?> fetchById(String id) async {
    for (final u in _items) {
      if (u.id == id) {
        return u;
      }
    }
    return null;
  }

  Future<UserModel> create({
    required String name,
    required String email,
    String? phone,
    required String username,
    String? employeeId,
    required String departmentId,
    required String departmentName,
    required String roleId,
    required String roleName,
    required UserStatus status,
  }) async {
    final now = DateTime.now();
    _idSeq += 1;
    final model = UserModel(
      id: 'user-new-$_idSeq',
      name: name,
      email: email,
      phone: phone,
      username: username,
      employeeId: employeeId,
      departmentId: departmentId,
      departmentName: departmentName,
      roleId: roleId,
      roleName: roleName,
      status: status,
      lastLogin: null,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(model);
    return model;
  }

  Future<UserModel> update({
    required String id,
    required String name,
    required String email,
    String? phone,
    required String username,
    String? employeeId,
    required String departmentId,
    required String departmentName,
    required String roleId,
    required String roleName,
    required UserStatus status,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('User not found: $id');
    }
    final prev = _items[i];
    final now = DateTime.now();
    final next = prev.copyWith(
      name: name,
      email: email,
      phone: phone,
      username: username,
      employeeId: employeeId,
      departmentId: departmentId,
      departmentName: departmentName,
      roleId: roleId,
      roleName: roleName,
      status: status,
      updatedAt: now,
    );
    _items[i] = next;
    return next;
  }

  Future<UserModel> toggleStatus(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('User not found: $id');
    }
    final prev = _items[i];
    final nextStatus = prev.status == UserStatus.active
        ? UserStatus.inactive
        : UserStatus.active;
    final now = DateTime.now();
    final next = prev.copyWith(status: nextStatus, updatedAt: now);
    _items[i] = next;
    return next;
  }

  Future<void> delete(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('User not found: $id');
    }
    _items.removeAt(i);
  }
}
