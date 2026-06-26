/// Shared timeline row for enquiry detail and quotation workflows.
class ActivityTimelineEntry {
  const ActivityTimelineEntry({
    required this.id,
    required this.at,
    required this.actorLabel,
    required this.message,
  });

  final String id;
  final DateTime at;
  final String actorLabel;
  final String message;
}
