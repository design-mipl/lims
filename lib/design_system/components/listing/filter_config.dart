/// Supported filter field types in [AppListingScreen] filter panels.
enum FilterType {
  text,
  multiSelect,
  dateRange,
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
