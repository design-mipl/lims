import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static _StatusColors? _colorsFor(String normalizedKey) {
    switch (normalizedKey) {
      case 'active':
      case 'completed':
        return const _StatusColors(
          background: AppTokens.success100,
          foreground: AppTokens.success500,
        );
      case 'inactive':
      case 'disabled':
        return const _StatusColors(
          background: AppTokens.surfaceSubtle,
          foreground: AppTokens.textSecondary,
        );
      case 'pending':
        return const _StatusColors(
          background: AppTokens.warning100,
          foreground: AppTokens.warning500,
        );
      case 'error':
      case 'cancelled':
        return const _StatusColors(
          background: AppTokens.error100,
          foreground: AppTokens.error500,
        );
      case 'draft':
        return const _StatusColors(
          background: AppTokens.primary50,
          foreground: AppTokens.primary800,
        );
      case 'inreview':
      case 'inprogress':
        return const _StatusColors(
          background: AppTokens.info100,
          foreground: AppTokens.info500,
        );
      case 'dataentrypending':
        return const _StatusColors(
          background: AppTokens.warning100,
          foreground: AppTokens.warning500,
        );
      case 'forwardedtolab':
        return const _StatusColors(
          background: AppTokens.primary50,
          foreground: AppTokens.primary700,
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
      case 'disabled':
        return 'Disabled';
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
      case 'error':
        return 'Error';
      case 'dataentrypending':
        return 'Data entry pending';
      case 'inprogress':
        return 'In progress';
      case 'forwardedtolab':
        return 'Forwarded to lab';
      default:
        return original;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeKey(status);
    final mapped = _colorsFor(normalized);
    final resolved = mapped ??
        const _StatusColors(
          background: AppTokens.surfaceSubtle,
          foreground: AppTokens.textSecondary,
        );
    final hasNamed = mapped != null;
    final label = customLabel ??
        (hasNamed ? _defaultLabel(normalized, status) : status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolved.background,
        borderRadius: BorderRadius.circular(AppTokens.chipRadius),
      ),
      child: SizedBox(
        height: AppTokens.chipHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.chipSize,
                fontWeight: AppTokens.chipWeight,
                color: resolved.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
