import 'role_model.dart';

(DateTime createdAt, DateTime updatedAt) _auditPair(int index) {
  final pairs = <(DateTime, DateTime)>[
    (DateTime(2024, 1, 15), DateTime(2024, 3, 20)),
    (DateTime(2024, 2, 10), DateTime(2024, 4, 5)),
    (DateTime(2024, 3, 1), DateTime(2024, 4, 15)),
    (DateTime(2024, 3, 18), DateTime(2024, 5, 2)),
  ];
  return pairs[index % pairs.length];
}

/// In-memory mock API for roles (no backend).
class RolesApi {
  RolesApi() {
    _items = [
      RoleModel(
        id: 'role-admin',
        name: 'Admin',
        level: 0,
        description: 'Full system access',
        type: RoleType.system,
        usersCount: 1,
        status: RoleStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(0).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(0).$2,
      ),
      RoleModel(
        id: 'role-power',
        name: 'Power User',
        level: 1,
        description: 'Extended operational access',
        type: RoleType.system,
        usersCount: 0,
        status: RoleStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(1).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(1).$2,
      ),
      RoleModel(
        id: 'role-project',
        name: 'Project User',
        level: 2,
        description: 'Project-scoped access',
        type: RoleType.system,
        usersCount: 0,
        status: RoleStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(2).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(2).$2,
      ),
      RoleModel(
        id: 'role-viewer',
        name: 'Viewer',
        level: 3,
        description: 'Read-only access',
        type: RoleType.system,
        usersCount: 0,
        status: RoleStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(3).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(3).$2,
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
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
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
      createdBy: prev.createdBy,
      createdAt: prev.createdAt,
      updatedBy: 'Admin User',
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
    final now = DateTime.now();
    final next = prev.copyWith(
      status: nextStatus,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items[i] = next;
    return next;
  }

  Future<void> updateStatus(String id, String status) async {
    final RoleStatus nextStatus = switch (status) {
      'active' => RoleStatus.active,
      'inactive' => RoleStatus.inactive,
      _ => throw ArgumentError('Invalid status: $status'),
    };
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Role not found: $id');
    }
    final prev = _items[i];
    if (prev.status == nextStatus) {
      return;
    }
    final now = DateTime.now();
    _items[i] = prev.copyWith(
      status: nextStatus,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
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
