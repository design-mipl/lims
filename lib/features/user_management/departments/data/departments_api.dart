import 'department_model.dart';

/// In-memory mock API for departments (no backend).
class DepartmentsApi {
  DepartmentsApi() {
    final t = DateTime.utc(2024, 1, 1);
    _items = [
      DepartmentModel(
        id: 'dept-adm',
        name: 'Admin',
        code: 'ADM',
        description: 'System administration',
        usersCount: 2,
        status: DepartmentStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      DepartmentModel(
        id: 'dept-lab',
        name: 'Lab',
        code: 'LAB',
        description: 'Laboratory operations',
        usersCount: 8,
        status: DepartmentStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      DepartmentModel(
        id: 'dept-acc',
        name: 'Accounts',
        code: 'ACC',
        description: 'Billing and finance',
        usersCount: 3,
        status: DepartmentStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      DepartmentModel(
        id: 'dept-sal',
        name: 'Sales',
        code: 'SAL',
        description: 'Sales and customer communication',
        usersCount: 1,
        status: DepartmentStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      DepartmentModel(
        id: 'dept-ops',
        name: 'Operations',
        code: 'OPS',
        description: 'Daily operations',
        usersCount: 4,
        status: DepartmentStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      DepartmentModel(
        id: 'dept-mgt',
        name: 'Management',
        code: 'MGT',
        description: 'Leadership and approvals',
        usersCount: 2,
        status: DepartmentStatus.active,
        createdAt: t,
        updatedAt: t,
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
      createdAt: now,
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
      createdAt: prev.createdAt,
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
