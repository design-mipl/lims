import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../cards/app_card.dart';
import '../display/kpi_metric.dart';
import '../primitives/app_button.dart';
import '../primitives/app_icon_button.dart';
import '../primitives/app_input.dart';
import '../primitives/app_select.dart';
import 'bulk_action.dart';
import 'filter_config.dart';
import 'table_column.dart';

// -----------------------------------------------------------------------------
// Desktop table layout (header + body share these insets)
// -----------------------------------------------------------------------------

double get _kListingTableOuterGutter => AppTokens.space0;

EdgeInsets _listingTableCellPadding({required bool isHeader}) =>
    EdgeInsets.symmetric(
      horizontal: 12,
      vertical: isHeader ? 0 : 0,
    );

Alignment _alignmentForTableColumn<T>(TableColumn<T> col) {
  if (col.key == 'status') {
    return Alignment.center;
  }
  if (col.numeric) {
    return Alignment.centerRight;
  }
  return Alignment.centerLeft;
}

MainAxisAlignment _headerMainAxisForColumn<T>(TableColumn<T> col) {
  if (col.key == 'status') {
    return MainAxisAlignment.center;
  }
  if (col.numeric) {
    return MainAxisAlignment.end;
  }
  return MainAxisAlignment.start;
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
      child: Align(
        alignment: alignment,
        child: child,
      ),
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
  });

  final String key;
  final String label;
  final Widget icon;
  final void Function(T row) onTap;
  final bool isDanger;

  /// When null, the action is always enabled. Otherwise called with the row.
  final bool Function(T row)? isEnabled;

  bool enabledFor(T row) => isEnabled?.call(row) ?? true;
}

/// Generic listing page: responsive table (desktop/tablet) or card list (mobile).
///
/// Sort headers update [_sortKey] / [_sortAscending]. When [onSortChanged] is set,
/// it is invoked so the parent can refetch or reorder [rows]; otherwise only the
/// indicators change.
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
  });

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

  @override
  State<AppListingScreen<T>> createState() => _AppListingScreenState<T>();
}

