import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../design_system/tokens.dart';
import '../lab_sample_label_data.dart';

/// On-screen label preview (matches print layout proportions).
class LabSampleLabelPreview extends StatelessWidget {
  const LabSampleLabelPreview({
    super.key,
    required this.labels,
  });

  final List<LabSampleLabelData> labels;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: labels.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: AppTokens.space3),
        itemBuilder: (_, i) => _LabelCard(label: labels[i]),
      ),
    );
  }
}

class _LabelCard extends StatelessWidget {
  const _LabelCard({required this.label});

  final LabSampleLabelData label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space3,
      ),
      decoration: BoxDecoration(
        color: AppTokens.white,
        border: Border.all(color: AppTokens.textPrimary, width: 1.2),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.formattedDate,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textBase,
              fontWeight: AppTokens.weightBold,
              color: AppTokens.textPrimary,
            ),
          ),
          SizedBox(height: AppTokens.space2),
          Text(
            label.sampleTypeDisplay,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textBase,
              fontWeight: AppTokens.weightBold,
              color: AppTokens.textPrimary,
            ),
          ),
          SizedBox(height: AppTokens.space2),
          Text(
            label.labCodeNumber,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textLg,
              fontWeight: AppTokens.weightBold,
              color: AppTokens.textPrimary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
