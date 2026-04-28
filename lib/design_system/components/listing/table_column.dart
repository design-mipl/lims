import 'package:flutter/widgets.dart';

import 'filter_config.dart';

/// Column definition for [AppListingScreen] data tables.
class TableColumn<T> {
  const TableColumn({
    required this.key,
    required this.label,
    required this.cellBuilder,
    this.width,
    this.flex,
    this.sortable = true,
    this.visible = true,
    this.numeric = false,
    this.filterConfig,
    this.filter,
    this.filterTextValue,
    this.filterSelectValue,
    this.sortValue,
  });

  final String key;
  final String label;
  final Widget Function(T row) cellBuilder;

  /// Fixed width in logical pixels; `null` means flex (shares remaining width).
  final double? width;

  /// Optional flex weight used during listing width distribution.
  ///
  /// When provided, [AppListingScreen] allocates any remaining horizontal space
  /// proportionally across all columns with a non-null [flex], while keeping
  /// header and data cells aligned through the shared computed width list.
  final int? flex;

  final bool sortable;
  final bool visible;

  /// When true, header label and cell content are right-aligned.
  final bool numeric;

  /// Optional inline column filter. When non-null, a filter icon appears in
  /// the column header and tapping it opens a filter popover.
  final ColumnFilterConfig? filterConfig;

  /// Optional column filter (new API). When non-null with [filterConfig], this
  /// takes precedence in [AppListingScreen].
  final AppColumnFilter? filter;

  /// Returns the string matched for [AppColumnFilterType.text] / text
  /// [ColumnFilterConfig] when a column filter is active. If null while a text
  /// filter is applied for this column, that filter is ignored for the row.
  final String Function(T row)? filterTextValue;

  /// Returns the value compared to select filter options for
  /// [AppColumnFilterType.select] / select [ColumnFilterConfig]. If null while
  /// a select filter is applied, that filter is ignored for the row.
  final String Function(T row)? filterSelectValue;

  /// Returns a comparable value for client-side sorting.
  ///
  /// - Return [num] for numeric columns (compared with [num.compareTo]).
  /// - Return [String] for text columns (compared case-insensitively).
  /// - Return `DateTime.millisecondsSinceEpoch` (an [int]) for date columns.
  /// - When `null`, the column is treated as not sortable (regardless of
  ///   [sortable]); the sort handler will skip it.
  final dynamic Function(T row)? sortValue;
}
