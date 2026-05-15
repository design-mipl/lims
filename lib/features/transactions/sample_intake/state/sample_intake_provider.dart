import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../design_system/components/components.dart';
import '../../lab_code/data/lab_code_api.dart';
import '../data/sample_intake_api.dart';
import '../data/sample_intake_model.dart';
import '../data/sample_master_options.dart';
import '../data/sample_row_model.dart';

/// Primary tabs on Sample Intake hub ([SampleIntakeHubScreen]).
enum SampleIntakeHubTab {
  receiptTracking,
  sampleReceipt,
  completedReceipt,
}

extension SampleIntakeModelWorkflowUi on SampleIntakeModel {
  String get datasheetStatusDisplay {
    return switch (status) {
      SampleIntakeStatus.forwardedToLab => 'Complete',
      SampleIntakeStatus.completed => 'Complete',
      SampleIntakeStatus.inProgress => 'In progress',
      SampleIntakeStatus.receiptComplete => 'Pending',
      SampleIntakeStatus.dataEntryPending => 'Pending',
      _ when isReceiptTrackingPending => '—',
      _ => 'Pending',
    };
  }

  String get labCodeStatusDisplay {
    return switch (status) {
      SampleIntakeStatus.forwardedToLab => 'Generated',
      SampleIntakeStatus.completed => 'Ready',
      SampleIntakeStatus.inProgress => 'Pending',
      SampleIntakeStatus.receiptComplete => 'Pending',
      _ when isReceiptTrackingPending => '—',
      _ => 'Pending',
    };
  }

  String get receiptTrackingStatusDisplay {
    if (isReceiptTrackingPending) return 'Incomplete';
    return 'Submitted';
  }

  String get courierOrHandDisplay =>
      receiptMode.isNotEmpty ? receiptMode : courierName;
}

class SampleIntakeProvider extends BaseProvider {
  SampleIntakeProvider({
    SampleIntakeApi? api,
    LabCodeApi? labCodeApi,
  })  : _api = api ?? sl<SampleIntakeApi>(),
        _labCodeApi = labCodeApi ?? sl<LabCodeApi>();

  final SampleIntakeApi _api;
  final LabCodeApi _labCodeApi;

  String peekNextLotNo() => _api.peekNextLotNo();

  List<SampleIntakeModel> receipts = <SampleIntakeModel>[];
  SampleIntakeModel? selected;

  List<SampleRowModel> sampleRows = <SampleRowModel>[];
  int? activeRowIndex;

  String _searchQuery = '';
  SampleIntakeHubTab _hubTab = SampleIntakeHubTab.receiptTracking;

  int _currentPage = 1;
  int _pageSize = 10;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  SampleIntakeHubTab get hubTab => _hubTab;

  int get hubTabIndex => switch (_hubTab) {
        SampleIntakeHubTab.receiptTracking => 0,
        SampleIntakeHubTab.sampleReceipt => 1,
        SampleIntakeHubTab.completedReceipt => 2,
      };

  void setHubTab(SampleIntakeHubTab tab) {
    if (_hubTab == tab) return;
    _hubTab = tab;
    _currentPage = 1;
    notifyListeners();
  }

  void setHubTabIndex(int index) {
    setHubTab(
      switch (index) {
        0 => SampleIntakeHubTab.receiptTracking,
        1 => SampleIntakeHubTab.sampleReceipt,
        _ => SampleIntakeHubTab.completedReceipt,
      },
    );
  }

  static bool _isTerminalIntakeHistory(SampleIntakeModel e) {
    return e.status == SampleIntakeStatus.forwardedToLab ||
        (e.status == SampleIntakeStatus.completed &&
            e.intakeCompletedAt != null);
  }

  int hubReceiptTrackingCount() => receipts
      .where(
        (e) =>
            !_isTerminalIntakeHistory(e) && e.isReceiptTrackingPending,
      )
      .length;

  int hubSampleReceiptCount() => receipts
      .where(
        (e) =>
            !_isTerminalIntakeHistory(e) && !e.isReceiptTrackingPending,
      )
      .length;

  int hubCompletedReceiptCount() =>
      receipts.where(_isTerminalIntakeHistory).length;

  /// Alias for dashboards referencing completed intake volume.
  int completedIntakeCount() => hubCompletedReceiptCount();

