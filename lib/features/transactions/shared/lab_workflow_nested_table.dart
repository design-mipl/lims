import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/tokens.dart';
import 'lab_workflow_test_line.dart';

BorderSide _nestedGridLine() => BorderSide(
      width: AppTokens.borderWidthMd,
      color: AppTokens.borderLight,
    );

/// Dense single-line technical summary for nested tables and detail views.
String labWorkflowTestLineTechnicalNotes(LabWorkflowTestLine l) {
  final parts = <String>[];
  void seg(String label, String raw) {
    final t = raw.trim();
    if (t.isEmpty || t == '—') return;
    parts.add('$label $t');
  }

  seg('Min', l.minValue);
  seg('Max', l.maxValue);
  seg('Typ', l.typical);
  final custLo = l.customerMin.trim();
  final custHi = l.customerMax.trim();
  if (custLo.isNotEmpty &&
      custHi.isNotEmpty &&
      custLo != '—' &&
      custHi != '—') {
    parts.add('Cust $custLo–$custHi');
  }
  final fluidLo = l.fluidMin.trim();
  final fluidHi = l.fluidMax.trim();
  if (fluidLo.isNotEmpty &&
      fluidHi.isNotEmpty &&
      fluidLo != '—' &&
      fluidHi != '—') {
    parts.add('Fluid $fluidLo–$fluidHi');
  }

  if (parts.isEmpty) {
    final c = l.chemistName.trim();
    return c.isEmpty ? '—' : 'Chemist $c';
  }
  return parts.join(' · ');
}

/// Groups [LabWorkflowTestLine]s by non-empty [LabWorkflowTestLine.sectionTitle]
/// (method name). Order follows first appearance when sorted by line number.
List<MapEntry<String, List<LabWorkflowTestLine>>> labWorkflowLinesGroupedByMethod(
  List<LabWorkflowTestLine> lines,
) {
  final sorted = [...lines]..sort((a, b) => a.lineNo.compareTo(b.lineNo));
  final map = <String, List<LabWorkflowTestLine>>{};
  final order = <String>[];
  for (final l in sorted) {
    final key = (l.sectionTitle ?? '').trim().isEmpty
        ? 'General'
        : l.sectionTitle!.trim();
    if (!map.containsKey(key)) {
      order.add(key);
      map[key] = [];
    }
    map[key]!.add(l);
  }
  return [for (final k in order) MapEntry(k, map[k]!)];
}

/// Single header row + full-width method bands + dense rows (LMV / Chemist popups).
class LabWorkflowPopupGroupedTable extends StatelessWidget {
  const LabWorkflowPopupGroupedTable({
    super.key,
    required this.groupedLines,
    this.retestRemarksShowPending = false,
  });

  final List<MapEntry<String, List<LabWorkflowTestLine>>> groupedLines;

  final bool retestRemarksShowPending;

  /// Matches [LabManagerVerificationNestedTable] balanced weights.
  static const List<double> _flex = [
    20, 14, 9, 9, 9, 9, 9, 9, 10, 18, 14,
  ];

  static const List<String> _headers = [
    'Test Name',
    'Value',
    'Min Value',
    'Max Value',
    'Customer Min',
    'Customer Max',
    'Fluid Min',
    'Fluid Max',
    'Typical',
    'Retest Remarks',
    'Chemist',
  ];

  /// Minimum layout width — scroll horizontally when the dialog is narrower.
  static const double tableMinWidth = 1420;

  BorderSide _gridLine() => BorderSide(
        color: AppTokens.borderLight,
        width: AppTokens.borderWidthMd,
      );

  List<double> _columnWidths() {
    final sum = _flex.fold<double>(0, (a, b) => a + b);
    return _flex.map((f) => tableMinWidth * f / sum).toList();
  }

  static String _display(String raw) {
    final t = raw.trim();
    return t.isEmpty ? '—' : t;
  }