class _AppListingScreenState<T> extends State<AppListingScreen<T>>
    with TickerProviderStateMixin {
  final Set<int> _selectedRows = <int>{};
  bool _filterPanelOpen = false;
  late List<bool> _columnVisibility;
  String? _sortKey;
  bool _sortAscending = true;
  int _selectedTab = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _searchController = TextEditingController();

  // Column selector overlay
  final LayerLink _columnsButtonLink = LayerLink();
  OverlayEntry? _columnSelectorEntry;

  // Column filter overlays
  final Map<String, LayerLink> _colFilterLinks = {};
  OverlayEntry? _colFilterEntry;

  // Column filter applied values (key = column key)
  final Map<String, String> _colFilterText = {};
  final Map<String, Set<String>> _colFilterMulti = {};

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
    _disposeFilterControllers();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppListingScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns.length != widget.columns.length) {
      _columnVisibility = List<bool>.generate(
        widget.columns.length,
        (i) => widget.columns[i].visible,
      );
    }
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _selectedTab = _clampTab(widget.initialTabIndex);
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

  List<double> _computeColumnWidths(double maxWidth) {
    final cols = _visibleColumnDefs;
    var fixed = 0.0;
    if (widget.showCheckboxes) {
      fixed += AppTokens.tableCheckboxColumnWidth;
    }
    if (widget.showToggle) {
      fixed += AppTokens.tableToggleColumnWidth;
    }
    if (widget.rowActions != null && widget.rowActions!.isNotEmpty) {
      fixed += AppTokens.tableActionsColumnWidth;
    }
    var flexCount = 0;
    for (var i = 0; i < cols.length; i++) {
      final w = cols[i].width;
      if (w != null) {
        fixed += w;
      } else {
        flexCount++;
      }
    }
    var flexW = 120.0;
    if (flexCount > 0 && maxWidth > fixed) {
      // Do not enforce a minimum flex width: with a low min, the sum of
      // flex columns can exceed maxWidth and the header Row overflows
      // (e.g. when the row also has horizontal padding in _ListingTableHeader).
      flexW = ((maxWidth - fixed) / flexCount).clamp(0.0, 480.0);
    }
    final widths = <double>[];
    if (widget.showCheckboxes) {
      widths.add(AppTokens.tableCheckboxColumnWidth);
    }
    if (widget.showToggle) {
      widths.add(AppTokens.tableToggleColumnWidth);
    }
    for (final c in cols) {
      var cw = c.width ?? flexW;
      if (c.key == 'status' && c.width == null) {
        cw = math.max(cw, AppTokens.tableStatusColumnPreferredWidth);
      }
      widths.add(cw);
    }
    if (widget.rowActions != null && widget.rowActions!.isNotEmpty) {
      widths.add(AppTokens.tableActionsColumnWidth);
    }
    var total = widths.fold<double>(AppTokens.space0, (a, b) => a + b);
    if (total > maxWidth + 0.5 && total > 0) {
      final scale = maxWidth / total;
      for (var i = 0; i < widths.length; i++) {
        widths[i] = widths[i] * scale;
      }
    }
    return widths;
  }

  List<T> _selectedRowValues() {
    final sorted = _selectedRows.toList()..sort();
    return sorted.map((i) => widget.rows[i]).toList();
  }

  void _toggleSelectAll(bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedRows
          ..clear()
          ..addAll(List.generate(widget.rows.length, (i) => i));
      } else {
        _selectedRows.clear();
      }
    });
  }

  bool? _selectAllState() {
    if (widget.rows.isEmpty) {
      return false;
    }
    final n = _selectedRows.length;
    if (n == 0) {
      return false;
    }
    if (n == widget.rows.length) {
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

  bool get _anyColFilterActive =>
      _colFilterText.values.any((v) => v.isNotEmpty) ||
      _colFilterMulti.values.any((s) => s.isNotEmpty);

  void _showColFilterOverlay(TableColumn<T> col) {
    _colFilterEntry?.remove();
    _colFilterEntry = null;
    final config = col.filterConfig;
    if (config == null) return;
    _colFilterEntry = OverlayEntry(
      builder: (ctx) => _ColumnFilterOverlay(
        link: _colFilterLink(col.key),
        columnKey: col.key,
        config: config,
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
          });
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

    final topSection = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space5,
        AppTokens.space4,
        AppTokens.space5,
        AppTokens.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader<T>(widget: widget),
          if (widget.kpiCards != null && widget.kpiCards!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space3),
              child: KpiRow(cards: widget.kpiCards!),
            ),
          if (widget.tabs != null && widget.tabs!.isNotEmpty)
            _TabStrip(
              tabs: widget.tabs!,
              selected: _selectedTab,
              onSelect: (i) {
                setState(() => _selectedTab = i);
                widget.onTabChanged?.call(i);
              },
            ),
        ],
      ),
    );

    final expandedBody = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space5,
        0,
        AppTokens.space5,
        AppTokens.space4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.08),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    );
                  },
                  child: _selectedRows.isNotEmpty
                      ? KeyedSubtree(
                          key: const ValueKey<String>('bulk'),
                          child: _BulkBar<T>(
                            count: _selectedRows.length,
                            bulkActions: widget.bulkActions,
                            onBulk: (fn) => fn(_selectedRowValues()),
                            onDeselectAll: () => setState(_selectedRows.clear),
                          ),
                        )
                      : KeyedSubtree(
                          key: const ValueKey<String>('toolbar'),
                          child: _ToolbarRow<T>(
                            widget: widget,
                            searchController: _searchController,
                            onToggleFilters: _onFilterToolbarPressed,
                            onColumnPicker: _showColumnPicker,
                            columnsButtonLink: _columnsButtonLink,
                            anyColFilterActive: _anyColFilterActive,
                          ),
                        ),
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
                Expanded(
                  child: AppBreakpoints.isMobileWidth(width)
                      ? _buildMobileBody()
                      : _buildDesktopTableBody(),
                ),
              ],
            ),
          ),
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
                      onClose: () =>
                          setState(() => _filterPanelOpen = false),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topSection,
          Expanded(child: expandedBody),
        ],
      ),
    );
  }

  Widget _buildMobileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: widget.isLoading
              ? _SkeletonTable(animation: _pulseAnimation)
              : widget.rows.isEmpty
              ? widget.emptyWidget ??
                    _EmptyState(
                      message: widget.emptyMessage ?? 'No records found',
                    )
              : ListView.separated(
                  padding: EdgeInsets.all(AppTokens.space4),
                  itemCount: widget.rows.length,
                  separatorBuilder: (context, index) => SizedBox(
                    key: ValueKey<int>(index),
                    height: AppTokens.space2,
                  ),
                  itemBuilder: (context, index) {
                    final row = widget.rows[index];
                    return AppCard(
                      padding: EdgeInsets.zero,
                      onTap: widget.onRowTap != null
                          ? () => widget.onRowTap!(row)
                          : null,
                      child: Padding(
                        padding: EdgeInsets.all(AppTokens.space4),
                        child: widget.mobileCardBuilder(row),
                      ),
                    );
                  },
                ),
        ),
        _PaginationRow(
          totalCount: widget.totalCount,
          currentPage: widget.currentPage,
          pageSize: widget.pageSize,
          pageSizeOptions: widget.pageSizeOptions,
          onPageChanged: widget.onPageChanged,
          onPageSizeChanged: widget.onPageSizeChanged,
        ),
      ],
    );
  }

  Widget _buildDesktopTableBody() {
    final tableRadius = BorderRadius.only(
      bottomLeft: Radius.circular(AppTokens.cardRadius),
      bottomRight: Radius.circular(AppTokens.cardRadius),
    );

    Widget tableCore() {
      if (widget.isLoading) {
        return _SkeletonTable(animation: _pulseAnimation);
      }
      if (widget.rows.isEmpty) {
        return widget.emptyWidget ??
            _EmptyState(
              message: widget.emptyMessage ?? 'No records found',
            );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final innerW =
              (constraints.maxWidth - 2 * _kListingTableOuterGutter)
                  .clamp(0.0, double.infinity);
          final widths = _computeColumnWidths(innerW);
          final totalW = widths.fold<double>(
            AppTokens.space0,
            (a, b) => a + b,
          );
          final tableCol = Column(
            children: [
              _ListingTableHeader<T>(
                widths: widths,
                columns: _visibleColumnDefs,
                showCheckboxes: widget.showCheckboxes,
                showToggle: widget.showToggle,
                hasRowActions:
                    widget.rowActions != null &&
                    widget.rowActions!.isNotEmpty,
                sortKey: _sortKey,
                sortAscending: _sortAscending,
                selectAll: _selectAllState(),
                onSelectAll: widget.showCheckboxes
                    ? _toggleSelectAll
                    : null,
                onSortTap: (col) {
                  if (!col.sortable) {
                    return;
                  }
                  setState(() {
                    if (_sortKey == col.key) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortKey = col.key;
                      _sortAscending = true;
                    }
                  });
                  widget.onSortChanged?.call((
                    columnKey: col.key,
                    ascending: _sortAscending,
                  ));
                },
                onFilterTap: _showColFilterOverlay,
                activeColFilters: {
                  ..._colFilterText.keys,
                  ..._colFilterMulti.keys,
                },
                colFilterLinks: _colFilterLinks,
                getColFilterLink: _colFilterLink,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.rows.length,
                  itemBuilder: (context, index) {
                    final row = widget.rows[index];
                    final selected = _selectedRows.contains(index);
                    final isLast = index == widget.rows.length - 1;
                    return _ListingDataRow<T>(
                      widths: widths,
                      columns: _visibleColumnDefs,
                      row: row,
                      index: index,
                      isLast: isLast,
                      selected: selected,
                      showCheckboxes: widget.showCheckboxes,
                      showToggle: widget.showToggle,
                      hasRowActions:
                          widget.rowActions != null &&
                          widget.rowActions!.isNotEmpty,
                      rowActions: widget.rowActions,
                      onToggleChanged: widget.onToggleChanged,
                      onRowTap: widget.onRowTap,
                      onSelectRow: (v) {
                        setState(() {
                          if (v) {
                            _selectedRows.add(index);
                          } else {
                            _selectedRows.remove(index);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
          if (totalW > innerW + 0.5) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalW + 2 * _kListingTableOuterGutter,
                child: tableCol,
              ),
            );
          }
          return tableCol;
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: tableRadius,
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppTokens.cardBg,
                border: Border(
                  left: BorderSide(
                    color: AppTokens.borderDefault,
                    width: AppTokens.borderWidthSm,
                  ),
                  right: BorderSide(
                    color: AppTokens.borderDefault,
                    width: AppTokens.borderWidthSm,
                  ),
                  bottom: BorderSide(
                    color: AppTokens.borderDefault,
                    width: AppTokens.borderWidthSm,
                  ),
                ),
              ),
              child: tableCore(),
            ),
          ),
        ),
        _PaginationRow(
          totalCount: widget.totalCount,
          currentPage: widget.currentPage,
          pageSize: widget.pageSize,
          pageSizeOptions: widget.pageSizeOptions,
          onPageChanged: widget.onPageChanged,
          onPageSizeChanged: widget.onPageSizeChanged,
        ),
      ],
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
                ),
              ),
              SizedBox(height: AppTokens.space1),
              Text(
                widget.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.pageSubtitleSize,
                  fontWeight: AppTokens.pageSubtitleWeight,
                  color: AppTokens.textSecondary,
                ),
              ),
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
        if (widget.primaryActionLabel != null &&
            widget.onPrimaryAction != null)
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

