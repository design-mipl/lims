import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps **Shift + mouse wheel** (and horizontal trackpad delta) to [controller].
class AppShiftWheelHorizontalScroll extends StatelessWidget {
  const AppShiftWheelHorizontalScroll({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    if (!shift && event.scrollDelta.dx.abs() <= event.scrollDelta.dy.abs()) {
      return;
    }
    if (!controller.hasClients) return;
    final position = controller.position;
    final delta = shift
        ? event.scrollDelta.dy
        : (event.scrollDelta.dx.abs() >= event.scrollDelta.dy.abs()
            ? event.scrollDelta.dx
            : 0);
    if (delta == 0) return;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) {
      controller.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: child,
    );
  }
}
