import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/tokens.dart';
import '../quotation/ui/widgets/quotation_activity_timeline.dart';
import 'activity_timeline_models.dart';
import 'billing_document_row.dart';
import 'billing_invoice_audit_history.dart';

/// Lightweight audit modal for Customer Invoice listing rows.
Future<void> showBillingInvoiceAuditDialog(
  BuildContext context, {
  required BillingDocumentListingRow row,
}) {
  final entries = buildBillingInvoiceAuditHistory(row);
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          'Audit History',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textMd,
            fontWeight: AppTokens.weightSemibold,
            color: AppTokens.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  row.documentNo,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.textSm,
                    color: AppTokens.textMuted,
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                QuotationActivityTimeline(
                  entries: entries,
                  emptyMessage: 'No audit history available.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
            ),
          ),
        ],
      );
    },
  );
}

/// Audit modal for invoice workspace line items (subset of invoice events).
Future<void> showInvoiceLineAuditDialog(
  BuildContext context, {
  required String invoiceNo,
  required String labNo,
  required List<ActivityTimelineEntry> entries,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          'Audit History',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textMd,
            fontWeight: AppTokens.weightSemibold,
            color: AppTokens.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$invoiceNo · $labNo',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.textSm,
                    color: AppTokens.textMuted,
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                QuotationActivityTimeline(
                  entries: entries,
                  emptyMessage: 'No audit history available.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
            ),
          ),
        ],
      );
    },
  );
}
