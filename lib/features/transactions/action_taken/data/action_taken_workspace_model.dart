/// Editable workspace payload for an Action Taken row (mock-persisted).
class ActionTakenWorkspaceDraft {
  const ActionTakenWorkspaceDraft({
    required this.rowId,
    required this.comments,
    required this.recommendation,
    required this.actionTaken,
    this.actionDate,
  });

  final String rowId;
  final String comments;
  final String recommendation;
  final String actionTaken;
  final DateTime? actionDate;

  ActionTakenWorkspaceDraft copyWith({
    String? rowId,
    String? comments,
    String? recommendation,
    String? actionTaken,
    DateTime? actionDate,
  }) {
    return ActionTakenWorkspaceDraft(
      rowId: rowId ?? this.rowId,
      comments: comments ?? this.comments,
      recommendation: recommendation ?? this.recommendation,
      actionTaken: actionTaken ?? this.actionTaken,
      actionDate: actionDate ?? this.actionDate,
    );
  }
}
