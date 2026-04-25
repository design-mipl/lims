import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

/// One option in [AppSegmentedControl].
class AppSegmentOption {
  const AppSegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;
}

/// Compact segmented control for binary or small multi-choice inputs.
///
/// ```dart
/// AppSegmentedControl(
///   label: 'Status',
///   options: [
///     AppSegmentOption(value: 'active',   label: 'Active',   icon: LucideIcons.check),
///     AppSegmentOption(value: 'inactive', label: 'Inactive', icon: LucideIcons.ban),
///   ],
///   value: selectedStatus,
///   onChanged: (v) => setState(() => selectedStatus = v),
/// )
/// ```
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.label,
    this.isRequired = false,
  });

  static const double _trackHeight = 28;

  final List<AppSegmentOption> options;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTokens.inputRadius);

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null && label!.isNotEmpty) ...[
            Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.fieldLabelSize,
                  fontWeight: AppTokens.fieldLabelWeight,
                  color: AppTokens.labelColor,
                ),
                children: [
                  TextSpan(text: label),
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.poppins(
                        color: AppTokens.error500,
                        fontSize: AppTokens.fieldLabelSize,
                        fontWeight: AppTokens.fieldLabelWeight,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.space1),
          ],
          ClipRRect(
            borderRadius: radius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTokens.surfaceSubtle,
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
                borderRadius: radius,
              ),
              child: SizedBox(
                height: _trackHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0)
                        ColoredBox(
                          color: AppTokens.borderDefault,
                          child: const SizedBox(width: 1),
                        ),
                      Expanded(
                        child: _SegmentCell(
                          option: options[i],
                          isSelected: options[i].value == value,
                          onTap: onChanged == null
                              ? null
                              : () => onChanged!(options[i].value),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentCell extends StatelessWidget {
  const _SegmentCell({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AppSegmentOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? AppTokens.white : AppTokens.textSecondary;
    final weight = isSelected ? FontWeight.w500 : FontWeight.w400;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        height: AppSegmentedControl._trackHeight,
        width: double.infinity,
        color: isSelected ? AppTokens.primary800 : Colors.transparent,
        alignment: Alignment.center,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 11, color: fg),
                SizedBox(width: AppTokens.space1),
              ],
              Flexible(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: weight,
                    color: fg,
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

/// Legacy alias — kept for backward compatibility.
/// Prefer [AppSegmentedControl] + [AppSegmentOption] for new code.
class AppSegment<T> {
  const AppSegment({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}