  bool _matchesSurface(SampleIntakeModel e) {
    switch (_hubTab) {
      case SampleIntakeHubTab.receiptTracking:
        return !_isTerminalIntakeHistory(e) && e.isReceiptTrackingPending;
      case SampleIntakeHubTab.sampleReceipt:
        return !_isTerminalIntakeHistory(e) && !e.isReceiptTrackingPending;
      case SampleIntakeHubTab.completedReceipt:
        return _isTerminalIntakeHistory(e);
    }
  }

  bool _matchesSearch(SampleIntakeModel e, String q) {
    if (q.isEmpty) return true;
    final buckets = <String>[
      e.lotNo,
      e.primarySampleId,
      e.customerName,
      e.customerCompany,
      e.siteContactPerson,
      e.siteCompany,
      e.courierName,
      e.podNo,
      e.workOrderNo,
      e.typeOfSample,
      e.receivedBy,
    ];
    return buckets.any((s) => s.toLowerCase().contains(q));
  }

  List<SampleIntakeModel> get filteredItems {
    Iterable<SampleIntakeModel> items = receipts.where(_matchesSurface);
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

  void setSearchQuery(String value) {
    _searchQuery = value;
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

  Future<void> loadReceiptForForm(String id) async {
    await runAsync(() async {
      selected = await _api.fetchById(id);
      notifyListeners();
    });
  }

  Future<void> updateReceiptFromForm(
    String id,
    Map<String, dynamic> patch,
  ) async {
    await runAsync(() async {
      final existing = await _api.fetchById(id);
      if (existing == null) {
        setError('Receipt not found');
        return;
      }
      final merged = SampleIntakeModel.fromJson({
        ...existing.toJson(),
        ...patch,
        'id': id,
        'dataEntryCompletedCount': existing.dataEntryCompletedCount,
        'status': patch['status'] ?? existing.status,
      });
      await _api.update(id, merged);
      selected = merged;
      receipts = await _api.fetchAll();
    });
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
        ).copyWith(
          runningHrsBaseline: 1000.0 + i * 100,
        ),
    ];
    await _api.upsertRows(receiptId, list);
    final rec = await _api.fetchById(receiptId);
    if (rec != null && list.isNotEmpty) {
      await _api.update(
        receiptId,
        rec.copyWith(primarySampleId: list.first.sampleId),
      );
    }
    return list;
  }

