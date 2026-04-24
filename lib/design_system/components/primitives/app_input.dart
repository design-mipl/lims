import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens.dart';

/// Vertical size preset for [AppInput] value text (single-line only).
enum AppInputSize { sm, md, lg }

/// Single-line text field with full border box and label above the field.
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.size = AppInputSize.md,
    this.required = false,
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final AppInputSize size;
  final bool required;

  double get _fontSize => switch (size) {
        AppInputSize.sm => AppTokens.textSm,
        AppInputSize.md => AppTokens.bodySize,
        AppInputSize.lg => AppTokens.textMd,
      };

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
    final fontSize = _fontSize;

    final fieldStyle = TextStyle(
      fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? AppTokens.fontFamily,
      fontSize: fontSize,
      fontWeight: AppTokens.bodyWeight,
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.onSurface
          : AppTokens.textPrimary,
    );

    final defaultBorder = _border(AppTokens.borderDefault, AppTokens.borderWidthSm);
    final focusBorder =
        _border(AppTokens.primary800, AppTokens.borderWidthMd);
    final errorBorder =
        _border(AppTokens.error500, AppTokens.borderWidthMd);

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTokens.white,
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? AppTokens.fontFamily,
        fontSize: fontSize,
        fontWeight: AppTokens.bodyWeight,
        color: AppTokens.hintColor,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      border: defaultBorder,
      enabledBorder: hasError ? errorBorder : defaultBorder,
      focusedBorder: hasError ? errorBorder : focusBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      disabledBorder: defaultBorder,
    );

    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      maxLines: 1,
      maxLength: maxLength,
      maxLengthEnforcement: maxLength != null
          ? MaxLengthEnforcement.enforced
          : MaxLengthEnforcement.none,
      style: fieldStyle,
      cursorColor: theme.colorScheme.primary,
      decoration: decoration,
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
                  if (required)
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
            child: textField,
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
        if (helperText != null &&
            helperText!.isNotEmpty &&
            !hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppTokens.space1),
            child: Text(
              helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTokens.captionSize,
                fontWeight: AppTokens.captionWeight,
                color: theme.brightness == Brightness.dark
                    ? AppTokens.textMuted
                    : AppTokens.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
