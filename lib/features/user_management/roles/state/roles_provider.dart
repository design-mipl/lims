import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/role_model.dart';
import '../data/roles_api.dart';

class RolesProvider extends BaseProvider {
  RolesProvider({RolesApi? api}) : _api = api ?? sl<RolesApi>();

  final RolesApi _api;

  List<RoleModel> _items = [];
  String _searchQuery = '';
  RoleStatus? _selectedStatusFilter;
  int _currentPage = 1;
  int _pageSize = 10;

  List<RoleModel> get items => List<RoleModel>.unmodifiable(_items);

  String get searchQuery => _searchQuery;

  RoleStatus? get selectedStatusFilter => _selectedStatusFilter;

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
    if (_selectedStatusFilter == RoleStatus.active) {
      return 1;
    }
    return 2;
  }

  int get totalCount => _items.length;

  int get activeCount =>
      _items.where((e) => e.status == RoleStatus.active).length;

  int get inactiveCount =>
      _items.where((e) => e.status == RoleStatus.inactive).length;

  int get tabAllCount => _items.length;

  List<RoleModel> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<RoleModel> list = _items;
    if (_selectedStatusFilter != null) {
      list = list.where((e) => e.status == _selectedStatusFilter);
    }
    if (q.isEmpty) {
      return list.toList();
    }
    return list.where((e) {
      final name = e.name.toLowerCase();
      final desc = (e.description ?? '').toLowerCase();
      final levelLabel = RoleModel.labelForLevel(e.level).toLowerCase();
      return name.contains(q) || desc.contains(q) || levelLabel.contains(q);
    }).toList();
  }

  List<RoleModel> get pagedRows {
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

  void setStatusFilter(RoleStatus? status) {
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

  Future<void> createRole({
    required String name,
    required int level,
    String? description,
    required RoleType type,
    required RoleStatus status,
  }) async {
    await runAsync(() async {
      await _api.create(
        name: name,
        level: level,
        description: description,
        type: type,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> updateRole({
    required String id,
    required String name,
    required int level,
    String? description,
    required RoleType type,
    required RoleStatus status,
  }) async {
    await runAsync(() async {
      await _api.update(
        id: id,
        name: name,
        level: level,
        description: description,
        type: type,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> toggleRoleStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> deleteRole(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }
}
