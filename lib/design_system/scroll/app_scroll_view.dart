import 'package:flutter/material.dart';

import 'app_scrollbar.dart';
import 'app_shift_wheel_horizontal_scroll.dart';

/// [SingleChildScrollView] + [AppScrollbar] with shared [ScrollController].
///
/// Horizontal instances also support **Shift + mouse wheel** when [enableShiftWheel]
/// is true (default).
class AppScrollView extends StatefulWidget {
  const AppScrollView({
    super.key,
    required this.scrollDirection,
    required this.child,
    this.controller,
    this.primary,
    this.physics,
    this.padding,
    this.showScrollbar = true,
    this.enableShiftWheel = true,
  });

  final Axis scrollDirection;
  final Widget child;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool showScrollbar;
  final bool enableShiftWheel;

  @override
  State<AppScrollView> createState() => _AppScrollViewState();
}

class _AppScrollViewState extends State<AppScrollView> {
  ScrollController? _owned;

  ScrollController get _controller => widget.controller ?? _owned!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _owned = ScrollController();
    }
  }

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scrollable = SingleChildScrollView(
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      primary: widget.primary ?? false,
      physics: widget.physics ?? const ClampingScrollPhysics(),
      padding: widget.padding,
      child: widget.child,
    );

    if (widget.scrollDirection == Axis.horizontal && widget.enableShiftWheel) {
      scrollable = AppShiftWheelHorizontalScroll(
        controller: _controller,
        child: scrollable,
      );
    }

    if (!widget.showScrollbar) return scrollable;

    return AppScrollbar(
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      child: scrollable,
    );
  }
}
