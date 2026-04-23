import 'package:flutter/widgets.dart';

/// Column definition for [AppListingScreen] data tables.
class TableColumn<T> {
  const TableColumn({
    required this.key,
    required this.label,
    required this.cellBuilder,
    this.width,
    this.sortable = true,
    this.visible = true,
    this.numeric = false,
  });

  final String key;
  final String label;
  final Widget Function(T row) cellBuilder;

  /// Fixed width in logical pixels; `null` means flex (shares remaining width).
  final double? width;

  final bool sortable;
  final bool visible;

  /// When true, header label and cell content are right-aligned.
  final bool numeric;
}
