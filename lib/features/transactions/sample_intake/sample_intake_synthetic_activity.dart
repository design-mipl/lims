import 'data/sample_intake_model.dart';
import '../shared/activity_timeline_models.dart';

/// Derives a display-only activity list from receipt fields until API history exists.
List<ActivityTimelineEntry> syntheticSampleIntakeActivity(
  SampleIntakeModel r,
) {
  String actor() {
    final g = r.generatedBy.trim();
    if (g.isNotEmpty) return g;
    final rb = r.receivedBy.trim();
    if (rb.isNotEmpty) return rb;
    return 'System';
  }

  final a = actor();
  DateTime t(int minutesFromReceipt) =>
      r.receiptDate.add(Duration(minutes: minutesFromReceipt));

  final entries = <ActivityTimelineEntry>[
    ActivityTimelineEntry(
      id: '${r.id}_recorded',
      at: t(0),
      actorLabel: a,
      message: 'Receipt ${r.lotNo} recorded',
    ),
    ActivityTimelineEntry(
      id: '${r.id}_status',
      at: t(1),
      actorLabel: a,
      message: 'Workflow status: ${r.status}',
    ),
    ActivityTimelineEntry(
      id: '${r.id}_datasheet',
      at: t(2),
      actorLabel: a,
      message:
          'Sample data entry: ${r.dataEntryCompletedCount} of ${r.noOfSamples} completed',
    ),
  ];

  if (r.primarySampleId.trim().isNotEmpty) {
    entries.add(
      ActivityTimelineEntry(
        id: '${r.id}_sample_id',
        at: t(3),
        actorLabel: a,
        message: 'Primary sample ID: ${r.primarySampleId}',
      ),
    );
  }

  if (r.intakeCompletedAt != null) {
    entries.add(
      ActivityTimelineEntry(
        id: '${r.id}_intake_done',
        at: r.intakeCompletedAt!,
        actorLabel: a,
        message: 'Intake marked complete',
      ),
    );
  }

  if (r.status == SampleIntakeStatus.forwardedToLab) {
    entries.add(
      ActivityTimelineEntry(
        id: '${r.id}_forwarded',
        at: t(4),
        actorLabel: a,
        message: 'Receipt forwarded to lab',
      ),
    );
  }

  return entries;
}
