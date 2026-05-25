import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/supervisor_review_workspace_model.dart';
import '../state/supervisor_comments_provider.dart';

/// Method-grouped parameter grid for Supervisor Review workspace (LMV popup pattern).
///
/// Column headers stay pinned while the body scrolls vertically; horizontal
/// scroll is linked between header and body (same rhythm as listing tables).
class SupervisorReviewWorkspaceGroupedTable extends StatefulWidget {
  const SupervisorReviewWorkspaceGroupedTable({
    super.key,
    required this.columnWidths,
    required this.columnLabels,
    required this.rows,
    required this.provider,
    required this.rowBackgroundColor,
    this.emptyMessage = 'No test parameters',
  });

  final List<double> columnWidths;
  final List<String> columnLabels;
  final List<SupervisorReviewTestLine> rows;
  final SupervisorCommentsProvider provider;

  final Color? Function(SupervisorReviewTestLine line) rowBackgroundColor;

  final String emptyMessage;

  @override
  State<SupervisorReviewWorkspaceGroupedTable> createState() =>
      _SupervisorReviewWorkspaceGroupedTableState();
}

class _SupervisorReviewWorkspaceGroupedTableState
    extends State<SupervisorReviewWorkspaceGroupedTable> {
  static const int _histColStart = 15;
  static const double _compactRowHeight = 40.0;
  static const double _compactHeaderHeight = 42.0;

  final LinkedScrollControllerGroup _hScrollGroup = LinkedScrollControllerGroup();
  late final ScrollController _headerHScroll;
  late final ScrollController _bodyHScroll;
  late final ScrollController _bodyVScroll;

  @override
  void initState() {
    super.initState();
    _headerHScroll = _hScrollGroup.addAndGet();
    _bodyHScroll = _hScrollGroup.addAndGet();
    _bodyVScroll = ScrollController();
  }

  @override
  void dispose() {
    _headerHScroll.dispose();
    _bodyHScroll.dispose();
    _bodyVScroll.dispose();
    super.dispose();
  }

  double get _tableWidth =>
      widget.columnWidths.fold<double>(0, (a, w) => a + w);

  BorderSide get _gridLine => BorderSide(
        color: AppTokens.borderLight,
        width: AppTokens.borderWidthMd,
      );

  EdgeInsets get _dataCellPadding => EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space1,
      );

  String _display(String raw) {
    final t = raw.trim();
    return t.isEmpty ? '—' : t;
  }

  String _normalizedMethod(SupervisorReviewTestLine line) {
    final m = line.methodGroup.trim();
    return m.isEmpty ? 'General' : m;
  }

  bool _isCheckboxHeaderColumn(int index) {
    if (index < 0 || index >= widget.columnLabels.length) return false;
    final k = widget.columnLabels[index];
    return k == 'Highlight' || k == 'Retest' || k == 'Report';
  }

  bool _isHistoricalColumn(int index) => index >= _histColStart;

  Widget _headerLabel(int index, String label, TextStyle hdrStyle) {
    if (_isHistoricalColumn(index) && label.contains('\n')) {
      final lines = label.split('\n');
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lines.first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: hdrStyle,
          ),
          if (lines.length > 1) ...[
            SizedBox(height: AppTokens.spaceHalf),
            Text(
              lines[1],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: hdrStyle.copyWith(
                fontSize: AppTokens.captionSize,
                fontWeight: AppTokens.weightMedium,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      );
    }
    return Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: _isCheckboxHeaderColumn(index)
          ? TextAlign.center
          : TextAlign.left,
      style: hdrStyle,
    );
  }

  Widget _headerRow(BuildContext context) {
    final hdrStyle = GoogleFonts.poppins(
      fontSize: AppTokens.textXs,
      fontWeight: AppTokens.weightSemibold,
      color: AppTokens.textSecondary,
      letterSpacing: 0.3,
      decoration: TextDecoration.none,
    );

    return SizedBox(
      height: _compactHeaderHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.columnLabels.length; i++)
            SizedBox(
              width: widget.columnWidths[i],
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTokens.surfaceSubtle,
                  border: Border(
                    right: i < widget.columnLabels.length - 1
                        ? _gridLine
                        : BorderSide.none,
                    bottom: _gridLine,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space2,
                    vertical: AppTokens.space1,
                  ),
                  child: Align(
                    alignment: _isCheckboxHeaderColumn(i)
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: _headerLabel(i, widget.columnLabels[i], hdrStyle),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _methodBand(BuildContext context, String methodTitle) {
    final theme = Theme.of(context);
    final methodStyle = GoogleFonts.poppins(
      fontSize: AppTokens.textSm,
      fontWeight: AppTokens.weightBold,
      color: theme.colorScheme.onSurface,
      decoration: TextDecoration.none,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.surfaceSubtle,
        border: Border(bottom: _gridLine),
      ),
      child: SizedBox(
        width: _tableWidth,
        height: 32,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space2,
            vertical: AppTokens.spaceHalf,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'METHOD: $methodTitle',
              style: methodStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _textDataCell(
    String text, {
    required double width,
    required bool showRightDivider,
    required Color? rowTint,
    TextAlign align = TextAlign.left,
  }) {
    final cellStyle = GoogleFonts.poppins(
      fontSize: AppTokens.tableCellSize,
      fontWeight: FontWeight.w400,
      color: AppTokens.textPrimary,
      height: 1.2,
      decoration: TextDecoration.none,
    );

    return SizedBox(
      width: width,
      height: _compactRowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: rowTint,
          border: Border(
            right: showRightDivider ? _gridLine : BorderSide.none,
            bottom: _gridLine,
          ),
        ),
        child: Padding(
          padding: _dataCellPadding,
          child: Align(
            alignment: align == TextAlign.center
                ? Alignment.center
                : (align == TextAlign.end
                    ? Alignment.centerRight
                    : Alignment.centerLeft),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: align,
              style: cellStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _severityCell(
    SupervisorReviewTestLine r, {
    required double width,
    required bool showRightDivider,
    required Color? rowTint,
  }) {
    final cellStyle = GoogleFonts.poppins(
      fontSize: AppTokens.tableCellSize,
      fontWeight: AppTokens.weightMedium,
      color: AppTokens.textPrimary,
      height: 1.2,
      decoration: TextDecoration.none,
    );

    return SizedBox(
      width: width,
      height: _compactRowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: rowTint,
          border: Border(
            right: showRightDivider ? _gridLine : BorderSide.none,
            bottom: _gridLine,
          ),
        ),
        child: Padding(
          padding: _dataCellPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              r.severity.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: cellStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkboxCell({
    required double width,
    required bool value,
    required bool showRightDivider,
    required Color? rowTint,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: _compactRowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: rowTint,
          border: Border(
            right: showRightDivider ? _gridLine : BorderSide.none,
            bottom: _gridLine,
          ),
        ),
        child: Padding(
          padding: _dataCellPadding,
          child: Center(
            child: Checkbox(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: widget.provider.isLoading ? null : onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataRow(BuildContext context, SupervisorReviewTestLine r) {
    final bg = widget.rowBackgroundColor(r);
    final n = widget.columnWidths.length;
    assert(widget.columnLabels.length == n);

    final cells = <Widget>[
      _severityCell(
        r,
        width: widget.columnWidths[0],
        showRightDivider: n > 1,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.parameterName),
        width: widget.columnWidths[1],
        showRightDivider: n > 2,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.currentValue),
        width: widget.columnWidths[2],
        showRightDivider: n > 3,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.minLimit),
        width: widget.columnWidths[3],
        showRightDivider: n > 4,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.maxLimit),
        width: widget.columnWidths[4],
        showRightDivider: n > 5,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.customerMin),
        width: widget.columnWidths[5],
        showRightDivider: n > 6,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.customerMax),
        width: widget.columnWidths[6],
        showRightDivider: n > 7,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.fluidMin),
        width: widget.columnWidths[7],
        showRightDivider: n > 8,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.fluidMax),
        width: widget.columnWidths[8],
        showRightDivider: n > 9,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.freshFluidValue),
        width: widget.columnWidths[9],
        showRightDivider: n > 10,
        rowTint: bg,
      ),
      _textDataCell(
        _display(r.typical),
        width: widget.columnWidths[10],
        showRightDivider: n > 11,
        rowTint: bg,
      ),
      _checkboxCell(
        width: widget.columnWidths[11],
        value: r.highlightFlag,
        showRightDivider: n > 12,
        rowTint: bg,
        onChanged: (v) => widget.provider.updateTestLine(
          r.copyWith(highlightFlag: v ?? false),
        ),
      ),
      _checkboxCell(
        width: widget.columnWidths[12],
        value: r.retestFlag,
        showRightDivider: n > 13,
        rowTint: bg,
        onChanged: (v) => widget.provider.updateTestLine(
          r.copyWith(retestFlag: v ?? false),
        ),
      ),
      _checkboxCell(
        width: widget.columnWidths[13],
        value: r.includeInReport,
        showRightDivider: n > 14,
        rowTint: bg,
        onChanged: (v) => widget.provider.updateTestLine(
          r.copyWith(includeInReport: v ?? false),
        ),
      ),
      _textDataCell(
        _display(r.chemist),
        width: widget.columnWidths[14],
        showRightDivider: n > _histColStart,
        rowTint: bg,
      ),
    ];

    for (var i = _histColStart; i < n; i++) {
      final histIdx = i - _histColStart;
      final val = histIdx < r.historicalComparisonValues.length
          ? r.historicalComparisonValues[histIdx]
          : '—';
      cells.add(
        _textDataCell(
          _display(val),
          width: widget.columnWidths[i],
          showRightDivider: i < n - 1,
          rowTint: bg,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cells,
    );
  }

  List<Widget> _bodyScrollChildren(BuildContext context) {
    final out = <Widget>[];
    if (widget.rows.isEmpty) {
      out.add(
        SizedBox(
          width: _tableWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space3,
              vertical: AppTokens.space3,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.emptyMessage,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      );
      return out;
    }

    String? prevMethod;
    for (final line in widget.rows) {
      final m = _normalizedMethod(line);
      if (m != prevMethod) {
        out.add(_methodBand(context, m));
        prevMethod = m;
      }
      out.add(_dataRow(context, line));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final bodyColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _bodyScrollChildren(context),
    );

    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: _gridLine,
            top: _gridLine,
            right: _gridLine,
            bottom: _gridLine,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppScrollView(
              scrollDirection: Axis.horizontal,
              controller: _headerHScroll,
              showScrollbar: false,
              scrollbarThickness: AppScrollMetrics.listingHorizontalThickness,
              physics: const ClampingScrollPhysics(),
              child: _headerRow(context),
            ),
            Expanded(
              child: AppScrollView(
                scrollDirection: Axis.vertical,
                controller: _bodyVScroll,
                scrollbarThickness: AppScrollMetrics.thickness,
                physics: const ClampingScrollPhysics(),
                child: AppScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _bodyHScroll,
                  scrollbarThickness: AppScrollMetrics.listingHorizontalThickness,
                  enableShiftWheel: true,
                  physics: const ClampingScrollPhysics(),
                  child: bodyColumn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lab Id + HMR stacked cell for Supervisor Review listing (Ultra Labs pattern).
Widget supervisorReviewLabIdCell({
  required String labId,
  required double hmr,
}) {
  final primary = GoogleFonts.poppins(
    fontSize: AppTokens.tableCellSize,
    color: AppTokens.textPrimary,
  );
  final secondary = GoogleFonts.poppins(
    fontSize: AppTokens.captionSize,
    color: AppTokens.textMuted,
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        labId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: primary,
      ),
      Text(
        'HMR: ${supervisorReviewLabIdCellHmrText(hmr)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: secondary,
      ),
    ],
  );
}

String supervisorReviewLabIdCellHmrText(double hmr) {
  if (hmr == hmr.roundToDouble()) return hmr.toInt().toString();
  return hmr.toStringAsFixed(1);
}
