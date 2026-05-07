import '../../../../core/providers/base_provider.dart';
import '../data/lab_manager_assignment_model.dart';
import '../data/lab_manager_assignment_test_columns.dart';

/// Mock chemist for [AppSelect].
class LabChemistOption {
  const LabChemistOption({required this.id, required this.name});

  final String id;
  final String name;
}

class LabManagerAssignmentProvider extends BaseProvider {
  static const List<LabMethodDefinition> kMethods = [
    LabMethodDefinition(
      id: 'm1',
      label: 'ASTM D664 — Acid Number',
    ),
    LabMethodDefinition(
      id: 'm2',
      label: 'ISO 4406 — Particle Count',
    ),
    LabMethodDefinition(
      id: 'm3',
      label: 'ASTM D5185 — ICP Metals',
    ),
    LabMethodDefinition(
      id: 'm4',
      label: 'Water / Sediment',
    ),
  ];

  static const List<LabChemistOption> kChemists = [
    LabChemistOption(id: 'u1', name: 'Priya Nair'),
    LabChemistOption(id: 'u2', name: 'Rahul Mehta'),
    LabChemistOption(id: 'u3', name: 'Anita Desai'),
    LabChemistOption(id: 'u4', name: 'Vikram Singh'),
  ];

  String? _selectedMethodId;
  String? _assignUserId;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _labNoQuery = '';
  /// 0 = Pending, 1 = Assigned
  int _assignmentTabIndex = 0;
  int _currentPage = 1;
  int _pageSize = 25;

  int _tableRevision = 0;

  final Map<String, List<LabManagerAssignmentRow>> _pendingByMethod = {};
  final Map<String, List<LabManagerAssignmentRow>> _assignedByMethod = {};

  String? get selectedMethodId => _selectedMethodId;
  String? get assignUserId => _assignUserId;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get labNoQuery => _labNoQuery;
  int get assignmentTabIndex => _assignmentTabIndex;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get tableRevision => _tableRevision;

  bool get isAssignedTab => _assignmentTabIndex == 1;

  LabMethodDefinition? get selectedMethod {
    if (_selectedMethodId == null) return null;
    try {
      return kMethods.firstWhere((m) => m.id == _selectedMethodId);
    } catch (_) {
      return null;
    }
  }

  int get pendingCount {
    if (_selectedMethodId == null) return 0;
    return _pendingByMethod[_selectedMethodId]?.length ?? 0;
  }

  int get assignedCount {
    if (_selectedMethodId == null) return 0;
    return _assignedByMethod[_selectedMethodId]?.length ?? 0;
  }

