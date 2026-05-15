import 'package:flutter/material.dart';

import '../tokens.dart';

/// Standard scrollbar metrics for tables and panels across Ultra Labs.
abstract final class AppScrollMetrics {
  /// Wide enough for mouse click/drag on desktop and web.
  static const double thickness = AppTokens.space3;

  static Radius get radius => Radius.circular(AppTokens.inputRadius);
}

/// Draggable, always-visible scrollbar wired to [controller].
class AppScrollbar extends StatelessWidget {
  const AppScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.thumbVisibility = true,
    this.trackVisibility = true,
  });

  final ScrollController controller;
  final Widget child;
  final Axis scrollDirection;
  final bool thumbVisibility;
  final bool trackVisibility;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      interactive: true,
      thickness: AppScrollMetrics.thickness,
      radius: AppScrollMetrics.radius,
      notificationPredicate: scrollDirection == Axis.horizontal
          ? (ScrollNotification n) => n.metrics.axis == Axis.horizontal
          : (ScrollNotification n) => n.metrics.axis == Axis.vertical,
      child: child,
    );
  }
}
