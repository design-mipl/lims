import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../cards/app_card.dart';
import '../display/kpi_metric.dart';
import '../primitives/app_button.dart';
import '../primitives/app_icon_button.dart';
import '../primitives/app_input.dart';
import 'bulk_action.dart';
import 'filter_config.dart';
import 'table_column.dart';

// -----------------------------------------------------------------------------
// Supporting models
// -----------------------------------------------------------------------------

/// Tab item for the custom tab strip on [AppListingScreen].
class TabConfig {
  const TabConfig({
    required this.label,
    this.count,
  });

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
  });

  final String key;
  final String label;
  final Widget icon;
  final void Function(T row) onTap;
  final bool isDanger;
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
            final m = Map<Object?, Object?>.from(
              match.first.rawValue! as Map,
            );
            _draftDateFrom[f.key] = m['from'] is DateTime
                ? m['from'] as DateTime
                : null;
            _draftDateTo[f.key] =
                m['to'] is DateTime ? m['to'] as DateTime : null;
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
      flexW = ((maxWidth - fixed) / flexCount).clamp(80.0, 480.0);
    }
    final widths = <double>[];
    if (widget.showCheckboxes) {
      widths.add(AppTokens.tableCheckboxColumnWidth);
    }
    if (widget.showToggle) {
      widths.add(AppTokens.tableToggleColumnWidth);
    }
    for (final c in cols) {
      widths.add(c.width ?? flexW);
    }
    if (widget.rowActions != null && widget.rowActions!.isNotEmpty) {
      widths.add(AppTokens.tableActionsColumnWidth);
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
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Columns',
            style: Theme.of(ctx).textTheme.titleSmall,
          ),
          content: SizedBox(
            width: AppTokens.listingFilterPanelWidth,
            child: StatefulBuilder(
              builder: (context, setLocal) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.columns.length, (i) {
                      final col = widget.columns[i];
                      return CheckboxTheme(
                        data: CheckboxThemeData(
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppTokens.primary800;
                            }
                            return null;
                          }),
                        ),
                        child: CheckboxListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          value: _columnVisibility[i],
                          onChanged: (v) {
                            setLocal(() {
                              setState(() {
                                _columnVisibility[i] = v ?? false;
                              });
                            });
                          },
                          title: Text(
                            col.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopFilters =
        AppBreakpoints.isDesktopWidth(width) &&
            widget.filterFields != null &&
            widget.filterFields!.isNotEmpty;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader<T>(widget: widget, theme: theme),
          if (widget.kpiCards != null && widget.kpiCards!.isNotEmpty)
            _KpiStrip(cards: widget.kpiCards!, width: width),
          if (widget.tabs != null && widget.tabs!.isNotEmpty)
            _TabStrip(
              tabs: widget.tabs!,
              selected: _selectedTab,
              onSelect: (i) {
                setState(() => _selectedTab = i);
                widget.onTabChanged?.call(i);
              },
              theme: theme,
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppTokens.space6,
                AppTokens.space3,
                AppTokens.space6,
                AppTokens.space4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: AppBreakpoints.isMobileWidth(width)
                          ? _buildMobileBody(theme)
                          : _buildDesktopTableBody(theme),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ToolbarRow<T>(
          theme: theme,
          widget: widget,
          searchController: _searchController,
          onToggleFilters: _openFilters,
          onColumnPicker: _showColumnPicker,
        ),
        if (widget.activeFilters.isNotEmpty)
          _ActiveFilterChips(
            activeFilters: widget.activeFilters,
            onRemove: (f) {
              final next =
                  widget.activeFilters.where((a) => a.key != f.key).toList();
              widget.onFiltersChanged?.call(next);
            },
            onClearAll: () => widget.onFiltersChanged?.call([]),
            theme: theme,
          ),
        if (_selectedRows.isNotEmpty)
          _BulkBar<T>(
            count: _selectedRows.length,
            bulkActions: widget.bulkActions,
            onBulk: (fn) => fn(_selectedRowValues()),
            onDeselectAll: () => setState(_selectedRows.clear),
            theme: theme,
          ),
        Expanded(
          child: widget.isLoading
              ? _SkeletonTable(animation: _pulseAnimation)
              : widget.rows.isEmpty
                  ? widget.emptyWidget ??
                      _EmptyState(
                        message: widget.emptyMessage ?? 'No records found',
                        theme: theme,
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
          theme: theme,
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

  Widget _buildDesktopTableBody(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ToolbarRow<T>(
          theme: theme,
          widget: widget,
          searchController: _searchController,
          onToggleFilters: () {
            if (widget.filterFields == null ||
                widget.filterFields!.isEmpty) {
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
          },
          onColumnPicker: _showColumnPicker,
        ),
        if (widget.activeFilters.isNotEmpty)
          _ActiveFilterChips(
            activeFilters: widget.activeFilters,
            onRemove: (f) {
              final next =
                  widget.activeFilters.where((a) => a.key != f.key).toList();
              widget.onFiltersChanged?.call(next);
            },
            onClearAll: () => widget.onFiltersChanged?.call([]),
            theme: theme,
          ),
        if (_selectedRows.isNotEmpty)
          _BulkBar<T>(
            count: _selectedRows.length,
            bulkActions: widget.bulkActions,
            onBulk: (fn) => fn(_selectedRowValues()),
            onDeselectAll: () => setState(_selectedRows.clear),
            theme: theme,
          ),
        Expanded(
          child: widget.isLoading
              ? _SkeletonTable(animation: _pulseAnimation)
              : widget.rows.isEmpty
                  ? widget.emptyWidget ??
                      _EmptyState(
                        message: widget.emptyMessage ?? 'No records found',
                        theme: theme,
                      )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final widths =
                            _computeColumnWidths(constraints.maxWidth);
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
                              hasRowActions: widget.rowActions != null &&
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
                                widget.onSortChanged?.call(
                                  (
                                    columnKey: col.key,
                                    ascending: _sortAscending,
                                  ),
                                );
                              },
                              theme: theme,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.rows.length,
                                itemBuilder: (context, index) {
                                  final row = widget.rows[index];
                                  final selected =
                                      _selectedRows.contains(index);
                                  return _ListingDataRow<T>(
                                    widths: widths,
                                    columns: _visibleColumnDefs,
                                    row: row,
                                    index: index,
                                    selected: selected,
                                    showCheckboxes: widget.showCheckboxes,
                                    showToggle: widget.showToggle,
                                    hasRowActions: widget.rowActions !=
                                            null &&
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
                                    theme: theme,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                        if (totalW > constraints.maxWidth + 0.5) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: totalW,
                              child: tableCol,
                            ),
                          );
                        }
                        return tableCol;
                      },
                    ),
        ),
        _PaginationRow(
          theme: theme,
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
  const _PageHeader({required this.widget, required this.theme});

  final AppListingScreen<T> widget;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppTokens.space6,
            AppTokens.space4,
            AppTokens.space6,
            AppTokens.space2,
          ),
          child: Row(
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurface
                            : AppTokens.neutral900,
                      ),
                    ),
                    SizedBox(height: AppTokens.space1),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.neutral400
                            : AppTokens.neutral500,
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
          ),
        ),
        Divider(
          height: AppTokens.borderWidthHairline,
          color: theme.brightness == Brightness.dark
              ? AppTokens.neutral700
              : AppTokens.neutral200,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// KPI strip
// -----------------------------------------------------------------------------

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.cards, required this.width});

  final List<KpiCard> cards;
  final double width;

  int _crossAxisCount() {
    if (AppBreakpoints.isDesktopWidth(width)) {
      if (width > 1400) {
        return 4;
      }
      if (width > 1000) {
        return 3;
      }
      return 2;
    }
    if (!AppBreakpoints.isMobileWidth(width)) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileWidth(width);

    if (isMobile) {
      return SizedBox(
        height: AppTokens.inputHeightLg + AppTokens.space4,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space6),
          itemCount: cards.length,
          separatorBuilder: (context, index) => SizedBox(
            key: ValueKey<int>(index),
            width: AppTokens.space3,
          ),
          itemBuilder: (context, i) {
            return SizedBox(
              width: AppTokens.space8 * 5,
              child: KpiMetricTile(card: cards[i]),
            );
          },
        ),
      );
    }

    final n = _crossAxisCount();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space6,
        vertical: AppTokens.space2,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: n,
          mainAxisSpacing: AppTokens.space3,
          crossAxisSpacing: AppTokens.space3,
          childAspectRatio: 2.4,
        ),
        itemCount: cards.length,
        itemBuilder: (context, i) =>
            KpiMetricTile(card: cards[i]),
      ),
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
    required this.theme,
  });

  final List<TabConfig> tabs;
  final int selected;
  final ValueChanged<int> onSelect;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space6),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final t = tabs[i];
              final active = i == selected;
              return InkWell(
                onTap: () => onSelect(i),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTokens.space3,
                    AppTokens.space2,
                    AppTokens.space3,
                    AppTokens.space2,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: active
                                    ? AppTokens.weightSemibold
                                    : AppTokens.weightRegular,
                                color: active
                                    ? AppTokens.accent500
                                    : AppTokens.neutral500,
                              ),
                            ),
                            if (t.count != null) ...[
                              SizedBox(width: AppTokens.space2),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppTokens.neutral100,
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
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: AppTokens.neutral600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: AppTokens.space2),
                        Container(
                          height: 2,
                          color: active
                              ? AppTokens.accent500
                              : AppTokens.white.withValues(alpha: 0),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Divider(
          height: AppTokens.borderWidthHairline,
          color: AppTokens.neutral200,
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
    required this.theme,
    required this.widget,
    required this.searchController,
    required this.onToggleFilters,
    required this.onColumnPicker,
  });

  final ThemeData theme;
  final AppListingScreen<T> widget;
  final TextEditingController searchController;
  final VoidCallback onToggleFilters;
  final VoidCallback onColumnPicker;

  double _searchWidth(double w) {
    if (AppBreakpoints.isMobileWidth(w)) {
      return w;
    }
    if (AppBreakpoints.isTabletWidth(w)) {
      return AppTokens.listingSearchWidthTablet;
    }
    return AppTokens.listingSearchWidthDesktop;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final showLabels = AppBreakpoints.isDesktopWidth(w);
    final hasFilters =
        widget.filterFields != null && widget.filterFields!.isNotEmpty;

    return SizedBox(
      height: AppTokens.inputHeightLg,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: (AppTokens.inputHeightLg - AppTokens.buttonHeightMd) / 2,
        ),
        child: Row(
          children: [
            if (widget.showSearch)
              if (AppBreakpoints.isMobileWidth(w))
                Expanded(
                  child: _ListingSearchField(
                    controller: searchController,
                    hint: widget.searchHint,
                    onChanged: widget.onSearch,
                    theme: theme,
                  ),
                )
              else
                SizedBox(
                  width: _searchWidth(w),
                  child: _ListingSearchField(
                    controller: searchController,
                    hint: widget.searchHint,
                    onChanged: widget.onSearch,
                    theme: theme,
                  ),
                ),
            if (!AppBreakpoints.isMobileWidth(w)) const Spacer(),
            SizedBox(width: AppTokens.space2),
            if (hasFilters)
              _FilterButton(
                showLabels: showLabels,
                activeCount: widget.activeFilters.length,
                onPressed: onToggleFilters,
              ),
            if (widget.showColumnToggle) ...[
              SizedBox(width: AppTokens.space2),
              showLabels
                  ? AppButton(
                      label: 'Columns',
                      leadingIcon: const Icon(LucideIcons.columns3),
                      onPressed: onColumnPicker,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                    )
                  : AppIconButton(
                      icon: const Icon(LucideIcons.columns3),
                      onPressed: onColumnPicker,
                      variant: AppIconButtonVariant.outlined,
                      size: AppIconButtonSize.sm,
                      tooltip: 'Columns',
                    ),
            ],
            if (widget.showExport) ...[
              SizedBox(width: AppTokens.space2),
              showLabels
                  ? AppButton(
                      label: 'Export',
                      leadingIcon: const Icon(LucideIcons.download),
                      onPressed: widget.onExport,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                    )
                  : AppIconButton(
                      icon: const Icon(LucideIcons.download),
                      onPressed: widget.onExport,
                      variant: AppIconButtonVariant.outlined,
                      size: AppIconButtonSize.sm,
                      tooltip: 'Export',
                    ),
            ],
            if (widget.showImport) ...[
              SizedBox(width: AppTokens.space2),
              showLabels
                  ? AppButton(
                      label: 'Import',
                      leadingIcon: const Icon(LucideIcons.upload),
                      onPressed: widget.onImport,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                    )
                  : AppIconButton(
                      icon: const Icon(LucideIcons.upload),
                      onPressed: widget.onImport,
                      variant: AppIconButtonVariant.outlined,
                      size: AppIconButtonSize.sm,
                      tooltip: 'Import',
                    ),
            ],
            if (widget.showPrint) ...[
              SizedBox(width: AppTokens.space2),
              showLabels
                  ? AppButton(
                      label: 'Print',
                      leadingIcon: const Icon(LucideIcons.printer),
                      onPressed: widget.onPrint,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                    )
                  : AppIconButton(
                      icon: const Icon(LucideIcons.printer),
                      onPressed: widget.onPrint,
                      variant: AppIconButtonVariant.outlined,
                      size: AppIconButtonSize.sm,
                      tooltip: 'Print',
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListingSearchField extends StatelessWidget {
  const _ListingSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.theme,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final base = theme.inputDecorationTheme;
    final decoration = InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: AppTokens.neutral50,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: (AppTokens.buttonHeightMd - AppTokens.textSm) / 2,
      ),
      prefixIcon: const Padding(
        padding: EdgeInsets.only(left: AppTokens.space2, right: AppTokens.space1),
        child: Icon(
          LucideIcons.search,
          size: AppTokens.iconButtonIconSm,
          color: AppTokens.neutral400,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: AppTokens.space8,
        minHeight: AppTokens.buttonHeightMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        borderSide: const BorderSide(
          color: AppTokens.neutral200,
          width: AppTokens.borderWidthHairline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        borderSide: const BorderSide(
          color: AppTokens.neutral200,
          width: AppTokens.borderWidthHairline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        borderSide: const BorderSide(
          color: AppTokens.primary800,
          width: AppTokens.borderWidthMd,
        ),
      ),
    ).applyDefaults(base);

    return SizedBox(
      height: AppTokens.buttonHeightMd,
      child: TextField(
        controller: controller,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: AppTokens.textSm,
          color: theme.colorScheme.onSurface,
        ),
        cursorColor: theme.colorScheme.primary,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.showLabels,
    required this.activeCount,
    required this.onPressed,
  });

  final bool showLabels;
  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final badge = activeCount > 0;
    final child = showLabels
        ? AppButton(
            label: 'Filters',
            leadingIcon: const Icon(LucideIcons.filter),
            trailingIcon: const Icon(LucideIcons.chevronDown, size: 14),
            onPressed: onPressed,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.sm,
          )
        : AppIconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: onPressed,
            variant: AppIconButtonVariant.outlined,
            size: AppIconButtonSize.sm,
            tooltip: 'Filters',
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTokens.white,
                      fontSize: AppTokens.textXs,
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
    required this.theme,
  });

  final List<ActiveFilter> activeFilters;
  final ValueChanged<ActiveFilter> onRemove;
  final VoidCallback onClearAll;
  final ThemeData theme;

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
                style: theme.textTheme.labelSmall?.copyWith(
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
    required this.theme,
  });

  final int count;
  final List<BulkAction<T>>? bulkActions;
  final void Function(void Function(List<T> rows) fn) onBulk;
  final VoidCallback onDeselectAll;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.primary50,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.primary100,
            width: AppTokens.borderWidthHairline,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.inputHeightLg,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          child: Row(
            children: [
              Text(
                '$count selected',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTokens.primary800,
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
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.sm,
                        ),
                  SizedBox(width: AppTokens.space2),
                ],
              AppIconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: onDeselectAll,
                variant: AppIconButtonVariant.ghost,
                size: AppIconButtonSize.sm,
                tooltip: 'Deselect all',
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
    required this.theme,
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
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    var wi = 0;
    Widget cell(Widget child, {bool right = false}) {
      final width = widths[wi++];
      return SizedBox(
        width: width,
        child: Align(
          alignment: right ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.neutral50,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.neutral200,
            width: AppTokens.borderWidthHairline,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.inputHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          child: Row(
            children: [
              if (showCheckboxes)
                cell(
                  Center(
                    child: _ListingCheckbox(
                      tristate: true,
                      value: selectAll,
                      onChanged: onSelectAll,
                    ),
                  ),
                ),
              if (showToggle) cell(const SizedBox.shrink()),
              for (final col in columns)
                cell(
                  InkWell(
                    onTap: col.sortable ? () => onSortTap(col) : null,
                    child: Row(
                      mainAxisAlignment: col.numeric
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            col.label.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTokens.neutral500,
                              fontWeight: AppTokens.weightSemibold,
                            ),
                          ),
                        ),
                        if (col.sortable) ...[
                          SizedBox(width: AppTokens.space1),
                          Icon(
                            sortKey != col.key
                                ? LucideIcons.chevronsUpDown
                                : (sortAscending
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown),
                            size: AppTokens.iconButtonIconSm,
                            color: sortKey == col.key
                                ? AppTokens.primary800
                                : AppTokens.neutral300,
                          ),
                        ],
                      ],
                    ),
                  ),
                  right: col.numeric,
                ),
              if (hasRowActions)
                cell(
                  const SizedBox.shrink(),
                ),
            ],
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
    required this.selected,
    required this.showCheckboxes,
    required this.showToggle,
    required this.hasRowActions,
    required this.rowActions,
    required this.onToggleChanged,
    required this.onRowTap,
    required this.onSelectRow,
    required this.theme,
  });

  final List<double> widths;
  final List<TableColumn<T>> columns;
  final T row;
  final int index;
  final bool selected;
  final bool showCheckboxes;
  final bool showToggle;
  final bool hasRowActions;
  final List<RowAction<T>>? rowActions;
  final ValueChanged<T>? onToggleChanged;
  final ValueChanged<T>? onRowTap;
  final ValueChanged<bool> onSelectRow;
  final ThemeData theme;

  @override
  State<_ListingDataRow<T>> createState() => _ListingDataRowState<T>();
}

class _ListingDataRowState<T> extends State<_ListingDataRow<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    var wi = 0;
    Widget cell(Widget child, {bool right = false}) {
      final width = widget.widths[wi++];
      return SizedBox(
        width: width,
        child: Align(
          alignment: right ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      );
    }

    final Color bg = widget.selected
        ? AppTokens.primary50
        : _hover
            ? AppTokens.neutral50
            : AppTokens.white.withValues(alpha: 0);

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
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTokens.neutral100,
                  width: AppTokens.borderWidthHairline,
                ),
              ),
            ),
            child: Row(
              children: [
                if (widget.showCheckboxes)
                  cell(
                    _ListingCheckbox(
                      value: widget.selected,
                      onChanged: (v) => widget.onSelectRow(v ?? false),
                    ),
                  ),
                if (widget.showToggle)
                  cell(
                    _RowToggleSwitch(
                      row: widget.row,
                      onToggleChanged: widget.onToggleChanged,
                    ),
                  ),
                for (final col in widget.columns)
                  cell(
                    DefaultTextStyle(
                      style: widget.theme.textTheme.bodySmall!.copyWith(
                        color: widget.theme.brightness == Brightness.dark
                            ? AppTokens.neutral300
                            : AppTokens.neutral700,
                      ),
                      child: col.numeric
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: col.cellBuilder(widget.row),
                            )
                          : col.cellBuilder(widget.row),
                    ),
                    right: col.numeric,
                  ),
                if (widget.hasRowActions)
                  cell(
                    PopupMenuButton<String>(
                      tooltip: 'Actions',
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        LucideIcons.ellipsis,
                        size: AppTokens.iconButtonIconMd,
                        color: AppTokens.neutral600,
                      ),
                      onSelected: (key) {
                        final a = widget.rowActions!.firstWhere(
                          (e) => e.key == key,
                        );
                        a.onTap(widget.row);
                      },
                      itemBuilder: (context) {
                        return widget.rowActions!
                            .map(
                              (a) => PopupMenuItem<String>(
                                value: a.key,
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
                                      style: widget.theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: a.isDanger
                                            ? AppTokens.error500
                                            : null,
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
  const _RowToggleSwitch({
    required this.row,
    required this.onToggleChanged,
  });

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
        return Opacity(
          opacity: animation.value,
          child: ListView.builder(
            padding: EdgeInsets.all(AppTokens.space4),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppTokens.space2),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: AppTokens.space3,
                        decoration: BoxDecoration(
                          color: AppTokens.neutral200,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: AppTokens.space3,
                        decoration: BoxDecoration(
                          color: AppTokens.neutral100,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.theme,
  });

  final String message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.inbox,
              size: AppTokens.space10,
              color: AppTokens.neutral300,
            ),
            SizedBox(height: AppTokens.space4),
            Text(
              'No records found',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTokens.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space2),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTokens.neutral400,
              ),
              textAlign: TextAlign.center,
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
    required this.theme,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final ThemeData theme;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final start = totalCount == 0
        ? 0
        : (currentPage - 1) * pageSize + 1;
    final end = totalCount == 0
        ? 0
        : (currentPage * pageSize).clamp(0, totalCount);
    final lastPage = totalCount == 0
        ? 1
        : ((totalCount - 1) ~/ pageSize) + 1;
    final canPrev = currentPage > 1;
    final canNext = totalCount > 0 && currentPage < lastPage;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppTokens.neutral700
                : AppTokens.neutral200,
            width: AppTokens.borderWidthHairline,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.inputHeightLg,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          child: Row(
            children: [
              Text(
                'Rows per page:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTokens.neutral500,
                ),
              ),
              SizedBox(width: AppTokens.space2),
              SizedBox(
                height: AppTokens.buttonHeightSm,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: pageSizeOptions.contains(pageSize)
                        ? pageSize
                        : pageSizeOptions.first,
                    items: pageSizeOptions
                        .map(
                          (n) => DropdownMenuItem<int>(
                            value: n,
                            child: Text(
                              '$n',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: AppTokens.textSm,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        onPageSizeChanged(v);
                      }
                    },
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$start-$end of $totalCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTokens.neutral500,
                ),
              ),
              SizedBox(width: AppTokens.space2),
              AppIconButton(
                icon: const Icon(LucideIcons.chevronLeft),
                onPressed: canPrev ? () => onPageChanged(currentPage - 1) : null,
                variant: AppIconButtonVariant.ghost,
                size: AppIconButtonSize.sm,
                tooltip: 'Previous page',
              ),
              AppIconButton(
                icon: const Icon(LucideIcons.chevronRight),
                onPressed: canNext ? () => onPageChanged(currentPage + 1) : null,
                variant: AppIconButtonVariant.ghost,
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
                      style: theme.textTheme.titleSmall,
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
                          theme: theme,
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

class _FilterFieldBlock extends StatelessWidget {
  const _FilterFieldBlock({
    required this.field,
    required this.filterTextCtrls,
    required this.draftMulti,
    required this.draftDateFromText,
    required this.draftDateToText,
    required this.onDraftChanged,
    required this.pickDate,
    required this.theme,
  });

  final FilterField field;
  final Map<String, TextEditingController> filterTextCtrls;
  final Map<String, Set<String>> draftMulti;
  final Map<String, TextEditingController> draftDateFromText;
  final Map<String, TextEditingController> draftDateToText;
  final VoidCallback onDraftChanged;
  final Future<void> Function(String fieldKey, bool isFrom) pickDate;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          field.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : AppTokens.neutral700,
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
                      style: theme.textTheme.bodySmall,
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
