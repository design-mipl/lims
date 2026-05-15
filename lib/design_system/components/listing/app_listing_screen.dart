import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../breakpoints.dart';
import '../../scroll/app_scrollbar.dart';
import '../../scroll/app_shift_wheel_horizontal_scroll.dart';
import '../../tokens.dart';
import '../cards/app_card.dart';
import '../display/kpi_metric.dart';
import '../forms/app_confirm_dialog.dart';
import '../primitives/app_button.dart';
import '../primitives/app_icon_button.dart';
import '../primitives/app_input.dart';
import '../primitives/app_select.dart';
import 'bulk_action.dart';
import 'filter_config.dart';
import 'listing_bulk_print.dart';
import 'listing_lab_date_field.dart';
import 'listing_pagination_controls.dart';
import 'table_column.dart';

bool _tableColumnHasFilter<T>(TableColumn<T> col) =>
    col.filter != null || col.filterConfig != null;

/// Resolved column-header filter: text mode or select with [AppSelectItem] list.
({bool isText, List<AppSelectItem<String>>? selectItems})?
_resolvedColumnFilter<T>(TableColumn<T> col) {
  final f = col.filter;
  if (f != null) {
    return switch (f.type) {
      AppColumnFilterType.text => (isText: true, selectItems: null),
      AppColumnFilterType.select => (
        isText: false,
        selectItems: f.options ?? <AppSelectItem<String>>[],
      ),
      AppColumnFilterType.dateRange => null,
    };
  }
  final c = col.filterConfig;
  if (c != null) {
    return switch (c.type) {
      ColumnFilterType.text => (isText: true, selectItems: null),
      ColumnFilterType.select => (
        isText: false,
        selectItems: (c.options ?? <String>[])
            .map((s) => AppSelectItem<String>(value: s, label: s))
            .toList(),
      ),
    };
  }
  return null;
}

// -----------------------------------------------------------------------------
// Desktop table layout (header + body share these insets)
// -----------------------------------------------------------------------------

double get _kListingTableOuterGutter => AppTokens.space0;

/// Listing tab bar row height (compact); differs from [AppTokens.listingTabBarHeight].
const double _kListingTabBarHeight = 36.0;

const double _kListingTabBadgeHeight = 16.0;

const double _kListingTabBadgeFontSize = 10.0;
const double _kListingBodyMinRows = 2.0;

/// Horizontal scrollbar strip under the grid; bounded height keeps Scrollbar +
/// track paint from expanding past a tight [Expanded] table viewport (avoids
/// bottom overflow when embedded with other flex siblings).
const double _kListingTableHScrollFooterHeight = 36.0;

EdgeInsets _listingTableCellPadding({required bool isHeader}) =>
    EdgeInsets.symmetric(horizontal: 12, vertical: isHeader ? 0 : 0);

bool _isListingCenterPillColumn(String key) => key == 'status';

/// Test-matrix checkbox columns (Lab Manager Assignment).
bool _isListingCenterCheckboxColumn(String key) => key.startsWith('test_');

bool _isListingCenterContentColumn(String key) =>
    _isListingCenterPillColumn(key) || _isListingCenterCheckboxColumn(key);

Alignment _alignmentForTableColumn<T>(TableColumn<T> col) {
  if (_isListingCenterContentColumn(col.key)) {
    return Alignment.center;
  }
  if (col.numeric) {
    return Alignment.centerRight;
  }
  return Alignment.centerLeft;
}

MainAxisAlignment _headerMainAxisForColumn<T>(TableColumn<T> col) {
  if (_isListingCenterContentColumn(col.key)) {
    return MainAxisAlignment.center;
  }
  if (col.numeric) {
    return MainAxisAlignment.end;
  }
  return MainAxisAlignment.start;
}

TextAlign _textAlignForColumn<T>(TableColumn<T> col) {
  if (_isListingCenterContentColumn(col.key)) {
    return TextAlign.center;
  }
  if (col.numeric) {
    return TextAlign.end;
  }
  return TextAlign.start;
}

Widget _listingTableCellShell({
  required double width,
  required Alignment alignment,
  required Widget child,
  bool isHeader = false,
}) {
  return SizedBox(
    width: width,
    child: Padding(
      padding: _listingTableCellPadding(isHeader: isHeader),
      child: Align(alignment: alignment, child: child),
    ),
  );
}

// -----------------------------------------------------------------------------
// Supporting models
// -----------------------------------------------------------------------------

/// Tab item for the custom tab strip on [AppListingScreen].
class TabConfig {
  const TabConfig({required this.label, this.count});

  final String label;
  final int? count;
}

/// Single row action in the overflow menu.
class RowAction<T> {
  const RowAction({
    required this.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
    this.isEnabled,
    this.labelBuilder,
    this.iconBuilder,
  });

  final String key;
  final String label;
  final Widget icon;
  final void Function(T row) onTap;
  final bool isDanger;

  /// When non-null, used to build the menu label for [row]; falls back to [label].
  final String Function(T row)? labelBuilder;

  /// When non-null, used to build the menu icon for [row]; falls back to [icon].
  final Widget Function(T row)? iconBuilder;

  /// When null, the action is always enabled. Otherwise called with the row.
  final bool Function(T row)? isEnabled;

  bool enabledFor(T row) => isEnabled?.call(row) ?? true;
}

/// Generic listing page: responsive table (desktop/tablet) or card list (mobile).
///
/// Sort headers update [_sortColumnKey] / [_sortDirection] using a 3-state
/// cycle: `asc → desc → unsorted`. When sortable rows have a non-null
/// [TableColumn.sortValue], the listing sorts the current page client-side.
/// When [onSortChanged] is set, it is also invoked so the parent can refetch
/// or reorder [rows] for server-side sort.
///
/// Per-column header filters subset the current [rows] list client-side only
/// (pagination totals are unchanged). For filters to narrow rows, set
/// [TableColumn.filterTextValue] and/or [TableColumn.filterSelectValue] on
/// filtered columns.
class AppListingScreen<T> extends StatefulWidget {
  const AppListingScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleIcon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.extraActions,
    this.kpiCards,
    this.tabs,
    this.initialTabIndex = 0,
    this.onTabChanged,
    required this.columns,
    required this.rows,
    required this.mobileCardBuilder,
    this.isLoading = false,
    this.emptyMessage = 'No records found',
    this.emptyWidget,
    this.onRowTap,
    this.showCheckboxes = true,
    this.showToggle = false,
    this.onToggleChanged,
    this.rowActions,
    this.bulkActions,
    this.showSearch = true,
    this.searchHint = 'Search...',
    this.onSearch,
    this.showExport = false,
    this.showImport = false,
    this.showPrint = false,
    this.showColumnToggle = true,
    this.onExport,
    this.onImport,
    this.onPrint,
    this.filterFields,
    this.activeFilters = const [],
    this.onFiltersChanged,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.onSortChanged,
    this.showKpis = true,
    this.onBulkActivate,
    this.onBulkDeactivate,
    this.onBulkDelete,
    this.onBulkExport,
    this.bulkPrimaryLabel,
    this.onBulkPrimary,
    this.bulkRowId,
    this.toolbarAfterSearch,
    this.toolbarTrailingActions,
    this.tableScrollableMinWidth,
    this.showTableHorizontalScrollbar = false,
    this.showPageHeader = true,
    this.onRowSelectionChanged,
    this.showToolbar = true,
    this.showBulkBar = true,
    this.bulkBarVisibleOnlyWhenSelection = false,
    this.bulkSelectionSummary,
    this.tableHeaderHeight,
    this.tableRowHeight,
    this.paginationFooterHeight,
    this.tableBodyFillsViewport = false,
    this.tableBodyVerticalScrollController,
    this.listingShellPadding,
    this.showExpandColumn = false,
    this.isRowExpanded,
    this.onExpandRowTap,
    this.expandedRowBuilder,
    this.expandedPanelContentPadding,
    this.showActionsColumnLeadingBorder = true,
    this.showPaginationFooter = true,
    this.tabsBelowToolbar = false,
    this.rowBackgroundColor,
    this.disableOuterVerticalScroll = false,
    this.actionsColumnWidth,
    this.scaleDataColumnsToFillViewport = true,
  });

  /// When non-null, invoked after row checkbox selection changes (indices into
  /// [rows], not filtered order).
  final ValueChanged<Set<int>>? onRowSelectionChanged;

  /// When false, omits the listing page title/subtitle/KPI header so the table
  /// can be embedded under another chrome (e.g. [AppFormPage]).
  final bool showPageHeader;

  final String title;
  final String subtitle;
  final Widget? titleIcon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final List<Widget>? extraActions;

  final List<KpiCard>? kpiCards;
  final List<TabConfig>? tabs;
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;

  final List<TableColumn<T>> columns;
  final List<T> rows;
  final Widget Function(T row) mobileCardBuilder;
  final bool isLoading;
  final String? emptyMessage;
  final Widget? emptyWidget;

  final ValueChanged<T>? onRowTap;
  final bool showCheckboxes;
  final bool showToggle;
  final ValueChanged<T>? onToggleChanged;

  final List<RowAction<T>>? rowActions;
  final List<BulkAction<T>>? bulkActions;

  final bool showSearch;
  final String searchHint;
  final ValueChanged<String>? onSearch;

  final bool showExport;
  final bool showImport;
  final bool showPrint;
  final bool showColumnToggle;
  final VoidCallback? onExport;
  final VoidCallback? onImport;
  final VoidCallback? onPrint;

  final List<FilterField>? filterFields;
  final List<ActiveFilter> activeFilters;
  final ValueChanged<List<ActiveFilter>>? onFiltersChanged;

  final int totalCount;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final List<int> pageSizeOptions;

  /// Notifies parent when the user changes sort column or direction.
  final ValueChanged<({String columnKey, bool ascending})>? onSortChanged;

  /// When false, KPI cards are not shown even if [kpiCards] is provided.
  final bool showKpis;

  final Future<void> Function(List<dynamic> selectedIds)? onBulkActivate;

  final Future<void> Function(List<dynamic> selectedIds)? onBulkDeactivate;

  final Future<void> Function(List<dynamic> selectedIds)? onBulkDelete;

  final Future<void> Function(List<dynamic> selectedRows)? onBulkExport;

  /// Optional primary bulk action label (e.g. "Verify"). Shown as a filled
  /// [AppButton] that stays visible when there is no selection but is disabled
  /// until rows are selected (unlike greyed mini actions).
  final String? bulkPrimaryLabel;

  /// Invoked with selected row ids when the primary bulk button is pressed.
  final Future<void> Function(List<dynamic> selectedIds)? onBulkPrimary;

  /// Maps a row to an id for [onBulkActivate] / [onBulkDeactivate] / [onBulkDelete].
  /// When null, those callbacks receive the row objects as [dynamic].
  final dynamic Function(T row)? bulkRowId;

  /// Optional widgets placed after the search field and before the toolbar
  /// [Spacer] (e.g. date filters). Use compact heights matching the toolbar
  /// search field ([AppTokens.listingToolbarSearchHeight]).
  final List<Widget>? toolbarAfterSearch;

  /// Compact actions placed on the toolbar right, before Export / Columns.
  final List<Widget>? toolbarTrailingActions;

  /// When non-null, the data columns use at least this width for layout so fixed
  /// and flex columns do not over-compress; the table [SingleChildScrollView]
  /// scrolls horizontally when the viewport is narrower.
  final double? tableScrollableMinWidth;

  /// When true, a horizontal [Scrollbar] is shown under the data rows (pagination
  /// stays below). Uses a [ScrollController] linked to the header and row scrollers.
  final bool showTableHorizontalScrollbar;

  /// When false, omits the search/export/columns toolbar row inside the listing card.
  final bool showToolbar;

  /// When false, omits the bulk-selection bar above the table.
  final bool showBulkBar;

  /// When true with [showBulkBar], the bulk strip is hidden until at least one row is selected.
  final bool bulkBarVisibleOnlyWhenSelection;

  /// Replaces the default “N rows selected” label when non-null.
  final String Function(int selectedCount)? bulkSelectionSummary;

  /// Optional override for data table header row height (defaults to [AppTokens.tableHeaderHeight]).
  final double? tableHeaderHeight;

  /// Optional override for data table body row height (defaults to [AppTokens.tableRowHeight]).
  final double? tableRowHeight;

  /// Optional override for the pagination footer row height (defaults to
  /// [AppTokens.listingPaginationHeight]).
  final double? paginationFooterHeight;

  /// When true on non-mobile widths, the listing root uses [Column] + [Expanded] so the page
  /// body gets bounded height: tabs/toolbar/bulk stay pinned in the card and only the data
  /// rows scroll vertically (with scrollbar and sticky column header). Works with or without
  /// [showPageHeader] (title/subtitle stay pinned above the card when the header is shown).
  ///
  /// On mobile widths, this flag is ignored (same layout as [tableBodyFillsViewport] false).
  final bool tableBodyFillsViewport;

  /// Optional vertical scroll controller for the table body when [tableBodyFillsViewport] is true.
  /// If null, an internal controller is created and disposed by this widget.
  final ScrollController? tableBodyVerticalScrollController;

  /// Padding around the listing card (tabs, table, pagination) inside the page shell.
  ///
  /// When null, defaults to horizontal [AppTokens.space5] and bottom [AppTokens.space4]
  /// (matches full-page listings). For embedding next to other full-width sections
  /// (e.g. under [AppFormPage] with shared horizontal inset), pass an [EdgeInsets] without
  /// extra horizontal inset so edges align with siblings.
  final EdgeInsets? listingShellPadding;

  /// When true, renders a leading expand column (before checkboxes) with a
  /// (+)/(-) toggle when [expandedRowBuilder], [isRowExpanded], and
  /// [onExpandRowTap] are also set.
  ///
  /// Inline expansion can still run with [showExpandColumn] false: pass the
  /// three callbacks and drive toggling from [onRowTap] (no expand column).
  final bool showExpandColumn;

  /// Whether [row] is expanded for [expandedRowBuilder].
  final bool Function(T row)? isRowExpanded;

  /// Toggles expansion for [row] (parent should update state).
  final void Function(T row)? onExpandRowTap;

  /// Inline content below the row when expanded; must stay non-modal.
  final Widget Function(BuildContext context, T row)? expandedRowBuilder;

  /// Padding inside the desktop inline expand panel around [expandedRowBuilder]
  /// content (between checkbox/toggle gutter and actions gutter).
  ///
  /// When null, uses horizontal [AppTokens.space2] and vertical [AppTokens.space3].
  /// Pass [EdgeInsets.zero] or tighter insets when nested content should align
  /// flush with the listing row (e.g. wide nested tables).
  final EdgeInsets? expandedPanelContentPadding;

  /// When false, the fixed actions column has no left border (matches tables
  /// that should blend with the scrollable data area).
  final bool showActionsColumnLeadingBorder;

  /// When false, omits the footer pagination row (use [toolbarAfterSearch] with
  /// [ListingPaginationControls] placement [ListingPaginationPlacement.toolbar]
  /// instead).
  final bool showPaginationFooter;

  /// When true, renders [ListingTabStrip] below the toolbar row instead of above.
  final bool tabsBelowToolbar;

  /// Optional per-row background tint on desktop (e.g. status stripes).
  final Color? Function(T row)? rowBackgroundColor;

  /// When true with [tableBodyFillsViewport] false, omits the outer vertical
  /// [SingleChildScrollView] around the listing shell so a parent owns vertical
  /// scrolling (embedded workspaces).
  final bool disableOuterVerticalScroll;

  /// When non-null, replaces [AppTokens.tableActionsColumnWidth] for this listing only.
  final double? actionsColumnWidth;

  /// When true (default), fixed-width data columns scale up to fill extra viewport
  /// width. When false, they keep their declared widths (finance-style dense grids).
  final bool scaleDataColumnsToFillViewport;

  @override
  State<AppListingScreen<T>> createState() => _AppListingScreenState<T>();
}

