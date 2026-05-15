/// Summary row for the Chemist Test Details lab listing (read-only).
class ChemistTestSummaryRow {
  const ChemistTestSummaryRow({
    required this.id,
    required this.labDate,
    required this.labNo,
    required this.testCount,
    this.expectedDate,
    required this.sample,
  });

  final String id;
  final DateTime labDate;
  final String labNo;
  final int testCount;
  final DateTime? expectedDate;
  final String sample;
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
