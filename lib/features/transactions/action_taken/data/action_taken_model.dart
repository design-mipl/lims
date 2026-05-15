/// Row lifecycle for Action Taken listing.
enum ActionTakenStatus {
  pending,
  completed,
}

/// Severity shown on each row and available as a toolbar filter.
enum ActionTakenRowSeverity {
  critical,
  cautions,
  normal,
}

/// Toolbar severity filter.
enum ActionTakenSeverityFilter {
  /// Show rows regardless of severity.
  all,
  critical,
  cautions,
  normal,
}

class ActionTakenRow {
  const ActionTakenRow({
    required this.id,
    required this.companyName,
    required this.siteContactPerson,
    required this.siteName,
    required this.labId,
    required this.typeOfSample,
    required this.samplingDate,
    required this.equipmentIdNo,
    required this.sampleId,
    required this.make,
    required this.chemist,
    required this.severity,
    required this.status,
  });

  final String id;
  final String companyName;
  final String siteContactPerson;
  final String siteName;
  final String labId;
  final String typeOfSample;
  final DateTime samplingDate;
  final String equipmentIdNo;
  final String sampleId;
  final String make;
  final String chemist;
  final ActionTakenRowSeverity severity;
  final ActionTakenStatus status;

  ActionTakenRow copyWith({
    String? id,
    String? companyName,
    String? siteContactPerson,
    String? siteName,
    String? labId,
    String? typeOfSample,
    DateTime? samplingDate,
    String? equipmentIdNo,
    String? sampleId,
    String? make,
    String? chemist,
    ActionTakenRowSeverity? severity,
    ActionTakenStatus? status,
  }) {
    return ActionTakenRow(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      siteContactPerson: siteContactPerson ?? this.siteContactPerson,
      siteName: siteName ?? this.siteName,
      labId: labId ?? this.labId,
      typeOfSample: typeOfSample ?? this.typeOfSample,
      samplingDate: samplingDate ?? this.samplingDate,
      equipmentIdNo: equipmentIdNo ?? this.equipmentIdNo,
      sampleId: sampleId ?? this.sampleId,
      make: make ?? this.make,
      chemist: chemist ?? this.chemist,
      severity: severity ?? this.severity,
      status: status ?? this.status,
    );
  }
}
