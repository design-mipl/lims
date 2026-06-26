import 'package:flutter/material.dart';

import '../data/create_credit_note_prefill.dart';
import '../data/credit_note_invoice_line_model.dart';

/// State for **Create Credit Note** — line selection, totals, and mock persistence.
class CreateCreditNoteProvider extends ChangeNotifier {
  CreateCreditNoteProvider() {
    final t = DateTime.now();
    _creditNoteDate = DateTime(t.year, t.month, t.day);
  }

  static const double _cgstFraction = 0.09;
  static const double _sgstFraction = 0.09;

  final List<CreditNoteInvoiceLineRow> _source = [];
  final Set<String> _removedFromBilling = {};
  final Set<String> _selectedIds = {};
  final Map<String, String> _rateTextById = {};

  String _searchQuery = '';

  DateTime? _creditNoteDate;
  String? _creditNoteType;
  String? _gstType;

  DateTime? _buyerOrderDate;
  DateTime? _dispatchDate;
  DateTime? _referenceInvoiceDate;

  String provisionalCreditNoteNo = 'CN-DRAFT-NEW';
  String linkedInvoiceNo = '—';

  /// From Customer Invoice navigation — drives customer / reference form sync.
  CreateCreditNotePrefill? appliedPrefill;

  String? _error;

  String? get error => _error;
  bool get hasError => _error != null;

  DateTime? get creditNoteDate => _creditNoteDate;
  String? get creditNoteType => _creditNoteType;
  String? get gstType => _gstType;
  DateTime? get buyerOrderDate => _buyerOrderDate;
  DateTime? get dispatchDate => _dispatchDate;
  DateTime? get referenceInvoiceDate => _referenceInvoiceDate;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setError(String? m) {
    _error = m;
    notifyListeners();
  }

  void setCreditNoteDate(DateTime? d) {
    _creditNoteDate = d;
    notifyListeners();
  }

  void setCreditNoteType(String? v) {
    _creditNoteType = v;
    notifyListeners();
  }

  void setGstType(String? v) {
    _gstType = v;
    notifyListeners();
  }

  void setBuyerOrderDate(DateTime? d) {
    _buyerOrderDate = d;
    notifyListeners();
  }

  void setDispatchDate(DateTime? d) {
    _dispatchDate = d;
    notifyListeners();
  }

  void setReferenceInvoiceDate(DateTime? d) {
    _referenceInvoiceDate = d;
    notifyListeners();
  }

  void setProvisionalCreditNoteNo(String v) {
    final t = v.trim();
    provisionalCreditNoteNo = t.isEmpty ? 'CN-DRAFT-NEW' : t;
    notifyListeners();
  }

  /// Pre-fills Create Credit Note from Customer Invoice listing or workspace.
  void applyPrefill(CreateCreditNotePrefill prefill) {
    appliedPrefill = prefill;
    _source
      ..clear()
      ..addAll(prefill.lines);
    _removedFromBilling.clear();
    _selectedIds
      ..clear()
      ..addAll(prefill.lines.map((e) => e.id));
    _rateTextById.clear();
    linkedInvoiceNo = prefill.invoiceNo;
    _referenceInvoiceDate = prefill.referenceInvoiceDate ?? prefill.invoiceDate;
    _creditNoteType = prefill.creditNoteType ?? 'credit';
    _gstType = prefill.gstType;
    _buyerOrderDate = prefill.buyerOrderDate;
    _dispatchDate = prefill.dispatchDate;
    _searchQuery = '';
    _page = 1;
    clearError();
    notifyListeners();
  }

  CreditNoteInvoiceLineRow? _rowById(String id) {
    for (final r in _source) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<CreditNoteInvoiceLineRow> get activeLines {
    return _source.where((r) => !_removedFromBilling.contains(r.id)).toList();
  }

  List<CreditNoteInvoiceLineRow> get filteredLines {
    var rows = activeLines;
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      rows = rows.where((r) {
        return r.labNo.toLowerCase().contains(q) ||
            r.invoiceNo.toLowerCase().contains(q) ||
            r.customer.toLowerCase().contains(q) ||
            r.site.toLowerCase().contains(q) ||
            r.lineItem.toLowerCase().contains(q) ||
            r.reportId.toLowerCase().contains(q) ||
            r.contactPerson.toLowerCase().contains(q);
      }).toList();
    }
    return rows;
  }

  static const int kPageSize = 25;
  int _page = 1;

