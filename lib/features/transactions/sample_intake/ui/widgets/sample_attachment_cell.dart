import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      final text = Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final k = event.logicalKey;
          if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
            onPickMock('$prefix-${DateTime.now().millisecondsSinceEpoch}.bin');
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
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
        ),
      );
      if (!dense) return text;
      return SizedBox(
        height: AppTokens.inputHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: text,
        ),
      );
    }
    if (dense) {
      return Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final k = event.logicalKey;
          if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
            onPickMock('$prefix-${DateTime.now().millisecondsSinceEpoch}.bin');
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SizedBox(
          height: AppTokens.inputHeight,
          child: Material(
            color: AppTokens.transparent,
            child: InkWell(
              onTap: () =>
                  onPickMock('$prefix-${DateTime.now().millisecondsSinceEpoch}.bin'),
              borderRadius: BorderRadius.circular(AppTokens.inputRadius),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTokens.cardBg,
                  borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                  border: Border.all(
                    color: AppTokens.borderDefault,
                    width: AppTokens.borderWidthSm,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.paperclip,
                      size: AppTokens.iconButtonIconSm,
                      color: AppTokens.textMuted,
                    ),
                    SizedBox(width: AppTokens.space1),
                    Text(
                      'Attach',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textXs,
                        fontWeight: AppTokens.weightMedium,
                        color: AppTokens.primary600,
                      ),
                    ),
                  ],
                ),
              ),
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
