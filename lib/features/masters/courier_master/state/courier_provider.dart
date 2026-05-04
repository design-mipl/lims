import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/courier_api.dart';
import '../data/courier_model.dart';

class CourierProvider extends BaseProvider {
  CourierProvider({CourierApi? api}) : _api = api ?? sl<CourierApi>();

  final CourierApi _api;

  List<CourierModel> couriers = <CourierModel>[];
  CourierModel? selected;
  bool saving = false;

  String _searchQuery = '';
  String _statusFilter = 'all';
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  bool _matchesSearch(CourierModel e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.companyName,
      e.personName,
      e.city,
      e.state,
      ...e.emails,
      ...e.mobiles,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<CourierModel> get filteredItems {
    Iterable<CourierModel> items = couriers;
    if (_statusFilter == 'active') {
      items = items.where((e) => e.status == 'active');
    } else if (_statusFilter == 'inactive') {
      items = items.where((e) => e.status == 'inactive');
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) => _matchesSearch(e, q));
    }
    return items.toList();
  }

  int get activeCount => couriers.where((e) => e.status == 'active').length;
  int get inactiveCount =>
      couriers.where((e) => e.status == 'inactive').length;

  int get statusTabIndex =>
      _statusFilter == 'all' ? 0 : (_statusFilter == 'active' ? 1 : 2);

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<CourierModel> get pagedRows {
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
      couriers = await _api.fetchAll();
    });
  }

  Future<void> fetchById(String id) async {
    await runAsync(() async {
      selected = await _api.fetchById(id);
    });
  }

  Future<CourierModel?> create(Map<String, dynamic> data) async {
    CourierModel? created;
    await runAsync(() async {
      saving = true;
      notifyListeners();
      created = await _api.create(data);
      couriers = await _api.fetchAll();
      selected = created;
      saving = false;
      notifyListeners();
    });
    return created;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await runAsync(() async {
      saving = true;
      notifyListeners();
      await _api.update(id, data);
      couriers = await _api.fetchAll();
      if (selected?.id == id) {
        selected = await _api.fetchById(id);
      }
      saving = false;
      notifyListeners();
    });
  }

  Future<void> delete(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      couriers = await _api.fetchAll();
      if (selected?.id == id) {
        selected = null;
      }
    });
  }

  Future<void> toggleStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      couriers = await _api.fetchAll();
      if (selected?.id == id) {
        selected = await _api.fetchById(id);
      }
    });
  }

  Future<void> bulkActivate(List<String> ids) async {
    await runAsync(() async {
      await _api.bulkActivate(ids);
      couriers = await _api.fetchAll();
    });
  }

  Future<void> bulkDeactivate(List<String> ids) async {
    await runAsync(() async {
      await _api.bulkDeactivate(ids);
      couriers = await _api.fetchAll();
    });
  }

  Future<void> bulkDelete(List<String> ids) async {
    await runAsync(() async {
      await _api.bulkDelete(ids);
      couriers = await _api.fetchAll();
      if (selected != null && ids.contains(selected!.id)) {
        selected = null;
      }
    });
  }

  /// Code unique among current list (excluding [excludeCourierId] when editing).
  bool isCodeUnique(String code, {String? excludeCourierId}) {
    final t = code.trim().toLowerCase();
    if (t.isEmpty) return false;
    for (final c in couriers) {
      if (excludeCourierId != null && c.id == excludeCourierId) continue;
      if (c.code.trim().toLowerCase() == t) return false;
    }
    return true;
  }
}
