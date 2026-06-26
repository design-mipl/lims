import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/tokens.dart';
import 'lab_sample_label_data.dart';
import 'widgets/lab_sample_label_preview.dart';

/// Non-web: show preview dialog (labels match portal layout).
Future<bool> printLabSampleLabels(
  BuildContext context,
  List<LabSampleLabelData> labels,
) async {
  if (labels.isEmpty) return false;

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(
        'Lab sample labels',
        style: GoogleFonts.poppins(fontWeight: AppTokens.weightSemibold),
      ),
      content: SizedBox(
        width: 360,
        child: LabSampleLabelPreview(labels: labels),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  return true;
}
