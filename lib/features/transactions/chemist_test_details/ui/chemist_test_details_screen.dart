import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/chemist_test_details_model.dart';
import '../state/chemist_test_details_provider.dart';

/// Chemist Test Details — lab summary listing + inline editable parameter grid.
class ChemistTestDetailsScreen extends StatefulWidget {
  const ChemistTestDetailsScreen({super.key});

  @override
  State<ChemistTestDetailsScreen> createState() =>
      _ChemistTestDetailsScreenState();
}

class _ChemistTestDetailsScreenState extends State<ChemistTestDetailsScreen> {
  ChemistTestDetailsProvider? _provider;

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _formatDateNullable(DateTime? d) {
    if (d == null) return '—';
    return _formatDate(d);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pr = context.read<ChemistTestDetailsProvider>();
      _provider = pr;
      pr.addListener(_onProviderNotify);
      pr.load();
    });
  }

  void _onProviderNotify() {
    final pr = _provider;
    if (pr == null || !mounted || pr.error == null) return;
    final message = pr.error!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _provider == null || message.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      _provider?.clearError();
    });
  }

  @override
  void dispose() {
    final pr = _provider;
    pr?.removeListener(_onProviderNotify);
    pr?.cancelPendingWork();
    _provider = null;
    super.dispose();
  }

  Future<void> _onSave(ChemistTestDetailsProvider p) async {
    await p.saveDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Details saved (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  Future<void> _onExport(ChemistTestDetailsProvider p) async {
    await p.exportDetails();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export details queued (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  Future<void> _onImport(ChemistTestDetailsProvider p) async {
    await p.importDetails();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Import details queued (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ChemistTestDetailsProvider>();
    final selectedId = p.selectedSummaryId;
    final selected = p.selectedSummary;

    final listing = AppListingScreen<ChemistTestSummaryRow>(
      title: 'Chemist Test Details',
      subtitle:
          'Tap Lab No. to load parameter lines in the Test Details panel on the right.',
      showPageHeader: true,
      showKpis: false,
      showCheckboxes: false,
      showBulkBar: false,
      showExport: false,
      showImport: false,
      showPrint: false,
      showColumnToggle: false,
      tableScrollableMinWidth: 116 + 132 + 88 + 116 + 260 + AppTokens.space4,
      showTableHorizontalScrollbar: true,
      tableBodyFillsViewport: true,
      searchHint: 'Lab No., sample, dates…',
      onSearch: p.setSearchQuery,
      extraActions: [
        AppButton(
          label: 'Refresh',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          leadingIcon: Icon(
            LucideIcons.refreshCw,
            size: 14,
            color: AppTokens.textPrimary,
          ),
          onPressed: p.isLoading ? null : () => p.load(),
        ),
        AppButton(
          label: 'Save',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          leadingIcon: Icon(
            LucideIcons.save,
            size: 14,
            color: AppTokens.textPrimary,
          ),
          onPressed: () => _onSave(p),
        ),
        AppButton(
          label: 'Export Details',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          leadingIcon: Icon(
            LucideIcons.download,
            size: 14,
            color: AppTokens.textPrimary,
          ),
          onPressed: () => _onExport(p),
        ),
        AppButton(
          label: 'Import Details',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          leadingIcon: Icon(
            LucideIcons.upload,
            size: 14,
            color: AppTokens.textPrimary,
          ),
          onPressed: () => _onImport(p),
        ),
      ],
      columns: [
        TableColumn<ChemistTestSummaryRow>(
          key: 'labDate',
          label: 'Lab Date',
          width: 116,
          sortValue: (r) => r.labDate.millisecondsSinceEpoch,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => _formatDate(r.labDate),
          cellBuilder: (r) => Text(
            _formatDate(r.labDate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
          ),
        ),
        TableColumn<ChemistTestSummaryRow>(
          key: 'labNo',
          label: 'Lab No.',
          width: 132,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.labNo,
          cellBuilder: (r) => InkWell(
            onTap: () => p.toggleSummarySelection(r.id),
            child: Text(
              r.labNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.primary800,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        TableColumn<ChemistTestSummaryRow>(
          key: 'testCount',
          label: 'No. of Test',
          width: 88,
          sortValue: (r) => r.testCount,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => '${r.testCount}',
          cellBuilder: (r) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${r.testCount}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
        ),
        TableColumn<ChemistTestSummaryRow>(
          key: 'expDate',
          label: 'Exp. Date',
          width: 116,
          sortValue: (r) =>
              r.expectedDate?.millisecondsSinceEpoch ?? -9223372036854775808,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => _formatDateNullable(r.expectedDate),
          cellBuilder: (r) => Text(
            _formatDateNullable(r.expectedDate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
          ),
        ),
        TableColumn<ChemistTestSummaryRow>(
          key: 'sample',
          label: 'Sample',
          flex: 1,
          sortValue: (r) => r.sample.toLowerCase(),
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.sample,
          cellBuilder: (r) => Text(
            r.sample,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
          ),
        ),
      ],
      rows: p.pagedRows,
      mobileCardBuilder: (r) => Padding(
        padding: EdgeInsets.all(AppTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => p.toggleSummarySelection(r.id),
              child: Text(
                r.labNo,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightSemibold,
                  color: AppTokens.primary800,
                ),
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              r.sample,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ],
        ),
      ),
      isLoading: p.isLoading,
      emptyMessage: 'No labs in queue',
      totalCount: p.totalFilteredCount,
      currentPage: p.currentPage,
      pageSize: p.pageSize,
      onPageChanged: p.setPage,
      onPageSizeChanged: p.setPageSize,
      rowBackgroundColor: (row) =>
          row.id == selectedId ? AppTokens.warning50 : null,
      rowActions: [
        RowAction<ChemistTestSummaryRow>(
          key: 'view',
          label: 'View',
          icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
          onTap: (row) => p.openSummaryView(row.id),
        ),
        RowAction<ChemistTestSummaryRow>(
          key: 'edit',
          label: 'Edit',
          icon: Icon(LucideIcons.pencilLine, size: AppTokens.iconButtonIconMd),
          onTap: (row) => p.openSummaryEdit(row.id),
        ),
      ],
    );

    final rightPane = _ChemistTestDetailsRightPane(
      summary: selected,
      lines: selected != null ? p.selectedDetailLines : const [],
      readOnly: !p.detailPanelEditable,
      onValueChanged: p.updateDetailValue,
      onClearSelection: selected != null
          ? () => p.toggleSummarySelection(selected.id)
          : null,
      onBeginEdit: selected != null
          ? () => p.openSummaryEdit(selected.id)
          : null,
      onEndEdit: selected != null
          ? () => p.openSummaryView(selected.id)
          : null,
    );

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 960;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: listing),
                Divider(
                  height: AppTokens.borderWidthSm,
                  thickness: AppTokens.borderWidthSm,
                  color: AppTokens.border,
                ),
                Expanded(child: rightPane),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 55, child: listing),
              VerticalDivider(
                width: 1,
                thickness: AppTokens.borderWidthSm,
                color: AppTokens.border,
              ),
              Expanded(flex: 45, child: rightPane),
            ],
          );
        },
      ),
    );
  }
}

/// Right-hand Test Details workspace (empty until a Lab No. is selected).
class _ChemistTestDetailsRightPane extends StatelessWidget {
  const _ChemistTestDetailsRightPane({
    required this.summary,
    required this.lines,
    required this.readOnly,
    required this.onValueChanged,
    required this.onClearSelection,
    this.onBeginEdit,
    this.onEndEdit,
  });

  final ChemistTestSummaryRow? summary;
  final List<ChemistTestDetailLine> lines;
  final bool readOnly;
  final void Function(int lineIndex, int valueSlot, String value)
  onValueChanged;
  final VoidCallback? onClearSelection;
  final VoidCallback? onBeginEdit;
  final VoidCallback? onEndEdit;

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return ColoredBox(
        color: AppTokens.cardBg,
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Test Details',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  fontWeight: AppTokens.weightSemibold,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              Expanded(
                child: Center(
                  child: Text(
                    'Select a Lab No. from the listing to load parameters.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.tableCellSize,
                      color: AppTokens.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: AppTokens.cardBg,
      child: _ChemistTestDetailWorkspace(
        summary: summary!,
        lines: lines,
        readOnly: readOnly,
        onValueChanged: onValueChanged,
        onClearSelection: onClearSelection,
        onBeginEdit: onBeginEdit,
        onEndEdit: onEndEdit,
      ),
    );
  }
}

class _ChemistTestDetailWorkspace extends StatefulWidget {
  const _ChemistTestDetailWorkspace({
    required this.summary,
    required this.lines,
    required this.readOnly,
    required this.onValueChanged,
    required this.onClearSelection,
    this.onBeginEdit,
    this.onEndEdit,
  });

  final ChemistTestSummaryRow summary;
  final List<ChemistTestDetailLine> lines;
  final bool readOnly;
  final void Function(int lineIndex, int valueSlot, String value)
  onValueChanged;
  final VoidCallback? onClearSelection;
  final VoidCallback? onBeginEdit;
  final VoidCallback? onEndEdit;

  @override
  State<_ChemistTestDetailWorkspace> createState() =>
      _ChemistTestDetailWorkspaceState();
}

class _ChemistTestDetailWorkspaceState
    extends State<_ChemistTestDetailWorkspace> {
  final ScrollController _vScroll = ScrollController();

  List<List<TextEditingController>> _valueCtrls = [];

  /// Column 1–3 share equal flex so Value inputs align under Name / Method / Unit.
  static const double _rowHHeader = 34;
  static const double _rowHInfo = 36;
  static const double _rowHValueLabel = 28;
  static const double _rowHValueInput = 40;

  /// # | Name | Method | Unit | PDF — values live in rows below, same column grid.
  static const Map<int, TableColumnWidth> _columnWidths = {
    0: FixedColumnWidth(32),
    1: FlexColumnWidth(1.0),
    2: FlexColumnWidth(1.0),
    3: FlexColumnWidth(1.0),
    4: FixedColumnWidth(34),
  };

  /// Uniform cell padding for aligned grid lines.
  EdgeInsets get _cellPadding => EdgeInsets.symmetric(
    horizontal: AppTokens.space2,
    vertical: AppTokens.space1,
  );

  TableBorder get _gridBorder => TableBorder.all(
    color: AppTokens.borderLight,
    width: AppTokens.borderWidthSm,
  );

  TextStyle get _hdrStyle => GoogleFonts.poppins(
    fontSize: AppTokens.textXs,
    fontWeight: AppTokens.weightSemibold,
    color: AppTokens.textSecondary,
    letterSpacing: 0.3,
  );

  TextStyle get _cellStyle => GoogleFonts.poppins(
    fontSize: AppTokens.tableCellSize,
    color: AppTokens.textPrimary,
    height: 1.2,
  );

  void _bindControllers() {
    _disposeControllers();
    _valueCtrls = [];
    for (final line in widget.lines) {
      _valueCtrls.add([
        TextEditingController(text: line.value1),
        TextEditingController(text: line.value2),
        TextEditingController(text: line.value3),
      ]);
    }
  }

  void _disposeControllers() {
    for (final triple in _valueCtrls) {
      for (final c in triple) {
        c.dispose();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bindControllers();
  }

  @override
  void didUpdateWidget(covariant _ChemistTestDetailWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.id != widget.summary.id ||
        _valueCtrls.length != widget.lines.length) {
      _bindControllers();
      return;
    }
    for (var i = 0; i < widget.lines.length; i++) {
      final line = widget.lines[i];
      final ctrls = _valueCtrls[i];
      void sync(TextEditingController c, String v) {
        if (c.text != v) c.text = v;
      }

      sync(ctrls[0], line.value1);
      sync(ctrls[1], line.value2);
      sync(ctrls[2], line.value3);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _vScroll.dispose();
    super.dispose();
  }

  Widget _headerLabAttachment() {
    return Tooltip(
      message: 'PDF attachment (placeholder)',
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space1),
          child: Icon(
            LucideIcons.paperclip,
            size: AppTokens.iconButtonIconSm,
            color: AppTokens.primary800,
          ),
        ),
      ),
    );
  }

  TableCell _headerCell(
    String label, {
    TextAlign textAlign = TextAlign.left,
    double height = _rowHHeader,
  }) {
    final align = textAlign == TextAlign.center
        ? Alignment.center
        : Alignment.centerLeft;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: _cellPadding,
          child: Align(
            alignment: align,
            child: Text(
              label,
              textAlign: textAlign,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _hdrStyle,
            ),
          ),
        ),
      ),
    );
  }

  TableCell _readOnlyGridCell(
    String text, {
    int maxLines = 1,
    TextAlign textAlign = TextAlign.left,
    double height = _rowHInfo,
  }) {
    final align = textAlign == TextAlign.center
        ? Alignment.center
        : Alignment.centerLeft;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: _cellPadding,
          child: Align(
            alignment: align,
            child: Text(
              text,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: _cellStyle,
            ),
          ),
        ),
      ),
    );
  }

  TableCell _emptyGridCell(double height) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(height: height, child: const SizedBox.shrink()),
    );
  }

  TextStyle get _valueHdrStyle => GoogleFonts.poppins(
    fontSize: AppTokens.captionSize,
    fontWeight: AppTokens.weightSemibold,
    color: AppTokens.textSecondary,
    letterSpacing: 0.2,
  );

  TableCell _valueLabelCell(String label) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: _rowHValueLabel,
        child: Padding(
          padding: _cellPadding,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _valueHdrStyle,
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _gridInputOutline(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.inputRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  TableCell _valueInputCell({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String hintText,
    required bool readOnly,
  }) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: _rowHValueInput,
        child: Padding(
          padding: _cellPadding,
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onChanged: readOnly ? null : onChanged,
                style: _cellStyle,
                textAlign: TextAlign.center,
                cursorColor: AppTokens.borderFocus,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppTokens.cardBg,
                  border: _gridInputOutline(
                    AppTokens.borderDefault,
                    AppTokens.borderWidthSm,
                  ),
                  enabledBorder: _gridInputOutline(
                    AppTokens.borderDefault,
                    AppTokens.borderWidthSm,
                  ),
                  focusedBorder: _gridInputOutline(
                    AppTokens.borderFocus,
                    AppTokens.focusRingWidth,
                  ),
                  disabledBorder: _gridInputOutline(
                    AppTokens.borderDefault,
                    AppTokens.borderWidthSm,
                  ),
                  hintText: hintText,
                  hintStyle: _cellStyle.copyWith(color: AppTokens.hintColor),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space2,
                    vertical: 6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableCell _pdfActionCell(int lineIndex) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: _rowHInfo,
        child: Center(
          child: IconButton(
            tooltip:
                'Generate PDF for this test (${widget.summary.labNo} • row ${lineIndex + 1}) — placeholder',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            style: IconButton.styleFrom(
              foregroundColor: AppTokens.primary800,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {},
            icon: Icon(LucideIcons.fileText, size: 15),
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildGridRows(List<ChemistTestDetailLine> lines) {
    final rows = <TableRow>[
      TableRow(
        decoration: const BoxDecoration(color: AppTokens.surfaceSubtle),
        children: [
          _headerCell('#'),
          _headerCell('Test Name'),
          _headerCell('Method'),
          _headerCell('Unit'),
          _headerCell('PDF', textAlign: TextAlign.center),
        ],
      ),
    ];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final c = _valueCtrls[i];
      rows.add(
        TableRow(
          children: [
            _readOnlyGridCell('${line.serialNo}', textAlign: TextAlign.center),
            _readOnlyGridCell(line.testName),
            _readOnlyGridCell(line.methodType),
            _readOnlyGridCell(line.unit, textAlign: TextAlign.center),
            _pdfActionCell(i),
          ],
        ),
      );
      rows.add(
        TableRow(
          children: [
            _emptyGridCell(_rowHValueLabel),
            _valueLabelCell('Value 1'),
            _valueLabelCell('Value 2'),
            _valueLabelCell('Value 3'),
            _emptyGridCell(_rowHValueLabel),
          ],
        ),
      );
      rows.add(
        TableRow(
          children: [
            _emptyGridCell(_rowHValueInput),
            _valueInputCell(
              controller: c[0],
              hintText: 'Value 1',
              readOnly: widget.readOnly,
              onChanged: (v) => widget.onValueChanged(i, 0, v),
            ),
            _valueInputCell(
              controller: c[1],
              hintText: 'Value 2',
              readOnly: widget.readOnly,
              onChanged: (v) => widget.onValueChanged(i, 1, v),
            ),
            _valueInputCell(
              controller: c[2],
              hintText: 'Value 3',
              readOnly: widget.readOnly,
              onChanged: (v) => widget.onValueChanged(i, 2, v),
            ),
            _emptyGridCell(_rowHValueInput),
          ],
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines;

    final Widget panel;
    if (lines.isEmpty) {
      panel = Padding(
        padding: EdgeInsets.all(AppTokens.space3),
        child: Text(
          'No test lines for this lab.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.captionSize,
            color: AppTokens.textMuted,
          ),
        ),
      );
    } else {
      panel = ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Table(
          border: _gridBorder,
          columnWidths: _columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: _buildGridRows(lines),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.space5,
        AppTokens.space2,
        AppTokens.space5,
        AppTokens.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Test Details — ${widget.summary.labNo}',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.textSm,
                    fontWeight: AppTokens.weightSemibold,
                    color: AppTokens.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              _headerLabAttachment(),
              SizedBox(width: AppTokens.space1),
              if (widget.onClearSelection != null)
                TextButton(
                  onPressed: widget.onClearSelection,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXs,
                      fontWeight: AppTokens.weightMedium,
                      color: AppTokens.primary800,
                    ),
                  ),
                ),
              if (widget.readOnly && widget.onBeginEdit != null)
                TextButton(
                  onPressed: widget.onBeginEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXs,
                      fontWeight: AppTokens.weightMedium,
                      color: AppTokens.primary800,
                    ),
                  ),
                ),
              if (!widget.readOnly && widget.onEndEdit != null)
                TextButton(
                  onPressed: widget.onEndEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Cancel edit',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXs,
                      fontWeight: AppTokens.weightMedium,
                      color: AppTokens.primary800,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTokens.space2),
          Expanded(
            child: AppScrollbar(
              controller: _vScroll,
              child: SingleChildScrollView(
                controller: _vScroll,
                primary: false,
                physics: const ClampingScrollPhysics(),
                child: panel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
