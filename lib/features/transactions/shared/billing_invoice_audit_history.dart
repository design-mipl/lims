import '../customer_invoice/data/invoice_item_row_model.dart';
import 'activity_timeline_models.dart';
import 'billing_document_row.dart';

/// Synthetic invoice audit timeline for listing **Audit History** (mock until API).
List<ActivityTimelineEntry> buildBillingInvoiceAuditHistory(
  BillingDocumentListingRow row,
) {
  final entries = <ActivityTimelineEntry>[
    ActivityTimelineEntry(
      id: '${row.id}-created',
      at: row.docDate,
      actorLabel: 'Billing System',
      message: 'Invoice Created',
    ),
  ];
  if (row.gstVerified) {
    entries.add(
      ActivityTimelineEntry(
        id: '${row.id}-gst',
        at: row.docDate.add(const Duration(hours: 2)),
        actorLabel: 'GST Portal',
        message: 'GST/eInvoice Verified',
      ),
    );
  }
  if (row.statusLabel == 'Shared') {
    entries.add(
      ActivityTimelineEntry(
        id: '${row.id}-email',
        at: row.docDate.add(const Duration(days: 1)),
        actorLabel: 'Accounts Team',
        message: 'Email Sent',
      ),
    );
  }
  if (row.ceoSignatureOnTemplate) {
    entries.add(
      ActivityTimelineEntry(
        id: '${row.id}-sig',
        at: row.docDate.add(const Duration(days: 1, hours: 4)),
        actorLabel: 'CEO Office',
        message: 'Signature Updated',
      ),
    );
  }
  entries.add(
    ActivityTimelineEntry(
      id: '${row.id}-pdf',
      at: row.docDate.add(const Duration(hours: 5)),
      actorLabel: 'Finance User',
      message: 'PDF Downloaded',
    ),
  );
  if (row.statusLabel == 'Generated' || row.outstanding <= 0) {
    entries.add(
      ActivityTimelineEntry(
        id: '${row.id}-cn',
        at: row.docDate.add(const Duration(days: 2)),
        actorLabel: 'Accounts Team',
        message: 'Credit Note Generated',
      ),
    );
  }
  return entries;
}

/// Line-level audit for Create / View Customer Invoice item grid.
List<ActivityTimelineEntry> buildInvoiceLineAuditHistory(
  String invoiceNo,
  InvoiceItemRowModel line,
) {
  return [
    ActivityTimelineEntry(
      id: '${line.id}-created',
      at: line.labDate,
      actorLabel: 'Billing System',
      message: 'Invoice Created',
    ),
    ActivityTimelineEntry(
      id: '${line.id}-pdf',
      at: line.labDate.add(const Duration(hours: 3)),
      actorLabel: 'Finance User',
      message: 'PDF Downloaded',
    ),
    ActivityTimelineEntry(
      id: '${line.id}-line',
      at: line.labDate.add(const Duration(hours: 1)),
      actorLabel: line.contactPerson,
      message: 'Line added — $invoiceNo / ${line.labNo}',
    ),
  ];
}
