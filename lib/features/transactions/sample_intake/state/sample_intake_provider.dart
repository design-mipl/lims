import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../design_system/components/components.dart';
import '../data/sample_intake_api.dart';
import '../data/sample_intake_model.dart';
import '../data/sample_master_options.dart';
import '../data/sample_row_model.dart';

class SampleIntakeProvider extends BaseProvider {
  SampleIntakeProvider({SampleIntakeApi? api})
      : _api = api ?? sl<SampleIntakeApi>();

  final SampleIntakeApi _api;

  List<SampleIntakeModel> receipts = <SampleIntakeModel>[];
  SampleIntakeModel? selected;

  /// Sample grid for the loaded receipt detail (`fetchById`).
  List<SampleRowModel> sampleRows = <SampleRowModel>[];
  int? activeRowIndex;

  String _searchQuery = '';
  String _statusFilter = 'all';
  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  bool _matchesSearch(SampleIntakeModel e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.lotNo,
      e.customerName,
      e.customerCompany,
      e.siteContactPerson,
      e.siteCompany,
      e.courierName,
      e.podNo,
      e.workOrderNo,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<SampleIntakeModel> get filteredItems {
    Iterable<SampleIntakeModel> items = receipts;
    if (_statusFilter != 'all') {
      items = items.where((e) => e.status == _statusFilter);
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) => _matchesSearch(e, q));
    }
    return items.toList();
  }

  int get effectiveCurrentPage {
    final total = filteredItems.length;
    if (total == 0) return 1;
    final last = ((total - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, last);
  }

  List<SampleIntakeModel> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) return const [];
    final page = effectiveCurrentPage;
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  int countForStatus(String status) =>
      receipts.where((e) => e.status == status).length;

  int get allCount => receipts.length;

  int get statusTabIndex {
    return switch (_statusFilter) {
      SampleIntakeStatus.draft => 1,
      SampleIntakeStatus.dataEntryPending => 2,
      SampleIntakeStatus.inProgress => 3,
      SampleIntakeStatus.completed => 4,
      SampleIntakeStatus.forwardedToLab => 5,
      _ => 0,
    };
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setStatusFilterByTab(int index) {
    _statusFilter = switch (index) {
      1 => SampleIntakeStatus.draft,
      2 => SampleIntakeStatus.dataEntryPending,
      3 => SampleIntakeStatus.inProgress,
      4 => SampleIntakeStatus.completed,
      5 => SampleIntakeStatus.forwardedToLab,
      _ => 'all',
    };
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

  Future<void> loadReceipts() async {
    await runAsync(() async {
      receipts = await _api.fetchAll();
    });
  }

  Future<void> refresh() => loadReceipts();

  void _clearDetailGrid() {
    sampleRows = <SampleRowModel>[];
    activeRowIndex = null;
  }

  Future<void> fetchById(String id) async {
    await runAsync(() async {
      selected = await _api.fetchById(id);
      _clearDetailGrid();
      if (selected == null) {
        notifyListeners();
        return;
      }
      var rows = await _api.fetchRows(id);
      final n = selected!.noOfSamples;
      if (rows.isEmpty) {
        rows = await _buildFreshRows(selected!.id, n);
      } else if (rows.length != n) {
        rows = _reconcileRowCount(rows, n);
        await _api.upsertRows(selected!.id, rows);
      }
      sampleRows = rows;
      await _persistReceiptAggregate(recomputeReceiptStatus: false);
      notifyListeners();
    });
  }

  List<SampleRowModel> _reconcileRowCount(
    List<SampleRowModel> existing,
    int targetCount,
  ) {
    if (existing.length > targetCount) {
      return [
        for (var i = 0; i < targetCount; i++)
          existing[i].copyWith(index: i + 1),
      ];
    }
    final out = List<SampleRowModel>.from(existing);
    for (var i = existing.length; i < targetCount; i++) {
      out.add(
        SampleRowModel.empty(
          index: i + 1,
          sampleId: _api.nextSampleId(),
        ),
      );
    }
    return [
      for (var i = 0; i < out.length; i++) out[i].copyWith(index: i + 1),
    ];
  }

  Future<List<SampleRowModel>> _buildFreshRows(
    String receiptId,
    int count,
  ) async {
    final list = <SampleRowModel>[
      for (var i = 0; i < count; i++)
        SampleRowModel.empty(
          index: i + 1,
          sampleId: _api.nextSampleId(),
        ),
    ];
    await _api.upsertRows(receiptId, list);
    return list;
  }

  /// Regenerates in-memory/API rows when [count] should match receipt.
  Future<void> generateRows(int count) async {
    final receipt = selected;
    if (receipt == null) return;
    try {
      final list = await _buildFreshRows(receipt.id, count);
      sampleRows = list;
      activeRowIndex = null;
      await _persistReceiptAggregate(recomputeReceiptStatus: true);
      receipts = await _api.fetchAll();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    }
  }

  void setActiveRow(int index) {
    if (index < 0 || index >= sampleRows.length) {
      return;
    }
    activeRowIndex = index;
    notifyListeners();
  }

  void clearActiveRow() {
    if (activeRowIndex != null) {
      activeRowIndex = null;
      notifyListeners();
    }
  }

  dynamic _serializeFieldValue(SampleRowField field, dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return value;
  }

  void updateRowField(int index, SampleRowField field, dynamic value) {
    if (selected == null || index < 0 || index >= sampleRows.length) {
      return;
    }
    final row = sampleRows[index];
    final patch = <String, dynamic>{
      field.key: _serializeFieldValue(field, value),
      'isCompleted': false,
    };
    if (field == SampleRowField.make) {
      patch['model'] = null;
    }
    var next = SampleRowModel.fromJson({
      ...row.toJson(),
      ...patch,
    });
    sampleRows = List<SampleRowModel>.from(sampleRows)..[index] = next;
    notifyListeners();
    unawaited(
      _persistReceiptAggregate(recomputeReceiptStatus: false),
    );
  }

  int getCompletedCount() =>
      sampleRows.where((SampleRowModel e) => e.isCompleted).length;

  Future<void> _persistReceiptAggregate({
    required bool recomputeReceiptStatus,
  }) async {
    final receipt = selected;
    if (receipt == null) return;
    final completed = getCompletedCount();
    SampleIntakeModel next;
    if (!recomputeReceiptStatus) {
      next = receipt.copyWith(dataEntryCompletedCount: completed);
    } else {
      var status = receipt.status;
      if (receipt.noOfSamples > 0 && completed >= receipt.noOfSamples) {
        status = SampleIntakeStatus.completed;
      } else if (receipt.noOfSamples > 0 &&
          (completed > 0 ||
              sampleRows.any(
                (SampleRowModel r) =>
                    r.equipSrNo.isNotEmpty ||
                    (r.make?.isNotEmpty ?? false),
              ))) {
        status = SampleIntakeStatus.inProgress;
      } else if (completed == 0 && sampleRows.isNotEmpty) {
        status = SampleIntakeStatus.dataEntryPending;
      }
      next = receipt.copyWith(
        dataEntryCompletedCount: completed,
        status: status,
      );
    }
    if (next.dataEntryCompletedCount == receipt.dataEntryCompletedCount &&
        next.status == receipt.status) {
      return;
    }
    try {
      await _api.update(receipt.id, next);
      selected = next;
      receipts = await _api.fetchAll();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    }
  }

  /// Persists grid + marks one row completed; clears active selection.
  Future<void> saveRow(int index) async {
    final receipt = selected;
    if (receipt == null || index < 0 || index >= sampleRows.length) {
      return;
    }
    try {
      final nextRows = List<SampleRowModel>.from(sampleRows);
      nextRows[index] = nextRows[index].copyWith(isCompleted: true);
      sampleRows = nextRows;
      await _api.upsertRows(receipt.id, sampleRows);
      final completed = getCompletedCount();
      String status = receipt.status;
      if (completed >= receipt.noOfSamples && receipt.noOfSamples > 0) {
        status = SampleIntakeStatus.completed;
      } else {
        status = SampleIntakeStatus.inProgress;
      }
      final nextReceipt = receipt.copyWith(
        dataEntryCompletedCount: completed,
        status: status,
      );
      await _api.update(receipt.id, nextReceipt);
      selected = nextReceipt;
      receipts = await _api.fetchAll();
      activeRowIndex = null;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    }
  }

  List<AppSelectItem<String>> getModelsForMake(String make) =>
      SampleMasterOptions.modelsForMakeItems(
        make.isEmpty ? null : make,
      );

  Future<void> createReceipt(Map<String, dynamic> data) async {
    await runAsync(() async {
      final payload = Map<String, dynamic>.from(data)
        ..['status'] = SampleIntakeStatus.dataEntryPending
        ..['dataEntryCompletedCount'] = 0
        ..['id'] = '';
      await _api.create(SampleIntakeModel.fromJson(payload));
      receipts = await _api.fetchAll();
    });
  }

  Future<void> deleteReceipt(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      receipts = await _api.fetchAll();
      if (selected?.id == id) {
        selected = null;
        _clearDetailGrid();
      }
    });
  }

  Future<void> bulkDeleteReceipts(List<dynamic> ids) async {
    if (ids.isEmpty) return;
    await runAsync(() async {
      await _api.deleteMany(ids.cast<String>());
      receipts = await _api.fetchAll();
      final removed = ids.cast<String>().toSet();
      if (selected != null && removed.contains(selected!.id)) {
        selected = null;
        _clearDetailGrid();
      }
    });
  }
}
