import 'lab_manager_listing_row.dart';
import 'lab_workflow_test_line.dart';

/// Count of line-level verifications vs assigned tests (each test row counts once).
String labWorkflowVerifiedProgressText(List<LabWorkflowTestLine> lines) {
  final v = lines.where((e) => e.lineVerified).length;
  final t = lines.length;
  return '$v/$t';
}

/// Tab/listing completion: every line verified and at least one line exists.
bool labManagerListingVerificationComplete(LabManagerListingRow row) {
  final lines = row.testLines;
  if (lines.isEmpty) return false;
  return lines.every((e) => e.lineVerified);
}
