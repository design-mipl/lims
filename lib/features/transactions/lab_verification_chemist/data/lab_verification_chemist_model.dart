import '../../shared/lab_workflow_test_line.dart';

/// Lab Verification Chemist transaction row (mock / in-memory).
class LabVerificationChemistModel {
  const LabVerificationChemistModel({
    required this.id,
    required this.verified,
    required this.typeOfSample,
    required this.labId,
    required this.dateOfReceipt,
    required this.customerName,
    required this.customerCompany,
    required this.lotNo,
    required this.sampleId,
    required this.make,
    required this.model,
    required this.serialNo,
    required this.brandOfOil,
    required this.grade,
    required this.equipmentNo,
    required this.lubeHrs,
    required this.hmr,
    required this.reportId,
    this.status,
    this.testLines = const [],
  });

  final String id;
  final bool verified;
  final String typeOfSample;
  final String labId;
  final DateTime dateOfReceipt;
  final String customerName;
  final String customerCompany;
  final String lotNo;
  final String sampleId;
  final String make;
  final String model;
  final String serialNo;
  final String brandOfOil;
  final String grade;
  final String equipmentNo;
  final double lubeHrs;
  final String hmr;
  final String reportId;
  final String? status;
  final List<LabWorkflowTestLine> testLines;

  LabVerificationChemistModel copyWith({
    bool? verified,
    String? status,
    List<LabWorkflowTestLine>? testLines,
  }) {
    return LabVerificationChemistModel(
      id: id,
      verified: verified ?? this.verified,
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
      status: status ?? this.status,
      testLines: testLines ?? this.testLines,
    );
  }
}
