import 'package:flutter/material.dart';

/// Toolbar action run against the current row selection.
class BulkAction<T> {
  const BulkAction({
    required this.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
    this.showOnlyWhenSelected = false,
  });

  final String key;
  final String label;
  final Widget icon;

  /// Invoked with the currently selected row values (same order as indices).
  final void Function(List<T> rows) onTap;

  final bool isDanger;

  /// When true, the action is omitted from the bulk bar until at least one row
  /// is selected (not merely disabled).
  final bool showOnlyWhenSelected;
}