  int get effectivePage {
    final total = filteredLines.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ kPageSize) + 1;
    return _page.clamp(1, last);
  }

  List<CreditNoteInvoiceLineRow> get pagedRows {
    final all = filteredLines;
    if (all.isEmpty) return const [];
    final page = effectivePage;
    final start = (page - 1) * kPageSize;
    final end = (start + kPageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  int get totalFilteredCount => filteredLines.length;

  Set<String> get selectedIds => Set<String>.from(_selectedIds);

  void setPageSize(int _) {
    notifyListeners();
  }

  CreditNoteInvoiceLineRow? firstSelectedRow() {
    for (final id in _selectedIds) {
      final r = _rowById(id);
      if (r != null && !_removedFromBilling.contains(id)) return r;
    }
    return null;
  }

  void setPage(int p) {
    _page = p < 1 ? 1 : p;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _page = 1;
    notifyListeners();
  }

  /// No-op refresh for embedded listing toolbars (rebuild table chrome).
  void refreshListing() => notifyListeners();

  void _syncLinkedInvoiceFromSelection() {
    final invs = <String>{};
    for (final id in _selectedIds) {
      final r = _rowById(id);
      if (r != null) invs.add(r.invoiceNo);
    }
    if (invs.isEmpty) {
      linkedInvoiceNo = '—';
    } else if (invs.length == 1) {
      linkedInvoiceNo = invs.first;
    } else {
      linkedInvoiceNo = '${invs.length} invoices';
    }
  }

  void onRowSelectionChanged(
    Set<int> indices,
    List<CreditNoteInvoiceLineRow> pageRows,
  ) {
    final pageIds = pageRows.map((e) => e.id).toSet();
    _selectedIds.removeAll(pageIds);
    for (final i in indices) {
      if (i >= 0 && i < pageRows.length) {
        _selectedIds.add(pageRows[i].id);
      }
    }
    _syncLinkedInvoiceFromSelection();
    notifyListeners();
  }

  double _rateFor(CreditNoteInvoiceLineRow r) {
    final t = _rateTextById[r.id];
    if (t != null) {
      final v = double.tryParse(t.trim());
      if (v != null) return v;
    }
    return r.rate;
  }

  double resolvedRateForId(String id) {
    final r = _rowById(id);
    return r == null ? 0 : _rateFor(r);
  }

  void setRateText(String id, String text) {
    if (!_selectedIds.contains(id)) return;
    _rateTextById[id] = text;
    notifyListeners();
  }

  String rateFieldText(String id) {
    final row = _rowById(id);
    if (row == null) return '';
    return _rateTextById[id] ?? row.rate.toStringAsFixed(2);
  }

  void commitRatesFromFields() {
    for (final id in _selectedIds) {
      final idx = _source.indexWhere((e) => e.id == id);
      if (idx < 0) continue;
      final t = _rateTextById[id];
      if (t == null) continue;
      final v = double.tryParse(t.trim());
      if (v == null) continue;
      _source[idx] = _source[idx].copyWith(rate: v);
    }
    _rateTextById.removeWhere((k, _) => _selectedIds.contains(k));
    notifyListeners();
  }

  double get lineValueSelected {
    var sum = 0.0;
    for (final r in _source) {
      if (_selectedIds.contains(r.id) && !_removedFromBilling.contains(r.id)) {
        sum += _rateFor(r);
      }
    }
    return sum;
  }

  double get otherCharges => 0;
  double get discount => 0;

  double get taxableBase =>
      (lineValueSelected + otherCharges - discount).clamp(0, double.infinity);

  double get cgst => taxableBase * _cgstFraction;
  double get sgst => taxableBase * _sgstFraction;
  double get igst => 0;
  double get grandTotal => taxableBase + cgst + sgst + igst;

  int removeSelectedFromBilling() {
    if (_selectedIds.isEmpty) return 0;
    var n = 0;
    for (final id in _selectedIds.toList()) {
      if (!_removedFromBilling.contains(id)) {
        _removedFromBilling.add(id);
        n++;
      }
    }
    _selectedIds.clear();
    _syncLinkedInvoiceFromSelection();
    notifyListeners();
    return n;
  }

  Future<void> saveDraft() async {
    commitRatesFromFields();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    clearError();
    notifyListeners();
  }

  Future<String?> generateCreditNote() async {
    if (_selectedIds.isEmpty) {
      setError('Select at least one invoice line.');
      return null;
    }
    commitRatesFromFields();
    await Future<void>.delayed(const Duration(milliseconds: 160));
    clearError();
    final id = 'cn-${DateTime.now().millisecondsSinceEpoch % 100000}';
    provisionalCreditNoteNo = id.toUpperCase();
    notifyListeners();
    return id;
  }
}
