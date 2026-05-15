/// One test / parameter row for Lab Manager Verification or Lab Verification
/// Chemist expandable inline detail tables.
class LabWorkflowTestLine {
  const LabWorkflowTestLine({
    required this.lineNo,
    required this.testName,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.customerMin,
    required this.customerMax,
    required this.fluidMin,
    required this.fluidMax,
    required this.typical,
    required this.retestRemarks,
    required this.chemistName,
    required this.lineVerified,
    this.sectionTitle,
  });

  final int lineNo;
  final String testName;
  final String value;
  final String minValue;
  final String maxValue;
  final String customerMin;
  final String customerMax;
  final String fluidMin;
  final String fluidMax;
  final String typical;
  final String retestRemarks;
  final String chemistName;

  /// Line-level verification (nested status).
  final bool lineVerified;

  /// When non-null, lines with the same consecutive title share one group header
  /// in nested detail tables.
  final String? sectionTitle;

  LabWorkflowTestLine copyWith({
    bool? lineVerified,
    String? sectionTitle,
  }) {
    return LabWorkflowTestLine(
      lineNo: lineNo,
      testName: testName,
      value: value,
      minValue: minValue,
      maxValue: maxValue,
      customerMin: customerMin,
      customerMax: customerMax,
      fluidMin: fluidMin,
      fluidMax: fluidMax,
      typical: typical,
      retestRemarks: retestRemarks,
      chemistName: chemistName,
      lineVerified: lineVerified ?? this.lineVerified,
      sectionTitle: sectionTitle ?? this.sectionTitle,
    );
  }
}
