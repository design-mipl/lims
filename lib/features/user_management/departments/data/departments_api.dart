import 'department_model.dart';

(DateTime createdAt, DateTime updatedAt) _auditPair(int index) {
  final pairs = <(DateTime, DateTime)>[
    (DateTime(2024, 1, 15), DateTime(2024, 3, 20)),
    (DateTime(2024, 2, 10), DateTime(2024, 4, 5)),
    (DateTime(2024, 3, 1), DateTime(2024, 4, 15)),
    (DateTime(2024, 3, 18), DateTime(2024, 5, 2)),
    (DateTime(2024, 4, 8), DateTime(2024, 5, 22)),
    (DateTime(2024, 4, 25), DateTime(2024, 6, 8)),
  ];
  return pairs[index % pairs.length];
}

/// In-memory mock API for departments (no backend).
class DepartmentsApi {
  DepartmentsApi() {
    _items = [
      DepartmentModel(
        id: 'dept-adm',
        name: 'Admin',
        code: 'ADM',
        description: 'System administration',
        usersCount: 2,
        status: DepartmentStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(0).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(0).$2,
      ),
      DepartmentModel(
        id: 'dept-lab',
        name: 'Lab',
        code: 'LAB',
        description: 'Laboratory operations',
        usersCount: 8,
        status: DepartmentStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(1).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(1).$2,
      ),
      DepartmentModel(
        id: 'dept-acc',
        name: 'Accounts',
        code: 'ACC',
        description: 'Billing and finance',
        usersCount: 3,
        status: DepartmentStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(2).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(2).$2,
      ),
      DepartmentModel(
        id: 'dept-sal',
        name: 'Sales',
        code: 'SAL',
        description: 'Sales and customer communication',
        usersCount: 1,
        status: DepartmentStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(3).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(3).$2,
      ),
      DepartmentModel(
        id: 'dept-ops',
        name: 'Operations',
        code: 'OPS',
        description: 'Daily operations',
        usersCount: 4,
        status: DepartmentStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(4).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(4).$2,
      ),
      DepartmentModel(
        id: 'dept-mgt',
        name: 'Management',
        code: 'MGT',
        description: 'Leadership and approvals',
        usersCount: 2,
        status: DepartmentStatus.active,
        createdBy: 'Admin User',
        createdAt: _auditPair(5).$1,
        updatedBy: 'Admin User',
        updatedAt: _auditPair(5).$2,
      ),
    ];
  }

  late final List<DepartmentModel> _items;
  int _idSeq = 0;

  Future<List<DepartmentModel>> fetchAll() async {
    return List<DepartmentModel>.unmodifiable(_items);
  }

  Future<DepartmentModel> create({
    required String name,
    required String code,
    String? description,
    required DepartmentStatus status,
  }) async {
    final now = DateTime.now();
    _idSeq += 1;
    final model = DepartmentModel(
      id: 'dept-new-$_idSeq',
      name: name,
      code: code,
      description: description,
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

  Future<DepartmentModel> update({
    required String id,
    required String name,
    required String code,
    String? description,
    required DepartmentStatus status,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Department not found: $id');
    }
    final prev = _items[i];
    final now = DateTime.now();
    final next = DepartmentModel(
      id: prev.id,
      name: name,
      code: code,
      description: description,
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

  Future<DepartmentModel> toggleStatus(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Department not found: $id');
    }
    final prev = _items[i];
    final nextStatus = prev.status == DepartmentStatus.active
        ? DepartmentStatus.inactive
        : DepartmentStatus.active;
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
    final DepartmentStatus nextStatus = switch (status) {
      'active' => DepartmentStatus.active,
      'inactive' => DepartmentStatus.inactive,
      _ => throw ArgumentError('Invalid status: $status'),
    };
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) {
      throw StateError('Department not found: $id');
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
      throw StateError('Department not found: $id');
    }
    final row = _items[i];
    if (row.usersCount > 0) {
      throw StateError(
        'Cannot delete department while it has assigned users.',
      );
    }
    _items.removeAt(i);
  }
}
