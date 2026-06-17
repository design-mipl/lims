import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../quotation/data/quotation_model.dart';
import '../data/order_api.dart';
import '../data/order_model.dart';

class OrderProvider extends BaseProvider {
  OrderProvider({OrderApi? api}) : _api = api ?? sl<OrderApi>();

  final OrderApi _api;

  List<QuotationRecord> pendingQuotations = <QuotationRecord>[];
  List<OrderRecord> confirmedOrders = <OrderRecord>[];

  String _searchQuery = '';
  int _tabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get tabIndex => _tabIndex;

  int get pendingCount => pendingQuotations.length;
  int get confirmedCount => confirmedOrders.length;

  bool _matchesPending(QuotationRecord q, String query) {
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

  bool _matchesOrder(OrderRecord o, String query) {
    if (query.isEmpty) return true;
    final buckets = <String>[
      o.orderNo,
      o.quoteNo,
      o.enquiryNo,
      o.customerName,
      o.status,
      o.updatedBy,
    ];
    return buckets.any((s) => s.toLowerCase().contains(query));
  }

  List<QuotationRecord> get filteredPending {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List<QuotationRecord>.from(pendingQuotations);
    return pendingQuotations.where((e) => _matchesPending(e, q)).toList();
  }

  List<OrderRecord> get filteredConfirmed {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List<OrderRecord>.from(confirmedOrders);
    return confirmedOrders.where((e) => _matchesOrder(e, q)).toList();
  }

  List<dynamic> get filteredItems =>
      _tabIndex == 0 ? filteredPending : filteredConfirmed;

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<QuotationRecord> get pagedPending {
    final all = filteredPending;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  List<OrderRecord> get pagedConfirmed {
    final all = filteredConfirmed;
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
      pendingQuotations = await _api.fetchPendingQuotations();
      confirmedOrders = await _api.fetchConfirmedOrders();
    });
  }

  Future<void> refresh() => loadItems();

  Future<void> createOrdersFromQuotations(List<String> quotationIds) async {
    if (quotationIds.isEmpty) return;
    await runAsync(() async {
      await _api.createOrdersFromQuotations(quotationIds);
      pendingQuotations = await _api.fetchPendingQuotations();
      confirmedOrders = await _api.fetchConfirmedOrders();
    });
  }

  OrderRecord? orderById(String id) {
    try {
      return confirmedOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  OrderRecord? orderByQuotationId(String quotationId) {
    try {
      return confirmedOrders.firstWhere((o) => o.quotationId == quotationId);
    } catch (_) {
      return null;
    }
  }
}
