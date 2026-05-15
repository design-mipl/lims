import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/quotation_api.dart';
import '../data/quotation_model.dart';

class QuotationProvider extends BaseProvider {
  QuotationProvider({QuotationApi? api}) : _api = api ?? sl<QuotationApi>();

  final QuotationApi _api;

  List<QuotationRecord> items = <QuotationRecord>[];
  QuotationRecord? active;

  String _searchQuery = '';
  int _tabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get tabIndex => _tabIndex;

  bool _inTab(QuotationRecord q, int tab) {
    switch (tab) {
      case 0:
        return q.status == QuotationStatus.pendingPrep ||
            q.status == QuotationStatus.changesRequested;
      case 1:
        return q.status == QuotationStatus.inReview;
      default:
        return q.status == QuotationStatus.approved;
    }
  }

  int countForTab(int tabIdx) => items.where((q) => _inTab(q, tabIdx)).length;

  bool _matchesSearch(QuotationRecord q, String query) {
    if (query.isEmpty) return true;
    final buckets = <String>[
      q.quoteNo,
      q.enquiryNo,
      q.customerName,
      q.siteName,
      q.typeOfSample,
      q.preparedBy,
    ];
    return buckets.any((s) => s.toLowerCase().contains(query));
  }

  List<QuotationRecord> get filteredItems {
    Iterable<QuotationRecord> rows = items.where((q) => _inTab(q, _tabIndex));
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      rows = rows.where((e) => _matchesSearch(e, q));
    }
    return rows.toList();
  }

  /// Approved-only listing (Phase 7 screen).
  List<QuotationRecord> get approvedOnly {
    Iterable<QuotationRecord> rows =
        items.where((q) => q.status == QuotationStatus.approved);
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

  int effectiveApprovedPage(int total) {
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<QuotationRecord> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  List<QuotationRecord> pagedApprovedRows() {
    final all = approvedOnly;
    if (all.isEmpty) return const [];
    final page = effectiveApprovedPage(all.length);
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

  Future<void> loadQuote(String id) async {
    await runAsync(() async {
      active = await _api.fetchById(id);
    });
  }

  void setActiveLocal(QuotationRecord q) {
    active = q;
    notifyListeners();
  }

  Future<void> persistActive() async {
    final q = active;
    if (q == null) return;
    await runAsync(() async {
      await _api.upsert(q);
      items = await _api.fetchAll();
      active = await _api.fetchById(q.id);
    });
  }

  Future<void> deleteQuote(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      items = await _api.fetchAll();
      if (active?.id == id) active = null;
    });
  }

  Future<void> bulkDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.deleteMany(ids);
      items = await _api.fetchAll();
    });
  }

  Future<void> sendToSalesReview(String id) async {
    await runAsync(() async {
      await _api.sendToSalesReview(id);
      items = await _api.fetchAll();
      active = await _api.fetchById(id);
    });
  }

  Future<void> approveQuote(String id, {double? discountOverride}) async {
    await runAsync(() async {
      await _api.approve(id, discountOverride: discountOverride);
      items = await _api.fetchAll();
      active = await _api.fetchById(id);
    });
  }

  Future<void> requestChangesQuote(String id, String note) async {
    await runAsync(() async {
      await _api.requestChanges(id, note);
      items = await _api.fetchAll();
      active = await _api.fetchById(id);
    });
  }

  Future<void> convertToOrder(String id) async {
    await runAsync(() async {
      await _api.convertToOrder(id);
      items = await _api.fetchAll();
      active = await _api.fetchById(id);
    });
  }

  Future<QuotationRecord?> createFromEnquiry(String enquiryId) async {
    QuotationRecord? created;
    await runAsync(() async {
      created = await _api.createDraftFromEnquiry(enquiryId);
      items = await _api.fetchAll();
    });
    return created;
  }

  void replaceLine(String quoteId, QuotationPricingLine line) {
    final q = active;
    if (q == null || q.id != quoteId) return;
    final lines = q.lines
        .map((l) => l.id == line.id ? line : l)
        .toList(growable: false);
    active = q.copyWith(lines: lines);
    notifyListeners();
  }

  void toggleLineSelected(String quoteId, String lineId, bool selected) {
    final q = active;
    if (q == null || q.id != quoteId) return;
    final lines = q.lines
        .map(
          (l) => l.id == lineId ? l.copyWith(selected: selected) : l,
        )
        .toList(growable: false);
    active = q.copyWith(lines: lines);
    notifyListeners();
  }

  void setCommercial({
    required String quoteId,
    double? discountAmount,
    double? gstPercent,
    String? terms,
    String? notes,
    String? internalComments,
    List<String>? attachmentNames,
  }) {
    final q = active;
    if (q == null || q.id != quoteId) return;
    active = q.copyWith(
      discountAmount: discountAmount ?? q.discountAmount,
      gstPercent: gstPercent ?? q.gstPercent,
      terms: terms ?? q.terms,
      notes: notes ?? q.notes,
      internalComments: internalComments ?? q.internalComments,
      attachmentNames: attachmentNames ?? q.attachmentNames,
    );
    notifyListeners();
  }

  void setDiscussionNotes(String quoteId, String note) {
    final q = active;
    if (q == null || q.id != quoteId) return;
    active = q.copyWith(discussionNotes: note);
    notifyListeners();
  }
}
