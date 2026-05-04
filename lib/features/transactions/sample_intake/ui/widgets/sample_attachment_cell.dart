import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';

/// Attachment placeholder: mock pick with [onPickMock].
class SampleAttachmentCell extends StatelessWidget {
  const SampleAttachmentCell({
    super.key,
    required this.filename,
    required this.onPickMock,
    required this.dense,
    this.prefix = 'file',
  });

  final String? filename;
  final ValueChanged<String?> onPickMock;
  final bool dense;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    if (filename != null && filename!.isNotEmpty) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () =>
              onPickMock('$prefix-${DateTime.now().millisecondsSinceEpoch}.bin'),
          child: Text(
            filename!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: dense ? AppTokens.textXs : AppTokens.tableCellSize,
              color: AppTokens.primary600,
              decoration: TextDecoration.underline,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ),
      );
    }
    return AppButton(
      label: '+ Attach',
      variant: AppButtonVariant.tertiary,
      size: AppButtonSize.sm,
      icon: LucideIcons.paperclip,
      onPressed: () =>
          onPickMock('$prefix-${DateTime.now().millisecondsSinceEpoch}.bin'),
    );
  }
}