  List<String> _dataCells(LabWorkflowTestLine l) => [
        _display(l.testName),
        _display(l.value),
        _display(l.minValue),
        _display(l.maxValue),
        _display(l.customerMin),
        _display(l.customerMax),
        _display(l.fluidMin),
        _display(l.fluidMax),
        _display(l.typical),
        retestRemarksShowPending ? 'Pending' : _display(l.retestRemarks),
        _display(l.chemistName),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colW = _columnWidths();
    final line = _gridLine();

    final hdrStyle = GoogleFonts.poppins(
      fontSize: AppTokens.textXs,
      fontWeight: AppTokens.weightSemibold,
      color: AppTokens.textSecondary,
      letterSpacing: 0.3,
      decoration: TextDecoration.none,
    );

    final cellStyle = GoogleFonts.poppins(
      fontSize: AppTokens.tableCellSize,
      fontWeight: AppTokens.weightRegular,
      color: AppTokens.textPrimary,
      decoration: TextDecoration.none,
    );

    final methodStyle = GoogleFonts.poppins(
      fontSize: AppTokens.textSm,
      fontWeight: AppTokens.weightBold,
      color: theme.colorScheme.onSurface,
      decoration: TextDecoration.none,
    );

    final hdrMinH =
        AppTokens.tableHeaderHeight - AppTokens.space2 - AppTokens.space2;
    final rowMinH =
        AppTokens.tableRowHeight - AppTokens.space3 - AppTokens.space2;
    final padH = AppTokens.spaceHalf;
    final padW = AppTokens.space1;

    final nonEmpty =
        groupedLines.where((e) => e.value.isNotEmpty).toList(growable: false);
    if (nonEmpty.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Text(
          'No test lines for this sample.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            color: AppTokens.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    Widget gridCell({
      required Widget child,
      required double width,
      required bool headerRow,
      required bool showRightDivider,
      required double minHeight,
    }) {
      return SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: headerRow ? AppTokens.surfaceSubtle : null,
            border: Border(
              right: showRightDivider ? line : BorderSide.none,
              bottom: line,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padW, vertical: padH),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    Widget textRow(List<String> cells, {required bool header}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cells.length; i++)
            gridCell(
              child: Text(
                cells[i],
                maxLines: header ? 2 : 6,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.left,
                style: header ? hdrStyle : cellStyle,
              ),
              width: colW[i],
              headerRow: header,
              showRightDivider: i < cells.length - 1,
              minHeight: header ? hdrMinH : rowMinH,
            ),
        ],
      );
    }

    final body = <Widget>[
      textRow(_headers, header: true),
      for (final g in nonEmpty) ...[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTokens.surfaceSubtle,
            border: Border(bottom: line),
          ),
          child: SizedBox(
            width: tableMinWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space2,
                vertical: AppTokens.spaceHalf,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'METHOD: ${g.key}',
                  style: methodStyle,
                ),
              ),
            ),
          ),
        ),
        for (final tl in [...g.value]..sort((a, b) => a.lineNo.compareTo(b.lineNo)))
          textRow(_dataCells(tl), header: false),
      ],
    ];

    return SizedBox(
      width: tableMinWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: line,
            top: line,
            right: line,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: body,
        ),
      ),
    );
  }
}

/// Flat read-only grid for Lab Manager Verification inline expansion.
///
/// Columns mirror [LabWorkflowTestLine] (assigned test method shape). Method
/// Master is not wired yet; lines come from listing/detail payloads via
/// `row.testLines`. When a Method Master API exists, consider a small resolver
/// (e.g. `Future<List<LabWorkflowTestLine>> linesForRow(...)` on the listing row)
/// behind DI that delegates to `row.testLines` today and swaps to the join later.
class LabManagerVerificationNestedTable extends StatelessWidget {
  const LabManagerVerificationNestedTable({
    super.key,
    required this.lines,
    this.dense = false,
    this.retestRemarksShowPending = false,
    this.balancedSpread = false,
  });

  final List<LabWorkflowTestLine> lines;

  /// Compact padding and row heights for dialogs / tight layouts.
  final bool dense;

  /// When true (e.g. LMV Test Details popup), Retest Remarks cells show "Pending".
  final bool retestRemarksShowPending;

  /// Wider relative column weights for spacious containers (popup).
  final bool balancedSpread;

