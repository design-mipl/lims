import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/plant_api.dart';
import '../data/plant_model.dart';

class PlantProvider extends BaseProvider {
  PlantProvider({PlantApi? api}) : _api = api ?? sl<PlantApi>();

  final PlantApi _api;

  List<PlantModel> plants = <PlantModel>[];
  bool saving = false;

  String _searchQuery = '';
  String _statusFilter = 'all';
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  List<PlantModel> get filteredItems {
    Iterable<PlantModel> items = plants;
    if (_statusFilter == 'active') {
      items = items.where((e) => e.status == 'active');
    } else if (_statusFilter == 'inactive') {
      items = items.where((e) => e.status == 'inactive');
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) {
        return e.code.toLowerCase().contains(q) ||
            e.plant.toLowerCase().contains(q);
      });
    }
    return items.toList();
  }

  int get activeCount => plants.where((e) => e.status == 'active').length;
  int get inactiveCount => plants.where((e) => e.status == 'inactive').length;

  int get statusTabIndex =>
      _statusFilter == 'all' ? 0 : (_statusFilter == 'active' ? 1 : 2);

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<PlantModel> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setStatusFilterByTab(int index) {
    if (index == 1) {
      _statusFilter = 'active';
    } else if (index == 2) {
      _statusFilter = 'inactive';
    } else {
      _statusFilter = 'all';
    }
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

  Future<void> fetchAll() async {
    await runAsync(() async {
      plants = await _api.fetchAll();
    });
  }

  Future<void> create(Map<String, dynamic> data) async {
    await runAsync(() async {
      saving = true;
      notifyListeners();
      await _api.create(data);
      plants = await _api.fetchAll();
      saving = false;
      notifyListeners();
    });
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await runAsync(() async {
      saving = true;
      notifyListeners();
      await _api.update(id, data);
      plants = await _api.fetchAll();
      saving = false;
      notifyListeners();
    });
  }

  Future<void> delete(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      plants = await _api.fetchAll();
    });
  }

  Future<void> toggleStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      plants = await _api.fetchAll();
    });
  }

  Future<void> bulkActivate(List<String> ids) async {
    await runAsync(() async {
      var list = await _api.fetchAll();
      for (final id in ids) {
        PlantModel? row;
        for (final e in list) {
          if (e.id == id) {
            row = e;
            break;
          }
        }
        if (row != null && row.status != 'active') {
          await _api.toggleStatus(id);
          list = await _api.fetchAll();
        }
      }
      plants = await _api.fetchAll();
    });
  }

  Future<void> bulkDeactivate(List<String> ids) async {
    await runAsync(() async {
      var list = await _api.fetchAll();
      for (final id in ids) {
        PlantModel? row;
        for (final e in list) {
          if (e.id == id) {
            row = e;
            break;
          }
        }
        if (row != null && row.status != 'inactive') {
          await _api.toggleStatus(id);
          list = await _api.fetchAll();
        }
      }
      plants = await _api.fetchAll();
    });
  }

  Future<void> bulkDelete(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        await _api.delete(id);
      }
      plants = await _api.fetchAll();
    });
  }
}
