import 'package:flutter/widgets.dart';

import 'filter_config.dart';

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
    this.filterConfig,
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

  /// Optional inline column filter. When non-null, a filter icon appears in
  /// the column header and tapping it opens a filter popover.
  final ColumnFilterConfig? filterConfig;
}
