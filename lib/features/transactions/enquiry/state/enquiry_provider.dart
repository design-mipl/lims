import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/enquiry_api.dart';
import '../data/enquiry_model.dart';

class EnquiryProvider extends BaseProvider {
  EnquiryProvider({EnquiryApi? api}) : _api = api ?? sl<EnquiryApi>();

  final EnquiryApi _api;

  List<EnquiryRecord> items = <EnquiryRecord>[];

  EnquiryRecord? detail;

  String _searchQuery = '';
  int _tabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get tabIndex => _tabIndex;

  String _tabStatus(int tabIndex) => switch (tabIndex) {
        0 => EnquiryStatus.pending,
        1 => EnquiryStatus.submitted,
        _ => EnquiryStatus.converted,
      };

  int countForTab(int tabIdx) =>
      items.where((e) => e.status == _tabStatus(tabIdx)).length;

  bool _matchesSearch(EnquiryRecord e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.enquiryNo,
      e.customerName,
      e.siteName,
      e.enquirySource,
      e.typeOfSample,
      e.createdBy,
      e.requestedTestsSummary,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<EnquiryRecord> get filteredItems {
    final status = _tabStatus(_tabIndex);
    Iterable<EnquiryRecord> rows = items.where((e) => e.status == status);
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      rows = rows.where((e) => _matchesSearch(e, q));
    }
    return rows.toList();
  }

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<EnquiryRecord> get pagedRows {
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

  void setTabByIndex(int index) {
    _tabIndex = index;
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

  Future<void> loadItems() async {
    await runAsync(() async {
      items = await _api.fetchAll();
    });
  }

  Future<void> refresh() => loadItems();

  Future<void> loadDetail(String id) async {
    await runAsync(() async {
      detail = await _api.fetchById(id);
    });
  }

  void clearDetail() {
    detail = null;
    notifyListeners();
  }

  Future<void> saveEnquiry(EnquiryRecord record) async {
    await runAsync(() async {
      await _api.upsert(record);
      items = await _api.fetchAll();
      detail = await _api.fetchById(record.id);
    });
  }

  Future<void> submitEnquiry(String id) async {
    await runAsync(() async {
      final e = await _api.fetchById(id);
      if (e == null) return;
      await _api.upsert(e.copyWith(status: EnquiryStatus.submitted));
      items = await _api.fetchAll();
      detail = await _api.fetchById(id);
    });
  }

  Future<void> deleteEnquiry(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      items = await _api.fetchAll();
    });
  }

  Future<void> bulkDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.deleteMany(ids);
      items = await _api.fetchAll();
    });
  }
}
