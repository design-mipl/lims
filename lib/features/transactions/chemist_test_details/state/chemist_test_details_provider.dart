import 'package:flutter/foundation.dart';

import '../../../../core/di/service_locator.dart';
import '../data/chemist_test_details_api.dart';
import '../data/chemist_test_details_model.dart';

class ChemistTestDetailsProvider extends ChangeNotifier {
  ChemistTestDetailsProvider({ChemistTestDetailsApi? api})
      : _api = api ?? sl<ChemistTestDetailsApi>();

  final ChemistTestDetailsApi _api;

  bool _disposed = false;
  int _loadRequestId = 0;

  List<ChemistTestSummaryRow> _summaries = [];
  final Map<String, List<ChemistTestDetailLine>> _details = {};
  String _searchQuery = '';
  String? _selectedSummaryId;
  bool _detailPanelEditable = false;
  bool _loading = false;
  String? _error;

  String get searchQuery => _searchQuery;

  static const int defaultPageSize = 25;
  int _currentPage = 1;
  int _pageSize = defaultPageSize;

  bool get isLoading => _loading;
  String? get error => _error;
  String? get selectedSummaryId => _selectedSummaryId;

  /// When false, parameter value inputs are read-only (view mode).
  bool get detailPanelEditable => _detailPanelEditable;

  ChemistTestSummaryRow? get selectedSummary {
    final id = _selectedSummaryId;
    if (id == null) return null;
    for (final s in _summaries) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<ChemistTestDetailLine> get selectedDetailLines {
    final id = _selectedSummaryId;
    if (id == null) return const [];
    return List<ChemistTestDetailLine>.from(_details[id] ?? const []);
  }

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalFilteredCount => _filteredSummaries().length;

  List<ChemistTestSummaryRow> get pagedRows {
    final all = _filteredSummaries();
    if (all.isEmpty) return const [];
    final start = (_currentPage - 1) * _pageSize;
    if (start >= all.length) return const [];
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  List<ChemistTestSummaryRow> _filteredSummaries() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List<ChemistTestSummaryRow>.from(_summaries);
    return _summaries.where((s) {
      return s.labNo.toLowerCase().contains(q) ||
          s.sample.toLowerCase().contains(q) ||
          _formatDate(s.labDate).contains(q) ||
          (s.expectedDate != null &&
              _formatDate(s.expectedDate!).contains(q));
    }).toList();
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Stops in-flight [load] without notifying (safe from screen [dispose]).
  void cancelPendingWork() {
    _loadRequestId++;
    _loading = false;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _loadRequestId++;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  bool _isActiveLoad(int requestId) =>
      !_disposed && requestId == _loadRequestId;

  void clearError() {
    if (_disposed) return;
    _error = null;
    notifyListeners();
  }

  Future<void> load() async {
    if (_disposed) return;
    final requestId = ++_loadRequestId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final next = await _api.fetchSummaries();
      if (!_isActiveLoad(requestId)) return;

      _summaries = next;
      _details.clear();
      for (final s in _summaries) {
        if (!_isActiveLoad(requestId)) return;
        _details[s.id] = await _api.fetchDetailLines(s.id);
      }
      if (!_isActiveLoad(requestId)) return;

      if (_selectedSummaryId != null &&
          !_summaries.any((e) => e.id == _selectedSummaryId)) {
        _selectedSummaryId = null;
        _detailPanelEditable = false;
      }
      _clampPage();
    } catch (e, st) {
      if (!_isActiveLoad(requestId)) return;
      debugPrint('ChemistTestDetailsProvider.load: $e\n$st');
      _error = 'Could not load chemist test details.';
    } finally {
      if (_isActiveLoad(requestId)) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void _clampPage() {
    final total = totalFilteredCount;
    final maxPage = total <= 0 ? 1 : ((total - 1) ~/ _pageSize) + 1;
    if (_currentPage > maxPage) _currentPage = maxPage;
    if (_currentPage < 1) _currentPage = 1;
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _currentPage = 1;
    _clampPage();
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page < 1 ? 1 : page;
    _clampPage();
    notifyListeners();
  }

  void setPageSize(int size) {
    _pageSize = size < 1 ? defaultPageSize : size;
    _currentPage = 1;
    _clampPage();
    notifyListeners();
  }

  /// Toggle workspace: same Lab No. again collapses. Row tap opens **view** mode.
  void toggleSummarySelection(String id) {
    if (_selectedSummaryId == id) {
      _selectedSummaryId = null;
      _detailPanelEditable = false;
    } else {
      _selectedSummaryId = id;
      _detailPanelEditable = false;
    }
    notifyListeners();
  }

  void openSummaryView(String id) {
    _selectedSummaryId = id;
    _detailPanelEditable = false;
    notifyListeners();
  }

  void openSummaryEdit(String id) {
    _selectedSummaryId = id;
    _detailPanelEditable = true;
    notifyListeners();
  }

  void updateDetailValue(int lineIndex, int valueSlot, String value) {
    if (!_detailPanelEditable) return;
    final sid = _selectedSummaryId;
    if (sid == null) return;
    final lines = _details[sid];
    if (lines == null ||
        lineIndex < 0 ||
        lineIndex >= lines.length) {
      return;
    }
    final line = lines[lineIndex];
    switch (valueSlot) {
      case 0:
        line.value1 = value;
        break;
      case 1:
        line.value2 = value;
        break;
      case 2:
        line.value3 = value;
        break;
      default:
        return;
    }
    // Values persist on [_ChemistTestDetailWorkspace] controllers; avoid notifying
    // every keystroke (caret jump / needless rebuilds).
  }

  Future<void> saveDraft() async {
    if (_disposed) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> exportDetails() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  Future<void> importDetails() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}
