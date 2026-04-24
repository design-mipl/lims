import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';

/// Design-system dropdown: same chrome as [AppInput] (label above, full border).
///
/// Wraps [DropdownButtonFormField] only here — do not use raw dropdowns in features.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    final defaultBorder = _border(AppTokens.borderDefault, AppTokens.borderWidthSm);
    final focusBorder =
        _border(AppTokens.primary800, AppTokens.borderWidthMd);
    final errorBorder =
        _border(AppTokens.error500, AppTokens.borderWidthMd);

    final valueStyle = TextStyle(
      fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? AppTokens.fontFamily,
      fontSize: AppTokens.bodySize,
      fontWeight: AppTokens.bodyWeight,
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.onSurface
          : AppTokens.textPrimary,
    );

    final hintStyle = TextStyle(
      fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? AppTokens.fontFamily,
      fontSize: AppTokens.bodySize,
      fontWeight: AppTokens.bodyWeight,
      color: AppTokens.hintColor,
    );

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTokens.white,
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      border: defaultBorder,
      enabledBorder: hasError ? errorBorder : defaultBorder,
      focusedBorder: hasError ? errorBorder : focusBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      disabledBorder: defaultBorder,
    );

    final menuTextStyle = TextStyle(
      fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? AppTokens.fontFamily,
      fontSize: AppTokens.bodySize,
      fontWeight: AppTokens.bodyWeight,
      color: AppTokens.textPrimary,
    );

    final field = Theme(
      data: theme.copyWith(
        canvasColor: AppTokens.white,
        textTheme: theme.textTheme.copyWith(
          bodyLarge: menuTextStyle,
          bodyMedium: menuTextStyle,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(AppTokens.white),
            elevation: const WidgetStatePropertyAll(AppTokens.elevationPopupMenu),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              ),
            ),
            maximumSize: const WidgetStatePropertyAll(
              Size(double.infinity, 240),
            ),
          ),
        ),
      ),
      child: DropdownButtonFormField<T>(
        key: ValueKey(value),
        initialValue: value,
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
                value: e.value,
                enabled: e.enabled,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DefaultTextStyle(
                    style: menuTextStyle,
                    child: e.child,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: enabled ? onChanged : null,
        isExpanded: true,
        isDense: true,
        itemHeight: 36,
        menuMaxHeight: 240,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        dropdownColor: AppTokens.white,
        icon: Icon(
          LucideIcons.chevronDown,
          size: 16,
          color: AppTokens.textSecondary,
        ),
        style: valueStyle,
        hint: hint != null
            ? Text(hint!, style: hintStyle, overflow: TextOverflow.ellipsis)
            : null,
        decoration: decoration,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space1),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily:
                      theme.textTheme.bodyMedium?.fontFamily ?? AppTokens.fontFamily,
                  fontSize: AppTokens.fieldLabelSize,
                  fontWeight: AppTokens.fieldLabelWeight,
                  color: AppTokens.labelColor,
                ),
                children: [
                  TextSpan(text: label),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppTokens.error500,
                        fontSize: AppTokens.fieldLabelSize,
                        fontWeight: AppTokens.fieldLabelWeight,
                      ),
                    ),
                ],
              ),
            ),
          ),
        SizedBox(
          height: AppTokens.inputHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: field,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              errorText!,
              style: TextStyle(
                fontFamily:
                    theme.textTheme.bodySmall?.fontFamily ?? AppTokens.fontFamily,
                fontSize: AppTokens.captionSize,
                fontWeight: AppTokens.captionWeight,
                color: AppTokens.error500,
              ),
            ),
          ),
      ],
    );
  }
}
