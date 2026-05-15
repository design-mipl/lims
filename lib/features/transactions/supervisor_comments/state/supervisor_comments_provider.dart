import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/supervisor_comments_api.dart';
import '../data/supervisor_comments_model.dart';
import '../data/supervisor_review_workspace_model.dart';

class SupervisorCommentsProvider extends BaseProvider {
  SupervisorCommentsProvider({SupervisorCommentsApi? api})
      : _api = api ?? sl<SupervisorCommentsApi>();

  final SupervisorCommentsApi _api;

  List<SupervisorCommentsRow> items = <SupervisorCommentsRow>[];

  /// Listing row for the currently opened review workspace (header summary).
  SupervisorCommentsRow? reviewSampleRow;

  /// Mutable review workspace (parameters + analysis fields).
  SupervisorReviewWorkspace? reviewWorkspace;

  String _searchQuery = '';
  int _tabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get tabIndex => _tabIndex;

  int get pendingCount => items
      .where((e) => e.status == SupervisorCommentsStatus.pending)
      .length;

  int get completedCount => items
      .where((e) => e.status == SupervisorCommentsStatus.completed)
      .length;

  bool _matchesSearch(SupervisorCommentsRow e, String q) {
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
      e.oilBrand,
      e.oilGrade,
      e.samplingPoint,
      e.customerNote,
      e.zone,
      e.fluid,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<SupervisorCommentsRow> get filteredItems {
    Iterable<SupervisorCommentsRow> rows = items;
    rows = rows.where((e) => _tabIndex == 0
        ? e.status == SupervisorCommentsStatus.pending
        : e.status == SupervisorCommentsStatus.completed);
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

  List<SupervisorCommentsRow> get pagedRows {
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

  Future<void> loadReviewWorkspace(String supervisorCommentsId) async {
    await runAsync(() async {
      final row = await _api.fetchById(supervisorCommentsId);
      final ws = await _api.fetchWorkspace(supervisorCommentsId);
      reviewSampleRow = row;
      reviewWorkspace = ws;
      notifyListeners();
    });
  }

  void updateReviewWorkspace(SupervisorReviewWorkspace workspace) {
    reviewWorkspace = workspace;
    notifyListeners();
  }

  void updateTestLine(SupervisorReviewTestLine line) {
    final ws = reviewWorkspace;
    if (ws == null) return;
    final reconciled = _api.recomputeReviewLine(line);
    final nextLines = ws.lines
        .map((e) => e.id == reconciled.id ? reconciled : e)
        .toList(growable: false);
    final status = _worstSampleStatus(nextLines);
    reviewWorkspace = ws.copyWith(lines: nextLines, severityStatus: status);
    notifyListeners();
  }

  void setWorkspaceProblem(String value) {
    final ws = reviewWorkspace;
    if (ws == null) return;
    reviewWorkspace = ws.copyWith(problem: value);
    notifyListeners();
  }

  void setWorkspaceComments(String value) {
    final ws = reviewWorkspace;
    if (ws == null) return;
    reviewWorkspace = ws.copyWith(comments: value);
    notifyListeners();
  }

  void setWorkspaceRecommendation(String value) {
    final ws = reviewWorkspace;
    if (ws == null) return;
    reviewWorkspace = ws.copyWith(recommendation: value);
    notifyListeners();
  }

  static String _worstSampleStatus(List<SupervisorReviewTestLine> lines) {
    var worst = SupervisorReviewSeverity.normal;
    for (final e in lines) {
      if (e.severity == SupervisorReviewSeverity.critical) {
        worst = SupervisorReviewSeverity.critical;
        break;
      }
      if (e.severity == SupervisorReviewSeverity.warning) {
        worst = SupervisorReviewSeverity.warning;
      }
    }
    return worst.label;
  }

  Future<void> saveReviewDraft() async {
    final ws = reviewWorkspace;
    if (ws == null) return;
    await runAsync(() async {
      await _api.saveWorkspaceDraft(ws);
      items = await _api.fetchAll();
      reviewSampleRow = await _api.fetchById(ws.supervisorCommentsId);
      notifyListeners();
    });
  }

  Future<void> approveReview() async {
    final ws = reviewWorkspace;
    if (ws == null) return;
    await runAsync(() async {
      await _api.saveWorkspaceDraft(ws);
      await _api.approveWorkspace(ws.supervisorCommentsId);
      items = await _api.fetchAll();
      notifyListeners();
    });
  }

  Future<void> sendBackReview() async {
    final ws = reviewWorkspace;
    if (ws == null) return;
    await runAsync(() async {
      await _api.saveWorkspaceDraft(ws);
      await _api.sendBackWorkspace(ws.supervisorCommentsId);
      items = await _api.fetchAll();
      notifyListeners();
    });
  }

  void clearReviewWorkspace() {
    reviewSampleRow = null;
    reviewWorkspace = null;
    notifyListeners();
  }

  Future<void> bulkDeleteItems(List<dynamic> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.deleteMany(ids.cast<String>());
      items = await _api.fetchAll();
      final removed = ids.cast<String>().toSet();
      if (reviewWorkspace != null &&
          removed.contains(reviewWorkspace!.supervisorCommentsId)) {
        reviewSampleRow = null;
        reviewWorkspace = null;
      }
    });
  }
}
