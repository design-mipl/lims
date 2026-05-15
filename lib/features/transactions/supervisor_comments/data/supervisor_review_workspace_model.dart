/// Row-level severity for test parameter lines (UI + limit logic).
enum SupervisorReviewSeverity {
  normal,
  warning,
  critical,
}

extension SupervisorReviewSeverityLabel on SupervisorReviewSeverity {
  String get label => switch (this) {
        SupervisorReviewSeverity.normal => 'Normal',
        SupervisorReviewSeverity.warning => 'Cautious',
        SupervisorReviewSeverity.critical => 'Critical',
      };
}

/// Single test parameter row on the supervisor review workspace table.
class SupervisorReviewTestLine {
  const SupervisorReviewTestLine({
    required this.id,
    required this.methodGroup,
    required this.parameterName,
    required this.currentValue,
    required this.minLimit,
    required this.maxLimit,
    required this.customerMin,
    required this.customerMax,
    required this.fluidMin,
    required this.fluidMax,
    required this.freshFluidValue,
    required this.typical,
    required this.highlightFlag,
    required this.previousValue,
    required this.trendDisplay,
    required this.historicalComparisonValues,
    required this.severity,
    required this.flagCritical,
    required this.includeInReport,
    required this.chemist,
    required this.recordedOn,
  });

  final String id;
  /// Method / analysis group (e.g. "Physico Chemical Analysis") for table banding.
  final String methodGroup;
  final String parameterName;
  final String currentValue;
  /// Test / method min limit (spec).
  final String minLimit;
  /// Test / method max limit (spec).
  final String maxLimit;
  final String customerMin;
  final String customerMax;
  final String fluidMin;
  final String fluidMax;
  final String freshFluidValue;
  final String typical;
  /// Row-level highlight toggle (Highlight column).
  final bool highlightFlag;
  /// Used internally for trend / severity recompute (not shown as its own column).
  final String previousValue;
  /// e.g. "↑ Increased", "↓ Decreased", "→ Stable"
  final String trendDisplay;
  /// Values under [SupervisorReviewWorkspace.historicalComparisonHeaders], same length.
  final List<String> historicalComparisonValues;
  final SupervisorReviewSeverity severity;
  final bool flagCritical;
  final bool includeInReport;
  final String chemist;

  /// Result / observation date (report date filter).
  final DateTime recordedOn;

  SupervisorReviewTestLine copyWith({
    String? methodGroup,
    String? parameterName,
    String? currentValue,
    String? minLimit,
    String? maxLimit,
    String? customerMin,
    String? customerMax,
    String? fluidMin,
    String? fluidMax,
    String? freshFluidValue,
    String? typical,
    bool? highlightFlag,
    String? previousValue,
    String? trendDisplay,
    List<String>? historicalComparisonValues,
    SupervisorReviewSeverity? severity,
    bool? flagCritical,
    bool? includeInReport,
    String? chemist,
    DateTime? recordedOn,
  }) {
    return SupervisorReviewTestLine(
      id: id,
      methodGroup: methodGroup ?? this.methodGroup,
      parameterName: parameterName ?? this.parameterName,
      currentValue: currentValue ?? this.currentValue,
      minLimit: minLimit ?? this.minLimit,
      maxLimit: maxLimit ?? this.maxLimit,
      customerMin: customerMin ?? this.customerMin,
      customerMax: customerMax ?? this.customerMax,
      fluidMin: fluidMin ?? this.fluidMin,
      fluidMax: fluidMax ?? this.fluidMax,
      freshFluidValue: freshFluidValue ?? this.freshFluidValue,
      typical: typical ?? this.typical,
      highlightFlag: highlightFlag ?? this.highlightFlag,
      previousValue: previousValue ?? this.previousValue,
      trendDisplay: trendDisplay ?? this.trendDisplay,
      historicalComparisonValues:
          historicalComparisonValues ?? this.historicalComparisonValues,
      severity: severity ?? this.severity,
      flagCritical: flagCritical ?? this.flagCritical,
      includeInReport: includeInReport ?? this.includeInReport,
      chemist: chemist ?? this.chemist,
      recordedOn: recordedOn ?? this.recordedOn,
    );
  }
}

/// Full supervisor review workspace payload for one listing row.
class SupervisorReviewWorkspace {
  const SupervisorReviewWorkspace({
    required this.supervisorCommentsId,
    required this.severityStatus,
    required this.assignedChemist,
    required this.historicalComparisonHeaders,
    required this.lines,
    required this.problem,
    required this.comments,
    required this.recommendation,
  });

  final String supervisorCommentsId;

  /// Sample-level summary label for header (Normal / Warning / Critical).
  final String severityStatus;
  final String assignedChemist;

  /// Historical column titles after Chemist (`LCN-…` + `HMR: …` per header), aligned with [SupervisorReviewTestLine.historicalComparisonValues].
  final List<String> historicalComparisonHeaders;

  final List<SupervisorReviewTestLine> lines;
  final String problem;
  final String comments;
  final String recommendation;

  SupervisorReviewWorkspace copyWith({
    String? severityStatus,
    String? assignedChemist,
    List<String>? historicalComparisonHeaders,
    List<SupervisorReviewTestLine>? lines,
    String? problem,
    String? comments,
    String? recommendation,
  }) {
    return SupervisorReviewWorkspace(
      supervisorCommentsId: supervisorCommentsId,
      severityStatus: severityStatus ?? this.severityStatus,
      assignedChemist: assignedChemist ?? this.assignedChemist,
      historicalComparisonHeaders:
          historicalComparisonHeaders ?? this.historicalComparisonHeaders,
      lines: lines ?? this.lines,
      problem: problem ?? this.problem,
      comments: comments ?? this.comments,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
