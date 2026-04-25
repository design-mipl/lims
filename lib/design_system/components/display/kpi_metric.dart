import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

/// Data class for a single KPI metric card.
/// Only [label] and [value] are required — icon props are optional.
class KpiCard {
  const KpiCard({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.sublabel,
    this.trend,
    this.trendPositive = true,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final String? sublabel;
  final String? trend;
  final bool trendPositive;
}

/// Single KPI metric card tile.
class KpiMetricTile extends StatelessWidget {
  const KpiMetricTile({super.key, required this.card});

  final KpiCard card;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = card.iconColor ?? AppTokens.primary800;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
        border: Border.all(color: AppTokens.borderDefault, width: AppTokens.borderWidthSm),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.label.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      fontWeight: FontWeight.w500,
                      color: AppTokens.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.value,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  if (card.sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      card.sublabel!,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        fontWeight: FontWeight.w400,
                        color: AppTokens.textMuted,
                      ),
                    ),
                  ],
                  if (card.trend != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      card.trend!,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        fontWeight: FontWeight.w400,
                        color: card.trendPositive ? AppTokens.success500 : AppTokens.error500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (card.icon != null) ...[
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: Icon(card.icon, size: 16, color: resolvedIconColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lays out multiple [KpiCard]s in a responsive row.
/// Desktop: equal-width columns in one row.
/// Mobile (< 600px): 2-column wrap grid.
class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.cards});

  final List<KpiCard> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Wrap(
            spacing: AppTokens.space3,
            runSpacing: AppTokens.space3,
            children: cards.map((card) {
              return SizedBox(
                width: (constraints.maxWidth - AppTokens.space3) / 2,
                child: KpiMetricTile(card: card),
              );
            }).toList(),
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: AppTokens.space3),
              Expanded(child: KpiMetricTile(card: cards[i])),
            ],
          ],
        );
      },
    );
  }
}
