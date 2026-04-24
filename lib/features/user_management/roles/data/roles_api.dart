import 'role_model.dart';

/// In-memory mock API for roles (no backend).
class RolesApi {
  RolesApi() {
    final t = DateTime.utc(2024, 1, 1);
    _items = [
      RoleModel(
        id: 'role-admin',
        name: 'Admin',
        level: 0,
        description: 'Full system access',
        type: RoleType.system,
        usersCount: 1,
        status: RoleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      RoleModel(
        id: 'role-power',
        name: 'Power User',
        level: 1,
        description: 'Extended operational access',
        type: RoleType.system,
        usersCount: 0,
        status: RoleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      RoleModel(
        id: 'role-project',
        name: 'Project User',
        level: 2,
        description: 'Project-scoped access',
        type: RoleType.system,
        usersCount: 0,
        status: RoleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      RoleModel(
        id: 'role-viewer',
        name: 'Viewer',
        level: 3,
        description: 'Read-only access',
        type: RoleType.system,
        usersCount: 0,
        status: RoleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
    ];
  }

  late final List<RoleModel> _items;
  int _idSeq = 0;

  Future<List<RoleModel>> fetchAll() async {
    return List<RoleModel>.unmodifiable(_items);
  }

  Future<RoleModel> create({
    required String name,
    required int level,
    String? description,
    required RoleType type,
    required RoleStatus status,
  }) async {
    final now = DateTime.now();
    _idSeq += 1;
    final model = RoleModel(
      id: 'role-new-$_idSeq',
      name: name,
      level: level.clamp(0, 3),
      description: description,
      type: type,
      usersCount: 0,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(model);
    return model;
  }

  Future<RoleModel> update({
    required String id,
    required String name,
    required int level,
    String? description,
    required RoleType type,
    required RoleStatus status,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Role not found: $id');
    }
    final prev = _items[i];
    final now = DateTime.now();
    final next = RoleModel(
      id: prev.id,
      name: name,
      level: level.clamp(0, 3),
      description: description,
      type: type,
      usersCount: prev.usersCount,
      status: status,
      createdAt: prev.createdAt,
      updatedAt: now,
    );
    _items[i] = next;
    return next;
  }

  Future<RoleModel> toggleStatus(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Role not found: $id');
    }
    final prev = _items[i];
    final nextStatus = prev.status == RoleStatus.active
        ? RoleStatus.inactive
        : RoleStatus.active;
    final next = prev.copyWith(
      status: nextStatus,
      updatedAt: DateTime.now(),
    );
    _items[i] = next;
    return next;
  }

  Future<void> delete(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Role not found: $id');
    }
    final row = _items[i];
    if (row.type == RoleType.system) {
      throw StateError('Cannot delete a system role.');
    }
    if (row.usersCount > 0) {
      throw StateError(
        'Cannot delete a role while users are assigned to it.',
      );
    }
    _items.removeAt(i);
  }
}