class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<TabConfig> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final t = tabs[i];
              final active = i == selected;
              return InkWell(
                onTap: () => onSelect(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                            ),
                          ),
                          if (t.count != null && t.count! > 0) ...[
                            SizedBox(width: AppTokens.space2),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppTokens.primary50,
                                borderRadius: BorderRadius.circular(
                                  AppTokens.radiusFull,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTokens.space2,
                                  vertical: AppTokens.space1 / 2,
                                ),
                                child: Text(
                                  '${t.count}',
                                  style: GoogleFonts.poppins(
                                    fontSize: AppTokens.captionSize,
                                    fontWeight: AppTokens.weightMedium,
                                    color: AppTokens.primary800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 2,
                        color: active
                            ? AppTokens.accent500
                            : AppTokens.white.withValues(alpha: 0),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Container(
          height: AppTokens.borderWidthSm,
          color: AppTokens.borderDefault,
        ),
      ],
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
    required this.anyColFilterActive,
  });

  final AppListingScreen<T> widget;
  final TextEditingController searchController;
  final VoidCallback onToggleFilters;
  final VoidCallback onColumnPicker;
  final LayerLink columnsButtonLink;
  final bool anyColFilterActive;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hasFilters =
        widget.filterFields != null && widget.filterFields!.isNotEmpty;

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
        height: AppTokens.inputHeightLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              if (widget.showSearch)
                if (AppBreakpoints.isMobileWidth(w))
                  Expanded(
                    child: _ListingSearchField(
                      controller: searchController,
                      hint: widget.searchHint,
                      onChanged: widget.onSearch,
                    ),
                  )
                else
                  SizedBox(
                    width: AppTokens.topbarSearchWidthDesktop,
                    child: _ListingSearchField(
                      controller: searchController,
                      hint: widget.searchHint,
                      onChanged: widget.onSearch,
                    ),
                  ),
              if (!AppBreakpoints.isMobileWidth(w)) const Spacer(),
              if (hasFilters) ...[
                _FilterButton(
                  activeCount: widget.activeFilters.length,
                  onPressed: onToggleFilters,
                ),
                SizedBox(width: AppTokens.space2),
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
                      if (anyColFilterActive)
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
              if (widget.showExport && widget.onExport != null) ...[
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
      width: 7,
      height: 7,
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
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: AppTokens.cardBg,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: (AppTokens.buttonHeightMd - AppTokens.textSm) / 2,
      ),
      prefixIcon: const Padding(
        padding: EdgeInsets.only(
          left: AppTokens.space2,
          right: AppTokens.space1,
        ),
        child: Icon(
          LucideIcons.search,
          size: 14,
          color: AppTokens.textMuted,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: AppTokens.space8,
        minHeight: AppTokens.buttonHeightMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.inputRadius),
        borderSide: const BorderSide(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.inputRadius),
        borderSide: const BorderSide(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.inputRadius),
        borderSide: const BorderSide(
          color: AppTokens.primary800,
          width: AppTokens.borderWidthMd,
        ),
      ),
    );

    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.textSm,
        fontWeight: FontWeight.w400,
        color: AppTokens.textPrimary,
      ),
      cursorColor: AppTokens.primary800,
      decoration: decoration,
      onChanged: onChanged,
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.activeCount,
    required this.onPressed,
  });

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
        horizontal: AppTokens.space4,
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