class _AppListingScreenState<T> extends State<AppListingScreen<T>>
    with TickerProviderStateMixin {
  final Set<int> _selectedRows = <int>{};
  bool _filterPanelOpen = false;
  late List<bool> _columnVisibility;
  String? _sortColumnKey;
  // 'asc' | 'desc' | null — null means not sorted.
  String? _sortDirection;
  int _selectedTab = 0;

  double get _tableRowHeight =>
      widget.tableRowHeight ?? AppTokens.tableRowHeight;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _searchController = TextEditingController();

  // Column selector overlay
  final LayerLink _columnsButtonLink = LayerLink();
  OverlayEntry? _columnSelectorEntry;

  // Column filter overlays
  final Map<String, LayerLink> _colFilterLinks = {};
  OverlayEntry? _colFilterEntry;

  /// Syncs horizontal scroll of table header and data rows (see linked_scroll_controller).
  final LinkedScrollControllerGroup _tableHScrollGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _tableHeaderHScroll;
  ScrollController? _tableFooterHScroll;

  /// Owned when [AppListingScreen.tableBodyVerticalScrollController] is null and fill mode is on.
  ScrollController? _ownedTableBodyVScroll;

  // Column filter applied values (key = column key)
  final Map<String, String> _colFilterText = {};
  final Map<String, Set<String>> _colFilterMulti = {};
  final Map<String, DateTime?> _colFilterDateFrom = {};
  final Map<String, DateTime?> _colFilterDateTo = {};

  final Map<String, TextEditingController> _filterTextCtrls = {};
  final Map<String, Set<String>> _draftMulti = {};
  final Map<String, DateTime?> _draftDateFrom = {};
  final Map<String, DateTime?> _draftDateTo = {};
  final Map<String, TextEditingController> _draftDateFromText = {};
  final Map<String, TextEditingController> _draftDateToText = {};

  List<TableColumn<T>> get _visibleColumnDefs {
    final out = <TableColumn<T>>[];
    for (var i = 0; i < widget.columns.length; i++) {
      if (i < _columnVisibility.length && _columnVisibility[i]) {
        out.add(widget.columns[i]);
      }
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _tableHeaderHScroll = _tableHScrollGroup.addAndGet();
    if (widget.showTableHorizontalScrollbar) {
      _tableFooterHScroll = _tableHScrollGroup.addAndGet();
    }
    _columnVisibility = List<bool>.generate(
      widget.columns.length,
      (i) => widget.columns[i].visible,
    );
    _selectedTab = _clampTab(widget.initialTabIndex);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initFilterControllers();
    _ensureTableBodyVScroll();
  }

  void _ensureTableBodyVScroll() {
    final wantOwn =
        widget.tableBodyFillsViewport &&
        widget.tableBodyVerticalScrollController == null;
    if (wantOwn && _ownedTableBodyVScroll == null) {
      _ownedTableBodyVScroll = ScrollController();
    } else if (!wantOwn && _ownedTableBodyVScroll != null) {
      _ownedTableBodyVScroll!.dispose();
      _ownedTableBodyVScroll = null;
    }
  }

  int _clampTab(int i) {
    final tabs = widget.tabs;
    if (tabs == null || tabs.isEmpty) {
      return 0;
    }
    if (i < 0) {
      return 0;
    }
    if (i >= tabs.length) {
      return tabs.length - 1;
    }
    return i;
  }

  void _initFilterControllers() {
    final fields = widget.filterFields;
    if (fields == null) {
      return;
    }
    for (final f in fields) {
      switch (f.type) {
        case FilterType.text:
          _filterTextCtrls.putIfAbsent(f.key, TextEditingController.new);
        case FilterType.multiSelect:
          _draftMulti.putIfAbsent(f.key, () => <String>{});
        case FilterType.dateRange:
          _draftDateFrom.putIfAbsent(f.key, () => null);
          _draftDateTo.putIfAbsent(f.key, () => null);
          _draftDateFromText.putIfAbsent(f.key, TextEditingController.new);
          _draftDateToText.putIfAbsent(f.key, TextEditingController.new);
      }
    }
  }

  void _disposeFilterControllers() {
    for (final c in _filterTextCtrls.values) {
      c.dispose();
    }
    _filterTextCtrls.clear();
    for (final c in _draftDateFromText.values) {
      c.dispose();
    }
    _draftDateFromText.clear();
    for (final c in _draftDateToText.values) {
      c.dispose();
    }
    _draftDateToText.clear();
    _draftMulti.clear();
    _draftDateFrom.clear();
    _draftDateTo.clear();
  }

  @override
  void dispose() {
    _columnSelectorEntry?.remove();
    _columnSelectorEntry = null;
    _colFilterEntry?.remove();
    _colFilterEntry = null;
    _pulseController.dispose();
    _searchController.dispose();
    _tableHeaderHScroll.dispose();
    _tableFooterHScroll?.dispose();
    _ownedTableBodyVScroll?.dispose();
    _disposeFilterControllers();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppListingScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureTableBodyVScroll();
    if (oldWidget.columns.length != widget.columns.length) {
      _columnVisibility = List<bool>.generate(
        widget.columns.length,
        (i) => widget.columns[i].visible,
      );
    }
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _selectedTab = _clampTab(widget.initialTabIndex);
    }
    if (oldWidget.rows.length != widget.rows.length) {
      _selectedRows.removeWhere((i) => i >= widget.rows.length);
      _scheduleEmitRowSelection();
    }
    if (oldWidget.filterFields != widget.filterFields) {
      _disposeFilterControllers();
      _initFilterControllers();
    }
  }

  void _hydrateDraftFromActiveFilters() {
    final fields = widget.filterFields;
    if (fields == null) {
      return;
    }
    for (final f in fields) {
      final match = widget.activeFilters.where((a) => a.key == f.key).toList();
      switch (f.type) {
        case FilterType.text:
          final c = _filterTextCtrls[f.key];
          if (c != null) {
            final v = match.isNotEmpty ? match.first.value : '';
            c.text = v;
          }
        case FilterType.multiSelect:
          if (match.isNotEmpty && match.first.rawValue is List) {
            final raw = match.first.rawValue as List;
            _draftMulti[f.key] = raw.map((e) => e.toString()).toSet();
          } else {
            _draftMulti[f.key] = <String>{};
          }
        case FilterType.dateRange:
          if (match.isNotEmpty && match.first.rawValue is Map) {
            final m = Map<Object?, Object?>.from(match.first.rawValue! as Map);
            _draftDateFrom[f.key] = m['from'] is DateTime
                ? m['from'] as DateTime
                : null;
            _draftDateTo[f.key] = m['to'] is DateTime
                ? m['to'] as DateTime
                : null;
          } else {
            _draftDateFrom[f.key] = null;
            _draftDateTo[f.key] = null;
          }
          _syncDateTextControllers(f.key);
      }
    }
  }

  void _syncDateTextControllers(String key) {
    String fmt(DateTime? d) {
      if (d == null) {
        return '';
      }
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    _draftDateFromText[key]?.text = fmt(_draftDateFrom[key]);
    _draftDateToText[key]?.text = fmt(_draftDateTo[key]);
  }

  List<ActiveFilter> _collectFiltersFromDraft() {
    final out = <ActiveFilter>[];
    final fields = widget.filterFields;
    if (fields == null) {
      return out;
    }
    for (final f in fields) {
      switch (f.type) {
        case FilterType.text:
          final text = _filterTextCtrls[f.key]?.text.trim() ?? '';
          if (text.isNotEmpty) {
            out.add(
              ActiveFilter(
                key: f.key,
                label: f.label,
                value: text,
                rawValue: text,
              ),
            );
          }
        case FilterType.multiSelect:
          final set = _draftMulti[f.key] ?? {};
          if (set.isNotEmpty) {
            out.add(
              ActiveFilter(
                key: f.key,
                label: f.label,
                value: set.join(', '),
                rawValue: set.toList(),
              ),
            );
          }
        case FilterType.dateRange:
          final from = _draftDateFrom[f.key];
          final to = _draftDateTo[f.key];
          if (from != null || to != null) {
            final fromS = from != null
                ? '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}'
                : '…';
            final toS = to != null
                ? '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}'
                : '…';
            out.add(
              ActiveFilter(
                key: f.key,
                label: f.label,
                value: '$fromS — $toS',
                rawValue: <String, DateTime?>{'from': from, 'to': to},
              ),
            );
          }
      }
    }
    return out;
  }

  void _clearFilterDraft() {
    for (final c in _filterTextCtrls.values) {
      c.clear();
    }
    for (final k in _draftMulti.keys.toList()) {
      _draftMulti[k] = <String>{};
    }
    for (final k in _draftDateFrom.keys.toList()) {
      _draftDateFrom[k] = null;
      _draftDateTo[k] = null;
      _syncDateTextControllers(k);
    }
  }

  /// Widths for scrollable data columns only (excludes checkbox, toggle, actions).
  List<double> _computeDataColumnWidths(double maxWidth) {
    final cols = _visibleColumnDefs;
    if (cols.isEmpty) return const <double>[];
    final widths = List<double>.filled(
      cols.length,
      AppTokens.space0,
      growable: false,
    );
    var fixedTotal = AppTokens.space0;
    var totalFlexWeight = 0;
    final flexIndices = <int>[];

    for (var i = 0; i < cols.length; i++) {
      final c = cols[i];
      if (c.flex != null && c.flex! > 0) {
        flexIndices.add(i);
        totalFlexWeight += c.flex!;
        continue;
      }
      var baseWidth = c.width ?? 150.0;
      if (_isListingCenterPillColumn(c.key)) {
        baseWidth = math.max(
          baseWidth,
          AppTokens.tableStatusColumnPreferredWidth,
        );
      }
      widths[i] = baseWidth;
      fixedTotal += baseWidth;
    }

    if (flexIndices.isNotEmpty) {
      final remaining = math.max(AppTokens.space0, maxWidth - fixedTotal);
      final fallbackFlexWidth = 150.0;
      final effectiveFlexTotal = remaining > AppTokens.space0
          ? remaining
          : fallbackFlexWidth * flexIndices.length;
      for (final idx in flexIndices) {
        final weight = cols[idx].flex!;
        widths[idx] = effectiveFlexTotal * (weight / totalFlexWeight);
      }
      return widths;
    }

    final totalDefinedWidth = widths.fold<double>(
      AppTokens.space0,
      (a, b) => a + b,
    );
    if (widget.scaleDataColumnsToFillViewport &&
        maxWidth > AppTokens.space0 &&
        totalDefinedWidth < maxWidth &&
        totalDefinedWidth > AppTokens.space0) {
      final scale = maxWidth / totalDefinedWidth;
      return widths.map((w) => w * scale).toList(growable: false);
    }
    return widths;
  }

  bool _columnsVisibilityDivergedFromDefault() {
    for (var i = 0; i < widget.columns.length; i++) {
      if (i >= _columnVisibility.length) {
        return true;
      }
      if (_columnVisibility[i] != widget.columns[i].visible) {
        return true;
      }
    }
    return false;
  }

  bool _colDateRangeBoundsComplete(String columnKey) {
    return _colFilterDateFrom[columnKey] != null &&
        _colFilterDateTo[columnKey] != null;
  }

  DateTime _dateOnlyListing(DateTime d) => DateTime(d.year, d.month, d.day);

  Set<String> _activeColFilterKeys() {
    final keys = <String>{
      for (final e in _colFilterText.entries)
        if (e.value.isNotEmpty) e.key,
      ..._colFilterMulti.keys,
    };
    for (final col in widget.columns) {
      if (col.filter?.type != AppColumnFilterType.dateRange) continue;
      final k = col.key;
      if (_colFilterDateFrom[k] != null || _colFilterDateTo[k] != null) {
        keys.add(k);
      }
    }
    return keys;
  }

  bool _rowPassesColumnFilters(T row) {
    for (final col in widget.columns) {
      final key = col.key;
      if (col.filter?.type == AppColumnFilterType.dateRange) {
        final fn = col.filterDateValue;
        if (fn != null && _colDateRangeBoundsComplete(key)) {
          final rowDay = _dateOnlyListing(fn(row));
          final fromD = _dateOnlyListing(_colFilterDateFrom[key]!);
          final toD = _dateOnlyListing(_colFilterDateTo[key]!);
          if (rowDay.isBefore(fromD) || rowDay.isAfter(toD)) {
            return false;
          }
        }
        continue;
      }
      final resolved = _resolvedColumnFilter(col);
      final text = _colFilterText[key];
      if (text != null && text.isNotEmpty) {
        if (resolved != null && resolved.isText) {
          final fn = col.filterTextValue;
          if (fn == null) {
            continue;
          }
          if (!fn(row).toLowerCase().contains(text.toLowerCase())) {
            return false;
          }
        }
      }
      final multi = _colFilterMulti[key];
      if (multi != null && multi.isNotEmpty) {
        if (resolved != null && !resolved.isText) {
          final fn = col.filterSelectValue;
          if (fn == null) {
            continue;
          }
          if (!multi.contains(fn(row))) {
            return false;
          }
        }
      }
    }
    return true;
  }

  List<(int, T)> _filteredRowEntries() {
    final out = <(int, T)>[];
    for (var i = 0; i < widget.rows.length; i++) {
      final r = widget.rows[i];
      if (_rowPassesColumnFilters(r)) {
        out.add((i, r));
      }
    }
    return out;
  }

  /// Applies the current 3-state sort selection to [filtered] (post-filter,
  /// pre-render). Returns [filtered] unchanged when no sort is active or the
  /// active column has no [TableColumn.sortValue] extractor.
  List<(int, T)> _sortedRowEntries(List<(int, T)> filtered) {
    final key = _sortColumnKey;
    final dir = _sortDirection;
    if (key == null || dir == null) {
      return filtered;
    }
    TableColumn<T>? col;
    for (final c in widget.columns) {
      if (c.key == key) {
        col = c;
        break;
      }
    }
    final extractor = col?.sortValue;
    if (col == null || extractor == null) {
      return filtered;
    }
    final out = List<(int, T)>.from(filtered);
    out.sort((a, b) {
      final av = extractor(a.$2);
      final bv = extractor(b.$2);
      int cmp;
      if (av is num && bv is num) {
        cmp = av.compareTo(bv);
      } else {
        cmp = av.toString().toLowerCase().compareTo(
          bv.toString().toLowerCase(),
        );
      }
      return dir == 'asc' ? cmp : -cmp;
    });
    return out;
  }

  void _pruneSelectionToVisible() {
    final visible = _filteredRowEntries().map((e) => e.$1).toSet();
    _selectedRows.removeWhere((i) => !visible.contains(i));
  }

  void _emitRowSelection() {
    widget.onRowSelectionChanged?.call(Set<int>.from(_selectedRows));
  }

  /// Must not call [onRowSelectionChanged] synchronously from [didUpdateWidget]
  /// — that runs during the parent's build/update and would trigger
  /// setState/markNeedsBuild during build (e.g. when [rows] length changes).
  void _scheduleEmitRowSelection() {
    if (widget.onRowSelectionChanged == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onRowSelectionChanged?.call(Set<int>.from(_selectedRows));
    });
  }

  List<T> _selectedRowValues() {
    final sorted = _selectedRows.toList()..sort();
    return sorted.map((i) => widget.rows[i]).toList();
  }

  List<dynamic> _selectedBulkIds() {
    final rows = _selectedRowValues();
    final map = widget.bulkRowId;
    if (map != null) {
      return rows.map(map).toList();
    }
    return rows.map((r) => r as dynamic).toList();
  }

  void _toggleSelectAll(bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedRows
          ..clear()
          ..addAll(_filteredRowEntries().map((e) => e.$1));
      } else {
        _selectedRows.clear();
      }
    });
    _emitRowSelection();
  }

  bool? _selectAllState() {
    final visible = _filteredRowEntries();
    if (visible.isEmpty) {
      return false;
    }
    final visibleIndices = visible.map((e) => e.$1).toSet();
    final selectedVisible = _selectedRows.where(visibleIndices.contains).length;
    if (selectedVisible == 0) {
      return false;
    }
    if (selectedVisible == visibleIndices.length) {
      return true;
    }
    return null;
  }

  void _openFilters() {
    _hydrateDraftFromActiveFilters();
    final w = MediaQuery.sizeOf(context).width;
    if (!AppBreakpoints.isDesktopWidth(w) &&
        widget.filterFields != null &&
        widget.filterFields!.isNotEmpty) {
      _showFilterBottomSheet();
      return;
    }
    setState(() => _filterPanelOpen = true);
  }

  Future<void> _showFilterBottomSheet() async {
    final maxH = MediaQuery.sizeOf(context).height * 0.8;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: _FilterPanelContent<T>(
            filterFields: widget.filterFields!,
            filterTextCtrls: _filterTextCtrls,
            draftMulti: _draftMulti,
            draftDateFrom: _draftDateFrom,
            draftDateTo: _draftDateTo,
            draftDateFromText: _draftDateFromText,
            draftDateToText: _draftDateToText,
            onClearDraft: () {
              setState(_clearFilterDraft);
            },
            onApply: () {
              final next = _collectFiltersFromDraft();
              widget.onFiltersChanged?.call(next);
              Navigator.of(sheetContext).pop();
            },
            syncDateText: _syncDateTextControllers,
            pickDate: _pickDate,
            onDraftChanged: () => setState(() {}),
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(String fieldKey, bool isFrom) async {
    final initial = isFrom
        ? (_draftDateFrom[fieldKey] ?? DateTime.now())
        : (_draftDateTo[fieldKey] ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isFrom) {
          _draftDateFrom[fieldKey] = picked;
        } else {
          _draftDateTo[fieldKey] = picked;
        }
        _syncDateTextControllers(fieldKey);
      });
    }
  }

  void _showColumnPicker() {
    if (_columnSelectorEntry != null) {
      _columnSelectorEntry?.remove();
      _columnSelectorEntry = null;
      return;
    }
    _columnSelectorEntry = OverlayEntry(
      builder: (ctx) => _ColumnSelectorOverlay(
        link: _columnsButtonLink,
        columns: widget.columns,
        visibility: List<bool>.from(_columnVisibility),
        onToggle: (i, v) {
          setState(() => _columnVisibility[i] = v);
          // Re-build the overlay so its checkboxes stay in sync.
          _columnSelectorEntry?.markNeedsBuild();
        },
        onDismiss: () {
          _columnSelectorEntry?.remove();
          _columnSelectorEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_columnSelectorEntry!);
  }

  LayerLink _colFilterLink(String key) =>
      _colFilterLinks.putIfAbsent(key, LayerLink.new);

  bool get _anyColFilterActive {
    if (_colFilterText.values.any((v) => v.isNotEmpty)) return true;
    if (_colFilterMulti.values.any((s) => s.isNotEmpty)) return true;
    for (final col in widget.columns) {
      if (col.filter?.type == AppColumnFilterType.dateRange &&
          _colDateRangeBoundsComplete(col.key)) {
        return true;
      }
    }
    return false;
  }

  void _showColFilterOverlay(TableColumn<T> col) {
    _colFilterEntry?.remove();
    _colFilterEntry = null;
    if (col.filter?.type == AppColumnFilterType.dateRange) {
      if (col.filterDateValue == null) return;
      _colFilterEntry = OverlayEntry(
        builder: (ctx) => _ColumnDateRangeFilterOverlay(
          link: _colFilterLink(col.key),
          initialFrom: _colFilterDateFrom[col.key],
          initialTo: _colFilterDateTo[col.key],
          onApply: (from, to) {
            setState(() {
              if (from != null) {
                _colFilterDateFrom[col.key] = from;
              } else {
                _colFilterDateFrom.remove(col.key);
              }
              if (to != null) {
                _colFilterDateTo[col.key] = to;
              } else {
                _colFilterDateTo.remove(col.key);
              }
              _pruneSelectionToVisible();
            });
            _emitRowSelection();
            _colFilterEntry?.remove();
            _colFilterEntry = null;
          },
          onClear: () {
            setState(() {
              _colFilterDateFrom.remove(col.key);
              _colFilterDateTo.remove(col.key);
              _pruneSelectionToVisible();
            });
            _emitRowSelection();
            _colFilterEntry?.remove();
            _colFilterEntry = null;
          },
          onDismiss: () {
            _colFilterEntry?.remove();
            _colFilterEntry = null;
          },
        ),
      );
      Overlay.of(context).insert(_colFilterEntry!);
      return;
    }
    final resolved = _resolvedColumnFilter(col);
    if (resolved == null) {
      return;
    }
    _colFilterEntry = OverlayEntry(
      builder: (ctx) => _ColumnFilterOverlay(
        link: _colFilterLink(col.key),
        isText: resolved.isText,
        selectItems: resolved.selectItems ?? const <AppSelectItem<String>>[],
        initialText: _colFilterText[col.key] ?? '',
        initialMulti: Set<String>.from(_colFilterMulti[col.key] ?? {}),
        onApply: (text, multi) {
          setState(() {
            if (text != null) {
              if (text.isEmpty) {
                _colFilterText.remove(col.key);
              } else {
                _colFilterText[col.key] = text;
              }
            }
            if (multi != null) {
              if (multi.isEmpty) {
                _colFilterMulti.remove(col.key);
              } else {
                _colFilterMulti[col.key] = multi;
              }
            }
            _pruneSelectionToVisible();
          });
          _emitRowSelection();
          _colFilterEntry?.remove();
          _colFilterEntry = null;
        },
        onDismiss: () {
          _colFilterEntry?.remove();
          _colFilterEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_colFilterEntry!);
  }

  Future<void> _runBulkExport() async {
    final fn = widget.onBulkExport;
    if (fn == null) {
      return;
    }
    final rows = _selectedRowValues()
        .map<dynamic>((e) => e as dynamic)
        .toList();
    await fn(rows);
    if (mounted) {
      setState(_selectedRows.clear);
      _emitRowSelection();
    }
  }

  Future<void> _runBulkActivate() async {
    final fn = widget.onBulkActivate;
    if (fn == null) {
      return;
    }
    await fn(_selectedBulkIds());
    if (mounted) {
      setState(_selectedRows.clear);
      _emitRowSelection();
    }
  }

  Future<void> _runBulkDeactivate() async {
    final fn = widget.onBulkDeactivate;
    if (fn == null) {
      return;
    }
    await fn(_selectedBulkIds());
    if (mounted) {
      setState(_selectedRows.clear);
      _emitRowSelection();
    }
  }

  Future<void> _runBulkDelete() async {
    final fn = widget.onBulkDelete;
    if (fn == null) {
      return;
    }
    final n = _selectedRows.length;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Selected',
      message: 'Delete $n selected records? This cannot be undone.',
      confirmLabel: 'Delete All',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await fn(_selectedBulkIds());
    if (mounted) {
      setState(_selectedRows.clear);
      _emitRowSelection();
    }
  }

  Future<void> _runBulkPrimary() async {
    final fn = widget.onBulkPrimary;
    if (fn == null) {
      return;
    }
    await fn(_selectedBulkIds());
    if (mounted) {
      setState(_selectedRows.clear);
      _emitRowSelection();
    }
  }

  void _onFilterToolbarPressed() {
    if (widget.filterFields == null || widget.filterFields!.isEmpty) {
      return;
    }
    final w = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isDesktopWidth(w)) {
      setState(() {
        _filterPanelOpen = !_filterPanelOpen;
        if (_filterPanelOpen) {
          _hydrateDraftFromActiveFilters();
        }
      });
    } else {
      _openFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopFilters =
        AppBreakpoints.isDesktopWidth(width) &&
        widget.filterFields != null &&
        widget.filterFields!.isNotEmpty;

    final headerColumn = widget.showPageHeader
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space5,
              AppTokens.space4,
              AppTokens.space5,
              AppTokens.space0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader<T>(widget: widget),
                SizedBox(height: AppTokens.space3),
                if (widget.showKpis &&
                    widget.kpiCards != null &&
                    widget.kpiCards!.isNotEmpty) ...[
                  KpiRow(cards: widget.kpiCards!),
                  SizedBox(height: AppTokens.space3),
                ],
              ],
            ),
          )
        : const SizedBox.shrink();

    final showColumnsDot =
        _anyColFilterActive || _columnsVisibilityDivergedFromDefault();

    final useDesktopTableFill =
        widget.tableBodyFillsViewport && !AppBreakpoints.isMobileWidth(width);
    final useTableFill = useDesktopTableFill;
    final useViewportFillRoot = useDesktopTableFill;

    final cardColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: useTableFill ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (!widget.tabsBelowToolbar) ...[
          if (widget.tabs != null && widget.tabs!.isNotEmpty)
            ListingTabStrip(
              tabs: widget.tabs!,
              selected: _selectedTab,
              onSelect: (i) {
                setState(() {
                  _selectedTab = i;
                  _sortColumnKey = null;
                  _sortDirection = null;
                });
                widget.onTabChanged?.call(i);
              },
            ),
          if (widget.showToolbar)
            _ToolbarRow<T>(
              widget: widget,
              searchController: _searchController,
              onToggleFilters: _onFilterToolbarPressed,
              onColumnPicker: _showColumnPicker,
              columnsButtonLink: _columnsButtonLink,
              showColumnsDot: showColumnsDot,
            ),
        ] else ...[
          if (widget.showToolbar)
            _ToolbarRow<T>(
              widget: widget,
              searchController: _searchController,
              onToggleFilters: _onFilterToolbarPressed,
              onColumnPicker: _showColumnPicker,
              columnsButtonLink: _columnsButtonLink,
              showColumnsDot: showColumnsDot,
            ),
          if (widget.tabs != null && widget.tabs!.isNotEmpty)
            ListingTabStrip(
              tabs: widget.tabs!,
              selected: _selectedTab,
              onSelect: (i) {
                setState(() {
                  _selectedTab = i;
                  _sortColumnKey = null;
                  _sortDirection = null;
                });
                widget.onTabChanged?.call(i);
              },
            ),
        ],
        if (widget.showBulkBar &&
            (!widget.bulkBarVisibleOnlyWhenSelection ||
                _selectedRows.isNotEmpty))
          _BulkBar<T>(
            selectedCount: _selectedRows.length,
            hasSelection: _selectedRows.isNotEmpty,
            bulkActions: widget.bulkActions,
            selectionSummary: widget.bulkSelectionSummary,
            onBulk: (fn) => fn(_selectedRowValues()),
            onClearSelection: () {
              setState(_selectedRows.clear);
              _emitRowSelection();
            },
            onBulkExport: widget.onBulkExport != null ? _runBulkExport : null,
            onBulkPrint: () => listingBulkPrint(context),
            showPrint: widget.showPrint,
            onBulkActivate: widget.onBulkActivate != null
                ? _runBulkActivate
                : null,
            onBulkDeactivate: widget.onBulkDeactivate != null
                ? _runBulkDeactivate
                : null,
            onBulkDelete: widget.onBulkDelete != null ? _runBulkDelete : null,
            bulkPrimaryLabel: widget.bulkPrimaryLabel,
            onBulkPrimary:
                widget.bulkPrimaryLabel != null && widget.onBulkPrimary != null
                ? _runBulkPrimary
                : null,
          ),
        if (widget.activeFilters.isNotEmpty)
          _ActiveFilterChips(
            activeFilters: widget.activeFilters,
            onRemove: (f) {
              final next = widget.activeFilters
                  .where((a) => a.key != f.key)
                  .toList();
              widget.onFiltersChanged?.call(next);
            },
            onClearAll: () => widget.onFiltersChanged?.call([]),
          ),
        if (useTableFill)
          Expanded(
            child: LayoutBuilder(
              builder: (context, cons) {
                final minRowsH = _tableRowHeight * _kListingBodyMinRows;
                final minH = math.min(minRowsH, cons.maxHeight);
                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minH),
                  child: _buildDesktopTableBody(fillViewport: true),
                );
              },
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _tableRowHeight * _kListingBodyMinRows,
            ),
            child: AppBreakpoints.isMobileWidth(width)
                ? _buildMobileBody()
                : _buildDesktopTableBody(fillViewport: false),
          ),
        if (widget.showPaginationFooter)
          _PaginationRow(
            height: widget.paginationFooterHeight ??
                AppTokens.listingPaginationHeight,
            totalCount: widget.totalCount,
            currentPage: widget.currentPage,
            pageSize: widget.pageSize,
            pageSizeOptions: widget.pageSizeOptions,
            onPageChanged: widget.onPageChanged,
            onPageSizeChanged: widget.onPageSizeChanged,
          ),
      ],
    );

    final listingCard = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        border: Border.all(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      ),
      child: cardColumn,
    );

    final expandedBody = Padding(
      padding:
          widget.listingShellPadding ??
          const EdgeInsets.fromLTRB(
            AppTokens.space5,
            AppTokens.space0,
            AppTokens.space5,
            AppTokens.space4,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: listingCard),
          if (isDesktopFilters)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: _filterPanelOpen
                  ? AppTokens.listingFilterPanelWidth
                  : AppTokens.space0,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: _filterPanelOpen ? 1 : 0,
                  child: SizedBox(
                    width: AppTokens.listingFilterPanelWidth,
                    child: _FilterPanelContent<T>(
                      filterFields: widget.filterFields!,
                      filterTextCtrls: _filterTextCtrls,
                      draftMulti: _draftMulti,
                      draftDateFrom: _draftDateFrom,
                      draftDateTo: _draftDateTo,
                      draftDateFromText: _draftDateFromText,
                      draftDateToText: _draftDateToText,
                      onClearDraft: () => setState(_clearFilterDraft),
                      onApply: () {
                        final next = _collectFiltersFromDraft();
                        widget.onFiltersChanged?.call(next);
                        setState(() => _filterPanelOpen = false);
                      },
                      syncDateText: _syncDateTextControllers,
                      onClose: () => setState(() => _filterPanelOpen = false),
                      pickDate: _pickDate,
                      onDraftChanged: () => setState(() {}),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return ColoredBox(
      color: AppTokens.pageBg,
      child: useViewportFillRoot
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerColumn,
                Expanded(child: expandedBody),
              ],
            )
          : widget.disableOuterVerticalScroll
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [headerColumn, expandedBody],
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [headerColumn, expandedBody],
              ),
            ),
    );
  }

  Widget _buildMobileBody() {
    return widget.isLoading
        ? _SkeletonTable(animation: _pulseAnimation)
        : widget.rows.isEmpty
        ? widget.emptyWidget ??
              _EmptyState(message: widget.emptyMessage ?? 'No records found')
        : Builder(
            builder: (context) {
              final filtered = _sortedRowEntries(_filteredRowEntries());
              if (filtered.isEmpty) {
                return widget.emptyWidget ??
                    _EmptyState(
                      message: widget.emptyMessage ?? 'No records found',
                    );
              }
              return ListView.separated(
                padding: EdgeInsets.all(AppTokens.space4),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => SizedBox(
                  key: ValueKey<int>(index),
                  height: AppTokens.space2,
                ),
                itemBuilder: (context, listIndex) {
                  final orig = filtered[listIndex].$1;
                  final row = filtered[listIndex].$2;
                  final showExpandChrome = widget.showExpandColumn;
                  final hasInlineExpand =
                      widget.expandedRowBuilder != null &&
                      widget.isRowExpanded != null &&
                      widget.onExpandRowTap != null;
                  final expandColumnInteractive =
                      showExpandChrome && hasInlineExpand;
                  final expandedMobile =
                      hasInlineExpand && widget.isRowExpanded!(row);

                  final card = AppCard(
                    key: ValueKey<int>(orig),
                    padding: EdgeInsets.zero,
                    onTap: widget.onRowTap != null
                        ? () => widget.onRowTap!(row)
                        : null,
                    child: Padding(
                      padding: EdgeInsets.all(AppTokens.space4),
                      child: widget.mobileCardBuilder(row),
                    ),
                  );

                  Widget expandedMobilePanel() => Padding(
                    padding: const EdgeInsets.only(top: AppTokens.space2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTokens.surfaceSubtle,
                        borderRadius: BorderRadius.circular(
                          AppTokens.cardRadius,
                        ),
                        border: Border.all(
                          color: AppTokens.borderDefault,
                          width: AppTokens.borderWidthSm,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.space3),
                        child: widget.expandedRowBuilder!(context, row),
                      ),
                    ),
                  );

                  if (!showExpandChrome && !hasInlineExpand) {
                    return card;
                  }

                  if (!showExpandChrome && hasInlineExpand) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        card,
                        if (expandedMobile) expandedMobilePanel(),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppTokens.space3,
                              right: AppTokens.space2,
                            ),
                            child: _ListingExpandToggle(
                              expanded: expandedMobile,
                              interactive: expandColumnInteractive,
                              onTap: expandColumnInteractive
                                  ? () => widget.onExpandRowTap!(row)
                                  : null,
                            ),
                          ),
                          Expanded(child: card),
                        ],
                      ),
                      if (hasInlineExpand && expandedMobile)
                        expandedMobilePanel(),
                    ],
                  );
                },
              );
            },
          );
  }

  Widget _buildDesktopTableBody({required bool fillViewport}) {
    if (widget.isLoading) {
      return fillViewport
          ? SizedBox.expand(child: _SkeletonTable(animation: _pulseAnimation))
          : _SkeletonTable(animation: _pulseAnimation);
    }
    if (widget.rows.isEmpty) {
      final empty =
          widget.emptyWidget ??
          _EmptyState(message: widget.emptyMessage ?? 'No records found');
      return fillViewport ? SizedBox.expand(child: empty) : empty;
    }
    final filtered = _sortedRowEntries(_filteredRowEntries());
    if (filtered.isEmpty) {
      final empty =
          widget.emptyWidget ??
          _EmptyState(message: widget.emptyMessage ?? 'No records found');
      return fillViewport ? SizedBox.expand(child: empty) : empty;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final vScroll = fillViewport
            ? (widget.tableBodyVerticalScrollController ??
                  _ownedTableBodyVScroll!)
            : null;
        final innerW = (constraints.maxWidth - 2 * _kListingTableOuterGutter)
            .clamp(0.0, double.infinity);
        final showExpandChrome = widget.showExpandColumn;
        final hasInlineExpand =
            widget.expandedRowBuilder != null &&
            widget.isRowExpanded != null &&
            widget.onExpandRowTap != null;
        final expandColumnInteractive = showExpandChrome && hasInlineExpand;
        final actionsColW =
            widget.actionsColumnWidth ?? AppTokens.tableActionsColumnWidth;
        var fixedNonScroll = 0.0;
        if (showExpandChrome) {
          fixedNonScroll += AppTokens.tableExpandColumnWidth;
        }
        if (widget.showCheckboxes) {
          fixedNonScroll += AppTokens.tableCheckboxColumnWidth;
        }
        if (widget.showToggle) {
          fixedNonScroll += AppTokens.tableToggleColumnWidth;
        }
        if (widget.rowActions != null && widget.rowActions!.isNotEmpty) {
          fixedNonScroll += actionsColW;
        }
        final dataMaxW = (innerW - fixedNonScroll).clamp(0.0, double.infinity);
        final layoutWidth = math.max(
          dataMaxW,
          widget.tableScrollableMinWidth ?? 0,
        );
        final scrollWidths = _computeDataColumnWidths(layoutWidth);
        final totalScrollWidth = scrollWidths.fold<double>(0, (a, w) => a + w);
        final showHScrollBar =
            widget.showTableHorizontalScrollbar &&
            _tableFooterHScroll != null &&
            totalScrollWidth > dataMaxW + 0.5;

        var footerPadLeft = _kListingTableOuterGutter;
        var footerPadRight = _kListingTableOuterGutter;
        if (showExpandChrome) {
          footerPadLeft += AppTokens.tableExpandColumnWidth;
        }
        if (widget.showCheckboxes) {
          footerPadLeft += AppTokens.tableCheckboxColumnWidth;
        }
        if (widget.showToggle) {
          footerPadLeft += AppTokens.tableToggleColumnWidth;
        }
        if (widget.rowActions != null && widget.rowActions!.isNotEmpty) {
          footerPadRight += actionsColW;
        }

        final header = _ListingTableHeader<T>(
          scrollWidths: scrollWidths,
          columns: _visibleColumnDefs,
          horizontalScroll: _tableHeaderHScroll,
          headerRowHeight:
              widget.tableHeaderHeight ?? AppTokens.tableHeaderHeight,
          actionsColumnWidth: actionsColW,
          showExpandColumn: showExpandChrome,
          showCheckboxes: widget.showCheckboxes,
          showToggle: widget.showToggle,
          hasRowActions:
              widget.rowActions != null && widget.rowActions!.isNotEmpty,
          showActionsColumnLeadingBorder: widget.showActionsColumnLeadingBorder,
          sortColumnKey: _sortColumnKey,
          sortDirection: _sortDirection,
          selectAll: _selectAllState(),
          onSelectAll: widget.showCheckboxes ? _toggleSelectAll : null,
          onSortTap: (col) {
            if (!col.sortable) {
              return;
            }
            setState(() {
              if (_sortColumnKey != col.key) {
                _sortColumnKey = col.key;
                _sortDirection = 'asc';
              } else if (_sortDirection == 'asc') {
                _sortDirection = 'desc';
              } else if (_sortDirection == 'desc') {
                _sortColumnKey = null;
                _sortDirection = null;
              } else {
                _sortDirection = 'asc';
              }
            });
            final activeKey = _sortColumnKey;
            final activeDir = _sortDirection;
            if (activeKey != null && activeDir != null) {
              widget.onSortChanged?.call((
                columnKey: activeKey,
                ascending: activeDir == 'asc',
              ));
            }
          },
          onFilterTap: _showColFilterOverlay,
          activeColFilters: _activeColFilterKeys(),
          getColFilterLink: _colFilterLink,
        );

        final listCore = ListView.builder(
          controller: fillViewport ? vScroll : null,
          physics: fillViewport
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          shrinkWrap: !fillViewport,
          itemCount: filtered.length,
          itemBuilder: (context, listIndex) {
            final origIndex = filtered[listIndex].$1;
            final row = filtered[listIndex].$2;
            final selected = _selectedRows.contains(origIndex);
            final isLastInList = listIndex == filtered.length - 1;
            final expanded = hasInlineExpand && widget.isRowExpanded!(row);
            final mainRowBottomBorder = !expanded && !isLastInList;

            return Column(
              key: ValueKey<Object>(
                widget.bulkRowId != null
                    ? widget.bulkRowId!(row) as Object
                    : origIndex,
              ),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ListingDataRow<T>(
                  scrollWidths: scrollWidths,
                  columns: _visibleColumnDefs,
                  horizontalScrollGroup: _tableHScrollGroup,
                  row: row,
                  index: origIndex,
                  isLast: isLastInList,
                  selected: selected,
                  showExpandColumn: showExpandChrome,
                  expandInteractive: expandColumnInteractive,
                  isExpanded: expanded,
                  onExpandTap: expandColumnInteractive
                      ? () => widget.onExpandRowTap!(row)
                      : null,
                  showMainRowBottomBorder: mainRowBottomBorder,
                  showCheckboxes: widget.showCheckboxes,
                  showToggle: widget.showToggle,
                  hasRowActions:
                      widget.rowActions != null &&
                      widget.rowActions!.isNotEmpty,
                  actionsColumnWidth: actionsColW,
                  showActionsColumnLeadingBorder:
                      widget.showActionsColumnLeadingBorder,
                  rowActions: widget.rowActions,
                  onToggleChanged: widget.onToggleChanged,
                  onRowTap: widget.onRowTap,
                  onSelectRow: (v) {
                    setState(() {
                      if (v) {
                        _selectedRows.add(origIndex);
                      } else {
                        _selectedRows.remove(origIndex);
                      }
                    });
                    _emitRowSelection();
                  },
                  rowBackgroundColor: widget.rowBackgroundColor,
                  tableRowHeight: _tableRowHeight,
                ),
                if (expanded)
                  _ListingInlineExpandPanel(
                    leftFixedWidth:
                        (showExpandChrome
                            ? AppTokens.tableExpandColumnWidth
                            : 0) +
                        (widget.showCheckboxes
                            ? AppTokens.tableCheckboxColumnWidth
                            : 0) +
                        (widget.showToggle
                            ? AppTokens.tableToggleColumnWidth
                            : 0),
                    rightFixedWidth:
                        widget.rowActions != null &&
                            widget.rowActions!.isNotEmpty
                        ? actionsColW
                        : 0,
                    contentPadding: widget.expandedPanelContentPadding,
                    child: widget.expandedRowBuilder!(context, row),
                  ),
              ],
            );
          },
        );

        final hBar = showHScrollBar
            ? SizedBox(
                height: _kListingTableHScrollFooterHeight,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: footerPadLeft,
                    right: footerPadRight,
                    top: AppTokens.space1,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppScrollbar(
                      controller: _tableFooterHScroll!,
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _tableFooterHScroll,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: totalScrollWidth,
                          height: AppTokens.space2,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null;

        final headerRowH =
            widget.tableHeaderHeight ?? AppTokens.tableHeaderHeight;
        final hBarTotalH =
            showHScrollBar ? _kListingTableHScrollFooterHeight : 0.0;

        Widget tableChrome(Widget column) {
          return AppShiftWheelHorizontalScroll(
            controller: _tableHeaderHScroll,
            child: column,
          );
        }

        if (!fillViewport) {
          return tableChrome(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, listCore, ?hBar],
            ),
          );
        }

        if (constraints.hasBoundedHeight) {
          final listViewportH = (constraints.maxHeight -
                  headerRowH -
                  hBarTotalH)
              .clamp(0.0, double.infinity);
          return tableChrome(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                SizedBox(
                  height: listViewportH,
                  child: AppScrollbar(
                    controller: vScroll!,
                    child: listCore,
                  ),
                ),
                ?hBar,
              ],
            ),
          );
        }

        return tableChrome(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: AppScrollbar(
                  controller: vScroll!,
                  child: listCore,
                ),
              ),
              ?hBar,
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Page header
// -----------------------------------------------------------------------------

