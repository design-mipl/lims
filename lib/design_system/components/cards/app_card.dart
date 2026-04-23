import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Elevated surface container with optional tap affordance.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hasBorder = true,
    this.shadow,
    this.backgroundColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool hasBorder;
  final List<BoxShadow>? shadow;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedRadius =
        borderRadius ?? BorderRadius.circular(AppTokens.radiusLg);
    final resolvedPadding =
        padding ?? EdgeInsets.all(AppTokens.space4);
    final resolvedShadow = shadow ?? AppTokens.shadowSm;
    final surfaceColor = backgroundColor ?? theme.cardColor;
    final borderColor = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral200;

    final shape = RoundedRectangleBorder(
      borderRadius: resolvedRadius,
      side: hasBorder
          ? BorderSide(
              color: borderColor,
              width: AppTokens.borderWidthHairline,
            )
          : BorderSide.none,
    );

    final paddedChild = Padding(
      padding: resolvedPadding,
      child: child,
    );

    final card = Card(
      margin: EdgeInsets.zero,
      color: surfaceColor,
      elevation: AppTokens.space0,
      surfaceTintColor:
          theme.colorScheme.surface.withValues(alpha: AppTokens.space0),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? paddedChild
          : InkWell(
              onTap: onTap,
              borderRadius: resolvedRadius,
              child: paddedChild,
            ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: resolvedRadius,
        boxShadow: resolvedShadow,
      ),
      child: card,
    );
  }
}
