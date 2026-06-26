import 'lab_workflow_test_line.dart';

/// Shared row model for Lab Manager Verification / Certification listings.
class LabManagerListingRow {
  const LabManagerListingRow({
    required this.id,
    required this.verified,
    required this.companyName,
    required this.siteName,
    required this.typeOfSample,
    required this.samplingDate,
    required this.lotNo,
    required this.labId,
    required this.labDate,
    required this.lubeHrs,
    required this.hmr,
    required this.dateOfReceipt,
    required this.equipmentNo,
    required this.sampleId,
    required this.make,
    required this.model,
    required this.serialNo,
    required this.brandOfOil,
    required this.grade,
    required this.referenceNo,
    required this.narration,
    required this.additionalRemarks,
    required this.customerNotes,
    required this.reportId,
    this.testLines = const [],
  });

  final String id;
  final bool verified;
  final String companyName;
  final String siteName;
  final String typeOfSample;
  final DateTime samplingDate;
  final String lotNo;
  final String labId;
  final DateTime labDate;
  final double lubeHrs;
  final String hmr;
  final DateTime dateOfReceipt;
  final String equipmentNo;
  final String sampleId;
  final String make;
  final String model;
  final String serialNo;
  final String brandOfOil;
  final String grade;
  final String referenceNo;
  final String narration;
  final String additionalRemarks;
  final String customerNotes;
  final String reportId;

  /// Inline expandable verification detail (manager verification); may be empty.
  final List<LabWorkflowTestLine> testLines;

  static String formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  LabManagerListingRow copyWith({
    bool? verified,
    List<LabWorkflowTestLine>? testLines,
  }) {
    return LabManagerListingRow(
      id: id,
      verified: verified ?? this.verified,
      companyName: companyName,
      siteName: siteName,
      typeOfSample: typeOfSample,
      samplingDate: samplingDate,
      lotNo: lotNo,
      labId: labId,
      labDate: labDate,
      lubeHrs: lubeHrs,
      hmr: hmr,
      dateOfReceipt: dateOfReceipt,
      equipmentNo: equipmentNo,
      sampleId: sampleId,
      make: make,
      model: model,
      serialNo: serialNo,
      brandOfOil: brandOfOil,
      grade: grade,
      referenceNo: referenceNo,
      narration: narration,
      additionalRemarks: additionalRemarks,
      customerNotes: customerNotes,
      reportId: reportId,
      testLines: testLines ?? this.testLines,
    );
  }
}

/// Distinct option sets for column filters (mock-friendly).
abstract final class LabManagerListingFilterOptions {
  static const sampleTypes = <String>[
    'LUBE OIL',
    'USED ENGINE OIL',
    'Coolant',
    'Hydraulic fluid',
    'Metal swarf',
    'Process water',
    'Grease',
    'Fuel',
  ];

  static const brands = <String>[
    'Shell',
    'Mobil',
    'Castrol',
    'Valvoline',
    'Indian Oil',
    'HP Lubricants',
  ];

  static const grades = <String>[
    'ISO VG 68',
    'ISO VG 46',
    'SAE 15W-40',
    'SAE 20W-50',
    'TBN 6',
    'Synthetic 5W-30',
  ];
}
