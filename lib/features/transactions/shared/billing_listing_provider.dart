import 'package:flutter/foundation.dart';

import 'billing_document_row.dart';

/// Filters, sorts (via [AppListingScreen]), paginates listing rows for billing modules.
class BillingListingProvider extends ChangeNotifier {
  BillingListingProvider({
    required Future<List<BillingDocumentListingRow>> Function() fetchRows,
  }) : _fetchRows = fetchRows;

  final Future<List<BillingDocumentListingRow>> Function() _fetchRows;

  List<BillingDocumentListingRow> _items = [];
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;
  bool _gstVerificationInProgress = false;

  List<BillingDocumentListingRow> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get gstVerificationInProgress => _gstVerificationInProgress;
  String get searchQuery => _searchQuery;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inDocDateRange(BillingDocumentListingRow e) {
    final day = _dateOnly(e.docDate);
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

  bool _matchesSearch(BillingDocumentListingRow e, String q) {
    if (q.isEmpty) return true;
    final hay = [
      e.documentNo,
      e.customer,
      e.statusLabel,
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }

  List<BillingDocumentListingRow> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    return _items
        .where(_inDocDateRange)
        .where((e) => _matchesSearch(e, q))
        .toList();
  }

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<BillingDocumentListingRow> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  int get totalFilteredCount => filteredItems.length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _fetchRows();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setFromDate(DateTime d) {
    _fromDate = _dateOnly(d);
    _currentPage = 1;
    notifyListeners();
  }

  void setToDate(DateTime d) {
    _toDate = _dateOnly(d);
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

  /// GST / eInvoice verification for selected rows (mock delay + IRN/QR/response).
  /// Returns false if [rows] is empty or another run is in progress.
  Future<bool> verifyGstForRows(List<BillingDocumentListingRow> rows) async {
    if (rows.isEmpty || _gstVerificationInProgress) return false;
    _gstVerificationInProgress = true;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final stamp = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final idx = _items.indexWhere((e) => e.id == row.id);
        if (idx < 0) continue;
        final existing = _items[idx];
        final irn =
            'IRN${stamp.toString()}${i.toString().padLeft(2, '0')}';
        final qrPayload = '$irn|${existing.documentNo}|GSTINMOCK';
        final response =
            '{"AckNo":"ACK$stamp","Status":"ACT","Irn":"$irn","SignedQRCode":"$qrPayload"}';
        _items[idx] = existing.copyWith(
          gstVerified: true,
          irnNumber: irn,
          qrCodeData: qrPayload,
          gstVerificationResponse: response,
          ceoSignatureOnTemplate: true,
        );
      }
      return true;
    } finally {
      _gstVerificationInProgress = false;
      notifyListeners();
    }
  }
}