class _PageHeader<T> extends StatelessWidget {
  const _PageHeader({required this.widget});

  final AppListingScreen<T> widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.titleIcon != null) ...[
          IconTheme(
            data: const IconThemeData(
              size: AppTokens.avatarSizeSm,
              color: AppTokens.primary800,
            ),
            child: widget.titleIcon!,
          ),
          SizedBox(width: AppTokens.space3),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.pageTitleSize,
                  fontWeight: AppTokens.pageTitleWeight,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              if (widget.subtitle.isNotEmpty) ...[
                SizedBox(height: AppTokens.space1),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.pageSubtitleSize,
                    fontWeight: AppTokens.pageSubtitleWeight,
                    color: AppTokens.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.extraActions != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final a in widget.extraActions!) ...[
                a,
                SizedBox(width: AppTokens.space2),
              ],
            ],
          ),
        if (widget.primaryActionLabel != null && widget.onPrimaryAction != null)
          AppButton(
            label: widget.primaryActionLabel!,
            onPressed: widget.onPrimaryAction,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.md,
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Tabs
// -----------------------------------------------------------------------------

/// Listing tabs matching transaction modules ([AppListingScreen] strip style).
class ListingTabStrip extends StatelessWidget {
  const ListingTabStrip({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<TabConfig> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: SizedBox(
        height: _kListingTabBarHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.space3,
            AppTokens.space0,
            AppTokens.space3,
            AppTokens.space0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final t = tabs[i];
                  final active = i == selected;
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => onSelect(i),
                      child: Container(
                        height: _kListingTabBarHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space3,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: active ? 2 : 0,
                              color: active
                                  ? AppTokens.accent500
                                  : AppTokens.cardBg.withValues(alpha: 0),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.label,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.textSm,
                                fontWeight: AppTokens.weightMedium,
                                color: active
                                    ? AppTokens.primary800
                                    : AppTokens.textSecondary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            if (t.count != null) ...[
                              SizedBox(width: AppTokens.space2),
                              SizedBox(
                                height: _kListingTabBadgeHeight,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppTokens.primary800
                                        : AppTokens.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusLg,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTokens.space3 / 2,
                                      vertical: 1,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${t.count}',
                                        style: GoogleFonts.poppins(
                                          fontSize: _kListingTabBadgeFontSize,
                                          fontWeight: AppTokens.weightMedium,
                                          color: active
                                              ? AppTokens.white
                                              : AppTokens.textSecondary,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Toolbar
// -----------------------------------------------------------------------------

class _ToolbarRow<T> extends StatelessWidget {
  const _ToolbarRow({
    required this.widget,
    required this.searchController,
    required this.onToggleFilters,
    required this.onColumnPicker,
    required this.columnsButtonLink,
    required this.showColumnsDot,
  });

  final AppListingScreen<T> widget;
  final TextEditingController searchController;
  final VoidCallback onToggleFilters;
  final VoidCallback onColumnPicker;
  final LayerLink columnsButtonLink;
  final bool showColumnsDot;

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        widget.filterFields != null && widget.filterFields!.isNotEmpty;
    final extras = widget.toolbarAfterSearch;
    final hasExtras = extras != null && extras.isNotEmpty;

    final searchWidget = SizedBox(
      height: AppTokens.listingToolbarSearchHeight,
      child: _ListingSearchField(
        controller: searchController,
        hint: widget.searchHint,
        onChanged: widget.onSearch,
        compact: true,
      ),
    );

    Widget leadingToolbar() {
      if (!widget.showSearch && !hasExtras) {
        return const Spacer();
      }
      return Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showSearch)
                  SizedBox(
                    width: AppTokens.listingToolbarSearchWidth,
                    child: searchWidget,
                  ),
                if (hasExtras) ...[
                  SizedBox(width: AppTokens.space2),
                  ...extras,
                ],
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.listingToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              leadingToolbar(),
              if (widget.toolbarTrailingActions != null)
                for (final a in widget.toolbarTrailingActions!) ...[
                  a,
                  SizedBox(width: AppTokens.listingToolbarActionsGap),
                ],
              if (widget.onExport != null) ...[
                AppButton(
                  label: 'Export',
                  leadingIcon: Icon(
                    LucideIcons.download,
                    size: AppTokens.iconButtonIconSm,
                    color: AppTokens.textPrimary,
                  ),
                  onPressed: widget.onExport,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                ),
                SizedBox(width: AppTokens.listingToolbarActionsGap),
              ],
              if (widget.showColumnToggle) ...[
                CompositedTransformTarget(
                  link: columnsButtonLink,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppButton(
                        label: 'Columns',
                        leadingIcon: Icon(
                          LucideIcons.columns,
                          size: AppTokens.iconButtonIconSm,
                          color: AppTokens.textPrimary,
                        ),
                        onPressed: onColumnPicker,
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.sm,
                      ),
                      if (showColumnsDot)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: _ToolbarAccentDot(),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: AppTokens.space2),
              ],
              if (hasFilters) ...[
                _FilterButton(
                  activeCount: widget.activeFilters.length,
                  onPressed: onToggleFilters,
                ),
                SizedBox(width: AppTokens.space2),
              ],
              if (widget.showImport && widget.onImport != null) ...[
                AppButton(
                  label: 'Import',
                  leadingIcon: Icon(
                    LucideIcons.upload,
                    size: AppTokens.iconButtonIconSm,
                    color: AppTokens.textPrimary,
                  ),
                  onPressed: widget.onImport,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                ),
                SizedBox(width: AppTokens.space2),
              ],
              if (widget.showPrint && widget.onPrint != null)
                AppButton(
                  label: 'Print',
                  leadingIcon: Icon(
                    LucideIcons.printer,
                    size: AppTokens.iconButtonIconSm,
                    color: AppTokens.textPrimary,
                  ),
                  onPressed: widget.onPrint,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarAccentDot extends StatelessWidget {
  const _ToolbarAccentDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTokens.listingToolbarDotSize,
      height: AppTokens.listingToolbarDotSize,
      decoration: const BoxDecoration(
        color: AppTokens.accent500,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ListingSearchField extends StatelessWidget {
  const _ListingSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = compact
        ? AppTokens.listingToolbarSearchHeight
        : AppTokens.buttonHeightMd;
    final fontSize = compact ? AppTokens.textSm : AppTokens.textSm;
    final fillColor = compact ? AppTokens.surfaceSubtle : AppTokens.cardBg;
    final radius = BorderRadius.circular(
      compact ? AppTokens.inputRadius : AppTokens.inputRadius,
    );

    final decoration = InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: fillColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: (fieldHeight - fontSize) / 2,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: compact ? AppTokens.space2 : AppTokens.space2,
          right: AppTokens.space1,
        ),
        child: Icon(
          LucideIcons.search,
          size: compact ? AppTokens.iconButtonIconSm : 14,
          color: AppTokens.textMuted,
        ),
      ),
      prefixIconConstraints: BoxConstraints(
        minWidth: AppTokens.space8,
        minHeight: fieldHeight,
      ),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(
          color: AppTokens.primary800,
          width: AppTokens.borderWidthMd,
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: AppTokens.textPrimary,
          decoration: TextDecoration.none,
        ),
        cursorColor: AppTokens.primary800,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onPressed});

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final badge = activeCount > 0;
    final child = AppButton(
      label: 'Filters',
      leadingIcon: const Icon(LucideIcons.filter),
      trailingIcon: const Icon(LucideIcons.chevronDown, size: 14),
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: AppButtonSize.sm,
    );
    if (!badge) {
      return child;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -2,
          top: -2,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppTokens.accent500,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space1),
              child: Text(
                '$activeCount',
                style: GoogleFonts.poppins(
                  color: AppTokens.white,
                  fontSize: AppTokens.textXs,
                  fontWeight: AppTokens.weightSemibold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Active filter chips
// -----------------------------------------------------------------------------

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({
    required this.activeFilters,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<ActiveFilter> activeFilters;
  final ValueChanged<ActiveFilter> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      child: Wrap(
        spacing: AppTokens.space2,
        runSpacing: AppTokens.space2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final f in activeFilters)
            InputChip(
              label: Text(
                '${f.label}: ${f.value}',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: AppTokens.weightMedium,
                  color: AppTokens.primary800,
                ),
              ),
              onDeleted: () => onRemove(f),
              deleteIconColor: AppTokens.primary800,
              backgroundColor: AppTokens.primary50,
              side: BorderSide.none,
              padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
            ),
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              foregroundColor: AppTokens.primary800,
              textStyle: GoogleFonts.poppins(
                fontSize: AppTokens.textSm,
                fontWeight: AppTokens.weightMedium,
              ),
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Bulk bar
// -----------------------------------------------------------------------------

class _BulkBarMiniAction extends StatelessWidget {
  const _BulkBarMiniAction({
    required this.label,
    required this.leading,
    required this.onPressed,
    this.isDanger = false,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDanger ? AppTokens.error500 : AppTokens.borderDefault;
    final bg = isDanger ? AppTokens.error100 : AppTokens.cardBg;
    final fg = isDanger ? AppTokens.error500 : AppTokens.textPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTokens.bulkActionButtonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTokens.bulkActionButtonRadius),
        child: Container(
          height: AppTokens.bulkActionButtonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppTokens.bulkActionButtonRadius,
            ),
            border: Border.all(
              color: borderColor,
              width: AppTokens.borderWidthSm,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(
                  size: AppTokens.bulkActionIconSize,
                  color: isDanger ? AppTokens.error500 : AppTokens.textMuted,
                ),
                child: leading,
              ),
              SizedBox(width: AppTokens.space1),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bulkActionFontSize,
                  fontWeight: AppTokens.weightRegular,
                  color: fg,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulkBar<T> extends StatelessWidget {
  const _BulkBar({
    required this.selectedCount,
    required this.hasSelection,
    required this.bulkActions,
    required this.selectionSummary,
    required this.onBulk,
    required this.onClearSelection,
    this.onBulkExport,
    required this.onBulkPrint,
    required this.showPrint,
    this.onBulkActivate,
    this.onBulkDeactivate,
    this.onBulkDelete,
    this.bulkPrimaryLabel,
    this.onBulkPrimary,
  });

  final int selectedCount;
  final bool hasSelection;
  final List<BulkAction<T>>? bulkActions;
  final String Function(int selectedCount)? selectionSummary;
  final void Function(void Function(List<T> rows) fn) onBulk;
  final VoidCallback onClearSelection;
  final Future<void> Function()? onBulkExport;
  final VoidCallback onBulkPrint;
  final bool showPrint;
  final Future<void> Function()? onBulkActivate;
  final Future<void> Function()? onBulkDeactivate;
  final Future<void> Function()? onBulkDelete;
  final String? bulkPrimaryLabel;
  final Future<void> Function()? onBulkPrimary;

  Widget _actionsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onBulkExport != null) ...[
            _BulkBarMiniAction(
              label: 'Export',
              leading: const Icon(LucideIcons.download),
              onPressed: () => onBulkExport!(),
            ),
            SizedBox(width: AppTokens.space2),
          ],
          if (showPrint) ...[
            _BulkBarMiniAction(
              label: 'Print',
              leading: const Icon(LucideIcons.printer),
              onPressed: onBulkPrint,
            ),
            SizedBox(width: AppTokens.space2),
          ],
          if (onBulkActivate != null) ...[
            _BulkBarMiniAction(
              label: 'Activate',
              leading: const Icon(LucideIcons.checkCircle),
              onPressed: () => onBulkActivate!(),
            ),
            SizedBox(width: AppTokens.space2),
          ],
          if (onBulkDeactivate != null) ...[
            _BulkBarMiniAction(
              label: 'Deactivate',
              leading: const Icon(LucideIcons.xCircle),
              onPressed: () => onBulkDeactivate!(),
            ),
            SizedBox(width: AppTokens.space2),
          ],
          if (onBulkDelete != null) ...[
            Container(
              width: AppTokens.borderWidthSm,
              height: AppTokens.space4,
              color: AppTokens.borderDefault,
            ),
            SizedBox(width: AppTokens.space2),
            _BulkBarMiniAction(
              label: 'Delete',
              leading: const Icon(LucideIcons.trash2),
              isDanger: true,
              onPressed: () => onBulkDelete!(),
            ),
            SizedBox(width: AppTokens.space2),
          ],
          if (bulkActions != null)
            for (final a in bulkActions!)
              if (!a.showOnlyWhenSelected || hasSelection) ...[
                _BulkBarMiniAction(
                  label: a.label,
                  leading: a.icon,
                  isDanger: a.isDanger,
                  onPressed: () => onBulk(a.onTap),
                ),
                SizedBox(width: AppTokens.space2),
              ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = hasSelection ? AppTokens.warning50 : AppTokens.surfaceSubtle;
    final bottomBorder = hasSelection
        ? AppTokens.bulkBarActiveBottomBorder
        : AppTokens.borderDefault;

    final rightActions = Opacity(
      opacity: hasSelection
          ? AppTokens.opacityFull
          : AppTokens.bulkBarGreyedOpacity,
      child: IgnorePointer(ignoring: !hasSelection, child: _actionsRow()),
    );

    final showBulkPrimary = bulkPrimaryLabel != null && onBulkPrimary != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: bottomBorder,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.listingBulkBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              Expanded(
                child: hasSelection
                    ? Row(
                        children: [
                          Container(
                            width: AppTokens.bulkBarMiniCheckSize,
                            height: AppTokens.bulkBarMiniCheckSize,
                            decoration: BoxDecoration(
                              color: AppTokens.primary800,
                              borderRadius: BorderRadius.circular(
                                AppTokens.bulkBarMiniCheckRadius,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTokens.listingToolbarActionsGap),
                          Text(
                            selectionSummary != null
                                ? selectionSummary!(selectedCount)
                                : '$selectedCount rows selected',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.textXs,
                              fontWeight: AppTokens.weightMedium,
                              color: AppTokens.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(width: AppTokens.space2),
                          GestureDetector(
                            onTap: onClearSelection,
                            child: Text(
                              'Clear Selection',
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.textXs,
                                color: AppTokens.textMuted,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Select rows to perform bulk actions',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.textXs,
                          fontWeight: AppTokens.weightRegular,
                          color: AppTokens.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  rightActions,
                  if (showBulkPrimary) ...[
                    SizedBox(width: AppTokens.space2),
                    AppButton(
                      label: bulkPrimaryLabel!,
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.sm,
                      onPressed: hasSelection ? () => onBulkPrimary!() : null,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Table header & rows
// -----------------------------------------------------------------------------

class _ListingExpandToggle extends StatelessWidget {
  const _ListingExpandToggle({
    required this.expanded,
    required this.interactive,
    this.onTap,
  });

  static const double _circle = 22;
  static const double _icon = 12;

  final bool expanded;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final control = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: interactive ? onTap : null,
        customBorder: const CircleBorder(),
        child: Ink(
          width: _circle,
          height: _circle,
          decoration: BoxDecoration(
            color: expanded ? AppTokens.error500 : AppTokens.success500,
            shape: BoxShape.circle,
          ),
          child: Icon(
            expanded ? LucideIcons.minus : LucideIcons.plus,
            size: _icon,
            color: AppTokens.white,
          ),
        ),
      ),
    );

    final faded = Opacity(
      opacity: interactive ? AppTokens.opacityFull : AppTokens.disabledOpacity,
      child: control,
    );

    if (!interactive) {
      return faded;
    }
    return Tooltip(
      message: expanded ? 'Collapse row' : 'Expand row',
      child: faded,
    );
  }
}

class _ListingInlineExpandPanel extends StatelessWidget {
  const _ListingInlineExpandPanel({
    required this.leftFixedWidth,
    required this.rightFixedWidth,
    required this.child,
    this.contentPadding,
  });

  final double leftFixedWidth;
  final double rightFixedWidth;
  final Widget child;

  /// When null, matches historical inline expand panel padding.
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.surfaceSubtle,
        border: Border(
          top: BorderSide(
            color: AppTokens.tableRowDivider,
            width: AppTokens.borderWidthSm,
          ),
          bottom: BorderSide(
            color: AppTokens.tableRowDivider,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _kListingTableOuterGutter),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: leftFixedWidth),
            Expanded(
              child: Padding(
                padding:
                    contentPadding ??
                    const EdgeInsets.fromLTRB(
                      AppTokens.space2,
                      AppTokens.space3,
                      AppTokens.space2,
                      AppTokens.space3,
                    ),
                child: child,
              ),
            ),
            SizedBox(width: rightFixedWidth),
          ],
        ),
      ),
    );
  }
}

class _ListingTableHeader<T> extends StatelessWidget {
  const _ListingTableHeader({
    required this.scrollWidths,
    required this.columns,
    required this.horizontalScroll,
    required this.headerRowHeight,
    required this.actionsColumnWidth,
    required this.showExpandColumn,
    required this.showCheckboxes,
    required this.showToggle,
    required this.hasRowActions,
    required this.showActionsColumnLeadingBorder,
    required this.sortColumnKey,
    required this.sortDirection,
    required this.selectAll,
    required this.onSelectAll,
    required this.onSortTap,
    required this.onFilterTap,
    required this.activeColFilters,
    required this.getColFilterLink,
  });

  final List<double> scrollWidths;
  final List<TableColumn<T>> columns;
  final ScrollController horizontalScroll;
  final double headerRowHeight;
  final double actionsColumnWidth;
  final bool showExpandColumn;
  final bool showCheckboxes;
  final bool showToggle;
  final bool hasRowActions;
  final bool showActionsColumnLeadingBorder;
  final String? sortColumnKey;
  // 'asc' | 'desc' | null
  final String? sortDirection;
  final bool? selectAll;
  final ValueChanged<bool?>? onSelectAll;
  final ValueChanged<TableColumn<T>> onSortTap;
  final ValueChanged<TableColumn<T>> onFilterTap;
  final Set<String> activeColFilters;
  final LayerLink Function(String key) getColFilterLink;

  @override
  Widget build(BuildContext context) {
    Widget shell(double width, Alignment align, Widget child) {
      return _listingTableCellShell(
        width: width,
        alignment: align,
        isHeader: true,
        child: child,
      );
    }

    Widget headerCell(TableColumn<T> col, double w) {
      final hasFilter = _tableColumnHasFilter(col);
      final maxLines = col.headerMaxLines.clamp(1, 4);
      final multiLine = maxLines > 1;
      final labelStyle = GoogleFonts.poppins(
        fontSize: AppTokens.tableHeaderSize,
        fontWeight: AppTokens.tableHeaderWeight,
        letterSpacing: 0.3,
        color: AppTokens.textSecondary,
        decoration: TextDecoration.none,
        height: multiLine ? 1.15 : 1.0,
      );
      Widget labelText({required TextAlign align}) {
        return Text(
          col.label.toUpperCase(),
          maxLines: maxLines,
          softWrap: multiLine,
          overflow: multiLine ? TextOverflow.clip : TextOverflow.ellipsis,
          textAlign: align,
          style: labelStyle,
        );
      }

      return shell(
        w,
        _alignmentForTableColumn(col),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: _headerMainAxisForColumn(col),
          children: [
            Expanded(
              child: col.sortable
                  ? InkWell(
                      onTap: () => onSortTap(col),
                      child: Row(
                        mainAxisAlignment: _headerMainAxisForColumn(col),
                        children: [
                          Expanded(
                            child: labelText(align: _textAlignForColumn(col)),
                          ),
                          SizedBox(width: AppTokens.space1),
                          Icon(
                            sortColumnKey != col.key
                                ? LucideIcons.chevronsUpDown
                                : (sortDirection == 'asc'
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown),
                            size: AppTokens.textSm,
                            color: sortColumnKey == col.key
                                ? AppTokens.primary800
                                : AppTokens.textMuted,
                          ),
                        ],
                      ),
                    )
                  : Align(
                      alignment: _alignmentForTableColumn(col),
                      child: labelText(align: _textAlignForColumn(col)),
                    ),
            ),
            if (hasFilter) ...[
              if (col.sortable) SizedBox(width: AppTokens.spaceHalf),
              CompositedTransformTarget(
                link: getColFilterLink(col.key),
                child: GestureDetector(
                  onTap: () => onFilterTap(col),
                  child: Icon(
                    LucideIcons.listFilter,
                    size: AppTokens.textXs,
                    color: activeColFilters.contains(col.key)
                        ? AppTokens.accent500
                        : AppTokens.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final scrollChildren = <Widget>[];
    for (var i = 0; i < columns.length; i++) {
      scrollChildren.add(headerCell(columns[i], scrollWidths[i]));
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.surfaceSubtle,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: headerRowHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _kListingTableOuterGutter,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showExpandColumn)
                  SizedBox(
                    width: AppTokens.tableExpandColumnWidth,
                    child: Center(
                      child: Text(
                        'EXPAND',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.tableHeaderSize,
                          fontWeight: AppTokens.tableHeaderWeight,
                          letterSpacing: 0.3,
                          color: AppTokens.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                if (showCheckboxes)
                  SizedBox(
                    width: AppTokens.tableCheckboxColumnWidth,
                    child: Center(
                      child: _ListingCheckbox(
                        tristate: true,
                        value: selectAll,
                        onChanged: onSelectAll,
                      ),
                    ),
                  ),
                if (showToggle)
                  SizedBox(
                    width: AppTokens.tableToggleColumnWidth,
                    child: const Center(child: SizedBox.shrink()),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        key: ObjectKey(horizontalScroll),
                        controller: horizontalScroll,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: scrollChildren,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (hasRowActions)
                  Container(
                    width: actionsColumnWidth,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTokens.surfaceSubtle,
                      border: showActionsColumnLeadingBorder
                          ? const Border(
                              left: BorderSide(
                                color: AppTokens.borderDefault,
                                width: AppTokens.borderWidthSm,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      'ACTIONS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.tableHeaderSize,
                        fontWeight: AppTokens.tableHeaderWeight,
                        letterSpacing: 0.3,
                        color: AppTokens.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingDataRow<T> extends StatefulWidget {
  const _ListingDataRow({
    super.key,
    required this.scrollWidths,
    required this.columns,
    required this.horizontalScrollGroup,
    required this.row,
    required this.index,
    required this.isLast,
    required this.selected,
    required this.showExpandColumn,
    required this.expandInteractive,
    required this.isExpanded,
    this.onExpandTap,
    required this.showMainRowBottomBorder,
    required this.showCheckboxes,
    required this.showToggle,
    required this.hasRowActions,
    required this.actionsColumnWidth,
    required this.showActionsColumnLeadingBorder,
    required this.rowActions,
    required this.onToggleChanged,
    required this.onRowTap,
    required     this.onSelectRow,
    this.rowBackgroundColor,
    required this.tableRowHeight,
  });

  final Color? Function(T)? rowBackgroundColor;
  final double tableRowHeight;

  final List<double> scrollWidths;
  final List<TableColumn<T>> columns;
  final LinkedScrollControllerGroup horizontalScrollGroup;
  final T row;
  final int index;
  final bool isLast;
  final bool selected;
  final bool showExpandColumn;
  final bool expandInteractive;
  final bool isExpanded;
  final VoidCallback? onExpandTap;
  final bool showMainRowBottomBorder;
  final bool showCheckboxes;
  final bool showToggle;
  final bool hasRowActions;
  final double actionsColumnWidth;
  final bool showActionsColumnLeadingBorder;
  final List<RowAction<T>>? rowActions;
  final ValueChanged<T>? onToggleChanged;
  final ValueChanged<T>? onRowTap;
  final ValueChanged<bool> onSelectRow;

  @override
  State<_ListingDataRow<T>> createState() => _ListingDataRowState<T>();
}

class _ListingDataRowState<T> extends State<_ListingDataRow<T>> {
  bool _hover = false;
  late final ScrollController _hScroll;

  @override
  void initState() {
    super.initState();
    _hScroll = widget.horizontalScrollGroup.addAndGet();
  }

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var wi = 0;

    Widget shell(double width, Alignment align, Widget child) {
      return _listingTableCellShell(
        width: width,
        alignment: align,
        isHeader: false,
        child: child,
      );
    }

    final Color? tint = widget.rowBackgroundColor?.call(widget.row);
    final Color baseBg = tint ?? AppTokens.cardBg;
    final Color bg = widget.selected
        ? AppTokens.warning50
        : _hover
        ? Color.alphaBlend(
            AppTokens.surfaceSubtle.withValues(alpha: 0.65),
            baseBg,
          )
        : baseBg;

    final scrollChildren = <Widget>[];
    for (final col in widget.columns) {
      scrollChildren.add(
        shell(
          widget.scrollWidths[wi++],
          _alignmentForTableColumn(col),
          DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: FontWeight.w400,
              color: AppTokens.textPrimary,
              decoration: TextDecoration.none,
            ),
            child: ClipRect(child: col.cellBuilder(widget.row)),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg,
        child: Container(
          height: widget.tableRowHeight,
          padding: EdgeInsets.symmetric(horizontal: _kListingTableOuterGutter),
          decoration: BoxDecoration(
            border: widget.showMainRowBottomBorder
                ? const Border(
                    bottom: BorderSide(
                      color: AppTokens.tableRowDivider,
                      width: AppTokens.borderWidthSm,
                    ),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showExpandColumn)
                SizedBox(
                  width: AppTokens.tableExpandColumnWidth,
                  child: Center(
                    child: _ListingExpandToggle(
                      expanded: widget.isExpanded,
                      interactive: widget.expandInteractive,
                      onTap: widget.onExpandTap,
                    ),
                  ),
                ),
              if (widget.showCheckboxes)
                SizedBox(
                  width: AppTokens.tableCheckboxColumnWidth,
                  child: Center(
                    child: _ListingCheckbox(
                      value: widget.selected,
                      onChanged: (v) => widget.onSelectRow(v ?? false),
                    ),
                  ),
                ),
              if (widget.showToggle)
                SizedBox(
                  width: AppTokens.tableToggleColumnWidth,
                  child: Center(
                    child: _RowToggleSwitch(
                      row: widget.row,
                      onToggleChanged: widget.onToggleChanged,
                    ),
                  ),
                ),
              Expanded(
                child: widget.onRowTap != null
                    ? InkWell(
                        onTap: () => widget.onRowTap!(widget.row),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              key: ObjectKey(_hScroll),
                              controller: _hScroll,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: scrollChildren,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            key: ObjectKey(_hScroll),
                            controller: _hScroll,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: scrollChildren,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (widget.hasRowActions)
                Container(
                  width: widget.actionsColumnWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg,
                    border: widget.showActionsColumnLeadingBorder
                        ? Border(
                            left: BorderSide(
                              color: AppTokens.borderDefault,
                              width: AppTokens.borderWidthSm,
                            ),
                          )
                        : null,
                  ),
                  child: PopupMenuButton<String>(
                    tooltip: 'Actions',
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      LucideIcons.moreHorizontal,
                      size: AppTokens.iconButtonIconMd,
                      color: AppTokens.textMuted,
                    ),
                    onSelected: (key) {
                      final actions = widget.rowActions!;
                      RowAction<T>? match;
                      for (final a in actions) {
                        if (a.key == key) {
                          match = a;
                          break;
                        }
                      }
                      if (match == null) return;
                      final row = widget.row;
                      if (!match.enabledFor(row)) return;
                      final onTap = match.onTap;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onTap(row);
                      });
                    },
                    itemBuilder: (context) {
                      return widget.rowActions!.map((a) {
                        final row = widget.row;
                        final effectiveLabel =
                            a.labelBuilder?.call(row) ?? a.label;
                        final effectiveIcon =
                            a.iconBuilder?.call(row) ?? a.icon;
                        return PopupMenuItem<String>(
                          value: a.key,
                          enabled: a.enabledFor(row),
                          child: Row(
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  size: AppTokens.textMd,
                                  color: a.isDanger
                                      ? AppTokens.error500
                                      : AppTokens.neutral700,
                                ),
                                child: effectiveIcon,
                              ),
                              SizedBox(width: AppTokens.space2),
                              Text(
                                effectiveLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: AppTokens.textSm,
                                  fontWeight: AppTokens.weightRegular,
                                  color: a.isDanger
                                      ? AppTokens.error500
                                      : AppTokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Checkbox (listing tables)
// -----------------------------------------------------------------------------

class _ListingCheckbox extends StatelessWidget {
  const _ListingCheckbox({
    required this.value,
    required this.onChanged,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTokens.primary800;
            }
            return null;
          }),
        ),
      ),
      child: Checkbox(
        tristate: tristate,
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Row toggle (local display state + callback)
// -----------------------------------------------------------------------------

class _RowToggleSwitch<T> extends StatefulWidget {
  const _RowToggleSwitch({required this.row, required this.onToggleChanged});

  final T row;
  final ValueChanged<T>? onToggleChanged;

  @override
  State<_RowToggleSwitch<T>> createState() => _RowToggleSwitchState<T>();
}

class _RowToggleSwitchState<T> extends State<_RowToggleSwitch<T>> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _on,
      onChanged: widget.onToggleChanged == null
          ? null
          : (v) {
              setState(() => _on = v);
              widget.onToggleChanged!(widget.row);
            },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTokens.primary800;
        }
        return null;
      }),
    );
  }
}

// -----------------------------------------------------------------------------
// Skeleton loading
// -----------------------------------------------------------------------------

class _SkeletonTable extends StatelessWidget {
  const _SkeletonTable({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final barColor = Color.lerp(
          AppTokens.surfaceSubtle,
          AppTokens.borderDefault,
          animation.value,
        )!;
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              height: AppTokens.tableRowHeight,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
              child: Container(
                height: AppTokens.space3,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.inbox, size: 32, color: AppTokens.textMuted),
            SizedBox(height: AppTokens.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.bodySize,
                fontWeight: AppTokens.bodyWeight,
                color: AppTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Pagination
// -----------------------------------------------------------------------------

class _PaginationRow extends StatelessWidget {
  const _PaginationRow({
    required this.height,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final double height;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(
          top: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
            child: ListingPaginationControls(
              placement: ListingPaginationPlacement.footer,
              totalCount: totalCount,
              currentPage: currentPage,
              pageSize: pageSize,
              pageSizeOptions: pageSizeOptions,
              onPageChanged: onPageChanged,
              onPageSizeChanged: onPageSizeChanged,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Filter side panel / bottom sheet body
// -----------------------------------------------------------------------------

class _FilterPanelContent<T> extends StatelessWidget {
  const _FilterPanelContent({
    required this.filterFields,
    required this.filterTextCtrls,
    required this.draftMulti,
    required this.draftDateFrom,
    required this.draftDateTo,
    required this.draftDateFromText,
    required this.draftDateToText,
    required this.onClearDraft,
    required this.onApply,
    required this.syncDateText,
    required this.pickDate,
    required this.onDraftChanged,
    this.onClose,
  });

  final List<FilterField> filterFields;
  final Map<String, TextEditingController> filterTextCtrls;
  final Map<String, Set<String>> draftMulti;
  final Map<String, DateTime?> draftDateFrom;
  final Map<String, DateTime?> draftDateTo;
  final Map<String, TextEditingController> draftDateFromText;
  final Map<String, TextEditingController> draftDateToText;
  final VoidCallback onClearDraft;
  final VoidCallback onApply;
  final void Function(String key) syncDateText;
  final Future<void> Function(String fieldKey, bool isFrom) pickDate;
  final VoidCallback onDraftChanged;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onClose != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTokens.space4,
                AppTokens.space3,
                AppTokens.space4,
                AppTokens.space2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textMd,
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ),
                  AppIconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: onClose,
                    variant: AppIconButtonVariant.ghost,
                    size: AppIconButtonSize.sm,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
          if (onClose != null)
            Divider(
              height: AppTokens.borderWidthHairline,
              color: theme.brightness == Brightness.dark
                  ? AppTokens.neutral700
                  : AppTokens.neutral200,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Theme(
                data: theme.copyWith(
                  checkboxTheme: CheckboxThemeData(
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTokens.primary800;
                      }
                      return null;
                    }),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final f in filterFields)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppTokens.space4),
                        child: _FilterFieldBlock(
                          field: f,
                          filterTextCtrls: filterTextCtrls,
                          draftMulti: draftMulti,
                          draftDateFromText: draftDateFromText,
                          draftDateToText: draftDateToText,
                          onDraftChanged: onDraftChanged,
                          pickDate: pickDate,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: AppTokens.borderWidthHairline,
            color: theme.brightness == Brightness.dark
                ? AppTokens.neutral700
                : AppTokens.neutral200,
          ),
          Padding(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Clear All',
                    onPressed: () {
                      onClearDraft();
                      onDraftChanged();
                    },
                    variant: AppButtonVariant.tertiary,
                    size: AppButtonSize.md,
                  ),
                ),
                SizedBox(width: AppTokens.space3),
                Expanded(
                  child: AppButton(
                    label: 'Apply Filters',
                    onPressed: onApply,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.md,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Column selector overlay (anchored to Columns button)
// -----------------------------------------------------------------------------

class _ColumnSelectorOverlay extends StatefulWidget {
  const _ColumnSelectorOverlay({
    required this.link,
    required this.columns,
    required this.visibility,
    required this.onToggle,
    required this.onDismiss,
  });

  final LayerLink link;
  final List<TableColumn<Object?>> columns;
  final List<bool> visibility;
  final void Function(int index, bool visible) onToggle;
  final VoidCallback onDismiss;

  @override
  State<_ColumnSelectorOverlay> createState() => _ColumnSelectorOverlayState();
}

class _ColumnSelectorOverlayState extends State<_ColumnSelectorOverlay> {
  late List<bool> _vis;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _vis = List<bool>.from(widget.visibility);
  }

  @override
  void didUpdateWidget(covariant _ColumnSelectorOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _vis = List<bool>.from(widget.visibility);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = <(int, TableColumn<Object?>)>[];
    for (var i = 0; i < widget.columns.length; i++) {
      final col = widget.columns[i];
      if (_query.isEmpty ||
          col.label.toLowerCase().contains(_query.toLowerCase())) {
        filtered.add((i, col));
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 4),
          child: Material(
            color: AppTokens.cardBg,
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
            elevation: 0,
            child: Container(
              width: AppTokens.columnPickerPopoverWidth,
              constraints: BoxConstraints(
                maxHeight: AppTokens.columnPickerPopoverMaxHeight,
              ),
              decoration: BoxDecoration(
                color: AppTokens.cardBg,
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
                borderRadius: BorderRadius.circular(AppTokens.cardRadius),
                boxShadow: AppTokens.shadowMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space3,
                      vertical: AppTokens.space2 + AppTokens.spaceHalf,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTokens.borderDefault,
                          width: AppTokens.borderWidthSm,
                        ),
                      ),
                    ),
                    child: Text(
                      'Columns',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textSm,
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.space2 + AppTokens.spaceHalf,
                      AppTokens.space2,
                      AppTokens.space2 + AppTokens.spaceHalf,
                      AppTokens.space1,
                    ),
                    child: SizedBox(
                      height: AppTokens.listingToolbarSearchHeight,
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: _search,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textXs,
                            color: AppTokens.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search columns...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: AppTokens.textXs,
                              color: AppTokens.textMuted,
                              decoration: TextDecoration.none,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppTokens.borderDefault,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppTokens.borderDefault,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppTokens.primary800,
                                width: AppTokens.borderWidthMd,
                              ),
                            ),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ),
                  ),
                  // Column list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final (i, col) = filtered[idx];
                        return SizedBox(
                          height: 32,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: Checkbox(
                                    value: _vis[i],
                                    onChanged: (v) {
                                      final next = v ?? false;
                                      setState(() => _vis[i] = next);
                                      widget.onToggle(i, next);
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    activeColor: AppTokens.primary800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    col.label,
                                    style: GoogleFonts.poppins(
                                      fontSize: AppTokens.textSm,
                                      fontWeight: AppTokens.weightRegular,
                                      color: AppTokens.textPrimary,
                                      decoration: TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  LucideIcons.gripVertical,
                                  size: AppTokens.iconButtonIconSm,
                                  color: AppTokens.textMuted,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Column date-range filter overlay (From / To using [LabCodeLabIdDateField])
// -----------------------------------------------------------------------------

const double _kColumnDateRangePopoverWidth = 288;

class _ColumnDateRangeFilterOverlay extends StatefulWidget {
  const _ColumnDateRangeFilterOverlay({
    required this.link,
    required this.initialFrom,
    required this.initialTo,
    required this.onApply,
    required this.onClear,
    required this.onDismiss,
  });

  final LayerLink link;
  final DateTime? initialFrom;
  final DateTime? initialTo;
  final void Function(DateTime? from, DateTime? to) onApply;
  final VoidCallback onClear;
  final VoidCallback onDismiss;

  @override
  State<_ColumnDateRangeFilterOverlay> createState() =>
      _ColumnDateRangeFilterOverlayState();
}

class _ColumnDateRangeFilterOverlayState
    extends State<_ColumnDateRangeFilterOverlay> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: AppTokens.cardBg,
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
            elevation: 0,
            child: Container(
              width: _kColumnDateRangePopoverWidth,
              decoration: BoxDecoration(
                color: AppTokens.cardBg,
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
                borderRadius: BorderRadius.circular(AppTokens.cardRadius),
                boxShadow: AppTokens.shadowMd,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'From',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        fontWeight: AppTokens.weightMedium,
                        color: AppTokens.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: AppTokens.space1),
                    LabCodeLabIdDateField(
                      hint: 'From date',
                      selectedDate: _from,
                      onDateSelected: (d) => setState(() => _from = d),
                    ),
                    SizedBox(height: AppTokens.space2),
                    Text(
                      'To',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        fontWeight: AppTokens.weightMedium,
                        color: AppTokens.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: AppTokens.space1),
                    LabCodeLabIdDateField(
                      hint: 'To date',
                      selectedDate: _to,
                      onDateSelected: (d) => setState(() => _to = d),
                    ),
                    SizedBox(height: AppTokens.space3),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Apply',
                            onPressed: () => widget.onApply(_from, _to),
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.sm,
                          ),
                        ),
                        SizedBox(width: AppTokens.listingToolbarActionsGap),
                        AppButton(
                          label: 'Reset',
                          onPressed: widget.onClear,
                          variant: AppButtonVariant.tertiary,
                          size: AppButtonSize.sm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Column filter overlay (anchored to filter icon in column header)
// -----------------------------------------------------------------------------

class _ColumnFilterOverlay extends StatefulWidget {
  const _ColumnFilterOverlay({
    required this.link,
    required this.isText,
    required this.selectItems,
    required this.initialText,
    required this.initialMulti,
    required this.onApply,
    required this.onDismiss,
  });

  final LayerLink link;
  final bool isText;
  final List<AppSelectItem<String>> selectItems;
  final String initialText;
  final Set<String> initialMulti;
  final void Function(String? text, Set<String>? multi) onApply;
  final VoidCallback onDismiss;

  @override
  State<_ColumnFilterOverlay> createState() => _ColumnFilterOverlayState();
}

class _ColumnFilterOverlayState extends State<_ColumnFilterOverlay> {
  late final TextEditingController _textCtrl;
  late Set<String> _multi;
  TextEditingController? _selectSearchCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.initialText);
    _multi = Set<String>.from(widget.initialMulti);
    if (!widget.isText) {
      _selectSearchCtrl = TextEditingController()
        ..addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _selectSearchCtrl?.dispose();
    super.dispose();
  }

  List<AppSelectItem<String>> get _filteredSelectItems {
    final q = _selectSearchCtrl?.text.trim().toLowerCase() ?? '';
    if (q.isEmpty) {
      return widget.selectItems;
    }
    return widget.selectItems.where((item) {
      return item.label.toLowerCase().contains(q) ||
          item.value.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: AppTokens.cardBg,
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
            elevation: 0,
            child: Container(
              width: AppTokens.columnFilterPopoverWidth,
              decoration: BoxDecoration(
                color: AppTokens.cardBg,
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
                borderRadius: BorderRadius.circular(AppTokens.cardRadius),
                boxShadow: AppTokens.shadowMd,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space3),
                child: widget.isText
                    ? _buildTextFilter()
                    : _buildSelectFilter(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFilter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          controller: _textCtrl,
          hint: 'Filter...',
          size: AppInputSize.sm,
        ),
        SizedBox(height: AppTokens.space2),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Apply',
                onPressed: () => widget.onApply(_textCtrl.text.trim(), null),
                variant: AppButtonVariant.primary,
                size: AppButtonSize.sm,
              ),
            ),
            SizedBox(width: AppTokens.listingToolbarActionsGap),
            AppButton(
              label: 'Reset',
              onPressed: () => widget.onApply('', null),
              variant: AppButtonVariant.tertiary,
              size: AppButtonSize.sm,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectFilter() {
    final items = _filteredSelectItems;
    final searchCtrl = _selectSearchCtrl!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          controller: searchCtrl,
          hint: 'Search…',
          size: AppInputSize.sm,
        ),
        SizedBox(height: AppTokens.space2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                return SizedBox(
                  height: AppTokens.columnFilterSelectRowHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTokens.space1,
                    ),
                    child: CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      value: _multi.contains(item.value),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _multi.add(item.value);
                          } else {
                            _multi.remove(item.value);
                          }
                        });
                      },
                      title: Text(
                        item.label,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.textSm,
                          fontWeight: AppTokens.weightRegular,
                          color: AppTokens.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: AppTokens.space2),
        Divider(
          height: AppTokens.borderWidthSm,
          thickness: AppTokens.borderWidthSm,
          color: AppTokens.borderDefault,
        ),
        SizedBox(height: AppTokens.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              label: 'Reset',
              onPressed: () => widget.onApply(null, {}),
              variant: AppButtonVariant.tertiary,
              size: AppButtonSize.sm,
            ),
            AppButton(
              label: 'OK',
              onPressed: () => widget.onApply(null, Set<String>.from(_multi)),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.sm,
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Filter side panel / bottom sheet body
// -----------------------------------------------------------------------------

class _FilterFieldBlock extends StatelessWidget {
  const _FilterFieldBlock({
    required this.field,
    required this.filterTextCtrls,
    required this.draftMulti,
    required this.draftDateFromText,
    required this.draftDateToText,
    required this.onDraftChanged,
    required this.pickDate,
  });

  final FilterField field;
  final Map<String, TextEditingController> filterTextCtrls;
  final Map<String, Set<String>> draftMulti;
  final Map<String, TextEditingController> draftDateFromText;
  final Map<String, TextEditingController> draftDateToText;
  final VoidCallback onDraftChanged;
  final Future<void> Function(String fieldKey, bool isFrom) pickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          field.label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.fieldLabelSize,
            fontWeight: AppTokens.fieldLabelWeight,
            color: AppTokens.neutral700,
          ),
        ),
        SizedBox(height: AppTokens.space2),
        switch (field.type) {
          FilterType.text => AppInput(
            size: AppInputSize.sm,
            controller: filterTextCtrls[field.key],
            onChanged: (_) => onDraftChanged(),
          ),
          FilterType.multiSelect => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final opt in field.options ?? <String>[])
                CheckboxListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    opt,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.bodySmSize,
                      fontWeight: AppTokens.weightRegular,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  value: (draftMulti[field.key] ?? {}).contains(opt),
                  onChanged: (v) {
                    draftMulti.putIfAbsent(field.key, () => <String>{});
                    if (v == true) {
                      draftMulti[field.key]!.add(opt);
                    } else {
                      draftMulti[field.key]!.remove(opt);
                    }
                    onDraftChanged();
                  },
                ),
            ],
          ),
          FilterType.dateRange => Row(
            children: [
              Expanded(
                child: AppInput(
                  size: AppInputSize.sm,
                  readOnly: true,
                  controller: draftDateFromText[field.key],
                  hint: 'From date',
                  onTap: () async {
                    await pickDate(field.key, true);
                    onDraftChanged();
                  },
                ),
              ),
              SizedBox(width: AppTokens.space2),
              Expanded(
                child: AppInput(
                  size: AppInputSize.sm,
                  readOnly: true,
                  controller: draftDateToText[field.key],
                  hint: 'To date',
                  onTap: () async {
                    await pickDate(field.key, false);
                    onDraftChanged();
                  },
                ),
              ),
            ],
          ),
        },
      ],
    );
  }
}
