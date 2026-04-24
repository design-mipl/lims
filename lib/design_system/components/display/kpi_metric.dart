import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Optional KPI metric shown above the listing table or on dashboards.
class KpiCard {
  const KpiCard({
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendPositive = true,
  });

  final String label;
  final String value;
  final Widget? icon;
  final String? trend;
  final bool trendPositive;
}

/// Single KPI surface (shared by listing strip and dashboard grid).
class KpiMetricTile extends StatelessWidget {
  const KpiMetricTile({
    super.key,
    required this.card,
    this.compact = false,
  });

  final KpiCard card;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendColor = card.trend == null
        ? null
        : (card.trendPositive ? AppTokens.success500 : AppTokens.error500);

    final padding = compact
        ? EdgeInsets.all(AppTokens.space3)
        : EdgeInsets.all(AppTokens.space4);

    final surface = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : AppTokens.white;
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
        padding: padding,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: card.icon != null ? AppTokens.space10 : AppTokens.space0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.label.toUpperCase(),
                    style: TextStyle(
                      fontFamily:
                          theme.textTheme.labelSmall?.fontFamily ?? AppTokens.fontFamily,
                      fontSize: AppTokens.textXs,
                      fontWeight: AppTokens.weightMedium,
                      letterSpacing: 0.5,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Text(
                    card.value,
                    style: TextStyle(
                      fontFamily:
                          theme.textTheme.headlineSmall?.fontFamily ?? AppTokens.fontFamily,
                      fontSize: AppTokens.text3xl,
                      fontWeight: AppTokens.weightBold,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : AppTokens.textPrimary,
                    ),
                  ),
                  if (card.trend != null) ...[
                    SizedBox(height: AppTokens.space1),
                    Text(
                      card.trend!,
                      style: TextStyle(
                        fontFamily:
                            theme.textTheme.bodySmall?.fontFamily ?? AppTokens.fontFamily,
                        fontSize: AppTokens.textSm,
                        fontWeight: AppTokens.bodyWeight,
                        color: trendColor ?? AppTokens.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (card.icon != null)
              Positioned(
                top: AppTokens.space0,
                right: AppTokens.space0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTokens.primary800.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: IconTheme(
                        data: IconThemeData(
                          color: AppTokens.primary800,
                          size: 20,
                        ),
                        child: card.icon!,
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
