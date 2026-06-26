import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../design_system/tokens.dart';
import 'billing_document_row.dart';
import 'billing_listing_provider.dart';
import 'billing_row_action_state.dart';
import 'billing_signature_attach.dart';

/// Compact row spinner used in icon columns during async row actions.
Widget billingRowInlineSpinner() {
  return Center(
    child: SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppTokens.primary800,
      ),
    ),
  );
}

/// Digital signature icon — rebuilds only when this row's attach state changes.
class BillingDigitalSignatureCell extends StatelessWidget {
  const BillingDigitalSignatureCell({
    super.key,
    required this.rowId,
    required this.enabled,
  });

  final String rowId;
  final bool enabled;

  void _onTap(BuildContext context) {
    BillingSignatureAttach.run(
      context,
      rowId: rowId,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<BillingRowActionState, bool>(
      (a) => a.isSignatureBusy(rowId),
    );
    final attached = context.select<BillingListingProvider, bool>(
      (p) => p.rowById(rowId)?.digitalSignatureAttached ?? false,
    );
    final fileName = context.select<BillingListingProvider, String?>(
      (p) => p.rowById(rowId)?.digitalSignatureFileName,
    );
    if (busy) return billingRowInlineSpinner();

    final tooltipMessage = attached
        ? (fileName != null && fileName.isNotEmpty
            ? 'Digital signature: $fileName'
            : 'Digital Signature Attached')
        : 'Attach Digital Signature';

    return Center(
      child: Tooltip(
        message: tooltipMessage,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: !enabled || attached ? null : () => _onTap(context),
            borderRadius: BorderRadius.circular(AppTokens.inputRadius),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                attached ? LucideIcons.fileCheck2 : LucideIcons.file,
                size: AppTokens.iconButtonIconSm,
                color: attached ? AppTokens.success500 : AppTokens.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// eInvoice icon column — rebuilds only when this row's GST/data state changes.
class BillingEInvoiceCell extends StatelessWidget {
  const BillingEInvoiceCell({
    super.key,
    required this.rowId,
    required this.enableGstWorkflow,
    required this.selectionSingular,
    required this.onSnack,
    required this.onShowQr,
  });

  final String rowId;
  final bool enableGstWorkflow;
  final String selectionSingular;
  final void Function(String message) onSnack;
  final void Function(BillingDocumentListingRow row) onShowQr;

  @override
  Widget build(BuildContext context) {
    final verifying = context.select<BillingRowActionState, bool>(
      (a) => a.isGstVerifying(rowId),
    );
    final gstVerified = context.select<BillingListingProvider, bool>(
      (p) => p.rowById(rowId)?.gstVerified ?? false,
    );
    final eInvoiceActive = context.select<BillingListingProvider, bool>(
      (p) => p.rowById(rowId)?.eInvoiceActive ?? false,
    );
    if (!enableGstWorkflow) {
      return _legacyCell(eInvoiceActive);
    }
    return _gstCell(
      context,
      rowId: rowId,
      gstVerified: gstVerified,
      verifying: verifying,
    );
  }

  Widget _legacyCell(bool eInvoiceActive) {
    return Center(
      child: Tooltip(
        message: eInvoiceActive ? 'eInvoice active' : 'eInvoice off',
        child: Icon(
          eInvoiceActive ? LucideIcons.badgeCheck : LucideIcons.circleDashed,
          size: AppTokens.iconButtonIconSm,
          color: eInvoiceActive ? AppTokens.primary800 : AppTokens.textMuted,
        ),
      ),
    );
  }

  Widget _gstCell(
    BuildContext context, {
    required String rowId,
    required bool gstVerified,
    required bool verifying,
  }) {
    if (verifying) return billingRowInlineSpinner();
    if (!gstVerified) {
      return Center(
        child: Tooltip(
          message: '$selectionSingular — GST verification pending',
          child: Icon(
            LucideIcons.fileText,
            size: AppTokens.iconButtonIconSm,
            color: AppTokens.textMuted,
          ),
        ),
      );
    }

    return Center(
      child: Tooltip(
        message: 'IRN & QR code',
        child: InkWell(
          onTap: () {
            final row =
                context.read<BillingListingProvider>().rowById(rowId);
            if (row != null) onShowQr(row);
          },
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.success500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Status cell — localized rebuild when row status changes.
class BillingStatusCell extends StatelessWidget {
  const BillingStatusCell({super.key, required this.rowId});

  final String rowId;

  @override
  Widget build(BuildContext context) {
    final status = context.select<BillingListingProvider, String?>(
      (p) => p.rowById(rowId)?.statusLabel,
    );
    return Text(
      status ?? '—',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: AppTokens.weightMedium,
        color: AppTokens.textPrimary,
      ),
    );
  }
}
