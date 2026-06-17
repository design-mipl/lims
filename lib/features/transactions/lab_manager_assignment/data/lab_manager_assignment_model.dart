/// Test method catalog entry (mock); selecting a method loads rows for that method.
///
/// Table test columns are fixed (see `LabAssignmentTestColumn` in
/// `lab_manager_assignment_test_columns.dart`).
class LabMethodDefinition {
  const LabMethodDefinition({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

/// One assignable lab row (pending or assigned).
class LabManagerAssignmentRow {
  const LabManagerAssignmentRow({
    required this.id,
    required this.sampleDate,
    required this.labId,
    required this.sampleId,
    required this.customer,
    required this.equipment,
    required this.methodLabel,
    required this.testSelections,
    this.isAssigned = false,
    this.assignedToUserId,
    this.assignedToName,
  });

  final String id;
  final DateTime sampleDate;
  final String labId;
  final String sampleId;
  final String customer;
  final String equipment;
  final String methodLabel;

  /// Per-test checkbox state for assignment (keys match
  /// `LabAssignmentTestColumn.key` in `lab_manager_assignment_test_columns.dart`).
  final Map<String, bool> testSelections;

  final bool isAssigned;
  final String? assignedToUserId;
  final String? assignedToName;

  LabManagerAssignmentRow copyWith({
    Map<String, bool>? testSelections,
    bool? isAssigned,
    String? assignedToUserId,
    String? assignedToName,
  }) {
    return LabManagerAssignmentRow(
      id: id,
      sampleDate: sampleDate,
      labId: labId,
      sampleId: sampleId,
      customer: customer,
      equipment: equipment,
      methodLabel: methodLabel,
      testSelections: testSelections ?? Map<String, bool>.from(this.testSelections),
      isAssigned: isAssigned ?? this.isAssigned,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToName: assignedToName ?? this.assignedToName,
    );
  }
}
