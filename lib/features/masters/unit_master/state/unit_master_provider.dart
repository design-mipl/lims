import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../shared/master_status.dart';
import '../data/unit_master_api.dart';
import '../models/unit_master_model.dart';

class UnitMasterProvider extends BaseProvider {
  UnitMasterProvider({UnitMasterApi? api}) : _api = api ?? sl<UnitMasterApi>();

  final UnitMasterApi _api;

  List<UnitMasterModel> _items = [];
  String _searchQuery = '';
  MasterStatus? _selectedStatusFilter;
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;

  int get effectiveCurrentPage {
    final n = filteredItems.length;
    if (n == 0) return 1;
    final lastPage = ((n - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, lastPage);
  }

  int get pageSize => _pageSize;

  int get statusTabIndex {
    if (_selectedStatusFilter == null) return 0;
    if (_selectedStatusFilter == MasterStatus.active) return 1;
    return 2;
  }

  int get activeCount =>
      _items.where((e) => e.status == MasterStatus.active).length;

  int get inactiveCount =>
      _items.where((e) => e.status == MasterStatus.inactive).length;

  List<UnitMasterModel> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<UnitMasterModel> list = _items;
    if (_selectedStatusFilter != null) {
      list = list.where((e) => e.status == _selectedStatusFilter);
    }
    if (q.isEmpty) return list.toList();
    return list.where((e) {
      return e.code.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q);
    }).toList();
  }

  List<UnitMasterModel> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return [];
    final lastPage = ((all.length - 1) ~/ _pageSize) + 1;
    var page = _currentPage;
    if (page > lastPage) page = lastPage;
    if (page < 1) page = 1;
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
    if (_currentPage > lastPage) _currentPage = lastPage;
    if (_currentPage < 1) _currentPage = 1;
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

  void setStatusFilter(MasterStatus? status) {
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

  Future<void> create({
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    await runAsync(() async {
      await _api.create(code: code, name: name, status: status);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> update({
    required String id,
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    await runAsync(() async {
      await _api.update(
        id: id,
        code: code,
        name: name,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> toggleStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> delete(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> bulkActivate(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        await _api.updateStatus(id, 'active');
      }
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> bulkDeactivate(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        await _api.updateStatus(id, 'inactive');
      }
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> bulkDelete(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        await _api.delete(id);
      }
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }
}
