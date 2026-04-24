import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Card-style section for medium/large forms (sentence case, optional action).
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    required this.child,
  });

  final String title;
  final String? description;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.brightness == Brightness.dark
        ? theme.cardColor
        : AppTokens.surfaceSubtle;
    final borderColor = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: AppTokens.borderWidthSm,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: theme.textTheme.titleSmall?.fontFamily ??
                              AppTokens.fontFamily,
                          fontSize: AppTokens.sectionTitleSize,
                          fontWeight: AppTokens.sectionTitleWeight,
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : AppTokens.textPrimary,
                        ),
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        SizedBox(height: AppTokens.space1),
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: AppTokens.bodySize,
                            fontWeight: AppTokens.bodyWeight,
                            color: theme.brightness == Brightness.dark
                                ? AppTokens.textMuted
                                : AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: AppTokens.space3),
                  trailing!,
                ],
              ],
            ),
            SizedBox(height: AppTokens.space3),
            child,
          ],
        ),
      ),
    );
  }
}
