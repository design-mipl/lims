import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Row-level status pill with stronger emphasis than the compact badge.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  final String status;
  final String? customLabel;

  static String _normalizeKey(String raw) {
    return raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  }

  static _StatusVisual? _visualFor(String normalizedKey) {
    switch (normalizedKey) {
      case 'active':
        return const _StatusVisual(
          backgroundLight: AppTokens.success50,
          foregroundLight: AppTokens.success500,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.success500,
          showDot: false,
        );
      case 'inactive':
        return const _StatusVisual(
          backgroundLight: AppTokens.neutral100,
          foregroundLight: AppTokens.neutral700,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.neutral100,
          showDot: false,
        );
      case 'pending':
        return const _StatusVisual(
          backgroundLight: AppTokens.warning50,
          foregroundLight: AppTokens.warning500,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.warning500,
          showDot: true,
        );
      case 'inreview':
        return const _StatusVisual(
          backgroundLight: AppTokens.info50,
          foregroundLight: AppTokens.info500,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.info500,
          showDot: true,
        );
      case 'completed':
        return const _StatusVisual(
          backgroundLight: AppTokens.success50,
          foregroundLight: AppTokens.success500,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.success500,
          showDot: false,
        );
      case 'cancelled':
        return const _StatusVisual(
          backgroundLight: AppTokens.error50,
          foregroundLight: AppTokens.error500,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.error500,
          showDot: false,
        );
      case 'draft':
        return const _StatusVisual(
          backgroundLight: AppTokens.neutral100,
          foregroundLight: AppTokens.neutral700,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.neutral100,
          showDot: false,
        );
      default:
        return null;
    }
  }

  static String _defaultLabel(String normalizedKey, String original) {
    switch (normalizedKey) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'pending':
        return 'Pending';
      case 'inreview':
        return 'In review';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'draft':
        return 'Draft';
      default:
        return original;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = _normalizeKey(status);
    final visual = _visualFor(normalized);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    final _StatusVisual resolved = visual ??
        const _StatusVisual(
          backgroundLight: AppTokens.neutral100,
          foregroundLight: AppTokens.neutral700,
          backgroundDark: AppTokens.neutral800,
          foregroundDark: AppTokens.neutral100,
          showDot: false,
        );

    final background =
        isDark ? resolved.backgroundDark : resolved.backgroundLight;
    final foreground =
        isDark ? resolved.foregroundDark : resolved.foregroundLight;

    final label = customLabel ??
        (visual == null ? status : _defaultLabel(normalized, status));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppTokens.statusChipHeight,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space3,
            vertical: AppTokens.space1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (resolved.showDot) ...[
                Container(
                  width: AppTokens.space2,
                  height: AppTokens.space2,
                  decoration: BoxDecoration(
                    color: foreground,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppTokens.space2),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily:
                      theme.textTheme.labelMedium?.fontFamily ?? 'Inter',
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightSemibold,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusVisual {
  const _StatusVisual({
    required this.backgroundLight,
    required this.foregroundLight,
    required this.backgroundDark,
    required this.foregroundDark,
    required this.showDot,
  });

  final Color backgroundLight;
  final Color foregroundLight;
  final Color backgroundDark;
  final Color foregroundDark;
  final bool showDot;
}
