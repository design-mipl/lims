import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/tokens.dart';

/// Shared header + centered body for user-management placeholder pages.
class UserManagementSectionPlaceholder extends StatelessWidget {
  const UserManagementSectionPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bodyMessage,
  });

  final String title;
  final String subtitle;
  final String bodyMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mq = MediaQuery.of(context);
    final contentHeight = (mq.size.height -
            mq.padding.vertical -
            AppTokens.topbarHeight)
        .clamp(0.0, double.infinity);

    return SizedBox(
      height: contentHeight,
      child: ColoredBox(
        color: AppTokens.pageBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTokens.space6,
                AppTokens.space4,
                AppTokens.space6,
                AppTokens.space2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.pageTitleSize,
                      fontWeight: AppTokens.pageTitleWeight,
                      color: isDark ? AppTokens.textOnDark : AppTokens.neutral900,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: AppTokens.space2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.pageSubtitleSize,
                      fontWeight: AppTokens.pageSubtitleWeight,
                      color: isDark ? AppTokens.neutral400 : AppTokens.neutral600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.space6),
                  child: Text(
                    bodyMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.bodySize,
                      fontWeight: AppTokens.bodyWeight,
                      color: isDark ? AppTokens.neutral400 : AppTokens.neutral500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
