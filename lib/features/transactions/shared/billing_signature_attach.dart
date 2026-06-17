import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../design_system/tokens.dart';
import 'billing_digital_signature_picker.dart';
import 'billing_listing_provider.dart';
import 'billing_row_action_state.dart';

/// Shared digital-signature attach flow for Customer Invoice and Credit Note.
abstract final class BillingSignatureAttach {
  static Future<void> run(
    BuildContext context, {
    required String rowId,
    required bool enabled,
  }) async {
    if (!enabled) return;

    final provider = context.read<BillingListingProvider>();
    final rowActions = context.read<BillingRowActionState>();
    final row = provider.rowById(rowId);
    if (row == null || row.digitalSignatureAttached) return;
    if (rowActions.isSignatureBusy(rowId)) return;

    rowActions.startSignatureFlow(rowId);
    try {
      final fallbackFileName =
          'ceo-signature-${row.documentNo.replaceAll('/', '-')}.png';
      final pickedName = await BillingDigitalSignaturePicker.pickFileName(
        context: context,
        fallbackFileName: fallbackFileName,
      );
      if (!context.mounted) return;
      if (pickedName == null) return;

      final ok = await provider.attachDigitalSignature(
        row,
        fileName: pickedName,
      );
      if (!context.mounted) return;
      if (!ok) {
        _showSnack(
          context,
          'Digital signature attachment failed.',
          error: true,
        );
        return;
      }
      _showSuccessSnack(
        context,
        'Digital signature attached: $pickedName',
      );
    } finally {
      if (context.mounted) {
        rowActions.endSignatureFlow(rowId);
      }
    }
  }

  static void _showSnack(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? LucideIcons.circleX : LucideIcons.info,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.white,
            ),
            SizedBox(width: AppTokens.space2),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: error ? AppTokens.error500 : AppTokens.primary800,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showSuccessSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              LucideIcons.circleCheck,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.white,
            ),
            SizedBox(width: AppTokens.space2),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTokens.success500,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