  static const int _colCount = 11;

  /// Relative column weights — scales to available width (no horizontal scroll).
  static const List<double> _colFlex = [
    17, 10, 8, 8, 8, 8, 8, 8, 8, 15, 12,
  ];

  /// Broader column weights for wide dialogs (e.g. Test Details popup).
  static const List<double> _colFlexBalanced = [
    20, 14, 9, 9, 9, 9, 9, 9, 10, 18, 14,
  ];

  static const List<String> _headers = [
    'Test Name',
    'Value',
    'Min Value',
    'Max Value',
    'Customer Min',
    'Customer Max',
    'Fluid Min',
    'Fluid Max',
    'Typical',
    'Retest Remarks',
    'Chemist',
  ];

  TextStyle get _hdrStyle => GoogleFonts.poppins(
        fontSize: AppTokens.textXs,
        fontWeight: AppTokens.weightSemibold,
        color: AppTokens.textSecondary,
        letterSpacing: 0.3,
        decoration: TextDecoration.none,
      );

  TextStyle get _cellStyle => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: AppTokens.weightRegular,
        color: AppTokens.textPrimary,
        decoration: TextDecoration.none,
      );

  static String _display(String raw) {
    final t = raw.trim();
    return t.isEmpty ? '—' : t;
  }

  List<String> _cellStrings(LabWorkflowTestLine l) => [
        _display(l.testName),
        _display(l.value),
        _display(l.minValue),
        _display(l.maxValue),
        _display(l.customerMin),
        _display(l.customerMax),
        _display(l.fluidMin),
        _display(l.fluidMax),
        _display(l.typical),
        retestRemarksShowPending ? 'Pending' : _display(l.retestRemarks),
        _display(l.chemistName),
      ];

  Map<int, TableColumnWidth> get _columnWidths => {
        for (var i = 0; i < _colCount; i++)
          i: FlexColumnWidth(
            balancedSpread ? _colFlexBalanced[i] : _colFlex[i],
          ),
      };

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Text(
          'No test lines for this sample.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            color: AppTokens.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    final sorted = [...lines]..sort((a, b) => a.lineNo.compareTo(b.lineNo));

    final headerCellPad = EdgeInsets.symmetric(
      horizontal: AppTokens.space1,
      vertical: AppTokens.space1,
    );

    final dataCellPad = dense
        ? EdgeInsets.symmetric(
            horizontal: AppTokens.space1,
            vertical: balancedSpread ? AppTokens.space1 : 0,
          )
        : EdgeInsets.symmetric(
            horizontal: AppTokens.space1,
            vertical: AppTokens.space1,
          );

    final headerMinH = dense
        ? AppTokens.tableHeaderHeight - AppTokens.space2 - AppTokens.space1
        : AppTokens.tableHeaderHeight - AppTokens.space2;

    final rowMinH = dense
        ? AppTokens.tableRowHeight - AppTokens.space3 - AppTokens.space2
        : AppTokens.tableRowHeight - AppTokens.space3;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: Table(
            border: TableBorder.all(
              color: AppTokens.borderLight,
              width: AppTokens.borderWidthMd,
            ),
            columnWidths: _columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: AppTokens.surfaceSubtle,
                ),
                children: [
                  for (final label in _headers)
                    TableCell(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: headerMinH,
                        ),
                        child: Padding(
                          padding: headerCellPad,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: _hdrStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              for (final l in sorted)
                TableRow(
                  children: [
                    for (final cell in _cellStrings(l))
                      TableCell(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: rowMinH,
                          ),
                          child: Padding(
                            padding: dataCellPad,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                cell,
                                softWrap: true,
                                maxLines: 8,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: _cellStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Nested parameter listing for Lab Verification Chemist (verified vs remaining).
class LabVerificationChemistNestedTable extends StatelessWidget {
  const LabVerificationChemistNestedTable({
    super.key,
    required this.lines,
  });

  final List<LabWorkflowTestLine> lines;

  /// Relative column weights — scales to available width (no horizontal scroll).
  static const List<int> _colFlex = [16, 10, 10, 14, 18];

  TextStyle get _hdr => GoogleFonts.poppins(
        fontSize: AppTokens.textXs,
        fontWeight: AppTokens.weightSemibold,
        color: AppTokens.textSecondary,
        letterSpacing: 0.3,
        decoration: TextDecoration.none,
      );

  TextStyle get _cell => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: AppTokens.weightRegular,
        color: AppTokens.textPrimary,
        decoration: TextDecoration.none,
      );

  Widget _flexRow({
    required List<Widget> cells,
    required bool isHeader,
    required bool hasBottomDivider,
    required BorderSide vLine,
  }) {
    assert(cells.length == _colFlex.length);
    final n = cells.length;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < n; i++)
            Expanded(
              flex: _colFlex[i],
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isHeader ? AppTokens.surfaceSubtle : null,
                  border: Border(
                    right: i < n - 1 ? vLine : BorderSide.none,
                    bottom: hasBottomDivider ? vLine : BorderSide.none,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space1,
                    vertical: AppTokens.space1,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: cells[i],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionBand(String title, BorderSide bottomLine) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.surfaceSubtle,
        border: Border(bottom: bottomLine),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space1,
          vertical: AppTokens.space1,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              fontWeight: AppTokens.weightMedium,
              color: AppTokens.textSecondary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _dataCells(LabWorkflowTestLine l) {
    final statusLabel = l.lineVerified ? 'Verified' : 'Pending';
    final remarks = l.retestRemarks.trim().isEmpty ? '—' : l.retestRemarks;
    final tech = labWorkflowTestLineTechnicalNotes(l);

    return [
      Text(
        l.testName,
        softWrap: true,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: _cell,
      ),
      Text(
        l.value,
        softWrap: true,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: _cell,
      ),
      Text(
        statusLabel,
        softWrap: true,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: GoogleFonts.poppins(
          fontSize: AppTokens.tableCellSize,
          fontWeight: AppTokens.weightMedium,
          color: AppTokens.textPrimary,
          decoration: TextDecoration.none,
        ),
      ),
      Text(
        remarks,
        softWrap: true,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: _cell,
      ),
      Text(
        tech,
        softWrap: true,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: _cell,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Text(
          'No test lines for this sample.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            color: AppTokens.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    final verified = lines.where((e) => e.lineVerified).toList()
      ..sort((a, b) => a.lineNo.compareTo(b.lineNo));
    final remaining = lines.where((e) => !e.lineVerified).toList()
      ..sort((a, b) => a.lineNo.compareTo(b.lineNo));

    final vLine = _nestedGridLine();

    final headerRow = _flexRow(
      cells: [
        Text(
          'PARAMETER / TEST NAME',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: _hdr,
        ),
        Text(
          'TEST RESULT',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: _hdr,
        ),
        Text(
          'VERIFICATION STATUS',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: _hdr,
        ),
        Text(
          'REMARKS',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: _hdr,
        ),
        Text(
          'TECHNICAL NOTES',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: _hdr,
        ),
      ],
      isHeader: true,
      hasBottomDivider: true,
      vLine: vLine,
    );

    final blocks = <Widget>[headerRow];

    void addRows(List<LabWorkflowTestLine> rows, {required bool lastBlock}) {
      for (var i = 0; i < rows.length; i++) {
        final lastRow = lastBlock && i == rows.length - 1;
        blocks.add(
          _flexRow(
            cells: _dataCells(rows[i]),
            isHeader: false,
            hasBottomDivider: !lastRow,
            vLine: vLine,
          ),
        );
      }
    }

    if (verified.isNotEmpty) {
      blocks.add(_sectionBand('Verified tests', vLine));
      addRows(verified, lastBlock: remaining.isEmpty);
    }
    if (remaining.isNotEmpty) {
      blocks.add(_sectionBand('Remaining tests', vLine));
      addRows(remaining, lastBlock: true);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: vLine,
              top: vLine,
              right: vLine,
              bottom: vLine,
            ),
          ),
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: blocks,
            ),
          ),
        );
      },
    );
  }
}
