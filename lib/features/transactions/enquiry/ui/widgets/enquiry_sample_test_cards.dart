import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/tokens.dart';
import '../../data/enquiry_model.dart';

/// Compact sample/test row cards for enquiry create-edit sample list.
class EnquirySampleTestCards extends StatelessWidget {
  const EnquirySampleTestCards({
    super.key,
    required this.tests,
    required this.showDelete,
    required this.onDelete,
  });

  final List<EnquiryRequestedTestRow> tests;
  final bool showDelete;
  final ValueChanged<EnquiryRequestedTestRow> onDelete;

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Added samples',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.fieldLabelSize,
            fontWeight: AppTokens.fieldLabelWeight,
            color: AppTokens.labelColor,
          ),
        ),
        SizedBox(height: AppTokens.space2),
        ...tests.map(
          (t) => Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space2),
            child: _SampleTestCard(
              test: t,
              showDelete: showDelete && tests.length > 1,
              onDelete: () => onDelete(t),
            ),
          ),
        ),
      ],
    );
  }
}

class _SampleTestCard extends StatelessWidget {
  const _SampleTestCard({
    required this.test,
    required this.showDelete,
    required this.onDelete,
  });

  final EnquiryRequestedTestRow test;
  final bool showDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.pageBg,
        border: Border.all(color: AppTokens.borderDefault),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.testCode,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textSm,
                      fontWeight: AppTokens.weightSemibold,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Text(
                    test.testName,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      color: AppTokens.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showDelete)
              IconButton(
                tooltip: 'Remove sample',
                onPressed: onDelete,
                icon: Icon(
                  LucideIcons.trash2,
                  size: AppTokens.iconButtonIconMd,
                  color: AppTokens.error500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
