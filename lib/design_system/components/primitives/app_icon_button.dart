import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Background / border treatment for [AppIconButton].
enum AppIconButtonVariant { ghost, outlined, filled, danger }

/// Hit target size for [AppIconButton].
enum AppIconButtonSize { sm, md, lg }

/// Compact icon-only control with design-system variants.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.size = AppIconButtonSize.md,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;
  final String? tooltip;

  double get _boxExtent => switch (size) {
        AppIconButtonSize.sm => AppTokens.buttonHeightSm,
        AppIconButtonSize.md => AppTokens.buttonHeightMd,
        AppIconButtonSize.lg => AppTokens.tableRowHeight,
      };

  double get _iconSize => switch (size) {
        AppIconButtonSize.sm => AppTokens.iconButtonIconSm,
        AppIconButtonSize.md => AppTokens.iconButtonIconMd,
        AppIconButtonSize.lg => AppTokens.iconSizeMd,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final box = _boxExtent;
    final radius = BorderRadius.circular(AppTokens.radiusMd);

    final Color materialColor = switch (variant) {
      AppIconButtonVariant.filled => AppTokens.primary800,
      _ => theme.colorScheme.surface.withValues(alpha: AppTokens.space0),
    };

    final BorderSide shapeSide = switch (variant) {
      AppIconButtonVariant.outlined => BorderSide(
          color: brightness == Brightness.dark
              ? AppTokens.neutral700
              : AppTokens.neutral200,
          width: AppTokens.borderWidthHairline,
        ),
      AppIconButtonVariant.danger => const BorderSide(
        color: AppTokens.error100,
        width: AppTokens.borderWidthHairline,
      ),
      _ => BorderSide.none,
    };

    final Color iconColor = switch (variant) {
      AppIconButtonVariant.filled => AppTokens.white,
      AppIconButtonVariant.danger => AppTokens.accent500,
      AppIconButtonVariant.outlined ||
      AppIconButtonVariant.ghost =>
        brightness == Brightness.dark
            ? theme.colorScheme.onSurface
            : AppTokens.neutral600,
    };

    final Widget core = Material(
      color: materialColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: shapeSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        canRequestFocus: onPressed != null,
        child: SizedBox(
          width: box,
          height: box,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: _iconSize,
                color: iconColor,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return core;
    }
    return Tooltip(
      message: tooltip!,
      child: core,
    );
  }
}
