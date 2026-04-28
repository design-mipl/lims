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

  static const Duration _segmentAnim = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final innerR = AppTokens.inputRadius - AppTokens.borderWidthSm;

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
          IntrinsicWidth(
            child: Container(
              height: _trackHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
                borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                color: AppTokens.surfaceSubtle,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < options.length; i++)
                    _SegmentChip(
                      option: options[i],
                      isSelected: options[i].value == value,
                      isFirst: i == 0,
                      isLast: i == options.length - 1,
                      innerRadius: innerR,
                      onTap: onChanged == null
                          ? null
                          : () => onChanged!(options[i].value),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.option,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.innerRadius,
    required this.onTap,
  });

  final AppSegmentOption option;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final double innerRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg =
        isSelected ? AppTokens.white : AppTokens.textSecondary;
    final weight =
        isSelected ? FontWeight.w500 : FontWeight.w400;

    final chip = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppSegmentedControl._segmentAnim,
        height: AppSegmentedControl._trackHeight,
        padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTokens.primary800
              : AppTokens.white.withValues(alpha: 0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? innerRadius : 0),
            bottomLeft: Radius.circular(isFirst ? innerRadius : 0),
            topRight: Radius.circular(isLast ? innerRadius : 0),
            bottomRight: Radius.circular(isLast ? innerRadius : 0),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 11, color: fg),
                SizedBox(width: AppTokens.space1),
              ],
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: weight,
                  color: fg,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: chip,
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
