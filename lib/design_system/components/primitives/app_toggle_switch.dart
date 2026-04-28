import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

/// Compact switch with optional field label and optional Active/Inactive status text.
class AppToggleSwitch extends StatelessWidget {
  const AppToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.activeLabel,
    this.inactiveLabel,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? activeLabel;
  final String? inactiveLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnChanged = enabled ? onChanged : null;

    final switchWidget = Switch(
      value: value,
      onChanged: effectiveOnChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTokens.primary800;
        }
        return AppTokens.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTokens.primary100;
        }
        return AppTokens.borderDefault;
      }),
    );

    final scaledSwitch = Transform.scale(
      scale: 0.8,
      child: enabled
          ? switchWidget
          : Opacity(
              opacity: 0.5,
              child: switchWidget,
            ),
    );

    final statusText = value ? activeLabel : inactiveLabel;
    final showStatus =
        statusText != null && statusText.isNotEmpty;

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        scaledSwitch,
        if (showStatus) ...[
          SizedBox(width: AppTokens.space3 / 2),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: value ? AppTokens.success500 : AppTokens.textMuted,
            ),
          ),
        ],
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: label != null && label!.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label!,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.fieldLabelSize,
                    fontWeight: AppTokens.fieldLabelWeight,
                    color: AppTokens.labelColor,
                  ),
                ),
                SizedBox(height: AppTokens.space1),
                row,
              ],
            )
          : row,
    );
  }
}
