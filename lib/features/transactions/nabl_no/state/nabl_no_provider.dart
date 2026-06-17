import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/nabl_no_api.dart';
import '../data/nabl_no_model.dart';

class NablNoProvider extends BaseProvider {
  NablNoProvider({NablNoApi? api}) : _api = api ?? sl<NablNoApi>();

  final NablNoApi _api;

  List<NablNoRow> items = <NablNoRow>[];

  String _searchQuery = '';
  int _subTabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  DateTime? _fromDate;
  DateTime? _toDate;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get subTabIndex => _subTabIndex;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inNablDateRange(NablNoRow e) {
    final day = _dateOnly(e.nablDate);
    if (_fromDate != null) {
      final from = _dateOnly(_fromDate!);
      if (day.isBefore(from)) return false;
    }
    if (_toDate != null) {
      final to = _dateOnly(_toDate!);
      if (day.isAfter(to)) return false;
    }
    return true;
  }

  int get pendingCount =>
      items.where((e) => e.status == NablNoStatus.pending).length;

  int get authenticatedCount =>
      items.where((e) => e.status == NablNoStatus.authenticated).length;

  int get duplicateCount =>
      items.where((e) => e.status == NablNoStatus.duplicate).length;

  bool _matchesSubTab(NablNoRow e) {
    return switch (_subTabIndex) {
      0 => e.status == NablNoStatus.pending,
      1 => e.status == NablNoStatus.authenticated,
      _ => e.status == NablNoStatus.duplicate,
    };
  }

  bool _matchesSearch(NablNoRow e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.nablNo,
      e.lcNo,
      e.typeOfSample,
      e.customerName,
      e.sampleId,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<NablNoRow> get filteredItems {
    var rows = items.where(_matchesSubTab).where(_inNablDateRange);
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      rows = rows.where((e) => _matchesSearch(e, q));
    }
    return rows.toList();
  }

  /// Rows matching status tab, search, and NABL date range (full result set).
  List<NablNoRow> get exportRows => filteredItems;

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<NablNoRow> get pagedRows {
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

  void setSubTabByIndex(int index) {
    _subTabIndex = index;
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

  void setFromDate(DateTime date) {
    _fromDate = _dateOnly(date);
    _currentPage = 1;
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = _dateOnly(date);
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> authorizeItems(List<String> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.authorizeMany(ids);
      items = await _api.fetchAll();
    });
  }

  Future<void> loadItems() async {
    await runAsync(() async {
      items = await _api.fetchAll();
    });
  }

  Future<void> bulkDeleteItems(List<dynamic> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.deleteMany(ids.cast<String>());
      items = await _api.fetchAll();
    });
  }
}
