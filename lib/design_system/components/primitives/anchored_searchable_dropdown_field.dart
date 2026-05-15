import 'package:flutter/material.dart';

import 'app_input.dart';
import 'app_select.dart';

/// Enterprise alias for searchable anchored selects — forwards to [AppSelect].
///
/// Use this API name when product/spec demands it; implementation stays aligned
/// with the shared DS overlay and field metrics used elsewhere (e.g. Sample Intake).
class AnchoredSearchableDropdownField<T> extends StatelessWidget {
  const AnchoredSearchableDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.size = AppInputSize.md,
    this.isSearchable = true,
    this.countLabel,
    this.focusNode,
    this.openOverlayWhenFocused = false,
    this.overlayMinimalShadow = false,
  });

  final String? label;
  final String? hint;
  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final AppInputSize size;

  /// Defaults to true (product-grade searchable dropdowns).
  final bool isSearchable;
  final String? countLabel;
  final FocusNode? focusNode;
  final bool openOverlayWhenFocused;
  final bool overlayMinimalShadow;

  @override
  Widget build(BuildContext context) {
    return AppSelect<T>(
      label: label,
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
      isRequired: isRequired,
      errorText: errorText,
      enabled: enabled,
      size: size,
      isSearchable: isSearchable,
      countLabel: countLabel,
      focusNode: focusNode,
      openOverlayWhenFocused: openOverlayWhenFocused,
      overlayMinimalShadow: overlayMinimalShadow,
    );
  }
}
