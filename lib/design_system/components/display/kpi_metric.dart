import 'package:flutter/material.dart';

import '../../tokens.dart';
import '../cards/app_card.dart';

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
        ? EdgeInsets.all(AppTokens.space2)
        : EdgeInsets.all(AppTokens.space4);

    final valueStyle = compact
        ? theme.textTheme.titleMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : AppTokens.neutral900,
            fontWeight: AppTokens.weightSemibold,
          )
        : theme.textTheme.headlineMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : AppTokens.neutral900,
            fontWeight: AppTokens.weightSemibold,
          );

    return AppCard(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? AppTokens.neutral400
                        : AppTokens.neutral500,
                    fontWeight: AppTokens.weightMedium,
                  ),
                ),
                SizedBox(height: AppTokens.space1),
                Text(
                  card.value,
                  style: valueStyle,
                ),
                if (card.trend != null) ...[
                  SizedBox(height: AppTokens.space1),
                  Text(
                    card.trend!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: trendColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (card.icon != null)
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppTokens.primary50,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  compact ? AppTokens.space1 : AppTokens.space2,
                ),
                child: SizedBox(
                  width: compact ? AppTokens.space6 : AppTokens.space8,
                  height: compact ? AppTokens.space6 : AppTokens.space8,
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: AppTokens.primary800,
                        size: compact ? AppTokens.space3 : AppTokens.space4,
                      ),
                      child: card.icon!,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
