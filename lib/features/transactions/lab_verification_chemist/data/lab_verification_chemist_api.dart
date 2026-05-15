import '../../shared/lab_workflow_detail_lines.dart';
import 'lab_verification_chemist_model.dart';

/// In-memory mock API for Lab Verification Chemist.
class LabVerificationChemistApi {
  LabVerificationChemistApi() {
    final now = DateTime.now();
    _items = [
      _row(
        id: 'lvc-1',
        verified: false,
        typeOfSample: 'LUBE OIL',
        labId: 'LAB-1001',
        dateOfReceipt: DateTime(now.year, now.month, now.day - 5),
        customerName: 'IDEMITSU LUBE INDIA PVT LTD',
        customerCompany: 'IDEMITSU LUBE INDIA PVT LTD',
        lotNo: 'LOT-77821',
        sampleId: '65LI0073',
        make: 'Shell',
        model: 'Turbo T46',
        serialNo: 'SN-T46-991',
        brandOfOil: 'Helix',
        grade: 'ISO VG 46',
        equipmentNo: 'EQ-MUM-01',
        lubeHrs: 4120.5,
        hmr: 'HMR-2041',
        reportId: 'RPT-LVC-001',
      ),
      _row(
        id: 'lvc-2',
        verified: false,
        typeOfSample: 'USED ENGINE OIL',
        labId: 'LAB-1002',
        dateOfReceipt: DateTime(now.year, now.month, now.day - 4),
        customerName: 'Amit Desai',
        customerCompany: 'Coastal Petro',
        lotNo: 'LOT-77822',
        sampleId: 'ES150',
        make: 'Cummins',
        model: 'QSB6.7',
        serialNo: 'CMI-44002',
        brandOfOil: 'Delo',
        grade: '15W-40',
        equipmentNo: 'EQ-JAM-12',
        lubeHrs: 8900,
        hmr: 'HMR-2042',
        reportId: 'RPT-LVC-002',
      ),
      _row(
        id: 'lvc-3',
        verified: true,
        typeOfSample: 'Coolant',
        labId: 'LAB-1001',
        dateOfReceipt: DateTime(now.year, now.month, now.day - 3),
        customerName: 'Neha Patel',
        customerCompany: 'Northwind Traders',
        lotNo: 'LOT-77823',
        sampleId: 'USN585462',
        make: 'Atlas Copco',
        model: 'GA 75',
        serialNo: 'AC-GA75-88',
        brandOfOil: 'Coolant XL',
        grade: 'Concentrate',
        equipmentNo: 'EQ-PUN-04',
        lubeHrs: 1200,
        hmr: 'HMR-1881',
        reportId: 'RPT-LVC-003',
      ),
      _row(
        id: 'lvc-4',
        verified: false,
        typeOfSample: 'Hydraulic fluid',
        labId: 'LAB-1003',
        dateOfReceipt: DateTime(now.year, now.month, now.day - 2),
        customerName: 'Vikram Singh',
        customerCompany: 'Steelworks Ltd',
        lotNo: 'LOT-77824',
        sampleId: 'USN585463',
        make: 'Komatsu',
        model: 'PC 200',
        serialNo: 'KM-PC200-77',
        brandOfOil: 'Hydraulic H68',
        grade: 'ISO VG 68',
        equipmentNo: 'EQ-BOK-03',
        lubeHrs: 15600.25,
        hmr: 'HMR-1902',
        reportId: 'RPT-LVC-004',
      ),
      _row(
        id: 'lvc-5',
        verified: true,
        typeOfSample: 'Metal swarf',
        labId: 'LAB-1002',
        dateOfReceipt: DateTime(now.year, now.month, now.day - 1),
        customerName: 'Ananya Iyer',
        customerCompany: 'BioPharm Co',
        lotNo: 'LOT-77825',
        sampleId: 'USN585464',
        make: 'GEA',
        model: 'Separator X',
        serialNo: 'GEA-X-102',
        brandOfOil: 'N/A',
        grade: '—',
        equipmentNo: 'EQ-HYD-09',
        lubeHrs: 0,
        hmr: 'HMR-2010',
        reportId: 'RPT-LVC-005',
      ),
      _row(
        id: 'lvc-6',
        verified: false,
        typeOfSample: 'Process water',
        labId: 'LAB-1003',
        dateOfReceipt: DateTime(now.year, now.month, now.day),
        customerName: 'Rahul Menon',
        customerCompany: 'IDEMITSU Mumbai Plant',
        lotNo: 'LOT-77826',
        sampleId: 'USN585465',
        make: 'Siemens',
        model: 'RO Unit 2',
        serialNo: 'SI-RO-2',
        brandOfOil: 'N/A',
        grade: '—',
        equipmentNo: 'EQ-MUM-07',
        lubeHrs: 0,
        hmr: 'HMR-2100',
        reportId: 'RPT-LVC-006',
      ),
      _row(
        id: 'lvc-7',
        verified: true,
        typeOfSample: 'LUBE OIL',
        labId: 'LAB-1001',
        dateOfReceipt: DateTime(now.year, now.month - 1, 15),
        customerName: 'S. Kumar',
        customerCompany: 'IDEMITSU Chennai DC',
        lotNo: 'LOT-77001',
        sampleId: 'CHN-884',
        make: 'BP',
        model: 'Energear',
        serialNo: 'BP-EG-221',
        brandOfOil: 'Castrol',
        grade: 'ISO VG 220',
        equipmentNo: 'EQ-CHN-02',
        lubeHrs: 3400,
        hmr: 'HMR-1800',
        reportId: 'RPT-LVC-007',
      ),
      _row(
        id: 'lvc-8',
        verified: false,
        typeOfSample: 'USED ENGINE OIL',
        labId: 'LAB-1002',
        dateOfReceipt: DateTime(now.year, now.month - 1, 8),
        customerName: 'Plant Ops',
        customerCompany: 'Coastal Jamnagar',
        lotNo: 'LOT-77002',
        sampleId: 'JAM-552',
        make: 'Wärtsilä',
        model: 'W20',
        serialNo: 'WRT-20-09',
        brandOfOil: 'Mobil',
        grade: 'SAE 40',
        equipmentNo: 'EQ-JAM-01',
        lubeHrs: 22000,
        hmr: 'HMR-1755',
        reportId: 'RPT-LVC-008',
      ),
    ];
  }

