import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

/// Multi-line text input matching [AppInput] label and border treatment.
class AppTextarea extends StatelessWidget {
  const AppTextarea({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool isRequired;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.inputRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    final defaultBorder = _border(AppTokens.borderDefault, AppTokens.borderWidthSm);
    final focusBorder = _border(AppTokens.borderFocus, AppTokens.borderWidthMd);
    final errorBorder = _border(AppTokens.error500, AppTokens.borderWidthSm);

    final fieldStyle = GoogleFonts.poppins(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: AppTokens.textPrimary,
    );

    final hintStyle = GoogleFonts.poppins(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: AppTokens.hintColor,
    );

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: enabled ? AppTokens.cardBg : AppTokens.surfaceSubtle,
      hintText: hint,
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: defaultBorder,
      enabledBorder: hasError ? errorBorder : defaultBorder,
      focusedBorder: hasError ? errorBorder : focusBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      disabledBorder: defaultBorder,
    );

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
            const SizedBox(height: 4),
          ],
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            readOnly: readOnly,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            maxLengthEnforcement: maxLength != null
                ? MaxLengthEnforcement.enforced
                : MaxLengthEnforcement.none,
            onChanged: onChanged,
            style: fieldStyle,
            cursorColor: AppTokens.borderFocus,
            decoration: decoration,
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 2),
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
