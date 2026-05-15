import '../../shared/lab_manager_listing_row.dart';
import '../../shared/lab_workflow_detail_lines.dart';

/// Mock API for Lab Manager Certification listing.
class LabManagerCertificationApi {
  LabManagerCertificationApi() {
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
        id: 'lmc-1',
        verified: true,
        company: 'Acme Industries Pvt Ltd',
        site: 'Mumbai Plant',
        type: 'LUBE OIL',
        daysAgoSample: 10,
        lot: 'LOT-2026-001',
        lab: 'LCN-2026/05-620',
        daysAgoLab: 9,
        lube: 5000,
        hmr: '14,200',
        daysAgoReceipt: 8,
        equip: 'EQ-M-010',
        sample: 'USN585600',
        make: 'Siemens',
        model: 'SIM-500',
        serial: 'SN-MU-77001',
        brand: 'Shell',
        grade: 'ISO VG 68',
        ref: 'REF-88001',
        narr: 'Certification batch — primary reference sample.',
        addl: 'Chain of custody complete.',
        custNote: '',
        report: 'RPT-2026-0401',
      ),
      r(
        id: 'lmc-2',
        verified: false,
        company: 'Zenith Labs',
        site: 'Bangalore DC',
        type: 'USED ENGINE OIL',
        daysAgoSample: 5,
        lot: 'LOT-2026-018',
        lab: 'LCN-2026/05-712',
        daysAgoLab: 4,
        lube: 2800,
        hmr: '9,100',
        daysAgoReceipt: 3,
        equip: 'EQ-Z-030',
        sample: 'USN585601',
        make: 'ABB',
        model: 'ABB-240',
        serial: 'SN-BLR-33002',
        brand: 'Mobil',
        grade: 'SAE 15W-40',
        ref: 'REF-88301',
        narr: 'Awaiting NABL reviewer sign-off.',
        addl: '',
        custNote: 'Customer requested PDF copy.',
        report: 'RPT-2026-0455',
      ),
      r(
        id: 'lmc-3',
        verified: true,
        company: 'Coastal Petro',
        site: 'Jamnagar',
        type: 'Coolant',
        daysAgoSample: 12,
        lot: 'LOT-2026-004',
        lab: 'LCN-2026/05-610',
        daysAgoLab: 11,
        lube: 0,
        hmr: '—',
        daysAgoReceipt: 10,
        equip: 'EQ-C-210',
        sample: 'USN585602',
        make: 'Grundfos',
        model: 'CR-28',
        serial: 'SN-JAM-4400',
        brand: 'Castrol',
        grade: 'TBN 6',
        ref: 'REF-87990',
        narr: 'Coolant certification — winter blend.',
        addl: '',
        custNote: '',
        report: 'RPT-2026-0388',
      ),
      r(
        id: 'lmc-4',
        verified: false,
        company: 'Northwind Traders',
        site: 'Pune WH',
        type: 'Hydraulic fluid',
        daysAgoSample: 3,
        lot: 'LOT-2026-019',
        lab: 'LCN-2026/05-715',
        daysAgoLab: 2,
        lube: 10200,
        hmr: '18,400',
        daysAgoReceipt: 2,
        equip: 'EQ-N-130',
        sample: 'USN585603',
        make: 'Bosch',
        model: 'HYD-100',
        serial: 'SN-PN-88002',
        brand: 'Valvoline',
        grade: 'ISO VG 46',
        ref: 'REF-88310',
        narr: 'Pressure spike investigation follow-up.',
        addl: '',
        custNote: '',
        report: 'RPT-2026-0459',
      ),
      r(
        id: 'lmc-5',
        verified: true,
        company: 'Steelworks Ltd',
        site: 'Bokaro',
        type: 'Metal swarf',
        daysAgoSample: 15,
        lot: 'LOT-2026-002',
        lab: 'LCN-2026/05-625',
        daysAgoLab: 14,
        lube: 800,
        hmr: '2,100',
        daysAgoReceipt: 13,
        equip: 'EQ-S-180',
        sample: 'USN585604',
        make: 'SKF',
        model: 'LAB-SW2',
        serial: 'SN-BK-22001',
        brand: 'Indian Oil',
        grade: 'Synthetic 5W-30',
        ref: 'REF-88055',
        narr: 'Certified ferrography package.',
        addl: 'Retains 24 months.',
        custNote: '',
        report: 'RPT-2026-0410',
      ),
      r(
        id: 'lmc-6',
        verified: false,
        company: 'BioPharm Co',
        site: 'Hyderabad',
        type: 'Process water',
        daysAgoSample: 4,
        lot: 'LOT-2026-020',
        lab: 'LCN-2026/05-718',
        daysAgoLab: 3,
        lube: 0,
        hmr: '—',
        daysAgoReceipt: 2,
        equip: 'EQ-B-088',
        sample: 'USN585605',
        make: 'Pall',
        model: 'PW-02',
        serial: 'SN-HYD-4401',
        brand: 'HP Lubricants',
        grade: 'ISO VG 46',
        ref: 'REF-88322',
        narr: 'Water chemistry limits per USP mock.',
        addl: '',
        custNote: 'Hold until QA email.',
        report: 'RPT-2026-0461',
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
