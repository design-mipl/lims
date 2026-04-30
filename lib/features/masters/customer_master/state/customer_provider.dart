import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/customer_api.dart';
import '../data/customer_model.dart';

class CustomerProvider extends BaseProvider {
  CustomerProvider({CustomerApi? api}) : _api = api ?? sl<CustomerApi>();

  final CustomerApi _api;

  List<CustomerModel> customers = <CustomerModel>[];
  CustomerModel? selected;
  bool saving = false;

  String _searchQuery = '';
  String _statusFilter = 'all';
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  List<CustomerModel> get filteredItems {
    Iterable<CustomerModel> items = customers;
    if (_statusFilter == 'active') {
      items = items.where((e) => e.status == 'active');
    } else if (_statusFilter == 'inactive') {
      items = items.where((e) => e.status == 'inactive');
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) {
        return e.companyName.toLowerCase().contains(q) ||
            (e.gstNo ?? '').toLowerCase().contains(q);
      });
    }
    return items.toList();
  }

  int get activeCount => customers.where((e) => e.status == 'active').length;
  int get inactiveCount =>
      customers.where((e) => e.status == 'inactive').length;
  int get statusTabIndex =>
      _statusFilter == 'all' ? 0 : (_statusFilter == 'active' ? 1 : 2);

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<CustomerModel> get pagedRows {
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
      customers = await _api.fetchAll();
    });
  }

  Future<void> fetchById(String id) async {
    await runAsync(() async {
      selected = await _api.fetchById(id);
    });
  }

  Future<void> create(Map<String, dynamic> data) async {
    await runAsync(() async {
      saving = true;
      await _api.create(data);
      customers = await _api.fetchAll();
      saving = false;
    });
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await runAsync(() async {
      saving = true;
      await _api.update(id, data);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(id);
      saving = false;
    });
  }

  Future<void> delete(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      customers = await _api.fetchAll();
    });
  }

  Future<void> toggleStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      customers = await _api.fetchAll();
      if (selected?.id == id) {
        selected = await _api.fetchById(id);
      }
    });
  }

  Future<void> addContact(String customerId, Map<String, dynamic> data) async {
    await runAsync(() async {
      await _api.addContact(customerId, data);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(customerId);
    });
  }

  Future<void> updateContact(
    String customerId,
    String contactId,
    Map<String, dynamic> data,
  ) async {
    await runAsync(() async {
      await _api.updateContact(customerId, contactId, data);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(customerId);
    });
  }

  Future<void> deleteContact(String customerId, String contactId) async {
    await runAsync(() async {
      await _api.deleteContact(customerId, contactId);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(customerId);
    });
  }

  Future<void> addSampleRow(
    String customerId,
    Map<String, dynamic> data,
  ) async {
    await runAsync(() async {
      await _api.addSampleRow(customerId, data);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(customerId);
    });
  }

  Future<void> updateSampleRow(
    String customerId,
    String rowId,
    Map<String, dynamic> data,
  ) async {
    await runAsync(() async {
      await _api.updateSampleRow(customerId, rowId, data);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(customerId);
    });
  }

  Future<void> deleteSampleRow(String customerId, String rowId) async {
    await runAsync(() async {
      await _api.deleteSampleRow(customerId, rowId);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(customerId);
    });
  }

  Future<void> clearAllSamples(String id) async {
    await runAsync(() async {
      await _api.clearAllSamples(id);
      customers = await _api.fetchAll();
      selected = await _api.fetchById(id);
    });
  }

  Future<void> bulkActivate(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        final item = await _api.fetchById(id);
        if (item.status != 'active') {
          await _api.toggleStatus(id);
        }
      }
      customers = await _api.fetchAll();
    });
  }

  Future<void> bulkDeactivate(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        final item = await _api.fetchById(id);
        if (item.status != 'inactive') {
          await _api.toggleStatus(id);
        }
      }
      customers = await _api.fetchAll();
    });
  }

  Future<void> bulkDelete(List<String> ids) async {
    await runAsync(() async {
      for (final id in ids) {
        await _api.delete(id);
      }
      customers = await _api.fetchAll();
    });
  }
}
