import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens.dart';

/// Vertical size preset for [AppInput].
enum AppInputSize { sm, md, lg }

/// Single-line or multi-line text field with design-system chrome.
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
    this.maxLines = 1,
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
  final int maxLines;
  final int? maxLength;
  final AppInputSize size;
  final bool required;

  double get _fontSize => switch (size) {
        AppInputSize.sm => AppTokens.textSm,
        AppInputSize.md => AppTokens.textBase,
        AppInputSize.lg => AppTokens.textMd,
      };

  double get _singleLineHeight => switch (size) {
        AppInputSize.sm => AppTokens.buttonHeightSm,
        AppInputSize.md => AppTokens.inputHeight,
        AppInputSize.lg => AppTokens.inputHeightLg,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = _fontSize;
    final singleH = _singleLineHeight;
    final verticalPad = (singleH - fontSize) / 2;
    final isMultiline = maxLines > 1;

    final fieldStyle = TextStyle(
      fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? 'Inter',
      fontSize: fontSize,
      fontWeight: AppTokens.weightRegular,
      color: theme.colorScheme.onSurface,
    );

    final decoration = InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: isMultiline ? AppTokens.space2 : verticalPad,
      ),
    ).applyDefaults(theme.inputDecorationTheme);

    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      maxLengthEnforcement: maxLength != null
          ? MaxLengthEnforcement.enforced
          : MaxLengthEnforcement.none,
      style: fieldStyle,
      cursorColor: theme.colorScheme.primary,
      decoration: decoration,
    );

    final wrappedField = isMultiline
        ? textField
        : SizedBox(
            height: singleH,
            child: Align(
              alignment: Alignment.centerLeft,
              child: textField,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space1),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: AppTokens.textSm,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.onSurface
                      : AppTokens.neutral700,
                ),
                children: [
                  TextSpan(text: label),
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontSize: AppTokens.textSm,
                        color: AppTokens.error500,
                        fontWeight: AppTokens.weightMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        wrappedField,
        if (helperText != null &&
            helperText!.isNotEmpty &&
            (errorText == null || errorText!.isEmpty))
          Padding(
            padding: EdgeInsets.only(top: AppTokens.space1),
            child: Text(
              helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTokens.textXs,
                color: theme.brightness == Brightness.dark
                    ? AppTokens.neutral400
                    : AppTokens.neutral500,
              ),
            ),
          ),
      ],
    );
  }
}
