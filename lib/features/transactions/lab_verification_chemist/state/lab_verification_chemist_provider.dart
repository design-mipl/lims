import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/lab_verification_chemist_api.dart';
import '../data/lab_verification_chemist_model.dart';

class LabVerificationChemistProvider extends BaseProvider {
  LabVerificationChemistProvider({LabVerificationChemistApi? api})
      : _api = api ?? sl<LabVerificationChemistApi>();

  final LabVerificationChemistApi _api;

  List<LabVerificationChemistModel> items = <LabVerificationChemistModel>[];

  /// Detail view selection (same pattern as [LabCodeProvider]).
  LabVerificationChemistModel? selected;

  String _searchQuery = '';
  int _tabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  int get tabIndex => _tabIndex;

  int get pendingCount =>
      items.where((e) => !e.verified).length;

  int get completeCount =>
      items.where((e) => e.verified).length;

  bool _matchesSearch(LabVerificationChemistModel e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.typeOfSample,
      e.labId,
      e.customerName,
      e.customerCompany,
      e.lotNo,
      e.sampleId,
      e.make,
      e.model,
      e.serialNo,
      e.reportId,
      e.equipmentNo,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<LabVerificationChemistModel> get filteredItems {
    Iterable<LabVerificationChemistModel> rows = items;
    if (_tabIndex == 0) {
      rows = rows.where((e) => !e.verified);
    } else {
      rows = rows.where((e) => e.verified);
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

  List<LabVerificationChemistModel> get pagedRows {
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

  Future<void> loadItemForView(String id) async {
    await runAsync(() async {
      selected = await _api.fetchById(id);
      notifyListeners();
    });
  }

  Future<void> verifyRows(List<dynamic> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.verifyIds(ids.cast<String>());
      items = await _api.fetchAll();
      final idSet = ids.cast<String>().toSet();
      if (selected != null && idSet.contains(selected!.id)) {
        selected = await _api.fetchById(selected!.id);
      }
    });
  }

  Future<void> verifyChemistTestLine(String parentId, int lineNo) async {
    await runAsync(() async {
      await _api.verifyTestLine(parentId, lineNo);
      items = await _api.fetchAll();
      if (selected?.id == parentId) {
        selected = await _api.fetchById(parentId);
      }
    });
  }
}
