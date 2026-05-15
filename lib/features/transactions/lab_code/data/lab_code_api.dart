import 'lab_code_model.dart';

/// In-memory mock API for Lab Code listing.
class LabCodeApi {
  LabCodeApi() {
    final now = DateTime.now();
    _items = [
      LabCodeModel(
        id: 'lc-1',
        recordedAt: DateTime(now.year, now.month, now.day),
        sampleId: '65LI0073',
        labCode: null,
        customerName: 'IDEMITSU LUBE INDIA PVT LTD',
        customerCompany: 'IDEMITSU LUBE INDIA PVT LTD',
        sampleType: 'LUBE OIL',
        status: LabCodeStatus.pending,
        siteContactPerson: 'Rahul Menon',
        siteCompany: 'IDEMITSU Mumbai Plant',
        workOrderNo: 'WO-LC-2041',
        createdBy: 'system',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedBy: 'system',
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      LabCodeModel(
        id: 'lc-2',
        recordedAt: DateTime(now.year, now.month, now.day - 1),
        sampleId: 'ES150',
        labCode: 'LCN-2026/05-639',
        linkedSampleReceiptId: 'si-1',
        customerName: 'IDEMITSU LUBE INDIA PVT LTD',
        customerCompany: 'IDEMITSU LUBE INDIA PVT LTD',
        sampleType: 'USED ENGINE OIL',
        status: LabCodeStatus.completed,
        siteContactPerson: 'S. Kumar',
        siteCompany: 'IDEMITSU Chennai DC',
        workOrderNo: 'WO-LC-2042',
        createdBy: 'system',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedBy: 'system',
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      LabCodeModel(
        id: 'lc-3',
        recordedAt: DateTime(now.year, now.month, now.day - 2),
        sampleId: 'USN585462',
        labCode: null,
        customerName: 'Amit Desai',
        customerCompany: 'Coastal Petro',
        sampleType: 'Coolant',
        status: LabCodeStatus.pending,
        siteContactPerson: 'Plant Ops',
        siteCompany: 'Coastal Jamnagar',
        workOrderNo: 'WO-LC-1030',
        createdBy: 'system',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedBy: 'system',
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      LabCodeModel(
        id: 'lc-4',
        recordedAt: DateTime(now.year, now.month, now.day - 3),
        sampleId: 'USN585463',
        labCode: 'LCN-2026/05-640',
        customerName: 'Neha Patel',
        customerCompany: 'Northwind Traders',
        sampleType: 'Hydraulic fluid',
        status: LabCodeStatus.completed,
        siteContactPerson: 'Warehouse Lead',
        siteCompany: 'Northwind Pune',
        workOrderNo: 'WO-LC-1881',
        createdBy: 'system',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedBy: 'system',
        updatedAt: now.subtract(const Duration(hours: 40)),
      ),
      LabCodeModel(
        id: 'lc-5',
        recordedAt: DateTime(now.year, now.month, now.day - 1),
        sampleId: 'USN585464',
        labCode: null,
        customerName: 'Vikram Singh',
        customerCompany: 'Steelworks Ltd',
        sampleType: 'Metal swarf',
        status: LabCodeStatus.pending,
        siteContactPerson: 'Floor Supervisor',
        siteCompany: 'Steelworks Bokaro',
        workOrderNo: 'WO-LC-1902',
        createdBy: 'system',
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedBy: null,
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      LabCodeModel(
        id: 'lc-6',
        recordedAt: DateTime(now.year, now.month, now.day - 4),
        sampleId: 'USN585465',
        labCode: 'LCN-2026/05-641',
        customerName: 'Ananya Iyer',
        customerCompany: 'BioPharm Co',
        sampleType: 'Process water',
        status: LabCodeStatus.completed,
        siteContactPerson: 'QA Manager',
        siteCompany: 'BioPharm Hyderabad',
        workOrderNo: 'WO-LC-2010',
        createdBy: 'system',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedBy: 'system',
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  late List<LabCodeModel> _items;

  Future<List<LabCodeModel>> fetchAll() async {
    return List<LabCodeModel>.unmodifiable(_items);
  }

  Future<LabCodeModel?> fetchById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    _items = _items.where((e) => e.id != id).toList();
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    final remove = ids.toSet();
    _items = _items.where((e) => !remove.contains(e.id)).toList();
  }

  int _nextLabCodeSeq = 642;
  int _nextLabRowId = 900;

  /// Allocate next synthetic lab code string for intake workflow.
  String allocateLabCode() {
    final y = DateTime.now().year;
    final m = DateTime.now().month.toString().padLeft(2, '0');
    final id = _nextLabCodeSeq++;
    return 'LCN-$y/$m-$id';
  }

  /// Upsert a lab code row by sample id (one row per sample in mock store).
  Future<LabCodeModel> upsertFromIntake({
    required String sampleId,
    required String linkedReceiptId,
    required String customerName,
    required String customerCompany,
    required String sampleType,
    String? siteCompany,
    String? labCode,
  }) async {
    await Future<void>.delayed(Duration.zero);
    final now = DateTime.now();
    final idx = _items.indexWhere((e) => e.sampleId == sampleId);
    if (idx >= 0) {
      final existing = _items[idx];
      final updated = List<LabCodeModel>.from(_items);
      updated[idx] = existing.copyWith(
        labCode: labCode ?? existing.labCode,
        linkedSampleReceiptId: linkedReceiptId,
        customerName: customerName,
        customerCompany: customerCompany,
        sampleType: sampleType,
        siteCompany: siteCompany ?? existing.siteCompany,
        status: labCode != null && labCode.isNotEmpty
            ? LabCodeStatus.completed
            : LabCodeStatus.pending,
        updatedAt: now,
        updatedBy: 'intake',
      );
      _items = updated;
      return updated[idx];
    }
    final id = 'lc-gen-${_nextLabRowId++}';
    final row = LabCodeModel(
      id: id,
      recordedAt: DateTime(now.year, now.month, now.day),
      sampleId: sampleId,
      labCode: labCode,
      linkedSampleReceiptId: linkedReceiptId,
      customerName: customerName,
      customerCompany: customerCompany,
      sampleType: sampleType,
      status: labCode != null && labCode.isNotEmpty
          ? LabCodeStatus.completed
          : LabCodeStatus.pending,
      siteCompany: siteCompany,
      createdBy: 'intake',
      createdAt: now,
      updatedAt: now,
    );
    _items = [..._items, row];
    return row;
  }

  Future<void> updateLabCodeRow(String id, LabCodeModel row) async {
    await Future<void>.delayed(Duration.zero);
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final next = List<LabCodeModel>.from(_items);
    next[idx] = row;
    _items = next;
  }
}
