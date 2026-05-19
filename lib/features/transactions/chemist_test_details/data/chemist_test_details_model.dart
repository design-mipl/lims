/// Workflow queue for chemist test-details listing tabs.
abstract final class ChemistTestWorkflowStatus {
  static const String pending = 'pending';
  static const String retest = 'retest';
  static const String history = 'history';
}

/// Summary row for the Chemist Test Details lab listing (read-only).
class ChemistTestSummaryRow {
  const ChemistTestSummaryRow({
    required this.id,
    required this.labDate,
    required this.labNo,
    required this.testCount,
    this.expectedDate,
    required this.sample,
    this.workflowStatus = ChemistTestWorkflowStatus.pending,
    this.tag,
    this.statusLabel,
  });

  final String id;
  final DateTime labDate;
  final String labNo;
  final int testCount;
  final DateTime? expectedDate;
  final String sample;
  final String workflowStatus;
  final String? tag;
  final String? statusLabel;

  ChemistTestSummaryRow copyWith({
    String? id,
    DateTime? labDate,
    String? labNo,
    int? testCount,
    Object? expectedDate = _sentinel,
    String? sample,
    String? workflowStatus,
    Object? tag = _sentinel,
    Object? statusLabel = _sentinel,
  }) {
    return ChemistTestSummaryRow(
      id: id ?? this.id,
      labDate: labDate ?? this.labDate,
      labNo: labNo ?? this.labNo,
      testCount: testCount ?? this.testCount,
      expectedDate: expectedDate == _sentinel
          ? this.expectedDate
          : expectedDate as DateTime?,
      sample: sample ?? this.sample,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      tag: tag == _sentinel ? this.tag : tag as String?,
      statusLabel: statusLabel == _sentinel
          ? this.statusLabel
          : statusLabel as String?,
    );
  }

  static const Object _sentinel = Object();
}

/// One editable parameter line under a lab (values only editable).
class ChemistTestDetailLine {
  ChemistTestDetailLine({
    required this.id,
    required this.serialNo,
    required this.testName,
    required this.methodType,
    required this.unit,
    this.value1 = '',
    this.value2 = '',
    this.value3 = '',
  });

  final String id;
  final int serialNo;
  final String testName;
  final String methodType;
  final String unit;
  String value1;
  String value2;
  String value3;
}