class _BulkBar<T> extends StatelessWidget {
  const _BulkBar({
    required this.count,
    required this.bulkActions,
    required this.onBulk,
    required this.onDeselectAll,
  });

  final int count;
  final List<BulkAction<T>>? bulkActions;
  final void Function(void Function(List<T> rows) fn) onBulk;
  final VoidCallback onDeselectAll;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppTokens.primary800),
      child: SizedBox(
        height: AppTokens.inputHeightLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              Text(
                '$count selected',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightMedium,
                  color: AppTokens.white,
                ),
              ),
              const Spacer(),
              if (bulkActions != null)
                for (final a in bulkActions!) ...[
                  a.isDanger
                      ? AppButton(
                          label: a.label,
                          leadingIcon: a.icon,
                          onPressed: () => onBulk(a.onTap),
                          variant: AppButtonVariant.danger,
                          size: AppButtonSize.sm,
                        )
                      : AppButton(
                          label: a.label,
                          leadingIcon: a.icon,
                          onPressed: () => onBulk(a.onTap),
                          variant: AppButtonVariant.tertiary,
                          size: AppButtonSize.sm,
                          foregroundColor: AppTokens.white,
                        ),
                  SizedBox(width: AppTokens.space2),
                ],
              AppButton(
                label: 'Clear selection',
                onPressed: onDeselectAll,
                variant: AppButtonVariant.tertiary,
                size: AppButtonSize.sm,
                foregroundColor: AppTokens.white,
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

class _ListingTableHeader<T> extends StatelessWidget {
  const _ListingTableHeader({
    required this.widths,
    required this.columns,
    required this.showCheckboxes,
    required this.showToggle,
    required this.hasRowActions,
    required this.sortKey,
    required this.sortAscending,
    required this.selectAll,
    required this.onSelectAll,
    required this.onSortTap,
    required this.onFilterTap,
    required this.activeColFilters,
    required this.colFilterLinks,
    required this.getColFilterLink,
  });

  final List<double> widths;
  final List<TableColumn<T>> columns;
  final bool showCheckboxes;
  final bool showToggle;
  final bool hasRowActions;
  final String? sortKey;
  final bool sortAscending;
  final bool? selectAll;
  final ValueChanged<bool?>? onSelectAll;
  final ValueChanged<TableColumn<T>> onSortTap;
  final ValueChanged<TableColumn<T>> onFilterTap;
  final Set<String> activeColFilters;
  final Map<String, LayerLink> colFilterLinks;
  final LayerLink Function(String key) getColFilterLink;

  @override
  Widget build(BuildContext context) {
    var wi = 0;

    Widget shell(double width, Alignment align, Widget child) {
      return _listingTableCellShell(
        width: width,
        alignment: align,
        isHeader: true,
        child: child,
      );
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
          height: AppTokens.tableHeaderHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _kListingTableOuterGutter),
            child: Row(
              children: [
                if (showCheckboxes)
                  shell(
                    widths[wi++],
                    Alignment.center,
                    _ListingCheckbox(
                      tristate: true,
                      value: selectAll,
                      onChanged: onSelectAll,
                    ),
                  ),
                if (showToggle)
                  shell(
                    widths[wi++],
                    Alignment.center,
                    const SizedBox.shrink(),
                  ),
                for (final col in columns)
                  shell(
                    widths[wi++],
                    _alignmentForTableColumn(col),
                    Row(
                      mainAxisSize: col.key == 'status'
                          ? MainAxisSize.min
                          : MainAxisSize.max,
                      mainAxisAlignment: _headerMainAxisForColumn(col),
                      children: [
                        if (col.sortable)
                          Flexible(
                            child: InkWell(
                              onTap: () => onSortTap(col),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      col.label.toUpperCase(),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: AppTokens.tableHeaderSize,
                                        fontWeight: AppTokens.tableHeaderWeight,
                                        letterSpacing: 0.3,
                                        color: AppTokens.textSecondary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppTokens.space1),
                                  Icon(
                                    sortKey != col.key
                                        ? LucideIcons.chevronsUpDown
                                        : (sortAscending
                                            ? LucideIcons.chevronUp
                                            : LucideIcons.chevronDown),
                                    size: 12,
                                    color: sortKey == col.key
                                        ? AppTokens.primary800
                                        : AppTokens.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: Text(
                              col.label.toUpperCase(),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableHeaderSize,
                                fontWeight: AppTokens.tableHeaderWeight,
                                letterSpacing: 0.3,
                                color: AppTokens.textSecondary,
                              ),
                            ),
                          ),
                        if (col.filterConfig != null) ...[
                          SizedBox(width: AppTokens.space1),
                          CompositedTransformTarget(
                            link: getColFilterLink(col.key),
                            child: GestureDetector(
                              onTap: () => onFilterTap(col),
                              child: Icon(
                                LucideIcons.listFilter,
                                size: 11,
                                color: activeColFilters.contains(col.key)
                                    ? AppTokens.accent500
                                    : AppTokens.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (hasRowActions)
                  shell(
                    widths[wi++],
                    Alignment.centerRight,
                    const SizedBox.shrink(),
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
    required this.widths,
    required this.columns,
    required this.row,
    required this.index,
    required this.isLast,
    required this.selected,
    required this.showCheckboxes,
    required this.showToggle,
    required this.hasRowActions,
    required this.rowActions,
    required this.onToggleChanged,
    required this.onRowTap,
    required this.onSelectRow,
  });

  final List<double> widths;
  final List<TableColumn<T>> columns;
  final T row;
  final int index;
  final bool isLast;
  final bool selected;
  final bool showCheckboxes;
  final bool showToggle;
  final bool hasRowActions;
  final List<RowAction<T>>? rowActions;
  final ValueChanged<T>? onToggleChanged;
  final ValueChanged<T>? onRowTap;
  final ValueChanged<bool> onSelectRow;

  @override
  State<_ListingDataRow<T>> createState() => _ListingDataRowState<T>();
}

class _ListingDataRowState<T> extends State<_ListingDataRow<T>> {
  bool _hover = false;

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

    final Color bg = widget.selected
        ? AppTokens.primary50
        : _hover
            ? AppTokens.surfaceSubtle
            : AppTokens.cardBg;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: widget.onRowTap != null
              ? () => widget.onRowTap!(widget.row)
              : null,
          child: Container(
            height: AppTokens.tableRowHeight,
            padding: EdgeInsets.symmetric(horizontal: _kListingTableOuterGutter),
            decoration: BoxDecoration(
              border: widget.isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                        color: AppTokens.borderDefault,
                        width: AppTokens.borderWidthSm,
                      ),
                    ),
            ),
            child: Row(
              children: [
                if (widget.showCheckboxes)
                  shell(
                    widget.widths[wi++],
                    Alignment.center,
                    _ListingCheckbox(
                      value: widget.selected,
                      onChanged: (v) => widget.onSelectRow(v ?? false),
                    ),
                  ),
                if (widget.showToggle)
                  shell(
                    widget.widths[wi++],
                    Alignment.center,
                    _RowToggleSwitch(
                      row: widget.row,
                      onToggleChanged: widget.onToggleChanged,
                    ),
                  ),
                for (final col in widget.columns)
                  shell(
                    widget.widths[wi++],
                    _alignmentForTableColumn(col),
                    DefaultTextStyle(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.tableCellSize,
                        fontWeight: FontWeight.w400,
                        color: AppTokens.textPrimary,
                      ),
                      child: ClipRect(
                        child: col.cellBuilder(widget.row),
                      ),
                    ),
                  ),
                if (widget.hasRowActions)
                  shell(
                    widget.widths[wi++],
                    Alignment.centerRight,
                    PopupMenuButton<String>(
                        tooltip: 'Actions',
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          LucideIcons.moreHorizontal,
                          size: 16,
                          color: AppTokens.textMuted,
                        ),
                        onSelected: (key) {
                          final a = widget.rowActions!.firstWhere(
                            (e) => e.key == key,
                          );
                          if (!a.enabledFor(widget.row)) {
                            return;
                          }
                          a.onTap(widget.row);
                        },
                        itemBuilder: (context) {
                          return widget.rowActions!
                              .map(
                                (a) => PopupMenuItem<String>(
                                  value: a.key,
                                  enabled: a.enabledFor(widget.row),
                                  child: Row(
                                    children: [
                                      IconTheme(
                                        data: IconThemeData(
                                          size: AppTokens.textMd,
                                          color: a.isDanger
                                              ? AppTokens.error500
                                              : AppTokens.neutral700,
                                        ),
                                        child: a.icon,
                                      ),
                                      SizedBox(width: AppTokens.space2),
                                      Text(
                                        a.label,
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
                                ),
                              )
                              .toList();
                        },
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
            const Icon(
              LucideIcons.inbox,
              size: 32,
              color: AppTokens.textMuted,
            ),
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
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final int totalCount;
  final int currentPage;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final start = totalCount == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final end = totalCount == 0
        ? 0
        : (currentPage * pageSize).clamp(0, totalCount);
    final canPrev = currentPage > 1;
    final lastPage = totalCount == 0 ? 1 : ((totalCount - 1) ~/ pageSize) + 1;
    final canNext = totalCount > 0 && currentPage < lastPage;
    final resolvedSize =
        pageSizeOptions.contains(pageSize) ? pageSize : pageSizeOptions.first;

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
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              Text(
                'Rows per page:',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightMedium,
                  color: AppTokens.textSecondary,
                ),
              ),
              SizedBox(width: AppTokens.space2),
              SizedBox(
                width: 70,
                height: 28,
                child: AppSelect<int>(
                  value: resolvedSize,
                  items: [
                    for (final n in pageSizeOptions)
                      AppSelectItem<int>(value: n, label: '$n'),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      onPageSizeChanged(v);
                    }
                  },
                  size: AppInputSize.sm,
                ),
              ),
              const Spacer(),
              Text(
                '$start–$end of $totalCount',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightRegular,
                  color: AppTokens.textSecondary,
                ),
              ),
              SizedBox(width: AppTokens.space2),
              AppIconButton(
                icon: const Icon(LucideIcons.chevronLeft),
                onPressed: canPrev
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                variant: AppIconButtonVariant.outlined,
                size: AppIconButtonSize.sm,
                tooltip: 'Previous page',
              ),
              AppIconButton(
                icon: const Icon(LucideIcons.chevronRight),
                onPressed: canNext
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                variant: AppIconButtonVariant.outlined,
                size: AppIconButtonSize.sm,
                tooltip: 'Next page',
              ),
            ],
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
              width: 220,
              constraints: const BoxConstraints(maxHeight: 320),
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
                      horizontal: 12,
                      vertical: 10,
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
                      ),
                    ),
                  ),
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                    child: SizedBox(
                      height: 28,
                      child: TextField(
                        controller: _search,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTokens.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search columns…',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTokens.textMuted,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            borderSide: const BorderSide(
                              color: AppTokens.borderDefault,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            borderSide: const BorderSide(
                              color: AppTokens.borderDefault,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
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
                                      fontWeight: FontWeight.w400,
                                      color: AppTokens.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.gripVertical,
                                  size: 14,
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
// Column filter overlay (anchored to filter icon in column header)
// -----------------------------------------------------------------------------

class _ColumnFilterOverlay extends StatefulWidget {
  const _ColumnFilterOverlay({
    required this.link,
    required this.columnKey,
    required this.config,
    required this.initialText,
    required this.initialMulti,
    required this.onApply,
    required this.onDismiss,
  });

  final LayerLink link;
  final String columnKey;
  final ColumnFilterConfig config;
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

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.initialText);
    _multi = Set<String>.from(widget.initialMulti);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
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
              width: 200,
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
                padding: const EdgeInsets.all(10),
                child: widget.config.type == ColumnFilterType.text
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
        SizedBox(
          height: 30,
          child: TextField(
            controller: _textCtrl,
            autofocus: true,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              color: AppTokens.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Filter...',
              hintStyle: GoogleFonts.poppins(
                fontSize: AppTokens.textSm,
                color: AppTokens.textMuted,
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: const BorderSide(color: AppTokens.borderDefault),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: const BorderSide(color: AppTokens.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: const BorderSide(
                  color: AppTokens.primary800,
                  width: AppTokens.borderWidthMd,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FilterPopoverButton(
                label: 'Clear',
                onTap: () => widget.onApply('', null),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FilterPopoverButton(
                label: 'Apply',
                primary: true,
                onTap: () => widget.onApply(_textCtrl.text.trim(), null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectFilter() {
    final options = widget.config.options ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                return SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: Checkbox(
                          value: _multi.contains(opt),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _multi.add(opt);
                              } else {
                                _multi.remove(opt);
                              }
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          activeColor: AppTokens.primary800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opt,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textSm,
                            color: AppTokens.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FilterPopoverButton(
                label: 'Clear',
                onTap: () => widget.onApply(null, {}),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FilterPopoverButton(
                label: 'Apply',
                primary: true,
                onTap: () => widget.onApply(null, Set<String>.from(_multi)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterPopoverButton extends StatelessWidget {
  const _FilterPopoverButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        decoration: BoxDecoration(
          color: primary ? AppTokens.primary800 : AppTokens.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: primary ? AppTokens.primary800 : AppTokens.borderDefault,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textXs,
            fontWeight: AppTokens.weightSemibold,
            color: primary ? AppTokens.white : AppTokens.textSecondary,
          ),
        ),
      ),
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