  List<LabManagerAssignmentRow> get _activeSourceRows {
    if (_selectedMethodId == null) return const [];
    final methodId = _selectedMethodId!;
    if (_assignmentTabIndex == 0) {
      return List<LabManagerAssignmentRow>.from(
        _pendingByMethod[methodId] ?? const [],
      );
    }
    return List<LabManagerAssignmentRow>.from(
      _assignedByMethod[methodId] ?? const [],
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<LabManagerAssignmentRow> get filteredRows {
    var rows = _activeSourceRows;
    if (_fromDate != null) {
      final from = _dateOnly(_fromDate!);
      rows = rows.where((r) => !_dateOnly(r.sampleDate).isBefore(from)).toList();
    }
    if (_toDate != null) {
      final to = _dateOnly(_toDate!);
      rows = rows.where((r) => !_dateOnly(r.sampleDate).isAfter(to)).toList();
    }
    final labQ = _labNoQuery.trim().toLowerCase();
    if (labQ.isNotEmpty) {
      rows = rows.where((r) => r.labId.toLowerCase().contains(labQ)).toList();
    }
    return rows;
  }

  int get _filteredTotal => filteredRows.length;

  int get effectiveCurrentPage {
    final total = _filteredTotal;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<LabManagerAssignmentRow> get pagedRows {
    final all = filteredRows;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void setSelectedMethod(String? id) {
    _selectedMethodId = id;
    _currentPage = 1;
    notifyListeners();
    if (id != null) {
      loadRowsForMethod();
    }
  }

  void setAssignUserId(String? id) {
    _assignUserId = id;
    notifyListeners();
  }

  void setFromDate(DateTime? d) {
    _fromDate = d;
    _currentPage = 1;
    notifyListeners();
  }

  void setToDate(DateTime? d) {
    _toDate = d;
    _currentPage = 1;
    notifyListeners();
  }

  void setLabNoQuery(String v) {
    _labNoQuery = v;
    _currentPage = 1;
    notifyListeners();
  }

  void setAssignmentTabIndex(int i) {
    _assignmentTabIndex = i.clamp(0, 1);
    _currentPage = 1;
    _tableRevision++;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    _tableRevision++;
    notifyListeners();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    _tableRevision++;
    notifyListeners();
  }

  Future<void> loadRowsForMethod() async {
    final methodId = _selectedMethodId;
    if (methodId == null) return;
    LabMethodDefinition? def;
    for (final m in kMethods) {
      if (m.id == methodId) {
        def = m;
        break;
      }
    }
    if (def == null) return;
    final methodDef = def;

    await runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (_pendingByMethod.containsKey(methodId)) {
        return;
      }
      _pendingByMethod[methodId] = _generateRows(methodDef, 22);
    });
  }

  static Map<String, bool> _emptyTestSelections() => {
        for (final c in kLabManagerAssignmentTestColumns) c.key: false,
      };

  List<LabManagerAssignmentRow> _generateRows(LabMethodDefinition def, int n) {
    final initialSelections = Map<String, bool>.from(_emptyTestSelections());
    final out = <LabManagerAssignmentRow>[];
    for (var i = 0; i < n; i++) {
      final day = DateTime(2025, 3, 1 + (i % 28));
      out.add(
        LabManagerAssignmentRow(
          id: '${def.id}_$i',
          sampleDate: day,
          labId: 'LAB-${1000 + i}',
          sampleId: 'SMP-${2400 + i}',
          customer: 'Customer ${String.fromCharCode(65 + (i % 26))} Ltd',
          equipment: i.isEven ? 'Spectrometer A' : 'Titration bench B',
          methodLabel: def.label,
          testSelections: Map<String, bool>.from(initialSelections),
        ),
      );
    }
    return out;
  }

  void toggleTestForRow(String rowId, String testKey) {
    if (_assignmentTabIndex != 0 || _selectedMethodId == null) return;
    final list = _pendingByMethod[_selectedMethodId!];
    if (list == null) return;
    final idx = list.indexWhere((r) => r.id == rowId);
    if (idx < 0) return;
    final row = list[idx];
    final next = Map<String, bool>.from(row.testSelections);
    next[testKey] = !(next[testKey] ?? false);
    list[idx] = row.copyWith(testSelections: next);
    notifyListeners();
  }

  /// True if any pending row for the current method has at least one test checked.
  bool get hasAnyPendingTestSelected {
    if (_selectedMethodId == null) return false;
    final list = _pendingByMethod[_selectedMethodId!];
    if (list == null) return false;
    for (final r in list) {
      if (r.testSelections.values.any((v) => v)) return true;
    }
    return false;
  }

  void clearAllTestSelectionsOnPending() {
    if (_selectedMethodId == null || _assignmentTabIndex != 0) return;
    final list = _pendingByMethod[_selectedMethodId!];
    if (list == null) return;
    final blank = _emptyTestSelections();
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(testSelections: Map<String, bool>.from(blank));
    }
    _tableRevision++;
    notifyListeners();
  }

  void bumpTableRevision() {
    _tableRevision++;
    notifyListeners();
  }

  void saveAssignmentForRowIds(List<String> rowIds) {
    if (_assignmentTabIndex != 0) return;
    final methodId = _selectedMethodId;
    if (methodId == null) {
      setError('Select a method');
      return;
    }
    final userId = _assignUserId;
    if (userId == null || userId.isEmpty) {
      setError('Select assign user');
      return;
    }
    if (rowIds.isEmpty) {
      setError('Select at least one row');
      return;
    }
    LabChemistOption? chemist;
    for (final c in kChemists) {
      if (c.id == userId) {
        chemist = c;
        break;
      }
    }
    if (chemist == null) {
      setError('Invalid assign user');
      return;
    }

    final pending = _pendingByMethod[methodId];
    if (pending == null) return;

    final toMove = <LabManagerAssignmentRow>[];
    for (final id in rowIds) {
      final idx = pending.indexWhere((r) => r.id == id);
      if (idx < 0) continue;
      final row = pending[idx];
      final hasTest = row.testSelections.values.any((v) => v);
      if (!hasTest) continue;
      toMove.add(
        row.copyWith(
          isAssigned: true,
          assignedToUserId: chemist.id,
          assignedToName: chemist.name,
        ),
      );
      pending.removeAt(idx);
    }

    if (toMove.isEmpty) {
      setError('Select at least one test per selected row');
      return;
    }

    _assignedByMethod.putIfAbsent(methodId, () => []).addAll(toMove);
    clearError();
    _tableRevision++;
    notifyListeners();
  }

  void resetFilters() {
    _assignUserId = null;
    _fromDate = null;
    _toDate = null;
    _labNoQuery = '';
    _currentPage = 1;
    _tableRevision++;
    clearError();
    notifyListeners();
  }

  /// Header + full filter reset (returns to “select method” state).
  void resetAll() {
    _selectedMethodId = null;
    resetFilters();
    _assignmentTabIndex = 0;
    notifyListeners();
  }

  void deleteAssignmentsForRows(List<LabManagerAssignmentRow> rows) {
    final methodId = _selectedMethodId;
    if (methodId == null || rows.isEmpty) return;
    final assigned = _assignedByMethod[methodId];
    if (assigned == null) return;
    final pending = _pendingByMethod.putIfAbsent(methodId, () => []);
    for (final row in rows) {
      final idx = assigned.indexWhere((r) => r.id == row.id);
      if (idx < 0) continue;
      assigned.removeAt(idx);
      pending.add(
        LabManagerAssignmentRow(
          id: row.id,
          sampleDate: row.sampleDate,
          labId: row.labId,
          sampleId: row.sampleId,
          customer: row.customer,
          equipment: row.equipment,
          methodLabel: row.methodLabel,
          testSelections: Map<String, bool>.from(_emptyTestSelections()),
        ),
      );
    }
    _tableRevision++;
    notifyListeners();
  }

  void clearTestSelectionsForRows(List<String> rowIds) {
    if (_selectedMethodId == null || _assignmentTabIndex != 0) return;
    final list = _pendingByMethod[_selectedMethodId!];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      if (!rowIds.contains(list[i].id)) continue;
      final row = list[i];
      list[i] = row.copyWith(
        testSelections: Map<String, bool>.from(_emptyTestSelections()),
      );
    }
    notifyListeners();
  }
}
