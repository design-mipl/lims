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
        customerName: 'IDEMITSU LUBE INDIA PVT LTD',
        customerCompany: 'IDEMITSU LUBE INDIA PVT LTD',
        sampleType: 'USED ENGINE OIL',
        status: LabCodeStatus.completed,
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

  Future<void> delete(String id) async {
    _items = _items.where((e) => e.id != id).toList();
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    final remove = ids.toSet();
    _items = _items.where((e) => !remove.contains(e.id)).toList();
  }
}
