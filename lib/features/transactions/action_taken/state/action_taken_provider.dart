import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/action_taken_api.dart';
import '../data/action_taken_model.dart';
import '../data/action_taken_workspace_model.dart';

class ActionTakenProvider extends BaseProvider {
  ActionTakenProvider({ActionTakenApi? api}) : _api = api ?? sl<ActionTakenApi>();

  final ActionTakenApi _api;

  List<ActionTakenRow> items = <ActionTakenRow>[];

  String _searchQuery = '';
  ActionTakenStatus _statusTab = ActionTakenStatus.pending;
  ActionTakenSeverityFilter _severityFilter = ActionTakenSeverityFilter.all;
  int _currentPage = 1;
  int _pageSize = 10;

  DateTime? _fromDate;
  DateTime? _toDate;

  ActionTakenRow? _workspaceRow;
  ActionTakenWorkspaceDraft? _workspaceDraft;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  ActionTakenSeverityFilter get severityFilter => _severityFilter;

  ActionTakenRow? get workspaceRow => _workspaceRow;
  ActionTakenWorkspaceDraft? get workspaceDraft => _workspaceDraft;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inSamplingDateRange(ActionTakenRow e) {
    final day = _dateOnly(e.samplingDate);
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

  bool _matchesSeverity(ActionTakenRow e) {
    return switch (_severityFilter) {
      ActionTakenSeverityFilter.all => true,
      ActionTakenSeverityFilter.critical =>
        e.severity == ActionTakenRowSeverity.critical,
      ActionTakenSeverityFilter.cautions =>
        e.severity == ActionTakenRowSeverity.cautions,
      ActionTakenSeverityFilter.normal =>
        e.severity == ActionTakenRowSeverity.normal,
    };
  }

  bool _matchesSearch(ActionTakenRow e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.companyName,
      e.siteContactPerson,
      e.siteName,
      e.labId,
      e.typeOfSample,
      e.equipmentIdNo,
      e.sampleId,
      e.make,
      e.chemist,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<ActionTakenRow> get filteredItems {
    Iterable<ActionTakenRow> rows =
        items.where((e) => e.status == _statusTab);
    rows = rows.where(_inSamplingDateRange);
    rows = rows.where(_matchesSeverity);
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

  List<ActionTakenRow> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  int countForStatus(ActionTakenStatus status) =>
      items.where((e) => e.status == status).length;

  int get statusTabIndex {
    return switch (_statusTab) {
      ActionTakenStatus.completed => 1,
      ActionTakenStatus.pending => 0,
    };
  }

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  void setSearchQuery(String value) {
    _searchQuery = value;
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

  void setSeverityFilter(ActionTakenSeverityFilter value) {
    _severityFilter = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setTabByIndex(int index) {
    _statusTab =
        index == 1 ? ActionTakenStatus.completed : ActionTakenStatus.pending;
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

  Future<void> loadWorkspace(String rowId) async {
    await runAsync(() async {
      _workspaceRow = _api.rowById(rowId);
      _workspaceDraft = _workspaceRow != null
          ? await _api.fetchWorkspaceDraft(rowId)
          : null;
    });
  }

  void clearWorkspace() {
    _workspaceRow = null;
    _workspaceDraft = null;
  }

  void setWorkspaceActionDate(DateTime date) {
    final draft = _workspaceDraft;
    if (draft == null) return;
    _workspaceDraft = draft.copyWith(actionDate: _dateOnly(date));
    notifyListeners();
  }

  Future<void> saveWorkspace({
    required String comments,
    required String recommendation,
    required String actionTaken,
  }) async {
    final draft = _workspaceDraft;
    if (draft == null) return;
    final merged = draft.copyWith(
      comments: comments,
      recommendation: recommendation,
      actionTaken: actionTaken,
    );
    clearError();
    try {
      await _api.saveWorkspaceDraft(merged);
      _workspaceDraft = merged;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }
}
