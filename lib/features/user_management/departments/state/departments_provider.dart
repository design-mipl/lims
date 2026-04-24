import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/department_model.dart';
import '../data/departments_api.dart';

class DepartmentsProvider extends BaseProvider {
  DepartmentsProvider({DepartmentsApi? api}) : _api = api ?? sl<DepartmentsApi>();

  final DepartmentsApi _api;

  List<DepartmentModel> _items = [];
  String _searchQuery = '';
  DepartmentStatus? _selectedStatusFilter;
  int _currentPage = 1;
  int _pageSize = 10;

  List<DepartmentModel> get items => List<DepartmentModel>.unmodifiable(_items);

  String get searchQuery => _searchQuery;

  DepartmentStatus? get selectedStatusFilter => _selectedStatusFilter;

  int get currentPage => _currentPage;

  /// Clamped page for the current filter and page size (for pagination UI).
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
    if (_selectedStatusFilter == DepartmentStatus.active) {
      return 1;
    }
    return 2;
  }

  int get totalCount => _items.length;

  int get activeCount =>
      _items.where((e) => e.status == DepartmentStatus.active).length;

  int get inactiveCount =>
      _items.where((e) => e.status == DepartmentStatus.inactive).length;

  int get tabAllCount => _items.length;

  List<DepartmentModel> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<DepartmentModel> list = _items;
    if (_selectedStatusFilter != null) {
      list = list.where((e) => e.status == _selectedStatusFilter);
    }
    if (q.isEmpty) {
      return list.toList();
    }
    return list.where((e) {
      final name = e.name.toLowerCase();
      final code = e.code.toLowerCase();
      final desc = (e.description ?? '').toLowerCase();
      return name.contains(q) || code.contains(q) || desc.contains(q);
    }).toList();
  }

  List<DepartmentModel> get pagedRows {
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

  void setStatusFilter(DepartmentStatus? status) {
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

  Future<void> createDepartment({
    required String name,
    required String code,
    String? description,
    required DepartmentStatus status,
  }) async {
    await runAsync(() async {
      await _api.create(
        name: name,
        code: code,
        description: description,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? description,
    required DepartmentStatus status,
  }) async {
    await runAsync(() async {
      await _api.update(
        id: id,
        name: name,
        code: code,
        description: description,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> toggleDepartmentStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> deleteDepartment(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }
}
