import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../sample_intake/ui/widgets/sample_attachment_cell.dart';
import '../data/quotation_model.dart';
import '../state/quotation_provider.dart';

/// Pricing workspace — enquiry strip + editable lines + commercial block.
class QuotationWorkspaceScreen extends StatefulWidget {
  const QuotationWorkspaceScreen({super.key, required this.quoteId});

  final String quoteId;

  @override
  State<QuotationWorkspaceScreen> createState() =>
      _QuotationWorkspaceScreenState();
}

class _QuotationWorkspaceScreenState extends State<QuotationWorkspaceScreen> {
  QuotationProvider? _provider;

  final LinkedScrollControllerGroup _lineHScrollGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _lineHeaderHScroll;
  late final ScrollController _lineBodyHScroll;
  late final ScrollController _lineBottomHScroll;
  late final ScrollController _lineVScroll;

  static const double _lineBulkW = 52;
  static const double _lineCodeW = 120;
  static const double _lineDescW = 260;
  static const double _lineQtyW = 100;
  static const double _lineRateW = 120;
  static const double _lineAmtW = 120;
  static const double _bottomHScrollTrackHeight = 36;

  final _discountCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _internalCtrl = TextEditingController();

  final Map<String, TextEditingController> _qtyCtrls = {};
  final Map<String, TextEditingController> _rateCtrls = {};

  String? _lastSyncedQuoteId;