  Future<void> generateRows(int count) async {
    final receipt = selected;
    if (receipt == null) return;
    try {
      final list = await _buildFreshRows(receipt.id, count);
      sampleRows = list;
      activeRowIndex = null;
      await _persistReceiptAggregate(recomputeReceiptStatus: true);
      receipts = await _api.fetchAll();
      selected = await _api.fetchById(receipt.id);
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
        if (!receipt.isReceiptTrackingPending) {
          status = SampleIntakeStatus.receiptComplete;
        }
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

  Future<void> saveRow(int index) async {
    final receipt = selected;
    if (receipt == null || index < 0 || index >= sampleRows.length) {
      return;
    }
    final row = sampleRows[index];
    final baseline = row.runningHrsBaseline;
    final hrs = row.runningHrs;
    if (baseline != null && hrs != null && hrs <= baseline) {
      setError(
        'Running hours must be greater than previous (${baseline.toString()}).',
      );
      notifyListeners();
      return;
    }
    try {
      final nextRows = List<SampleRowModel>.from(sampleRows);
      nextRows[index] = nextRows[index].copyWith(isCompleted: true);
      sampleRows = nextRows;
      await _api.upsertRows(receipt.id, sampleRows);
      final completed = getCompletedCount();
      String status = receipt.status;
      DateTime? intakeCompletedAt = receipt.intakeCompletedAt;
      if (completed >= receipt.noOfSamples && receipt.noOfSamples > 0) {
        status = SampleIntakeStatus.completed;
        intakeCompletedAt ??= DateTime.now();
      } else {
        status = SampleIntakeStatus.inProgress;
      }
      final nextReceipt = receipt.copyWith(
        dataEntryCompletedCount: completed,
        status: status,
        intakeCompletedAt: intakeCompletedAt,
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

  /// Quick receipt (tracking draft).
  Future<String?> saveQuickReceipt(Map<String, dynamic> data) async {
    String? newId;
    await runAsync(() async {
      final payload = Map<String, dynamic>.from(data)
        ..['status'] = SampleIntakeStatus.trackingDraft
        ..['dataEntryCompletedCount'] = 0
        ..['id'] = ''
        ..['lotNo'] = data['lotNo'] ?? _api.allocateLotNo();
      final created =
          await _api.create(SampleIntakeModel.fromJson(payload));
      newId = created.id;
      receipts = await _api.fetchAll();
    });
    if (hasError) return null;
    return newId;
  }

  /// Full operational receipt create (e.g. enquiry prefill) → intake queue.
  Future<String?> createReceipt(Map<String, dynamic> data) async {
    String? newId;
    await runAsync(() async {
      final payload = Map<String, dynamic>.from(data)
        ..['status'] =
            data['status'] ?? SampleIntakeStatus.receiptComplete
        ..['dataEntryCompletedCount'] = 0
        ..['id'] = '';
      final created =
          await _api.create(SampleIntakeModel.fromJson(payload));
      newId = created.id;
      receipts = await _api.fetchAll();
    });
    if (hasError) return null;
    return newId;
  }

  /// Create samples — new receipt row; optional [linkReceiptId] copies party/site from that receipt.
  Future<String?> createSamples({
    String? linkReceiptId,
    required int noOfSamples,
    required String typeOfSample,
    String internalNotes = '',
  }) async {
    String? newId;
    await runAsync(() async {
      final now = DateTime.now();
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      Map<String, dynamic> payload;

      final link = (linkReceiptId != null && linkReceiptId.isNotEmpty)
          ? await _api.fetchById(linkReceiptId)
          : null;
      if (link != null) {
        payload = Map<String, dynamic>.from(link.toJson());
      } else {
        payload = {
          'receiptDate': now.toIso8601String(),
          'receiptTime': time,
          'customerName': '',
          'customerCompany': '',
          'customerAddress': '',
          'customerMobile': '',
          'customerEmail': '',
          'siteContactPerson': '',
          'siteCompany': '',
          'siteAddress': '',
          'siteMobile': '',
          'siteEmail': '',
          'reportExpectedBy': null,
          'workOrderNo': '',
          'workOrderDate': null,
          'additionalInformation': null,
          'courierName': '',
          'podNo': '',
          'sampleDispatchedFromSite': false,
          'sampleCollectedFromCollectionCenter': false,
          'sampleReceivedAtCollectionCenter': false,
          'sampleReceivedAtLab': false,
          'freightCharges': null,
          'receivedBy': '',
          'receiptMode': '',
        };
      }

      final n = noOfSamples < 1 ? 1 : noOfSamples;
      payload
        ..['id'] = ''
        ..['lotNo'] = _api.allocateLotNo()
        ..['noOfSamples'] = n
        ..['typeOfSample'] = typeOfSample
        ..['internalNotes'] = internalNotes
        ..['status'] = SampleIntakeStatus.receiptComplete
        ..['dataEntryCompletedCount'] = 0
        ..['primarySampleId'] = ''
        ..['intakeCompletedAt'] = null;

      final created =
          await _api.create(SampleIntakeModel.fromJson(payload));
      newId = created.id;
      receipts = await _api.fetchAll();
    });
    if (hasError) return null;
    return newId;
  }

  Future<void> saveReceiptDraftFromCompleteForm(
    String id,
    Map<String, dynamic> patch,
  ) async {
    await updateReceiptFromForm(id, patch);
  }

  Future<void> saveReceiptAndContinueToQueue(
    String id,
    Map<String, dynamic> patch,
  ) async {
    await runAsync(() async {
      final existing = await _api.fetchById(id);
      if (existing == null) {
        setError('Receipt not found');
        return;
      }
      final merged = SampleIntakeModel.fromJson({
        ...existing.toJson(),
        ...patch,
        'id': id,
        'status': SampleIntakeStatus.receiptComplete,
      });
      await _api.update(id, merged);
      selected = merged;
      receipts = await _api.fetchAll();
    });
    await fetchById(id);
  }

  Future<void> persistDatasheetGrid(String receiptId) async {
    await runAsync(() async {
      await _api.upsertRows(receiptId, sampleRows);
      receipts = await _api.fetchAll();
      notifyListeners();
    });
  }

  Future<void> generateLabCodesForSamples({
    required String receiptId,
    required Iterable<int> rowIndexes,
    bool regenerate = false,
  }) async {
    await runAsync(() async {
      final receipt = await _api.fetchById(receiptId);
      if (receipt == null) {
        setError('Receipt not found');
        return;
      }
      var rows = List<SampleRowModel>.from(await _api.fetchRows(receiptId));
      if (rows.isEmpty && receipt.noOfSamples > 0) {
        rows = [
          for (var i = 0; i < receipt.noOfSamples; i++)
            SampleRowModel.empty(
              index: i + 1,
              sampleId: _api.nextSampleId(),
            ),
        ];
        await _api.upsertRows(receiptId, rows);
      }
      for (final i in rowIndexes) {
        if (i < 0 || i >= rows.length) continue;
        final row = rows[i];
        final code =
            regenerate || (row.generatedLabCode?.isEmpty ?? true)
                ? _labCodeApi.allocateLabCode()
                : row.generatedLabCode!;
        await _labCodeApi.upsertFromIntake(
          sampleId: row.sampleId,
          linkedReceiptId: receiptId,
          customerName: receipt.customerName,
          customerCompany: receipt.customerCompany,
          sampleType: row.typeOfSample ?? receipt.typeOfSample,
          siteCompany: receipt.siteCompany,
          labCode: code,
        );
        rows[i] = row.copyWith(
          generatedLabCode: code,
          labelStatus: 'Pending',
        );
      }
      await _api.upsertRows(receiptId, rows);
      var status = receipt.status;
      if (rows.isNotEmpty &&
          rows.every((r) => (r.generatedLabCode ?? '').isNotEmpty)) {
        status = SampleIntakeStatus.completed;
      }
      final updated = receipt.copyWith(status: status);
      await _api.update(receiptId, updated);
      if (selected?.id == receiptId) {
        sampleRows = rows;
        selected = updated;
      }
      receipts = await _api.fetchAll();
      notifyListeners();
    });
  }

  Future<void> forwardReceiptToLabModule(String receiptId) async {
    await runAsync(() async {
      final receipt = await _api.fetchById(receiptId);
      if (receipt == null) return;
      final rows = await _api.fetchRows(receiptId);
      final now = DateTime.now();
      for (final row in rows) {
        final code = row.generatedLabCode;
        if (code != null && code.isNotEmpty) {
          await _labCodeApi.upsertFromIntake(
            sampleId: row.sampleId,
            linkedReceiptId: receiptId,
            customerName: receipt.customerName,
            customerCompany: receipt.customerCompany,
            sampleType: row.typeOfSample ?? receipt.typeOfSample,
            siteCompany: receipt.siteCompany,
            labCode: code,
          );
        }
      }
      final next = receipt.copyWith(
        status: SampleIntakeStatus.forwardedToLab,
        intakeCompletedAt: receipt.intakeCompletedAt ?? now,
        generatedBy: receipt.generatedBy.isEmpty
            ? 'Current user'
            : receipt.generatedBy,
      );
      await _api.update(receiptId, next);
      receipts = await _api.fetchAll();
      notifyListeners();
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

  Future<void> deleteSampleRow(int index) async {
    final receipt = selected;
    if (receipt == null ||
        index < 0 ||
        index >= sampleRows.length ||
        sampleRows.length <= 1) {
      return;
    }
    await runAsync(() async {
      final next = List<SampleRowModel>.from(sampleRows)..removeAt(index);
      final reindexed = [
        for (var i = 0; i < next.length; i++)
          next[i].copyWith(index: i + 1),
      ];
      sampleRows = reindexed;
      await _api.upsertRows(receipt.id, sampleRows);
      await _api.update(
        receipt.id,
        receipt.copyWith(noOfSamples: sampleRows.length),
      );
      receipts = await _api.fetchAll();
      selected = await _api.fetchById(receipt.id);
      await _persistReceiptAggregate(recomputeReceiptStatus: true);
    });
  }

  Future<void> addSampleRow() async {
    final receipt = selected;
    if (receipt == null) return;
    await runAsync(() async {
      final next = List<SampleRowModel>.from(sampleRows)
        ..add(
          SampleRowModel.empty(
            index: sampleRows.length + 1,
            sampleId: _api.nextSampleId(),
          ),
        );
      final reindexed = [
        for (var i = 0; i < next.length; i++)
          next[i].copyWith(index: i + 1),
      ];
      sampleRows = reindexed;
      await _api.upsertRows(receipt.id, sampleRows);
      await _api.update(
        receipt.id,
        receipt.copyWith(noOfSamples: sampleRows.length),
      );
      receipts = await _api.fetchAll();
      selected = await _api.fetchById(receipt.id);
      notifyListeners();
    });
  }
}
