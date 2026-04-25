/// Supported filter field types in [AppListingScreen] filter panels.
enum FilterType {
  text,
  multiSelect,
  dateRange,
}

/// Filter type for inline column-header filter popovers.
enum ColumnFilterType { text, select }

/// Per-column filter configuration. Attach to [TableColumn.filterConfig] to
/// enable the filter icon and popover on that column header.
class ColumnFilterConfig {
  const ColumnFilterConfig({required this.type, this.options});

  final ColumnFilterType type;

  /// Option labels for [ColumnFilterType.select].
  final List<String>? options;
}

/// Declarative filter field shown in the filter sheet / side panel.
class FilterField {
  const FilterField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });

  final String key;
  final String label;
  final FilterType type;

  /// Option labels for [FilterType.multiSelect].
  final List<String>? options;
}

/// Applied filter shown as a chip and passed to [AppListingScreen.onFiltersChanged].
class ActiveFilter {
  const ActiveFilter({
    required this.key,
    required this.label,
    required this.value,
    required this.rawValue,
  });

  final String key;
  final String label;
  final String value;
  final dynamic rawValue;
}
