import 'module_model.dart';

(DateTime createdAt, DateTime updatedAt) _auditPair(int index) {
  final pairs = <(DateTime, DateTime)>[
    (DateTime(2024, 1, 15), DateTime(2024, 3, 20)),
    (DateTime(2024, 2, 10), DateTime(2024, 4, 5)),
    (DateTime(2024, 3, 1), DateTime(2024, 4, 15)),
    (DateTime(2024, 3, 18), DateTime(2024, 5, 2)),
    (DateTime(2024, 4, 8), DateTime(2024, 5, 22)),
    (DateTime(2024, 4, 25), DateTime(2024, 6, 8)),
    (DateTime(2024, 5, 12), DateTime(2024, 6, 20)),
    (DateTime(2024, 5, 28), DateTime(2024, 7, 5)),
    (DateTime(2024, 6, 10), DateTime(2024, 7, 18)),
    (DateTime(2024, 6, 22), DateTime(2024, 8, 1)),
    (DateTime(2024, 7, 5), DateTime(2024, 8, 12)),
    (DateTime(2024, 7, 14), DateTime(2024, 8, 25)),
  ];
  return pairs[index % pairs.length];
}

/// In-memory mock API for navigation modules (no backend).
class ModulesApi {
  ModulesApi() {
    _items = [
      _row(0, 'mod-dashboard', 'Dashboard', null, ModuleStatus.active),
      _row(1, 'mod-transactions', 'Transactions', null, ModuleStatus.active),
      _row(2, 'mod-sample-receipt', 'Sample Receipt', 'mod-transactions',
          ModuleStatus.active),
      _row(3, 'mod-lab-code', 'Lab Code', 'mod-transactions',
          ModuleStatus.active),
      _row(4, 'mod-masters', 'Masters', null, ModuleStatus.active),
      _row(5, 'mod-customer', 'Customer', 'mod-masters', ModuleStatus.active),
      _row(6, 'mod-site', 'Site', 'mod-masters', ModuleStatus.active),
      _row(7, 'mod-user-mgmt', 'User Management', null, ModuleStatus.active),
      _row(8, 'mod-departments', 'Departments', 'mod-user-mgmt',
          ModuleStatus.active),
      _row(9, 'mod-users', 'Users', 'mod-user-mgmt', ModuleStatus.active),
      _row(10, 'mod-roles', 'Roles', 'mod-user-mgmt', ModuleStatus.active),
      _row(11, 'mod-modules', 'Modules', 'mod-user-mgmt', ModuleStatus.active),
    ];
    _applyParentNames();
  }

  late List<ModuleModel> _items;
  int _idSeq = 0;

  ModuleModel _row(
    int auditIndex,
    String id,
    String name,
    String? parentId,
    ModuleStatus status,
  ) {
    final (ca, ua) = _auditPair(auditIndex);
    return ModuleModel(
      id: id,
      name: name,
      parentId: parentId,
      parentName: null,
      status: status,
      createdBy: 'Admin User',
      createdAt: ca,
      updatedBy: 'Admin User',
      updatedAt: ua,
    );
  }

  void _applyParentNames() {
    final byId = <String, String>{for (final m in _items) m.id: m.name};
    for (var i = 0; i < _items.length; i++) {
      final m = _items[i];
      final pn = m.parentId == null ? null : byId[m.parentId];
      _items[i] = m.copyWith(parentName: pn);
    }
  }

  Future<List<ModuleModel>> fetchAll() async {
    return List<ModuleModel>.unmodifiable(_items);
  }

  Future<ModuleModel> create({
    required String name,
    String? parentId,
    required ModuleStatus status,
  }) async {
    final now = DateTime.now();
    _idSeq += 1;
    final byId = <String, String>{for (final m in _items) m.id: m.name};
    final parentName = parentId == null ? null : byId[parentId];
    final model = ModuleModel(
      id: 'mod-new-$_idSeq',
      name: name,
      parentId: parentId,
      parentName: parentName,
      status: status,
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items.add(model);
    _applyParentNames();
    return model;
  }

  Future<ModuleModel> update({
    required String id,
    required String name,
    String? parentId,
    required ModuleStatus status,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Module not found: $id');
    }
    if (parentId == id) {
      throw StateError('A module cannot be its own parent.');
    }
    if (parentId != null && _wouldCreateCycle(id, parentId)) {
      throw StateError('Invalid parent: would create a cycle.');
    }
    final prev = _items[i];
    final now = DateTime.now();
    final byId = <String, String>{for (final m in _items) m.id: m.name};
    final parentName = parentId == null ? null : byId[parentId];
    final next = ModuleModel(
      id: prev.id,
      name: name,
      parentId: parentId,
      parentName: parentName,
      status: status,
      createdBy: prev.createdBy,
      createdAt: prev.createdAt,
      updatedBy: 'Admin User',
      updatedAt: now,
      usedInPermissions: prev.usedInPermissions,
    );
    _items[i] = next;
    _applyParentNames();
    return next;
  }

  bool _wouldCreateCycle(String moduleId, String newParentId) {
    var current = newParentId;
    final visited = <String>{};
    while (true) {
      if (current == moduleId) {
        return true;
      }
      if (!visited.add(current)) {
        break;
      }
      ModuleModel? row;
      for (final m in _items) {
        if (m.id == current) {
          row = m;
          break;
        }
      }
      final p = row?.parentId;
      if (p == null) {
        break;
      }
      current = p;
    }
    return false;
  }

  Future<ModuleModel> toggleStatus(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Module not found: $id');
    }
    final prev = _items[i];
    final nextStatus = prev.status == ModuleStatus.active
        ? ModuleStatus.inactive
        : ModuleStatus.active;
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
    final ModuleStatus nextStatus = switch (status) {
      'active' => ModuleStatus.active,
      'inactive' => ModuleStatus.inactive,
      _ => throw ArgumentError('Invalid status: $status'),
    };
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Module not found: $id');
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
      throw StateError('Module not found: $id');
    }
    final row = _items[i];
    if (_items.any((e) => e.parentId == id)) {
      throw StateError('Cannot delete a module that has child modules.');
    }
    if (row.usedInPermissions) {
      throw StateError('Cannot delete a module linked to permissions.');
    }
    _items.removeAt(i);
    _applyParentNames();
  }
}
