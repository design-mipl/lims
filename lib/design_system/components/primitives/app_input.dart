import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

enum AppInputSize { sm, md, lg }

/// Shared [InputDecoration] for [AppInput], [AppSelect] triggers, and any
/// future input-like control. All must use the same vertical metrics and
/// [prefixIconConstraints] / [suffixIconConstraints] ([AppTokens.inputFieldIconSlot])
/// so trailing icons never widen the field or trigger Material's default tall
/// icon slots (height drift vs plain text fields).
InputDecoration buildAppFormFieldDecoration({
  required bool enabled,
  required bool hasError,
  String? hintText,
  TextStyle? hintStyle,
  Widget? prefixIcon,
  Widget? suffixIcon,
  EdgeInsetsGeometry? contentPadding,
  String? counterText,
  TextStyle? counterStyle,
}) {
  OutlineInputBorder border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.inputRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  final defaultBorder =
      border(AppTokens.borderDefault, AppTokens.borderWidthSm);
  final focusBorder = border(AppTokens.borderFocus, AppTokens.focusRingWidth);
  final errorBorder = border(AppTokens.error500, AppTokens.borderWidthSm);
  final disabledBorder =
      border(AppTokens.borderDefault, AppTokens.borderWidthSm);

  final enabledBr = hasError
      ? errorBorder
      : (!enabled ? disabledBorder : defaultBorder);
  final focusedBr = hasError
      ? errorBorder
      : (!enabled ? disabledBorder : focusBorder);

  final iconSlot = BoxConstraints(
    minWidth: AppTokens.inputFieldIconSlot,
    maxWidth: AppTokens.inputFieldIconSlot,
    minHeight: AppTokens.inputFieldIconSlot,
    maxHeight: AppTokens.inputFieldIconSlot,
  );

  Widget? themedIcon(Widget? icon) {
    if (icon == null) return null;
    return Center(
      child: IconTheme(
        data: const IconThemeData(
          size: AppTokens.iconButtonIconSm,
          color: AppTokens.textMuted,
        ),
        child: icon,
      ),
    );
  }

  final padding = contentPadding ??
      const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      );

  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: enabled ? AppTokens.cardBg : AppTokens.surfaceSubtle,
    hintText: hintText,
    hintStyle: hintStyle,
    prefixIcon: themedIcon(prefixIcon),
    suffixIcon: themedIcon(suffixIcon),
    prefixIconConstraints: iconSlot,
    suffixIconConstraints: iconSlot,
    contentPadding: padding,
    border: defaultBorder,
    enabledBorder: enabledBr,
    focusedBorder: focusedBr,
    errorBorder: errorBorder,
    focusedErrorBorder: errorBorder,
    disabledBorder: disabledBorder,
    counterText: counterText,
    counterStyle: counterStyle,
  );
}

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
    this.maxLines = 1,
    this.minLines,
    this.size = AppInputSize.md,
    this.required = false,
    this.validator,
    this.isRequired = false,
    this.inputFormatters,
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
  final int? maxLines;
  final int? minLines;
  final AppInputSize size;
  final bool required;
  final bool isRequired;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  bool get _isRequired => required || isRequired;

  double get _fontSize => switch (size) {
        AppInputSize.sm => 11.0,
        AppInputSize.lg => 13.0,
        AppInputSize.md => 12.0,
      };

  /// Single-line shells always use [AppTokens.inputHeight] so fields align in grids
  /// regardless of [AppInputSize] (size only affects typography).
  bool get _isMultiline => maxLines != null && maxLines! > 1;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final fontSize = _fontSize;

    final fieldStyle = GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: enabled ? AppTokens.textPrimary : AppTokens.textMuted,
      letterSpacing: obscureText ? 2.0 : 0,
    );

    final hintStyle = GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppTokens.hintColor,
      letterSpacing: obscureText ? 2.0 : 0,
    );

    late final Widget textField;

    if (_isMultiline) {
      final decoration = buildAppFormFieldDecoration(
        enabled: enabled,
        hasError: hasError,
        hintText: hint,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      );

      textField = TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator,
        expands: false,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        maxLengthEnforcement: maxLength != null
            ? MaxLengthEnforcement.enforced
            : MaxLengthEnforcement.none,
        style: fieldStyle,
        cursorColor: AppTokens.borderFocus,
        inputFormatters: inputFormatters,
        decoration: decoration,
      );
    } else {
      // Same decoration contract as [AppSelect] so icon and plain fields share height.
      final decoration = buildAppFormFieldDecoration(
        enabled: enabled,
        hasError: hasError,
        hintText: hint,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? '' : null,
        counterStyle: maxLength != null
            ? const TextStyle(height: 0, fontSize: 0)
            : null,
      );

      textField = SizedBox(
        height: AppTokens.inputHeight,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          expands: false,
          maxLines: 1,
          maxLength: maxLength,
          maxLengthEnforcement: maxLength != null
              ? MaxLengthEnforcement.enforced
              : MaxLengthEnforcement.none,
          style: fieldStyle,
          cursorColor: AppTokens.borderFocus,
          inputFormatters: inputFormatters,
          decoration: decoration,
        ),
      );
    }

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
                  if (_isRequired)
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
          textField,
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.space1),
              child: Text(
                errorText!,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: AppTokens.captionWeight,
                  color: AppTokens.error500,
                ),
              ),
            ),
          if (helperText != null && helperText!.isNotEmpty && !hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.space1),
              child: Text(
                helperText!,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: AppTokens.captionWeight,
                  color: AppTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
