import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../design_system/components/components.dart';
import '../../design_system/tokens.dart';

/// Placeholder for modules not yet built.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.moduleName,
    this.subtitle,
  });

  final String moduleName;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.construction,
                size: 56,
                color: AppTokens.primary100,
              ),
              const SizedBox(height: AppTokens.space6),
              Text(
                moduleName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.pageTitleSize,
                  fontWeight: AppTokens.pageTitleWeight,
                  color: AppTokens.neutral700,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                'This module is coming soon.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  fontWeight: AppTokens.bodyWeight,
                  color: AppTokens.neutral500,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: AppTokens.space2),
              if (subtitle != null)
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySmSize,
                    fontWeight: AppTokens.bodyWeight,
                    color: AppTokens.neutral400,
                    decoration: TextDecoration.none,
                  ),
                ),
              if (subtitle != null) const SizedBox(height: AppTokens.space2),
              const SizedBox(height: AppTokens.space8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.space4,
                    horizontal: AppTokens.space6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _infoRow(
                        context,
                        icon: LucideIcons.clock,
                        text: 'Under active development',
                      ),
                      const SizedBox(height: AppTokens.space2),
                      _infoRow(
                        context,
                        icon: LucideIcons.info,
                        text: 'Check back in a future update',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final style = GoogleFonts.poppins(
      fontSize: AppTokens.bodySmSize,
      fontWeight: AppTokens.bodyWeight,
      color: AppTokens.neutral500,
      decoration: TextDecoration.none,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppTokens.iconButtonIconSm,
          color: AppTokens.neutral400,
        ),
        const SizedBox(width: AppTokens.space2),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
