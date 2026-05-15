import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Ultra Labs desktop-friendly scroll behavior (web + Windows).
///
/// Enables mouse drag-to-scroll and trackpad gestures on all [Scrollable]s.
class LimsScrollBehavior extends MaterialScrollBehavior {
  const LimsScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}
