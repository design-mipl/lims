import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/tokens.dart';

/// Read-only label + value row matching Customer Master overview styling.
class FormReadOnlyField extends StatelessWidget {
  const FormReadOnlyField({super.key, required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final hasContent = value != null && value!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textXs,
            fontWeight: AppTokens.weightMedium,
            color: AppTokens.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: AppTokens.space1),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space3,
            vertical: AppTokens.space2,
          ),
          decoration: BoxDecoration(
            color: AppTokens.pageBg,
            border: Border.all(color: AppTokens.border),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          child: Text(
            hasContent ? value!.trim() : '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              color: hasContent ? AppTokens.textPrimary : AppTokens.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
