import 'package:flutter/foundation.dart';

import 'billing_document_row.dart';
import 'billing_gst_verification_result.dart';
import 'billing_row_action_state.dart';

/// Filters, sorts (via [AppListingScreen]), paginates listing rows for billing modules.
class BillingListingProvider extends ChangeNotifier {
  BillingListingProvider({
    required Future<List<BillingDocumentListingRow>> Function() fetchRows,
    void Function(String id, String fileName)? onAttachDigitalSignature,
    void Function(BillingDocumentListingRow row)? onPersistRow,
  })  : _fetchRows = fetchRows,
        _onAttachDigitalSignature = onAttachDigitalSignature,
        _onPersistRow = onPersistRow;

  final Future<List<BillingDocumentListingRow>> Function() _fetchRows;
  final void Function(String id, String fileName)? _onAttachDigitalSignature;
  final void Function(BillingDocumentListingRow row)? _onPersistRow;

  final BillingRowActionState rowActions = BillingRowActionState();

  List<BillingDocumentListingRow> _items = [];
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;

  List<BillingDocumentListingRow> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get gstVerificationInProgress => rowActions.gstVerificationInProgress;
  String get searchQuery => _searchQuery;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  BillingDocumentListingRow? rowById(String id) {
    for (final row in _items) {
      if (row.id == id) return row;
    }
    return null;
  }

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
      // APIs may return unmodifiable snapshots — keep a mutable working copy.
      _items = List<BillingDocumentListingRow>.from(await _fetchRows());
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
  Future<BillingGstVerificationResult> verifyGstForRows(
    List<BillingDocumentListingRow> rows,
  ) async {
    if (rows.isEmpty) {
      return BillingGstVerificationResult.failure(
        'Select at least one document to verify.',
      );
    }
    if (rowActions.gstVerificationInProgress) {
      return BillingGstVerificationResult.failure(
        'GST verification is already in progress.',
      );
    }

    final ids = rows.map((e) => e.id).toList();
    rowActions.startGstVerify(ids);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));

      // Mock API rejection when document no. contains FAIL (for QA).
      BillingDocumentListingRow? failRow;
      for (final r in rows) {
        if (r.documentNo.toUpperCase().contains('FAIL')) {
          failRow = r;
          break;
        }
      }
      if (failRow != null) {
        return BillingGstVerificationResult.failure(
          'GST portal rejected ${failRow.documentNo}: '
          'Invalid GSTIN or document already cancelled (Error EINV-402).',
        );
      }

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final verified = <BillingGstVerifiedItem>[];
      final verifiedAt = DateTime.now();
      final nextItems = List<BillingDocumentListingRow>.from(_items);

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final idx = nextItems.indexWhere((e) => e.id == row.id);
        if (idx < 0) continue;
        final existing = nextItems[idx];
        final irn =
            'IRN${stamp.toString()}${i.toString().padLeft(2, '0')}';
        final qrPayload = '$irn|${existing.documentNo}|GSTINMOCK';
        final response =
            '{"AckNo":"ACK$stamp","Status":"ACT","Irn":"$irn","SignedQRCode":"$qrPayload"}';
        final updated = existing.copyWith(
          gstVerified: true,
          eInvoiceActive: true,
          irnNumber: irn,
          qrCodeData: qrPayload,
          gstVerificationResponse: response,
          statusLabel: 'GST Verified',
          ceoSignatureOnTemplate: existing.digitalSignatureAttached,
        );
        nextItems[idx] = updated;
        _onPersistRow?.call(updated);
        verified.add(
          BillingGstVerifiedItem(
            documentId: updated.id,
            documentNo: updated.documentNo,
            gstRefNo: irn,
          ),
        );
      }

      if (verified.isEmpty) {
        return BillingGstVerificationResult.failure(
          'No matching documents found to verify.',
        );
      }

      _items = nextItems;
      notifyListeners();
      return BillingGstVerificationResult.success(
        items: verified,
        timestamp: verifiedAt,
      );
    } catch (e) {
      return BillingGstVerificationResult.failure(
        e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e',
      );
    } finally {
      rowActions.endGstVerify();
    }
  }

  /// Persist signature on one row (mock upload). Caller owns row-level loading UI.
  Future<bool> attachDigitalSignature(
    BillingDocumentListingRow row, {
    required String fileName,
  }) async {
    try {
      // Mock upload latency — never block the UI isolate with sync I/O here.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final nextItems = List<BillingDocumentListingRow>.from(_items);
      final idx = nextItems.indexWhere((e) => e.id == row.id);
      if (idx < 0) return false;

      final updated = nextItems[idx].copyWith(
        digitalSignatureAttached: true,
        digitalSignatureFileName: fileName,
      );
      nextItems[idx] = updated;
      _items = nextItems;
      await Future<void>.delayed(Duration.zero);
      _onAttachDigitalSignature?.call(row.id, fileName);
      _onPersistRow?.call(updated);
      notifyListeners();
      return true;
    } on Object {
      return false;
    }
  }

  @override
  void dispose() {
    rowActions.dispose();
    super.dispose();
  }
}
