import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/module_model.dart';
import '../data/modules_api.dart';

class ModulesProvider extends BaseProvider {
  ModulesProvider({ModulesApi? api}) : _api = api ?? sl<ModulesApi>();

  final ModulesApi _api;

  List<ModuleModel> _items = [];
  String _searchQuery = '';
  ModuleStatus? _selectedStatusFilter;
  int _currentPage = 1;
  int _pageSize = 10;

  List<ModuleModel> get items => List<ModuleModel>.unmodifiable(_items);

  String get searchQuery => _searchQuery;

  ModuleStatus? get selectedStatusFilter => _selectedStatusFilter;

  int get currentPage => _currentPage;

  int get effectiveCurrentPage {
    final n = filteredItems.length;
    if (n == 0) {
      return 1;
    }
    final lastPage = ((n - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, lastPage);
  }

  int get pageSize => _pageSize;

  int get statusTabIndex {
    if (_selectedStatusFilter == null) {
      return 0;
    }
    if (_selectedStatusFilter == ModuleStatus.active) {
      return 1;
    }
    return 2;
  }

  int get totalCount => _items.length;

  int get activeCount =>
      _items.where((e) => e.status == ModuleStatus.active).length;

  int get inactiveCount =>
      _items.where((e) => e.status == ModuleStatus.inactive).length;

  int get tabAllCount => _items.length;

  String? parentNameFor(String? parentId) {
    if (parentId == null) {
      return null;
    }
    for (final m in _items) {
      if (m.id == parentId) {
        return m.name;
      }
    }
    return null;
  }

  bool moduleCanDelete(ModuleModel m) => m.canDeleteAmong(_items);

  List<ModuleModel> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<ModuleModel> list = _items;
    if (_selectedStatusFilter != null) {
      list = list.where((e) => e.status == _selectedStatusFilter);
    }
    if (q.isEmpty) {
      return list.toList();
    }
    return list.where((e) {
      final name = e.name.toLowerCase();
      final code = e.code.toLowerCase();
      final route = e.route.toLowerCase();
      final parent = (parentNameFor(e.parentId) ?? '').toLowerCase();
      return name.contains(q) ||
          code.contains(q) ||
          route.contains(q) ||
          parent.contains(q);
    }).toList();
  }

  List<ModuleModel> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) {
      return [];
    }
    final lastPage = ((all.length - 1) ~/ _pageSize) + 1;
    var page = _currentPage;
    if (page > lastPage) {
      page = lastPage;
    }
    if (page < 1) {
      page = 1;
    }
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void _clampCurrentPage() {
    final n = filteredItems.length;
    if (n == 0) {
      _currentPage = 1;
      return;
    }
    final lastPage = ((n - 1) ~/ _pageSize) + 1;
    if (_currentPage > lastPage) {
      _currentPage = lastPage;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }
  }

  Future<void> fetchAll() async {
    await runAsync(() async {
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setStatusFilter(ModuleStatus? status) {
    _selectedStatusFilter = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> createModule({
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
    await runAsync(() async {
      await _api.create(
        name: name,
        code: code,
        parentId: parentId,
        route: route,
        icon: icon,
        sortOrder: sortOrder,
        showInNavigation: showInNavigation,
        permissionEnabled: permissionEnabled,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> updateModule({
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
    await runAsync(() async {
      await _api.update(
        id: id,
        name: name,
        code: code,
        parentId: parentId,
        route: route,
        icon: icon,
        sortOrder: sortOrder,
        showInNavigation: showInNavigation,
        permissionEnabled: permissionEnabled,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> toggleModuleStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> deleteModule(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }
}
