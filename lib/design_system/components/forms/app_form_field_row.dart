import 'package:flutter/material.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';

/// Full-width field inside a form column (semantic wrapper).
class AppFormFullWidth extends StatelessWidget {
  const AppFormFullWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: child);
  }
}

/// Wraps a field cell in [AppFormFieldRow] with optional flex on desktop (Row).
class AppFormFieldSpan extends StatelessWidget {
  const AppFormFieldSpan({
    super.key,
    required this.child,
    this.flex = 1,
  });

  final Widget child;

  /// Horizontal flex when this row lays out as a [Row] on desktop.
  final int flex;

  @override
  Widget build(BuildContext context) => child;
}

/// Responsive row: two columns on desktop, stacked on mobile.
///
/// Children should be inputs with labels above (e.g. [AppInput]). Use
/// [AppFormFieldSpan] to set flex for uneven widths on desktop.
class AppFormFieldRow extends StatelessWidget {
  const AppFormFieldRow({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = AppBreakpoints.isDesktopWidth(constraints.maxWidth);
        if (!desktop || children.length == 1) {
          final stacked = children
              .map((w) => w is AppFormFieldSpan ? w.child : w)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withVerticalGaps(stacked),
          );
        }

        final rowChildren = <Widget>[];
        for (var i = 0; i < children.length; i++) {
          if (i > 0) {
            rowChildren.add(SizedBox(width: AppTokens.space3));
          }
          final w = children[i];
          final flex = w is AppFormFieldSpan ? w.flex : 1;
          final child = w is AppFormFieldSpan ? w.child : w;
          rowChildren.add(Expanded(flex: flex, child: child));
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: rowChildren,
        );
      },
    );
  }

  List<Widget> _withVerticalGaps(List<Widget> items) {
    if (items.isEmpty) {
      return items;
    }
    final out = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      out
        ..add(SizedBox(height: AppTokens.space4))
        ..add(items[i]);
    }
    return out;
  }
}

/// Alias for [AppFormFieldRow] (responsive two-column form layout).
typedef ResponsiveGridRow = AppFormFieldRow;
