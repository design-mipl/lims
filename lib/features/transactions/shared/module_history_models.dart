/// Rich read-only row for quotation history screens (distinct from
/// lightweight [ActivityTimelineEntry] used inside records).
class ModuleHistoryEntry {
  const ModuleHistoryEntry({
    required this.id,
    required this.at,
    required this.actorLabel,
    required this.actionPerformed,
    this.oldValue,
    this.newValue,
    this.statusBadgeKey,
    this.statusBadgeLabel,
    this.remarks,
  });

  final String id;
  final DateTime at;

  /// User display name (never treated as an entity id).
  final String actorLabel;

  /// Single-line title shown as primary timeline heading.
  final String actionPerformed;

  final String? oldValue;
  final String? newValue;

  /// Passed to [StatusChip.status] when non-null.
  final String? statusBadgeKey;

  /// Optional override label on [StatusChip].
  final String? statusBadgeLabel;

  final String? remarks;
}

/// Shared formatting for history screens.
abstract final class ModuleHistoryFormat {
  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Example: `11 May 2026 · 11:30 AM`
  static String dateTimeLine(DateTime d) {
    final h24 = d.hour;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = h24 >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_monthsShort[d.month - 1]} ${d.year} · $h12:$mm $ampm';
  }

  static String dateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