  late List<LabVerificationChemistModel> _items;

  LabVerificationChemistModel _row({
    required String id,
    required bool verified,
    required String typeOfSample,
    required String labId,
    required DateTime dateOfReceipt,
    required String customerName,
    required String customerCompany,
    required String lotNo,
    required String sampleId,
    required String make,
    required String model,
    required String serialNo,
    required String brandOfOil,
    required String grade,
    required String equipmentNo,
    required double lubeHrs,
    required String hmr,
    required String reportId,
  }) {
    return LabVerificationChemistModel(
      id: id,
      verified: verified,
      typeOfSample: typeOfSample,
      labId: labId,
      dateOfReceipt: dateOfReceipt,
      customerName: customerName,
      customerCompany: customerCompany,
      lotNo: lotNo,
      sampleId: sampleId,
      make: make,
      model: model,
      serialNo: serialNo,
      brandOfOil: brandOfOil,
      grade: grade,
      equipmentNo: equipmentNo,
      lubeHrs: lubeHrs,
      hmr: hmr,
      reportId: reportId,
      status: verified ? 'completed' : null,
      testLines:
          labWorkflowChemistVerificationDetailLines(rowId: id, parentVerified: verified),
    );
  }

  Future<List<LabVerificationChemistModel>> fetchAll() async {
    return List<LabVerificationChemistModel>.unmodifiable(_items);
  }

  Future<LabVerificationChemistModel?> fetchById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> verifyIds(List<String> ids) async {
    final idSet = ids.toSet();
    _items = _items.map((e) {
      if (!idSet.contains(e.id)) return e;
      final lines =
          e.testLines.map((l) => l.copyWith(lineVerified: true)).toList();
      return e.copyWith(
        verified: true,
        status: 'completed',
        testLines: lines,
      );
    }).toList();
  }

  Future<void> verifyTestLine(String parentId, int lineNo) async {
    final i = _items.indexWhere((e) => e.id == parentId);
    if (i < 0) return;
    final e = _items[i];
    final lines = e.testLines
        .map(
          (l) => l.lineNo == lineNo ? l.copyWith(lineVerified: true) : l,
        )
        .toList();
    final allLinesDone = lines.isNotEmpty && lines.every((l) => l.lineVerified);
    _items[i] = e.copyWith(
      testLines: lines,
      verified: allLinesDone,
      status: allLinesDone ? 'completed' : e.status,
    );
  }
}
