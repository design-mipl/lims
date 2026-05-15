import '../quotation/data/quotation_model.dart';
import 'activity_timeline_models.dart';
import 'module_history_models.dart';

ModuleHistoryEntry _fromLegacyActivity(ActivityTimelineEntry e) {
  final msg = e.message.trim();
  String? remarks;
  String title = msg;
  String? statusKey;
  String? statusLabel;

  if (msg.startsWith('Changes requested:')) {
    remarks = msg.substring('Changes requested:'.length).trim();
    title = 'Approval rejected — changes requested';
    statusKey = 'pending';
    statusLabel = 'Changes';
  } else if (msg.contains('approved')) {
    title = msg;
    statusKey = 'completed';
    statusLabel = 'Approved';
  } else if (msg.contains('Draft') || msg.contains('draft')) {
    statusKey = 'draft';
    statusLabel = 'Draft';
  } else if (msg.contains('review')) {
    statusKey = 'inreview';
    statusLabel = 'In review';
  }

  return ModuleHistoryEntry(
    id: 'act-${e.id}',
    at: e.at,
    actorLabel: e.actorLabel,
    actionPerformed: title,
    statusBadgeKey: statusKey,
    statusBadgeLabel: statusLabel,
    remarks: remarks,
  );
}

String quotationWorkflowStatusLabel(QuotationRecord q) {
  return switch (q.status) {
    QuotationStatus.pendingPrep => 'Pending preparation — pricing workspace',
    QuotationStatus.inReview => 'In sales review',
    QuotationStatus.changesRequested => 'Changes requested by sales',
    QuotationStatus.approved => 'Approved — ready for PDF / conversion',
    _ => q.status,
  };
}

List<ModuleHistoryEntry> buildQuotationHistoryEntries(QuotationRecord q) {
  final out = <ModuleHistoryEntry>[];

  DateTime slot(DateTime base, int addMinutes) =>
      base.add(Duration(minutes: addMinutes));

  final base = DateTime(
    q.createdAt.year,
    q.createdAt.month,
    q.createdAt.day,
    q.createdAt.hour,
    q.createdAt.minute,
  );

  out.add(
    ModuleHistoryEntry(
      id: 'syn-${q.id}-draft',
      at: slot(base, 0),
      actorLabel: q.preparedBy,
      actionPerformed: 'Draft created',
      newValue: q.quoteNo,
      statusBadgeKey: 'draft',
      statusBadgeLabel: 'Draft',
      remarks: 'From enquiry ${q.enquiryNo}',
    ),
  );

  out.add(
    ModuleHistoryEntry(
      id: 'syn-${q.id}-price',
      at: slot(base, 35),
      actorLabel: q.preparedBy,
      actionPerformed: 'Pricing updated',
      oldValue: '—',
      newValue: '${q.lines.length} line(s) · subtotal ${q.subtotal.toStringAsFixed(2)}',
      statusBadgeKey: 'inreview',
      statusBadgeLabel: 'Pricing',
    ),
  );

  out.add(
    ModuleHistoryEntry(
      id: 'syn-${q.id}-gst',
      at: slot(base, 48),
      actorLabel: q.preparedBy,
      actionPerformed: 'GST updated',
      oldValue: '18%',
      newValue: '${q.gstPercent.toStringAsFixed(0)}%',
      statusBadgeKey: 'pending',
      statusBadgeLabel: 'Tax',
    ),
  );

  out.add(
    ModuleHistoryEntry(
      id: 'syn-${q.id}-disc',
      at: slot(base, 52),
      actorLabel: q.preparedBy,
      actionPerformed: 'Discount changed',
      oldValue: '0.00',
      newValue: q.discountAmount.toStringAsFixed(2),
      remarks: q.approvedDiscountAmount != null
          ? 'Approved ceiling ${q.approvedDiscountAmount!.toStringAsFixed(2)}'
          : null,
      statusBadgeKey: 'pending',
      statusBadgeLabel: 'Discount',
    ),
  );

  out.add(
    ModuleHistoryEntry(
      id: 'syn-${q.id}-approval-req',
      at: slot(base, 70),
      actorLabel: q.preparedBy,
      actionPerformed: 'Approval requested',
      statusBadgeKey: 'inreview',
      statusBadgeLabel: 'Review',
      remarks: 'Route to sales approver',
    ),
  );

  if (q.status == QuotationStatus.approved) {
    out.add(
      ModuleHistoryEntry(
        id: 'syn-${q.id}-approved',
        at: slot(base, 120),
        actorLabel: 'Sales approver',
        actionPerformed: 'Approved',
        statusBadgeKey: 'completed',
        statusBadgeLabel: 'Approved',
      ),
    );
    out.add(
      ModuleHistoryEntry(
        id: 'syn-${q.id}-pdf',
        at: slot(base, 135),
        actorLabel: 'Document bot',
        actionPerformed: 'PDF generated',
        newValue: '${q.quoteNo}.pdf',
        statusBadgeKey: 'completed',
        statusBadgeLabel: 'PDF',
      ),
    );
    out.add(
      ModuleHistoryEntry(
        id: 'syn-${q.id}-email',
        at: slot(base, 142),
        actorLabel: 'Outbound mail',
        actionPerformed: 'Email sent',
        remarks: 'Proposal emailed to customer contacts',
        statusBadgeKey: 'completed',
        statusBadgeLabel: 'Sent',
      ),
    );
  }

  if (q.status == QuotationStatus.changesRequested) {
    out.add(
      ModuleHistoryEntry(
        id: 'syn-${q.id}-rej',
        at: slot(base, 110),
        actorLabel: 'Sales approver',
        actionPerformed: 'Rejected — negotiation',
        remarks: q.discussionNotes.isEmpty ? null : q.discussionNotes,
        statusBadgeKey: 'error',
        statusBadgeLabel: 'Rejected',
      ),
    );
  }

  if (q.discussionNotes.isNotEmpty &&
      q.status != QuotationStatus.changesRequested) {
    out.add(
      ModuleHistoryEntry(
        id: 'syn-${q.id}-neg',
        at: slot(base, 100),
        actorLabel: 'Sales',
        actionPerformed: 'Customer negotiation notes',
        remarks: q.discussionNotes,
        statusBadgeKey: 'pending',
        statusBadgeLabel: 'Notes',
      ),
    );
  }

  if (q.orderReference != null && q.orderReference!.isNotEmpty) {
    out.add(
      ModuleHistoryEntry(
        id: 'syn-${q.id}-conv',
        at: q.updatedAt,
        actorLabel: 'Operations',
        actionPerformed: 'Converted to sample intake',
        newValue: q.orderReference,
        statusBadgeKey: 'completed',
        statusBadgeLabel: 'Order',
        remarks: 'Booking reference recorded',
      ),
    );
  }

  for (final a in q.activity) {
    out.add(_fromLegacyActivity(a));
  }

  out.sort((a, b) => b.at.compareTo(a.at));

  final seen = <String>{};
  final deduped = <ModuleHistoryEntry>[];
  for (final e in out) {
    final key = '${e.actionPerformed}|${e.at.millisecondsSinceEpoch ~/ 60000}|${e.actorLabel}';
    if (seen.add(key)) deduped.add(e);
  }
  return deduped;
}
