import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final contentHeight = (mq.size.height -
            mq.padding.vertical -
            AppTokens.topbarHeight)
        .clamp(0.0, double.infinity);

    return SizedBox(
      height: contentHeight,
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : AppTokens.neutral900,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral400
                          : AppTokens.neutral600,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral400
                          : AppTokens.neutral500,
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
