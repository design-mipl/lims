import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../shared/lab_manager_listing_row.dart';
import '../data/lab_manager_certification_api.dart';

class LabManagerCertificationProvider extends BaseProvider {
  LabManagerCertificationProvider({LabManagerCertificationApi? api})
      : _api = api ?? sl<LabManagerCertificationApi>();

  final LabManagerCertificationApi _api;

  List<LabManagerListingRow> items = <LabManagerListingRow>[];

  String _searchQuery = '';
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  bool _matchesSearch(LabManagerListingRow e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.companyName,
      e.siteName,
      e.typeOfSample,
      e.lotNo,
      e.labId,
      e.sampleId,
      e.make,
      e.model,
      e.serialNo,
      e.reportId,
      e.referenceNo,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<LabManagerListingRow> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List<LabManagerListingRow>.from(items);
    return items.where((e) => _matchesSearch(e, q)).toList();
  }

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<LabManagerListingRow> get pagedRows {
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

  Future<void> bulkDeleteRows(List<dynamic> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.deleteMany(ids.cast<String>());
      items = await _api.fetchAll();
    });
  }

  Future<void> bulkSetVerified(List<dynamic> ids, bool verified) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.setVerifiedForIds(ids.cast<String>(), verified);
      items = await _api.fetchAll();
    });
  }
}
