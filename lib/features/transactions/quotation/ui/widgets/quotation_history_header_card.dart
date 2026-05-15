import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';

/// Summary header for Quotation History — mirrors [SampleReceiptHeaderCard] density.
class QuotationHistoryHeaderCard extends StatelessWidget {
  const QuotationHistoryHeaderCard({
    super.key,
    required this.quoteNo,
    required this.moduleBreadcrumbLine,
    required this.summaryStatusChip,
    required this.createdByLabel,
    required this.createdDateLabel,
    required this.stageLabel,
    required this.workflowStatusLabel,
  });

  final String quoteNo;

  /// Muted line above the reference (e.g. `Quotation · History`).
  final String moduleBreadcrumbLine;

  final Widget summaryStatusChip;

  final String createdByLabel;
  final String createdDateLabel;
  final String stageLabel;
  final String workflowStatusLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          name: quoteNo,
          size: AppAvatarSize.lg,
        ),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moduleBreadcrumbLine,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  color: AppTokens.textMuted,
                  fontWeight: AppTokens.weightRegular,
                ),
              ),
              SizedBox(height: AppTokens.spaceHalf),
              Text(
                quoteNo,
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
                child: summaryStatusChip,
              ),
              SizedBox(height: AppTokens.space2),
              Wrap(
                spacing: AppTokens.space4,
                runSpacing: AppTokens.space1,
                children: [
                  _InfoItem(
                    icon: LucideIcons.user,
                    label: createdByLabel,
                  ),
                  _InfoItem(
                    icon: LucideIcons.calendar,
                    label: createdDateLabel,
                  ),
                  _InfoItem(
                    icon: LucideIcons.flag,
                    label: stageLabel,
                  ),
                  _InfoItem(
                    icon: LucideIcons.workflow,
                    label: workflowStatusLabel,
                  ),
                ],
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
