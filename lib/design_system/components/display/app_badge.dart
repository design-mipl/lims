import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Semantic palette key for [AppBadge].
enum AppBadgeColor {
  primary,
  neutral,
  success,
  warning,
  error,
  info,
}

/// Surface treatment for [AppBadge].
enum AppBadgeVariant { filled, subtle, outline }

/// Compact pill label for counts and metadata.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color = AppBadgeColor.neutral,
    this.variant = AppBadgeVariant.subtle,
    this.dot = false,
  });

  final String label;
  final AppBadgeColor color;
  final AppBadgeVariant variant;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = _BadgeScheme.resolve(
      color: color,
      variant: variant,
      brightness: brightness,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppTokens.badgeHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.background,
          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          border: scheme.border,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dot) ...[
                  Container(
                    width: AppTokens.space1,
                    height: AppTokens.space1,
                    decoration: BoxDecoration(
                      color: scheme.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppTokens.space1),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.labelSmall?.fontFamily ??
                            'Inter',
                    fontSize: AppTokens.textXs,
                    fontWeight: AppTokens.weightMedium,
                    color: scheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeScheme {
  const _BadgeScheme({
    required this.background,
    required this.foreground,
    required this.dotColor,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color dotColor;
  final Border? border;

  static _BadgeScheme resolve({
    required AppBadgeColor color,
    required AppBadgeVariant variant,
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;

    Color subtleBgLight;
    Color subtleFgLight;
    Color subtleBgDark;
    Color subtleFgDark;
    Color strong;
    Color onStrong;

    switch (color) {
      case AppBadgeColor.primary:
        subtleBgLight = AppTokens.primary50;
        subtleFgLight = AppTokens.primary800;
        subtleBgDark = AppTokens.primary900;
        subtleFgDark = AppTokens.primary100;
        strong = AppTokens.primary800;
        onStrong = AppTokens.white;
      case AppBadgeColor.neutral:
        subtleBgLight = AppTokens.neutral100;
        subtleFgLight = AppTokens.neutral700;
        subtleBgDark = AppTokens.neutral800;
        subtleFgDark = AppTokens.neutral100;
        strong = AppTokens.neutral700;
        onStrong = AppTokens.white;
      case AppBadgeColor.success:
        subtleBgLight = AppTokens.success50;
        subtleFgLight = AppTokens.success500;
        subtleBgDark = AppTokens.neutral800;
        subtleFgDark = AppTokens.success500;
        strong = AppTokens.success500;
        onStrong = AppTokens.white;
      case AppBadgeColor.warning:
        subtleBgLight = AppTokens.warning50;
        subtleFgLight = AppTokens.warning500;
        subtleBgDark = AppTokens.neutral800;
        subtleFgDark = AppTokens.warning500;
        strong = AppTokens.warning500;
        onStrong = AppTokens.neutral900;
      case AppBadgeColor.error:
        subtleBgLight = AppTokens.error50;
        subtleFgLight = AppTokens.error500;
        subtleBgDark = AppTokens.neutral800;
        subtleFgDark = AppTokens.error500;
        strong = AppTokens.error500;
        onStrong = AppTokens.white;
      case AppBadgeColor.info:
        subtleBgLight = AppTokens.info50;
        subtleFgLight = AppTokens.info500;
        subtleBgDark = AppTokens.neutral800;
        subtleFgDark = AppTokens.info500;
        strong = AppTokens.info500;
        onStrong = AppTokens.white;
    }

    switch (variant) {
      case AppBadgeVariant.subtle:
        return _BadgeScheme(
          background: isDark ? subtleBgDark : subtleBgLight,
          foreground: isDark ? subtleFgDark : subtleFgLight,
          dotColor: isDark ? subtleFgDark : subtleFgLight,
        );
      case AppBadgeVariant.filled:
        return _BadgeScheme(
          background: strong,
          foreground: onStrong,
          dotColor: onStrong,
        );
      case AppBadgeVariant.outline:
        final fg = isDark ? subtleFgDark : subtleFgLight;
        return _BadgeScheme(
          background: isDark ? AppTokens.neutral900 : AppTokens.white,
          foreground: fg,
          dotColor: fg,
          border: Border.all(
            color: fg,
            width: AppTokens.borderWidthHairline,
          ),
        );
    }
  }
}
