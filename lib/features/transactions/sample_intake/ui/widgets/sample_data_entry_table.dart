import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../state/sample_intake_provider.dart';
import 'sample_data_entry_row.dart';
import 'sample_data_grid_layout.dart';

/// Sample data sheet: bulk bar + listing-style header (sticky), linked horizontal scroll, sticky actions.
class SampleDataEntryTable extends StatefulWidget {
  const SampleDataEntryTable({
    super.key,
    this.gridProfile = SampleDataGridProfile.full,
    required this.onSaveSelected,
    required this.onSaveAndGenerateLabCode,
    this.isActionBusy = false,
  });

  final SampleDataGridProfile gridProfile;

  /// Persists the grid (selected indexes indicate scope for UX; full grid is persisted).
  final Future<void> Function(Set<int> indexes) onSaveSelected;

  /// Persists then navigates to Generate Lab Code with [indexes] in the query string.
  final Future<void> Function(Set<int> indexes) onSaveAndGenerateLabCode;

  final bool isActionBusy;

  @override
  State<SampleDataEntryTable> createState() => _SampleDataEntryTableState();
}

class _SampleDataEntryTableState extends State<SampleDataEntryTable> {
  final LinkedScrollControllerGroup _tableHScrollGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _headerHScroll;
  late final ScrollController _bottomHScroll;
  late final ScrollController _vCtrl;

  final Set<int> _selectedDetailRows = <int>{};

  @override
  void initState() {
    super.initState();
    _headerHScroll = _tableHScrollGroup.addAndGet();
    _bottomHScroll = _tableHScrollGroup.addAndGet();
    _vCtrl = ScrollController();
  }

