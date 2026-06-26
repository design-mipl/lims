import '../../shared/lab_manager_listing_row.dart';
import '../../shared/lab_workflow_detail_lines.dart';

/// Mock API for Lab Manager Verification listing.
class LabManagerVerificationApi {
  LabManagerVerificationApi() {
    _items = _seedRows();
  }

  late List<LabManagerListingRow> _items;

  List<LabManagerListingRow> _seedRows() {
    final now = DateTime.now();
    LabManagerListingRow r({
      required String id,
      required bool verified,
      required String company,
      required String site,
      required String type,
      required int daysAgoSample,
      required String lot,
      required String lab,
      required int daysAgoLab,
      required double lube,
      required String hmr,
      required int daysAgoReceipt,
      required String equip,
      required String sample,
      required String make,
      required String model,
      required String serial,
      required String brand,
      required String grade,
      required String ref,
      required String narr,
      required String addl,
      required String custNote,
      required String report,
    }) {
      final sampleDate = now.subtract(Duration(days: daysAgoSample));
      final labDate = now.subtract(Duration(days: daysAgoLab));
      final receiptDate = now.subtract(Duration(days: daysAgoReceipt));
      return LabManagerListingRow(
        id: id,
        verified: verified,
        companyName: company,
        siteName: site,
        typeOfSample: type,
        samplingDate: sampleDate,
        lotNo: lot,
        labId: lab,
        labDate: labDate,
        lubeHrs: lube,
        hmr: hmr,
        dateOfReceipt: receiptDate,
        equipmentNo: equip,
        sampleId: sample,
        make: make,
        model: model,
        serialNo: serial,
        brandOfOil: brand,
        grade: grade,
        referenceNo: ref,
        narration: narr,
        additionalRemarks: addl,
        customerNotes: custNote,
        reportId: report,
        testLines: labWorkflowManagerVerificationDetailLines(
          rowId: id,
          parentVerified: verified,
        ),
      );
    }

    return [
      r(
        id: 'lmv-1',
        verified: true,
        company: 'Acme Industries Pvt Ltd',
        site: 'Mumbai Plant',
        type: 'LUBE OIL',
        daysAgoSample: 4,
        lot: 'LOT-2026-011',
        lab: 'LCN-2026/05-701',
        daysAgoLab: 3,
        lube: 4200,
        hmr: '12,480',
        daysAgoReceipt: 2,
        equip: 'EQ-M-104',
        sample: 'USN585500',
        make: 'Siemens',
        model: 'SIM-440',
        serial: 'SN-MU-99102',
        brand: 'Shell',
        grade: 'ISO VG 68',
        ref: 'REF-88231',
        narr: 'Routine annual sample per SOP-12.',
        addl: 'Lab temp 22°C.',
        custNote: 'Expedite if possible.',
        report: 'RPT-2026-0441',
      ),
      r(
        id: 'lmv-2',
        verified: false,
        company: 'Zenith Labs',
        site: 'Bangalore DC',
        type: 'USED ENGINE OIL',
        daysAgoSample: 2,
        lot: 'LOT-2026-014',
        lab: 'LCN-2026/05-705',
        daysAgoLab: 1,
        lube: 3100,
        hmr: '8,200',
        daysAgoReceipt: 1,
        equip: 'EQ-Z-022',
        sample: 'USN585501',
        make: 'ABB',
        model: 'ABB-220',
        serial: 'SN-BLR-22001',
        brand: 'Mobil',
        grade: 'SAE 15W-40',
        ref: 'REF-88240',
        narr: 'High soot noted in previous cycle.',
        addl: '',
        custNote: '',
        report: 'RPT-2026-0445',
      ),
      r(
        id: 'lmv-3',
        verified: false,
        company: 'Coastal Petro',
        site: 'Jamnagar',
        type: 'Coolant',
        daysAgoSample: 6,
        lot: 'LOT-2026-009',
        lab: 'LCN-2026/05-698',
        daysAgoLab: 5,
        lube: 0,
        hmr: '—',
        daysAgoReceipt: 4,
        equip: 'EQ-C-301',
        sample: 'USN585502',
        make: 'Grundfos',
        model: 'CR-32',
        serial: 'SN-JAM-5521',
        brand: 'Castrol',
        grade: 'TBN 6',
        ref: 'REF-88190',
        narr: 'Coolant dilution check requested.',
        addl: 'OEM tag attached.',
        custNote: 'Call lab before release.',
        report: 'RPT-2026-0438',
      ),
      r(
        id: 'lmv-4',
        verified: true,
        company: 'Northwind Traders',
        site: 'Pune WH',
        type: 'Hydraulic fluid',
        daysAgoSample: 3,
        lot: 'LOT-2026-012',
        lab: 'LCN-2026/05-702',
        daysAgoLab: 2,
        lube: 8900,
        hmr: '15,100',
        daysAgoReceipt: 2,
        equip: 'EQ-N-118',
        sample: 'USN585503',
        make: 'Bosch',
        model: 'HYD-90',
        serial: 'SN-PN-77881',
        brand: 'Valvoline',
        grade: 'ISO VG 46',
        ref: 'REF-88211',
        narr: 'Pressure line from press #4.',
        addl: '',
        custNote: '',
        report: 'RPT-2026-0442',
      ),
      r(
        id: 'lmv-5',
        verified: false,
        company: 'Steelworks Ltd',
        site: 'Bokaro',
        type: 'Metal swarf',
        daysAgoSample: 1,
        lot: 'LOT-2026-016',
        lab: 'LCN-2026/05-706',
        daysAgoLab: 0,
        lube: 1200,
        hmr: '3,400',
        daysAgoReceipt: 0,
        equip: 'EQ-S-205',
        sample: 'USN585504',
        make: 'SKF',
        model: 'LAB-SW',
        serial: 'SN-BK-12009',
        brand: 'Indian Oil',
        grade: 'Synthetic 5W-30',
        ref: 'REF-88255',
        narr: 'Swarf from gearbox line.',
        addl: 'Wear debris suspected.',
        custNote: '',
        report: 'RPT-2026-0449',
      ),
      r(
        id: 'lmv-6',
        verified: true,
        company: 'BioPharm Co',
        site: 'Hyderabad',
        type: 'Process water',
        daysAgoSample: 7,
        lot: 'LOT-2026-008',
        lab: 'LCN-2026/05-695',
        daysAgoLab: 6,
        lube: 0,
        hmr: '—',
        daysAgoReceipt: 5,
        equip: 'EQ-B-077',
        sample: 'USN585505',
        make: 'Pall',
        model: 'PW-01',
        serial: 'SN-HYD-3300',
        brand: 'HP Lubricants',
        grade: 'ISO VG 46',
        ref: 'REF-88155',
        narr: 'Water treatment skid inlet.',
        addl: '',
        custNote: 'QA sign-off required.',
        report: 'RPT-2026-0430',
      ),
      r(
        id: 'lmv-7',
        verified: false,
        company: 'Acme Industries Pvt Ltd',
        site: 'Taloja',
        type: 'Grease',
        daysAgoSample: 5,
        lot: 'LOT-2026-013',
        lab: 'LCN-2026/05-703',
        daysAgoLab: 4,
        lube: 650,
        hmr: '1,200',
        daysAgoReceipt: 3,
        equip: 'EQ-M-099',
        sample: 'USN585506',
        make: 'Atlas Copco',
        model: 'GR-LD',
        serial: 'SN-TJ-6612',
        brand: 'Shell',
        grade: 'SAE 20W-50',
        ref: 'REF-88222',
        narr: 'High-temp wheel bearing grease.',
        addl: '',
        custNote: '',
        report: 'RPT-2026-0443',
      ),
      r(
        id: 'lmv-8',
        verified: true,
        company: 'IDEMITSU LUBE INDIA PVT LTD',
        site: 'Chennai',
        type: 'Fuel',
        daysAgoSample: 8,
        lot: 'LOT-2026-007',
        lab: 'LCN-2026/05-690',
        daysAgoLab: 7,
        lube: 200,
        hmr: '500',
        daysAgoReceipt: 6,
        equip: 'EQ-I-044',
        sample: '65LI0090',
        make: 'Yokogawa',
        model: 'FL-200',
        serial: 'SN-CH-9012',
        brand: 'Mobil',
        grade: 'ISO VG 68',
        ref: 'REF-88120',
        narr: 'Diesel blend QC sample.',
        addl: '',
        custNote: '',
        report: 'RPT-2026-0422',
      ),
    ];
  }

  Future<List<LabManagerListingRow>> fetchAll() async {
    return List<LabManagerListingRow>.unmodifiable(_items);
  }

  Future<LabManagerListingRow?> fetchById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    final remove = ids.toSet();
    _items = _items.where((e) => !remove.contains(e.id)).toList();
  }

  Future<void> setVerifiedForIds(
    List<String> ids,
    bool verified,
  ) async {
    if (ids.isEmpty) return;
    final set = ids.toSet();
    _items = [
      for (final e in _items)
        set.contains(e.id)
            ? e.copyWith(
                verified: verified,
                testLines: labWorkflowManagerVerificationDetailLines(
                  rowId: e.id,
                  parentVerified: verified,
                ),
              )
            : e,
    ];
  }
}
