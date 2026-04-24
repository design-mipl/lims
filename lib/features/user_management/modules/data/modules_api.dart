import 'module_model.dart';

/// In-memory mock API for navigation modules (no backend).
class ModulesApi {
  ModulesApi() {
    final t = DateTime.utc(2024, 1, 1);
    _items = [
      ModuleModel(
        id: 'mod-dashboard',
        name: 'Dashboard',
        code: 'DASH',
        parentId: null,
        route: '/dashboard',
        icon: 'layoutDashboard',
        sortOrder: 10,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-transactions',
        name: 'Transactions',
        code: 'TXN',
        parentId: null,
        route: '/transactions',
        icon: 'fileStack',
        sortOrder: 20,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-sample-receipt',
        name: 'Sample Receipt',
        code: 'TXN_SR',
        parentId: 'mod-transactions',
        route: '/transactions/sample-receipt',
        icon: 'clipboardList',
        sortOrder: 10,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-lab-code',
        name: 'Lab Code',
        code: 'TXN_LC',
        parentId: 'mod-transactions',
        route: '/transactions/lab-code',
        icon: 'flaskConical',
        sortOrder: 20,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-masters',
        name: 'Masters',
        code: 'MST',
        parentId: null,
        route: '/masters',
        icon: 'database',
        sortOrder: 30,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-customer',
        name: 'Customer',
        code: 'MST_CUST',
        parentId: 'mod-masters',
        route: '/masters/customer',
        icon: 'users',
        sortOrder: 10,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-site',
        name: 'Site',
        code: 'MST_SITE',
        parentId: 'mod-masters',
        route: '/masters/site',
        icon: 'mapPin',
        sortOrder: 20,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-user-mgmt',
        name: 'User Management',
        code: 'UM',
        parentId: null,
        route: '/user-management',
        icon: 'userCog',
        sortOrder: 40,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-departments',
        name: 'Departments',
        code: 'UM_DEPT',
        parentId: 'mod-user-mgmt',
        route: '/user-management/departments',
        icon: 'building2',
        sortOrder: 10,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-users',
        name: 'Users',
        code: 'UM_USERS',
        parentId: 'mod-user-mgmt',
        route: '/user-management/users',
        icon: 'users',
        sortOrder: 20,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-roles',
        name: 'Roles',
        code: 'UM_ROLES',
        parentId: 'mod-user-mgmt',
        route: '/user-management/roles',
        icon: 'shield',
        sortOrder: 30,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
      ModuleModel(
        id: 'mod-modules',
        name: 'Modules',
        code: 'UM_MOD',
        parentId: 'mod-user-mgmt',
        route: '/user-management/modules',
        icon: 'layers',
        sortOrder: 40,
        showInNavigation: true,
        permissionEnabled: true,
        status: ModuleStatus.active,
        createdAt: t,
        updatedAt: t,
      ),
    ];
  }

  late final List<ModuleModel> _items;
  int _idSeq = 0;

  Future<List<ModuleModel>> fetchAll() async {
    return List<ModuleModel>.unmodifiable(_items);
  }

  Future<ModuleModel> create({
    required String name,
    required String code,
    String? parentId,
    required String route,
    required String icon,
    required int sortOrder,
    required bool showInNavigation,
    required bool permissionEnabled,
    required ModuleStatus status,
  }) async {
    final now = DateTime.now();
    _idSeq += 1;
    final model = ModuleModel(
      id: 'mod-new-$_idSeq',
      name: name,
      code: code,
      parentId: parentId,
      route: route,
      icon: icon,
      sortOrder: sortOrder,
      showInNavigation: showInNavigation,
      permissionEnabled: permissionEnabled,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(model);
    return model;
  }

  Future<ModuleModel> update({
    required String id,
    required String name,
    required String code,
    String? parentId,
    required String route,
    required String icon,
    required int sortOrder,
    required bool showInNavigation,
    required bool permissionEnabled,
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
    final next = ModuleModel(
      id: prev.id,
      name: name,
      code: code,
      parentId: parentId,
      route: route,
      icon: icon,
      sortOrder: sortOrder,
      showInNavigation: showInNavigation,
      permissionEnabled: permissionEnabled,
      status: status,
      createdAt: prev.createdAt,
      updatedAt: now,
      usedInPermissions: prev.usedInPermissions,
    );
    _items[i] = next;
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
  }
}
