import 'sample_intake_model.dart';
import 'sample_row_model.dart';

/// In-memory mock API for Sample Intake & Data Entry.
class SampleIntakeApi {
  SampleIntakeApi() {
    final now = DateTime.now();
    _items = [
      SampleIntakeModel(
        id: 'si-1',
        lotNo: 'LOT-2026-001',
        receiptDate: DateTime(now.year, now.month, now.day - 2),
        receiptTime: '09:15',
        courierName: 'BlueDart',
        podNo: 'POD-88231',
        noOfSamples: 10,
        customerName: 'Ravi Kumar',
        customerCompany: 'Acme Industries Pvt Ltd',
        customerAddress: 'Plot 12, MIDC Phase 2',
        customerMobile: '9876543210',
        customerEmail: 'ravi@acme-mock.in',
        siteContactPerson: 'Site Manager A',
        siteCompany: 'Acme Plant Mumbai',
        siteAddress: 'Taloja, Navi Mumbai',
        siteMobile: '9123456780',
        siteEmail: 'site@acme-mock.in',
        reportExpectedBy: now.add(const Duration(days: 5)),
        workOrderNo: 'WO-1042',
        workOrderDate: now.subtract(const Duration(days: 3)),
        additionalInformation: 'Urgent turnaround.',
        sampleDispatchedFromSite: true,
        sampleCollectedFromCollectionCenter: true,
        sampleReceivedAtCollectionCenter: true,
        sampleReceivedAtLab: false,
        freightCharges: 450.0,
        dataEntryCompletedCount: 3,
        status: SampleIntakeStatus.dataEntryPending,
      ),
      SampleIntakeModel(
        id: 'si-2',
        lotNo: 'LOT-2026-002',
        receiptDate: DateTime(now.year, now.month, now.day - 1),
        receiptTime: '14:40',
        courierName: 'DTDC',
        podNo: 'POD-99102',
        noOfSamples: 5,
        customerName: 'Priya Sharma',
        customerCompany: 'Zenith Labs',
        customerAddress: 'Electronics City',
        customerMobile: '9988776655',
        customerEmail: 'priya@zenith-mock.in',
        siteContactPerson: 'Lab Incharge',
        siteCompany: 'Zenith Bangalore',
        siteAddress: 'Phase 1, E-City',
        siteMobile: '9090909090',
        siteEmail: 'blr@zenith-mock.in',
        reportExpectedBy: now.add(const Duration(days: 2)),
        workOrderNo: 'WO-1048',
        workOrderDate: now.subtract(const Duration(days: 1)),
        additionalInformation: null,
        sampleDispatchedFromSite: true,
        sampleCollectedFromCollectionCenter: false,
        sampleReceivedAtCollectionCenter: false,
        sampleReceivedAtLab: false,
        freightCharges: null,
        dataEntryCompletedCount: 0,
        status: SampleIntakeStatus.inProgress,
      ),
      SampleIntakeModel(
        id: 'si-3',
        lotNo: 'LOT-2026-003',
        receiptDate: DateTime(now.year, now.month, now.day - 5),
        receiptTime: '11:00',
        courierName: 'FedEx',
        podNo: 'POD-77331',
        noOfSamples: 8,
        customerName: 'Amit Desai',
        customerCompany: 'Coastal Petro',
        customerAddress: 'Refinery Road',
        customerMobile: '9812345678',
        customerEmail: 'amit@coastal-mock.in',
        siteContactPerson: 'Ops Head',
        siteCompany: 'Coastal Jamnagar',
        siteAddress: 'Sector 7',
        siteMobile: '9822233344',
        siteEmail: 'jam@coastal-mock.in',
        reportExpectedBy: now.subtract(const Duration(days: 1)),
        workOrderNo: 'WO-1030',
        workOrderDate: now.subtract(const Duration(days: 7)),
        additionalInformation: null,
        sampleDispatchedFromSite: true,
        sampleCollectedFromCollectionCenter: true,
        sampleReceivedAtCollectionCenter: true,
        sampleReceivedAtLab: true,
        freightCharges: 200.0,
        dataEntryCompletedCount: 8,
        status: SampleIntakeStatus.forwardedToLab,
      ),
    ];
  }

  final Map<String, List<SampleRowModel>> _rowsByReceiptId =
      <String, List<SampleRowModel>>{};
  int _nextUsn = 585459;

  late List<SampleIntakeModel> _items;

  int _nextId = 4;

  Future<List<SampleIntakeModel>> fetchAll() async {
    return List<SampleIntakeModel>.unmodifiable(_items);
  }

  Future<SampleIntakeModel?> fetchById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<SampleIntakeModel> create(SampleIntakeModel receipt) async {
    final id = receipt.id.isEmpty ? 'si-${_nextId++}' : receipt.id;
    final created = receipt.copyWith(id: id);
    _items = [..._items, created];
    return created;
  }

  Future<void> update(String id, SampleIntakeModel receipt) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw StateError('Receipt not found: $id');
    final next = List<SampleIntakeModel>.from(_items);
    next[idx] = receipt.copyWith(id: id);
    _items = next;
  }

  Future<void> delete(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    _rowsByReceiptId.remove(id);
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    final remove = ids.toSet();
    _items = _items.where((e) => !remove.contains(e.id)).toList();
    for (final id in remove) {
      _rowsByReceiptId.remove(id);
    }
  }

  /// Monotonic mock USN id (e.g. USN585459).
  String nextSampleId() {
    final v = _nextUsn;
    _nextUsn++;
    return 'USN$v';
  }

  Future<List<SampleRowModel>> fetchRows(String receiptId) async {
    await Future<void>.delayed(Duration.zero);
    final list = _rowsByReceiptId[receiptId];
    if (list == null) return const [];
    return List<SampleRowModel>.from(list);
  }

  Future<void> upsertRows(String receiptId, List<SampleRowModel> rows) async {
    await Future<void>.delayed(Duration.zero);
    _rowsByReceiptId[receiptId] =
        List<SampleRowModel>.from(rows, growable: false);
  }
}
