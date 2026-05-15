import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/sample_intake_model.dart';

/// Header for Sample Receipt detail — mirrors [CustomerHeader] density and actions.
class SampleReceiptHeaderCard extends StatelessWidget {
  const SampleReceiptHeaderCard({
    super.key,
    required this.receipt,
    required this.readOnly,
    required this.isLoading,
    required this.onCancel,
    this.onSaveDraft,
    this.onSaveAndContinue,
    /// When true (view route inline edit), header shows **Cancel edit** + **Save changes** only.
    this.viewInlineEditActions = false,
  });

  final SampleIntakeModel receipt;
  final bool readOnly;
  final bool isLoading;
  final VoidCallback onCancel;
  final Future<void> Function()? onSaveDraft;
  final Future<void> Function()? onSaveAndContinue;

  /// Replaces wizard/draft actions while editing from read-only receipt view.
  final bool viewInlineEditActions;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _onEditReceipt(BuildContext context) {
    context.push('/transactions/sample-intake/${receipt.id}/complete');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions;
    if (viewInlineEditActions) {
      actions = <Widget>[
        AppButton(
          label: 'Cancel edit',
          variant: AppButtonVariant.tertiary,
          onPressed: onCancel,
        ),
        AppButton(
          label: 'Save changes',
          variant: AppButtonVariant.primary,
          onPressed: isLoading || onSaveDraft == null
              ? null
              : () => onSaveDraft!(),
          isLoading: isLoading,
        ),
      ];
    } else if (readOnly) {
      actions = <Widget>[
        AppButton(
          label: 'Edit Receipt',
          variant: AppButtonVariant.primary,
          icon: LucideIcons.pencil,
          onPressed: () => _onEditReceipt(context),
        ),
      ];
    } else {
      actions = <Widget>[
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.tertiary,
          onPressed: onCancel,
        ),
        AppButton(
          label: 'Save draft',
          variant: AppButtonVariant.secondary,
          onPressed: isLoading || onSaveDraft == null
              ? null
              : () => onSaveDraft!(),
          isLoading: isLoading,
        ),
        AppButton(
          label: 'Save & continue',
          variant: AppButtonVariant.primary,
          onPressed: isLoading || onSaveAndContinue == null
              ? null
              : () => onSaveAndContinue!(),
          isLoading: isLoading,
        ),
      ];
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          name: receipt.lotNo,
          size: AppAvatarSize.lg,
        ),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receipt.lotNo,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textXl,
                  fontWeight: AppTokens.weightBold,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(status: receipt.status),
              ),
              SizedBox(height: AppTokens.space2),
              Wrap(
                spacing: AppTokens.space4,
                runSpacing: AppTokens.space1,
                children: [
                  _InfoItem(
                    icon: LucideIcons.user,
                    label:
                        '${receipt.customerName} · ${receipt.customerCompany}',
                  ),
                  _InfoItem(
                    icon: LucideIcons.calendar,
                    label: _formatDate(receipt.receiptDate),
                  ),
                  _InfoItem(
                    icon: LucideIcons.package,
                    label: '${receipt.noOfSamples} samples',
                  ),
                  _InfoItem(
                    icon: LucideIcons.listChecks,
                    label:
                        '${receipt.dataEntryCompletedCount} / ${receipt.noOfSamples} data entry',
                  ),
                ],
              ),
              SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: actions,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppTokens.textSm,
          color: AppTokens.textMuted,
        ),
        SizedBox(width: AppTokens.space1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              color: AppTokens.textMuted,
              fontWeight: AppTokens.weightRegular,
            ),
          ),
        ),
      ],
    );
  }
}
