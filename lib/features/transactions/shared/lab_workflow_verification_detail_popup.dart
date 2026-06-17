import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../design_system/components/components.dart';
import '../../../design_system/tokens.dart';
import 'lab_workflow_nested_table.dart';
import 'lab_workflow_test_line.dart';

/// Shared Test Details modal for Lab Manager Verification and Lab Verification Chemist.
class LabWorkflowVerificationDetailPopup extends StatelessWidget {
  const LabWorkflowVerificationDetailPopup({
    super.key,
    required this.companyName,
    required this.siteName,
    required this.labId,
    required this.typeOfSample,
    required this.testLines,
  });

  final String companyName;
  final String siteName;
  final String labId;
  final String typeOfSample;
  final List<LabWorkflowTestLine> testLines;

  static Future<void> show(
    BuildContext context, {
    required String companyName,
    required String siteName,
    required String labId,
    required String typeOfSample,
    required List<LabWorkflowTestLine> testLines,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTokens.modalBarrierScrim,
      builder: (ctx) => LabWorkflowVerificationDetailPopup(
        companyName: companyName,
        siteName: siteName,
        labId: labId,
        typeOfSample: typeOfSample,
        testLines: testLines,
      ),
    );
  }

  static TextStyle _labelStyle(BuildContext context) => GoogleFonts.poppins(
        fontSize: AppTokens.captionSize,
        fontWeight: AppTokens.weightMedium,
        color: AppTokens.textMuted,
        decoration: TextDecoration.none,
      );

  static TextStyle _valueStyle(BuildContext context) => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: AppTokens.weightRegular,
        color: AppTokens.textPrimary,
        decoration: TextDecoration.none,
      );

  Widget _summaryMetaCell(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: _labelStyle(context)),
          SizedBox(height: AppTokens.spaceHalf),
          Text(value, style: _valueStyle(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final maxH = media.size.height * 0.93;
    final insetH = AppTokens.space5 * 2;
    final usableW = (media.size.width - insetH).clamp(0.0, double.infinity);
    final maxBodyW = math.min(usableW, 1360.0);

    final grouped = labWorkflowLinesGroupedByMethod(testLines);

    return Dialog(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0),
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space5,
        vertical: AppTokens.space4,
      ),
      child: Material(
        elevation: AppTokens.elevationPopupMenu * 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxBodyW,
            maxHeight: maxH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.space4,
                  AppTokens.space3,
                  AppTokens.space2,
                  AppTokens.space3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Test Details',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.bodySize,
                          fontWeight: AppTokens.weightSemibold,
                          color: theme.colorScheme.onSurface,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonLabel,
                      onPressed: () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(
                        Size.square(AppTokens.iconButtonIconMd + AppTokens.space2),
                      ),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        LucideIcons.x,
                        size: AppTokens.iconSizeMd,
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.neutral300
                            : AppTokens.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AppScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTokens.space4,
                      AppTokens.space1,
                      AppTokens.space4,
                      AppTokens.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppTokens.surfaceSubtle,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            border: Border.all(
                              color: AppTokens.borderLight,
                              width: AppTokens.borderWidthSm,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTokens.space3,
                              vertical: AppTokens.space1 + AppTokens.spaceHalf,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _summaryMetaCell(
                                  context,
                                  'Company Name',
                                  companyName,
                                ),
                                SizedBox(width: AppTokens.space3),
                                _summaryMetaCell(
                                  context,
                                  'Site Name',
                                  siteName,
                                ),
                                SizedBox(width: AppTokens.space3),
                                _summaryMetaCell(
                                  context,
                                  'Lab Id',
                                  labId,
                                ),
                                SizedBox(width: AppTokens.space3),
                                _summaryMetaCell(
                                  context,
                                  'Type of Sample',
                                  typeOfSample,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppTokens.space2),
                        AppScrollView(
                          scrollDirection: Axis.horizontal,
                          child: LabWorkflowPopupGroupedTable(
                            groupedLines: grouped,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
