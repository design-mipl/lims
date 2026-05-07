import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/lab_code_api.dart';
import '../data/lab_code_model.dart';

class LabCodeProvider extends BaseProvider {
  LabCodeProvider({LabCodeApi? api}) : _api = api ?? sl<LabCodeApi>();

  final LabCodeApi _api;

  List<LabCodeModel> items = <LabCodeModel>[];

  String _searchQuery = '';
  String _statusFilter = LabCodeStatus.pending;
  int _currentPage = 1;
  int _pageSize = 10;

  /// Inclusive bounds for **Lab Id** tab only (`recordedAt` calendar day).
  DateTime? _labIdFromDate;
  DateTime? _labIdToDate;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  DateTime? get labIdFromDate => _labIdFromDate;
  DateTime? get labIdToDate => _labIdToDate;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inLabIdDateRange(LabCodeModel e) {
    final day = _dateOnly(e.recordedAt);
    if (_labIdFromDate != null) {
      final from = _dateOnly(_labIdFromDate!);
      if (day.isBefore(from)) return false;
    }
    if (_labIdToDate != null) {
      final to = _dateOnly(_labIdToDate!);
      if (day.isAfter(to)) return false;
    }
    return true;
  }

  bool _matchesSearch(LabCodeModel e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.sampleId,
      e.labCode ?? '',
      e.customerName,
      e.customerCompany,
      e.sampleType,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<LabCodeModel> get filteredItems {
    Iterable<LabCodeModel> rows =
        items.where((e) => e.status == _statusFilter);
    if (_statusFilter == LabCodeStatus.completed) {
      rows = rows.where(_inLabIdDateRange);
    }
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

  List<LabCodeModel> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  int countForStatus(String status) =>
      items.where((e) => e.status == status).length;

  /// Tab index: 0 = Pending List, 1 = Lab Id
  int get statusTabIndex {
    return switch (_statusFilter) {
      LabCodeStatus.completed => 1,
      _ => 0,
    };
  }

  /// True when the **Lab Id** tab is selected (completed / generated lab codes).
  bool get isLabIdTabSelected => _statusFilter == LabCodeStatus.completed;

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setLabIdFromDate(DateTime date) {
    _labIdFromDate = _dateOnly(date);
    _currentPage = 1;
    notifyListeners();
  }

  void setLabIdToDate(DateTime date) {
    _labIdToDate = _dateOnly(date);
    _currentPage = 1;
    notifyListeners();
  }

  void setStatusFilterByTab(int index) {
    _statusFilter = index == 1 ? LabCodeStatus.completed : LabCodeStatus.pending;
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

  Future<void> deleteItem(String id) async {
    await runAsync(() async {
      await _api.delete(id);
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