  @override
  void dispose() {
    _headerHScroll.dispose();
    _bottomHScroll.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  bool? _selectAllValue(int rowCount) {
    if (rowCount == 0) return false;
    var n = 0;
    for (var i = 0; i < rowCount; i++) {
      if (_selectedDetailRows.contains(i)) n++;
    }
    if (n == 0) return false;
    if (n == rowCount) return true;
    return null;
  }

  void _setSelectAll(int rowCount, bool? v) {
    setState(() {
      _selectedDetailRows.removeWhere((i) => i < 0 || i >= rowCount);
      if (v == true) {
        _selectedDetailRows.addAll(List<int>.generate(rowCount, (i) => i));
      } else {
        _selectedDetailRows.clear();
      }
    });
  }

  void _toggleRowSelected(int rowCount, int listIndex, bool selected) {
    setState(() {
      _selectedDetailRows.removeWhere((i) => i < 0 || i >= rowCount);
      if (selected) {
        _selectedDetailRows.add(listIndex);
      } else {
        _selectedDetailRows.remove(listIndex);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedDetailRows.clear);
  }

  Future<void> _runSaveSelected() async {
    if (widget.isActionBusy || _selectedDetailRows.isEmpty) return;
    final sel = Set<int>.from(_selectedDetailRows);
    await widget.onSaveSelected(sel);
  }

  Future<void> _runSaveAndGenerate() async {
    if (widget.isActionBusy || _selectedDetailRows.isEmpty) return;
    final sel = Set<int>.from(_selectedDetailRows);
    await widget.onSaveAndGenerateLabCode(sel);
  }

  Widget _datasheetBulkMiniButton({
    required String label,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    final borderColor = AppTokens.borderDefault;
    final bg = AppTokens.cardBg;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTokens.bulkActionButtonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(AppTokens.bulkActionButtonRadius),
        child: Container(
          height: AppTokens.bulkActionButtonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppTokens.bulkActionButtonRadius),
            border: Border.all(
              color: borderColor,
              width: AppTokens.borderWidthSm,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppTokens.bulkActionIconSize,
                color: AppTokens.textMuted,
              ),
              SizedBox(width: AppTokens.space1),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bulkActionFontSize,
                  fontWeight: AppTokens.weightRegular,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datasheetBulkBar(int rowCount) {
    final selectedCount = _selectedDetailRows.length;
    final showActiveBar = rowCount > 0 && selectedCount > 0;
    final bg = showActiveBar ? AppTokens.warning50 : AppTokens.surfaceSubtle;
    final bottomBorder = showActiveBar
        ? AppTokens.bulkBarActiveBottomBorder
        : AppTokens.borderDefault;

    final validSelection = rowCount > 0 &&
        _selectedDetailRows.isNotEmpty &&
        _selectedDetailRows.every((i) => i >= 0 && i < rowCount);
    final canAct = validSelection && !widget.isActionBusy;

    final rightActions = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: canAct ? AppTokens.opacityFull : AppTokens.bulkBarGreyedOpacity,
            child: IgnorePointer(
              ignoring: !canAct,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _datasheetBulkMiniButton(
                    label: 'Save Selected',
                    icon: LucideIcons.save,
                    onPressed: _runSaveSelected,
                  ),
                  SizedBox(width: AppTokens.space2),
                  _datasheetBulkMiniButton(
                    label: 'Save & Generate Lab Code',
                    icon: LucideIcons.hash,
                    onPressed: _runSaveAndGenerate,
                  ),
                  SizedBox(width: AppTokens.space2),
                  _datasheetBulkMiniButton(
                    label: 'Clear Selection',
                    icon: LucideIcons.x,
                    onPressed: () => _clearSelection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

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
                child: showActiveBar
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
                            '$selectedCount rows selected',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.textXs,
                              fontWeight: AppTokens.weightMedium,
                              color: AppTokens.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(width: AppTokens.space2),
                          GestureDetector(
                            onTap: _clearSelection,
                            child: Text(
                              '✕ Clear',
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
              rightActions,
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime? current) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  static const double _bottomHScrollTrackHeight = 36;

  /// Horizontal scrollbar only; width matches scrollable grid (not sticky ACTIONS).
  ///
  /// The [Row] must have a **bounded height**: [Expanded] in a [Row] expands on the
  /// vertical axis; without a fixed height the row gets unbounded constraints and
  /// the flex layout can break (body/list height collapsing to zero on web/desktop).
  Widget _bottomHorizontalScrollBar() {
    final actionW = SampleDataGridLayout.actionColumnWidth;
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space1),
      child: SizedBox(
        height: _bottomHScrollTrackHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AppScrollbar(
                controller: _bottomHScroll,
                scrollDirection: Axis.horizontal,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentW =
                        SampleDataGridLayout.horizontalScrollContentWidth(
                      constraints.maxWidth,
                      widget.gridProfile,
                    );
                    return SingleChildScrollView(
                      controller: _bottomHScroll,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: contentW,
                        height: _bottomHScrollTrackHeight,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: actionW),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();
    final labels =
        SampleDataGridLayout.columnLabelsFor(widget.gridProfile);
    final widths =
        SampleDataGridLayout.scrollColumnWidthsFor(widget.gridProfile);
    final gap = SampleDataGridLayout.interColumnGap;

    final rowCount = p.sampleRows.length;

    final headerLabelStyle = GoogleFonts.poppins(
      fontSize: AppTokens.tableHeaderSize,
      fontWeight: AppTokens.tableHeaderWeight,
      letterSpacing: 0.3,
      color: AppTokens.textSecondary,
      decoration: TextDecoration.none,
    );

    Widget headerLabelRich(String raw) {
      final hasStar = raw.endsWith('*');
      final base = hasStar ? raw.substring(0, raw.length - 1) : raw;
      final upper = base.toUpperCase();
      if (!hasStar) {
        return Text(
          upper,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: headerLabelStyle,
        );
      }
      return Text.rich(
        TextSpan(
          style: headerLabelStyle,
          children: <InlineSpan>[
            TextSpan(text: upper),
            TextSpan(
              text: '*',
              style: headerLabelStyle.copyWith(color: AppTokens.accent500),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget headerCell(int i) {
      if (i == 0) {
        return SizedBox(
          width: widths[i],
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    tristate: true,
                    value: _selectAllValue(rowCount),
                    onChanged:
                        rowCount == 0 ? null : (v) => _setSelectAll(rowCount, v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  child: Text(
                    labels[i].toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: headerLabelStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return SizedBox(
        width: widths[i],
        child: Align(
          alignment: Alignment.centerLeft,
          child: headerLabelRich(labels[i]),
        ),
      );
    }

    // LayoutBuilder MUST be outside horizontal SingleChildScrollView so
    // constraints.maxWidth is finite (same pattern as AppListingScreen).
    // No horizontal Scrollbar here — it sits above pagination, linked via [_bottomHScroll].
    final headerRow = DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.surfaceSubtle,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.tableHeaderHeight + AppTokens.space2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _headerHScroll,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTokens.space2,
                          AppTokens.space1,
                          AppTokens.space2,
                          AppTokens.space2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < labels.length; i++) ...[
                              if (i > 0) SizedBox(width: gap),
                              headerCell(i),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: SampleDataGridLayout.actionColumnWidth,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTokens.surfaceSubtle,
                border: Border(
                  left: BorderSide(
                    color: AppTokens.borderDefault,
                    width: AppTokens.borderWidthSm,
                  ),
                ),
              ),
              child: Text(
                'ACTIONS',
                textAlign: TextAlign.center,
                style: headerLabelStyle,
              ),
            ),
          ],
        ),
      ),
    );

    Widget body;
    if (rowCount == 0) {
      body = SizedBox(
        height: AppTokens.tableRowHeight * 3,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Text(
              'No sample rows loaded. If this persists, reopen the receipt.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      );
    } else {
      body = FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: ListView.builder(
          controller: _vCtrl,
          padding: EdgeInsets.zero,
          itemCount: rowCount,
          itemBuilder: (context, listIndex) {
            final row = p.sampleRows[listIndex];
            final isActive = p.activeRowIndex == listIndex;
            final isLast = listIndex == rowCount - 1;
            final rowSelected =
                listIndex < rowCount && _selectedDetailRows.contains(listIndex);
            return SampleDataEntryRow(
              key: ValueKey<String>('${row.sampleId}_$listIndex'),
              row: row,
              gridProfile: widget.gridProfile,
              listIndex: listIndex,
              isActive: isActive,
              isLast: isLast,
              rowSelected: rowSelected,
              onRowSelected: (sel) =>
                  _toggleRowSelected(rowCount, listIndex, sel),
              horizontalScrollGroup: _tableHScrollGroup,
              onActivate: () => p.setActiveRow(listIndex),
              onPatch: (field, value) =>
                  p.updateRowField(listIndex, field, value),
              onSaveRow: () => p.saveRow(listIndex),
              pickDate: _pickDate,
            );
          },
        ),
      );
    }

    final footer = DecoratedBox(
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
          height: AppTokens.listingPaginationHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                rowCount == 0 ? '0 samples' : '1–$rowCount of $rowCount',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightRegular,
                  color: AppTokens.textSecondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: AppShiftWheelHorizontalScroll(
          controller: _headerHScroll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _datasheetBulkBar(rowCount),
              headerRow,
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: AppTokens.tableRowHeight * 5,
                  ),
                  child: rowCount == 0
                      ? body
                      : AppScrollbar(
                          controller: _vCtrl,
                          child: body,
                        ),
                ),
              ),
              if (rowCount > 0) _bottomHorizontalScrollBar(),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
