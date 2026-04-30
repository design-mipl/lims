import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

enum AppInputSize { sm, md, lg }

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

  bool get _isRequired => required || isRequired;

  double get _fontSize => switch (size) {
        AppInputSize.sm => 11.0,
        AppInputSize.md => 12.0,
        AppInputSize.lg => 13.0,
      };

  /// Fixed outer height for single-line fields (sm/md/lg).
  double _singleLineFieldHeight() => switch (size) {
        AppInputSize.sm => AppTokens.buttonHeightMd,
        AppInputSize.md => AppTokens.inputHeight,
        AppInputSize.lg => 38.0,
      };

  /// Vertical content padding for single-line (pairs with [_singleLineFieldHeight]).
  double _verticalPaddingSingleLine() => switch (size) {
        AppInputSize.sm => 7.0,
        AppInputSize.md => 9.0,
        AppInputSize.lg => 11.0,
      };

  bool get _isMultiline => maxLines != null && maxLines! > 1;

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.inputRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final fontSize = _fontSize;
    final fieldHeight = _singleLineFieldHeight();
    final horizontalInset = AppTokens.space2 + AppTokens.space1 / 2;

    final iconConstraints = BoxConstraints(
      minWidth: 32,
      minHeight: fieldHeight,
      maxHeight: fieldHeight,
    );

    final multilinePadding = EdgeInsets.symmetric(
      horizontal: horizontalInset,
      vertical: AppTokens.space2,
    );

    final defaultBorder = _border(AppTokens.borderDefault, AppTokens.borderWidthSm);
    final focusBorder = _border(AppTokens.borderFocus, AppTokens.focusRingWidth);
    final errorBorder = _border(AppTokens.error500, AppTokens.borderWidthSm);
    final disabledBorder = _border(AppTokens.borderDefault, AppTokens.borderWidthSm);

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
      final decoration = InputDecoration(
        isDense: true,
        filled: true,
        fillColor: enabled ? AppTokens.cardBg : AppTokens.surfaceSubtle,
        hintText: hint,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon != null
            ? Center(
                child: IconTheme(
                  data: const IconThemeData(
                    size: AppTokens.iconButtonIconSm,
                    color: AppTokens.textMuted,
                  ),
                  child: prefixIcon!,
                ),
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Center(
                child: IconTheme(
                  data: const IconThemeData(
                    size: AppTokens.iconButtonIconSm,
                    color: AppTokens.textMuted,
                  ),
                  child: suffixIcon!,
                ),
              )
            : null,
        prefixIconConstraints: iconConstraints,
        suffixIconConstraints: iconConstraints,
        contentPadding: multilinePadding,
        border: defaultBorder,
        enabledBorder: hasError ? errorBorder : defaultBorder,
        focusedBorder: hasError ? errorBorder : focusBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        disabledBorder: disabledBorder,
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
        decoration: decoration,
      );
    } else {
      final hasOverlayIcons = prefixIcon != null || suffixIcon != null;
      const double insetNoIcon = 10.0;
      const double insetWithIcon = 34.0;
      final vPad = _verticalPaddingSingleLine();
      final contentPadding = EdgeInsets.only(
        left: prefixIcon != null ? insetWithIcon : insetNoIcon,
        right: suffixIcon != null ? insetWithIcon : insetNoIcon,
        top: vPad,
        bottom: vPad,
      );

      final singleLineDecoration = InputDecoration(
        isDense: true,
        isCollapsed: true,
        filled: true,
        fillColor: enabled ? AppTokens.cardBg : AppTokens.surfaceSubtle,
        hintText: hint,
        hintStyle: hintStyle,
        contentPadding: contentPadding,
        border: defaultBorder,
        enabledBorder: hasError ? errorBorder : defaultBorder,
        focusedBorder: hasError ? errorBorder : focusBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        disabledBorder: disabledBorder,
        counterText: maxLength != null ? '' : null,
        counterStyle: maxLength != null
            ? const TextStyle(height: 0, fontSize: 0)
            : null,
      );

      Widget inner = SizedBox(
        height: fieldHeight,
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
          decoration: singleLineDecoration,
        ),
      );

      if (hasOverlayIcons) {
        inner = Stack(
          clipBehavior: Clip.none,
          children: [
            inner,
            if (prefixIcon != null)
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                width: 18,
                child: IgnorePointer(
                  child: Center(
                    child: IconTheme(
                      data: const IconThemeData(
                        size: AppTokens.iconButtonIconSm,
                        color: AppTokens.textMuted,
                      ),
                      child: prefixIcon!,
                    ),
                  ),
                ),
              ),
            if (suffixIcon != null)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                width: 18,
                child: IgnorePointer(
                  child: Center(
                    child: IconTheme(
                      data: const IconThemeData(
                        size: AppTokens.iconButtonIconSm,
                        color: AppTokens.textMuted,
                      ),
                      child: suffixIcon!,
                    ),
                  ),
                ),
              ),
          ],
        );
      }

      textField = inner;
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