  @override
  void initState() {
    super.initState();
    _lineHeaderHScroll = _lineHScrollGroup.addAndGet();
    _lineBodyHScroll = _lineHScrollGroup.addAndGet();
    _lineBottomHScroll = _lineHScrollGroup.addAndGet();
    _lineVScroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<QuotationProvider>();
      _provider!.addListener(_onErr);
      await _provider!.loadQuote(widget.quoteId);
      if (!mounted) return;
      setState(() {
        final q = _provider!.active;
        if (q != null) {
          _syncCtrls(q);
        }
      });
    });
  }

  void _onErr() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final m = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || m == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: AppTokens.error500),
      );
      pr.clearError();
    });
  }

  void _disposeLineCtrls() {
    for (final c in _qtyCtrls.values) {
      c.dispose();
    }
    for (final c in _rateCtrls.values) {
      c.dispose();
    }
    _qtyCtrls.clear();
    _rateCtrls.clear();
  }

  void _syncCtrls(QuotationRecord? q) {
    if (q == null) return;
    if (_lastSyncedQuoteId != q.id) {
      _disposeLineCtrls();
      _lastSyncedQuoteId = q.id;
    }
    _discountCtrl.text = q.discountAmount.toStringAsFixed(2);
    _gstCtrl.text = q.gstPercent.toStringAsFixed(1);
    _termsCtrl.text = q.terms;
    _notesCtrl.text = q.notes;
    _internalCtrl.text = q.internalComments;
    for (final line in q.lines) {
      _qtyCtrls.putIfAbsent(
        line.id,
        () => TextEditingController(text: '${line.qty}'),
      );
      _rateCtrls.putIfAbsent(
        line.id,
        () => TextEditingController(text: '${line.rate}'),
      );
      _qtyCtrls[line.id]!.text = '${line.qty}';
      _rateCtrls[line.id]!.text = '${line.rate}';
    }
  }

  void _applyCommercialPatch(QuotationProvider p) {
    final q = p.active;
    if (q == null) return;
    final disc = double.tryParse(_discountCtrl.text.trim()) ?? q.discountAmount;
    final gst = double.tryParse(_gstCtrl.text.trim()) ?? q.gstPercent;
    p.setCommercial(
      quoteId: q.id,
      discountAmount: disc,
      gstPercent: gst,
      terms: _termsCtrl.text,
      notes: _notesCtrl.text,
      internalComments: _internalCtrl.text,
    );
  }

  void _flushLineEdits(QuotationProvider p) {
    final q = p.active;
    if (q == null) return;
    for (final line in q.lines) {
      final qi = int.tryParse(_qtyCtrls[line.id]?.text.trim() ?? '');
      final rr = double.tryParse(_rateCtrls[line.id]?.text.trim() ?? '');
      if (qi != null && rr != null && (qi != line.qty || rr != line.rate)) {
        p.replaceLine(
          q.id,
          line.copyWith(qty: qi, rate: rr),
        );
      }
    }
  }

  /// Live totals from controllers without requiring persist.
  QuotationRecord _preview(QuotationRecord q) {
    final lines = <QuotationPricingLine>[
      for (final line in q.lines)
        line.copyWith(
          qty: int.tryParse(_qtyCtrls[line.id]?.text.trim() ?? '') ?? line.qty,
          rate:
              double.tryParse(_rateCtrls[line.id]?.text.trim() ?? '') ??
                  line.rate,
        ),
    ];
    final disc =
        double.tryParse(_discountCtrl.text.trim()) ?? q.discountAmount;
    final gst = double.tryParse(_gstCtrl.text.trim()) ?? q.gstPercent;
    return q.copyWith(
      lines: lines,
      discountAmount: disc,
      gstPercent: gst,
    );
  }

  @override
  void dispose() {
    _provider?.removeListener(_onErr);
    _lineHeaderHScroll.dispose();
    _lineBodyHScroll.dispose();
    _lineBottomHScroll.dispose();
    _lineVScroll.dispose();
    _disposeLineCtrls();
    _discountCtrl.dispose();
    _gstCtrl.dispose();
    _termsCtrl.dispose();
    _notesCtrl.dispose();
    _internalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuotationProvider>();
    final q = p.active;
    if (p.isLoading && q == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (q == null) {
      return Center(
        child: Text(
          'Quotation not found',
          style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
        ),
      );
    }

    final pv = _preview(q);

    return AppFormPage(
      title: 'Quotation workspace',
      subtitle: '${q.quoteNo} · ${q.enquiryNo}',
      scrollBody: false,
      fullWidthBody: true,
      onBack: () => context.go('/transactions/quotation/pending'),
      cancelLabel: 'Cancel',
      onCancel: () => context.go('/transactions/quotation/pending'),
      saveAndContinueLabel: 'Save draft',
      onSaveAndContinue: () async {
        _flushLineEdits(p);
        _applyCommercialPatch(p);
        await p.persistActive();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved')),
        );
      },
      primaryLabel: 'Send to sales review',
      onPrimary: () async {
        _flushLineEdits(p);
        _applyCommercialPatch(p);
        await p.persistActive();
        await p.sendToSalesReview(q.id);
        if (!context.mounted) return;
        context.go('/transactions/quotation/pending');
      },
      isPrimaryLoading: p.isLoading,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppTokens.border),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: _compactSummaryStrip(q),
          ),
          SizedBox(height: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildPricingLinesCard(q, pv, p),
                ),
                SizedBox(height: AppTokens.space3),
                Expanded(
                  flex: 2,
                  child: AppScrollView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(bottom: AppTokens.space4),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 272,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _totalRow('Subtotal', pv.subtotal),
                                  _totalRow('Discount', pv.discountAmount),
                                  _totalRow(
                                    'GST (${pv.gstPercent.toStringAsFixed(1)}%)',
                                    pv.gstAmount,
                                  ),
                                  Divider(height: AppTokens.space4),
                                  _totalRow(
                                    'Grand total',
                                    pv.grandTotal,
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: AppTokens.space4),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth > 880;
                              final row = [
                                AppInput(
                                  label: 'Discount (flat)',
                                  controller: _discountCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (_) {
                                    _applyCommercialPatch(p);
                                    setState(() {});
                                  },
                                ),
                                AppInput(
                                  label: 'GST %',
                                  controller: _gstCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (_) {
                                    _applyCommercialPatch(p);
                                    setState(() {});
                                  },
                                ),
                              ];
                              if (wide) {
                                return Row(
                                  children: [
                                    Expanded(child: row[0]),
                                    SizedBox(width: AppTokens.space4),
                                    Expanded(child: row[1]),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  row[0],
                                  SizedBox(height: AppTokens.space4),
                                  row[1],
                                ],
                              );
                            },
                          ),
                          SizedBox(height: AppTokens.space4),
                          AppInput(
                            label: 'Terms & conditions',
                            controller: _termsCtrl,
                            maxLines: 2,
                            onChanged: (_) => _applyCommercialPatch(p),
                          ),
                          SizedBox(height: AppTokens.space4),
                          AppInput(
                            label: 'Customer notes',
                            controller: _notesCtrl,
                            maxLines: 2,
                            onChanged: (_) => _applyCommercialPatch(p),
                          ),
                          SizedBox(height: AppTokens.space4),
                          AppInput(
                            label: 'Internal comments',
                            controller: _internalCtrl,
                            maxLines: 2,
                            onChanged: (_) => _applyCommercialPatch(p),
                          ),
                          SizedBox(height: AppTokens.space4),
                          Text(
                            'Attachments',
                            style: GoogleFonts.poppins(
                              fontWeight: AppTokens.weightSemibold,
                            ),
                          ),
                          SizedBox(height: AppTokens.space2),
                          SampleAttachmentCell(
                            filename: q.attachmentNames.isEmpty
                                ? null
                                : q.attachmentNames.first,
                            dense: false,
                            prefix: 'quote',
                            onPickMock: (name) {
                              _applyCommercialPatch(p);
                              p.setCommercial(
                                quoteId: q.id,
                                attachmentNames: name == null
                                    ? <String>[]
                                    : <String>[name],
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactSummaryStrip(QuotationRecord q) {
    Widget pair(String label, String value) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(width: AppTokens.space2),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.tableCellSize,
                  fontWeight: AppTokens.weightMedium,
                  color: AppTokens.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      child: Wrap(
        spacing: AppTokens.space4,
        runSpacing: AppTokens.space2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          pair('Customer', q.customerName),
          pair('Site', q.siteName),
          pair('Sample type', q.typeOfSample),
          pair('Enquiry', q.enquiryNo),
        ],
      ),
    );
  }

  Widget _bottomLineHScrollBar(double contentW) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space1),
      child: SizedBox(
        height: _bottomHScrollTrackHeight,
        child: LayoutBuilder(
          builder: (context, c) {
            return AppScrollbar(
              controller: _lineBottomHScroll,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _lineBottomHScroll,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: math.max(c.maxWidth, contentW),
                  height: _bottomHScrollTrackHeight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPricingLinesCard(
    QuotationRecord q,
    QuotationRecord pv,
    QuotationProvider p,
  ) {
    final contentW = _lineBulkW +
        _lineCodeW +
        _lineDescW +
        _lineQtyW +
        _lineRateW +
        _lineAmtW;
    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_lineBulkW),
      1: FixedColumnWidth(_lineCodeW),
      2: FixedColumnWidth(_lineDescW),
      3: FixedColumnWidth(_lineQtyW),
      4: FixedColumnWidth(_lineRateW),
      5: FixedColumnWidth(_lineAmtW),
    };

    final headerStyle = GoogleFonts.poppins(
      fontSize: AppTokens.captionSize,
      fontWeight: AppTokens.weightSemibold,
      color: AppTokens.textMuted,
    );

    Widget headerCell(String label, {bool numeric = false}) {
      return SizedBox(
        height: AppTokens.tableHeaderHeight,
        child: Align(
          alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
            child: Text(label, style: headerStyle),
          ),
        ),
      );
    }

    final header = DecoratedBox(
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
        height: AppTokens.tableHeaderHeight,
        child: LayoutBuilder(
          builder: (context, c) {
            return SingleChildScrollView(
              controller: _lineHeaderHScroll,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: c.maxWidth),
                child: SizedBox(
                  width: math.max(c.maxWidth, contentW),
                  height: AppTokens.tableHeaderHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: _lineBulkW,
                        child: Center(child: Text('Bulk', style: headerStyle)),
                      ),
                      SizedBox(width: _lineCodeW, child: headerCell('Code')),
                      SizedBox(
                        width: _lineDescW,
                        child: headerCell('Description'),
                      ),
                      SizedBox(
                        width: _lineQtyW,
                        child: headerCell('Qty', numeric: true),
                      ),
                      SizedBox(
                        width: _lineRateW,
                        child: headerCell('Rate', numeric: true),
                      ),
                      SizedBox(
                        width: _lineAmtW,
                        child: headerCell('Amount', numeric: true),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    Widget lineAmount(QuotationPricingLine line) {
      final priced = pv.lines.firstWhere(
        (l) => l.id == line.id,
        orElse: () => line,
      );
      return Text(
        priced.amount.toStringAsFixed(2),
        style: GoogleFonts.poppins(
          fontSize: AppTokens.tableCellSize,
          fontWeight: AppTokens.weightMedium,
        ),
      );
    }

    final body = q.lines.isEmpty
        ? Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Text(
                'No pricing lines.',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.tableCellSize,
                  color: AppTokens.textMuted,
                ),
              ),
            ),
          )
        : AppScrollbar(
            controller: _lineVScroll,
            child: SingleChildScrollView(
              controller: _lineVScroll,
              child: SingleChildScrollView(
                controller: _lineBodyHScroll,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: contentW,
                  child: Table(
                    defaultVerticalAlignment:
                        TableCellVerticalAlignment.middle,
                    columnWidths: columnWidths,
                    children: [
                      for (final line in q.lines)
                        TableRow(
                          children: [
                            SizedBox(
                              height: AppTokens.tableRowHeight,
                              child: Center(
                                child: Checkbox(
                                  value: line.selected,
                                  onChanged: (v) => p.toggleLineSelected(
                                    q.id,
                                    line.id,
                                    v ?? false,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(AppTokens.space2),
                              child: Text(
                                line.testCode,
                                style: GoogleFonts.poppins(
                                  fontSize: AppTokens.tableCellSize,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(AppTokens.space2),
                              child: Text(
                                line.description,
                                style: GoogleFonts.poppins(
                                  fontSize: AppTokens.tableCellSize,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(AppTokens.space2),
                              child: AppInput(
                                controller: _qtyCtrls.putIfAbsent(
                                  line.id,
                                  () => TextEditingController(
                                    text: '${line.qty}',
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(AppTokens.space2),
                              child: AppInput(
                                controller: _rateCtrls.putIfAbsent(
                                  line.id,
                                  () => TextEditingController(
                                    text: '${line.rate}',
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(AppTokens.space2),
                              child: SizedBox(
                                width: _lineAmtW,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: lineAmount(line),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppShiftWheelHorizontalScroll(
        controller: _lineBodyHScroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(child: body),
            if (q.lines.isNotEmpty) _bottomLineHScrollBar(contentW),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: bold ? AppTokens.weightSemibold : AppTokens.weightRegular,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: bold ? AppTokens.weightSemibold : AppTokens.weightRegular,
            ),
          ),
        ],
      ),
    );
  }
}
