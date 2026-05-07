import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/sample_master_options.dart';
import '../../data/sample_row_model.dart';
import 'sample_attachment_cell.dart';
import 'sample_data_grid_layout.dart';

typedef SampleFieldCallback = void Function(SampleRowField field, dynamic value);

class SampleDataEntryRow extends StatefulWidget {
  const SampleDataEntryRow({
    super.key,
    required this.row,
    required this.listIndex,
    required this.isActive,
    required this.isLast,
    required this.rowSelected,
    required this.onRowSelected,
    required this.horizontalScrollGroup,
    required this.onActivate,
    required this.onPatch,
    required this.onSaveRow,
    required this.pickDate,
  });

  final SampleRowModel row;
  final int listIndex;
  final bool isActive;
  final bool isLast;
  final bool rowSelected;
  final ValueChanged<bool> onRowSelected;
  final LinkedScrollControllerGroup horizontalScrollGroup;
  final VoidCallback onActivate;
  final SampleFieldCallback onPatch;
  final VoidCallback onSaveRow;
  final Future<DateTime?> Function(DateTime? initial) pickDate;

  @override
  State<SampleDataEntryRow> createState() => _SampleDataEntryRowState();
}

class _SampleDataEntryRowState extends State<SampleDataEntryRow> {
  late final ScrollController _hScroll;

  late final TextEditingController _equipSr;
  late final TextEditingController _equipId;
  late final TextEditingController _site;
  late final TextEditingController _subAsmNo;
  late final TextEditingController _runningHrs;
  late final TextEditingController _subAsmHrs;
  late final TextEditingController _lubeHrs;
  late final TextEditingController _topUp;
  late final TextEditingController _sump;
  late final TextEditingController _qty;
  late final TextEditingController _customerNote;

  @override
  void initState() {
    super.initState();
    _hScroll = widget.horizontalScrollGroup.addAndGet();
    _equipSr = TextEditingController();
    _equipId = TextEditingController();
    _site = TextEditingController();
    _subAsmNo = TextEditingController();
    _runningHrs = TextEditingController();
    _subAsmHrs = TextEditingController();
    _lubeHrs = TextEditingController();
    _topUp = TextEditingController();
    _sump = TextEditingController();
    _qty = TextEditingController();
    _customerNote = TextEditingController();
    _applyControllers();
  }

  @override
  void didUpdateWidget(covariant SampleDataEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.sampleId != widget.row.sampleId ||
        oldWidget.listIndex != widget.listIndex) {
      _applyControllers();
    } else {
      _syncControllersFromRow(widget.row);
    }
  }

  void _applyControllers() {
    final r = widget.row;
    _equipSr.text = r.equipSrNo;
    _equipId.text = r.equipIdNo;
    _site.text = r.siteName;
    _subAsmNo.text = r.subAssemblyNo;
    _runningHrs.text = _numStr(r.runningHrs);
    _subAsmHrs.text = _numStr(r.subAssemblyHrs);
    _lubeHrs.text = _numStr(r.lubeHrs);
    _topUp.text = _numStr(r.topUpVolume);
    _sump.text = _numStr(r.sumpCapacity);
    _qty.text = _numStr(r.qty);
    _customerNote.text = r.customerNote;
  }

  void _syncControllersFromRow(SampleRowModel r) {
    void sync(TextEditingController c, String next) {
      if (c.text != next) c.text = next;
    }

    sync(_equipSr, r.equipSrNo);
    sync(_equipId, r.equipIdNo);
    sync(_site, r.siteName);
    sync(_subAsmNo, r.subAssemblyNo);
    sync(_runningHrs, _numStr(r.runningHrs));
    sync(_subAsmHrs, _numStr(r.subAssemblyHrs));
    sync(_lubeHrs, _numStr(r.lubeHrs));
    sync(_topUp, _numStr(r.topUpVolume));
    sync(_sump, _numStr(r.sumpCapacity));
    sync(_qty, _numStr(r.qty));
    sync(_customerNote, r.customerNote);
  }

  String _numStr(double? n) {
    if (n == null) return '';
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toString();
  }

  double? _parseDouble(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  /// Consistent [NumericFocusOrder] for row-wise Tab traversal (see [SampleDataGridLayout.tableFocusStride]).
  Widget _ordered(int slot, Widget child) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(
        (widget.listIndex * SampleDataGridLayout.tableFocusStride + slot)
            .toDouble(),
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    _hScroll.dispose();
    _equipSr.dispose();
    _equipId.dispose();
    _site.dispose();
    _subAsmNo.dispose();
    _runningHrs.dispose();
    _subAsmHrs.dispose();
    _lubeHrs.dispose();
    _topUp.dispose();
    _sump.dispose();
    _qty.dispose();
    _customerNote.dispose();
    super.dispose();
  }

  TextStyle get _body => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textPrimary,
        decoration: TextDecoration.none,
      );

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAndSet(SampleRowField field, DateTime? current) async {
    final d = await widget.pickDate(current);
    if (d != null && mounted) {
      widget.onPatch(field, d);
    }
  }

  Widget _dateField(DateTime? value, SampleRowField field, int slot) {
    return _ordered(
      slot,
      Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final k = event.logicalKey;
          if (k == LogicalKeyboardKey.enter ||
              k == LogicalKeyboardKey.space) {
            _pickAndSet(field, value);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Material(
          color: AppTokens.transparent,
          child: InkWell(
            onTap: () => _pickAndSet(field, value),
            borderRadius: BorderRadius.circular(AppTokens.inputRadius),
            child: Container(
              height: AppTokens.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppTokens.cardBg,
                borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
              ),
              child: Text(
                _fmtDate(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapCell(int idx, Widget child) {
    final widths = SampleDataGridLayout.scrollColumnWidths;
    final h = SampleDataGridLayout.dataEntryRowHeight;
    final w = widths[idx];
    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: SizedBox(
          width: w,
          height: AppTokens.inputHeight,
          child: child,
        ),
      ),
    );
  }

  Widget _buildActionColumn(Color rowBgColor) {
    return _ordered(
      30,
      Container(
        width: SampleDataGridLayout.actionColumnWidth,
        height: SampleDataGridLayout.dataEntryRowHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: rowBgColor,
          border: Border(
            left: BorderSide(
              color: AppTokens.borderDefault,
              width: AppTokens.borderWidthSm,
            ),
          ),
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
            if (key == 'save') {
              widget.onSaveRow();
            } else if (key == 'select') {
              widget.onActivate();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'select',
              enabled: !widget.isActive,
              child: Row(
                children: [
                  IconTheme(
                    data: IconThemeData(
                      size: AppTokens.textMd,
                      color: AppTokens.neutral700,
                    ),
                    child: const Icon(LucideIcons.pencil),
                  ),
                  SizedBox(width: AppTokens.space2),
                  Text(
                    'Select row',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textSm,
                      fontWeight: AppTokens.weightRegular,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'save',
              child: Row(
                children: [
                  IconTheme(
                    data: IconThemeData(
                      size: AppTokens.textMd,
                      color: AppTokens.neutral700,
                    ),
                    child: const Icon(LucideIcons.save),
                  ),
                  SizedBox(width: AppTokens.space2),
                  Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textSm,
                      fontWeight: AppTokens.weightRegular,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widths = SampleDataGridLayout.scrollColumnWidths;
    final gap = SampleDataGridLayout.interColumnGap;
    final r = widget.row;

    assert(widths.length == 30);

    final rowBgColor = widget.isActive
        ? AppTokens.primary50
        : r.isCompleted
            ? AppTokens.success50
            : AppTokens.cardBg;

    final bottomBorder = widget.isLast
        ? BorderSide.none
        : const BorderSide(
            color: AppTokens.tableRowDivider,
            width: AppTokens.borderWidthSm,
          );

    final modelItems = SampleMasterOptions.modelsForMakeItems(r.make);

    final scrollCells = <Widget>[
      _wrapCell(
        0,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ordered(
              0,
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: widget.rowSelected,
                  onChanged: (v) => widget.onRowSelected(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            Text('${r.index}', style: _body),
            if (r.isCompleted) ...[
              SizedBox(width: AppTokens.space2),
              Icon(
                LucideIcons.circleCheckBig,
                size: AppTokens.iconButtonIconSm,
                color: AppTokens.success500,
              ),
            ],
          ],
        ),
      ),
      _wrapCell(
        1,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(r.sampleId, style: _body),
        ),
      ),
      _wrapCell(
        2,
        _ordered(
          1,
          AppInput(
            controller: _equipSr,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.equipSrNo, v),
          ),
        ),
      ),
      _wrapCell(
        3,
        _ordered(
          2,
          AppInput(
            controller: _equipId,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.equipIdNo, v),
          ),
        ),
      ),
      _wrapCell(
        4,
        _ordered(
          3,
          AppInput(
            controller: _site,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.siteName, v),
          ),
        ),
      ),
      _wrapCell(
        5,
        _ordered(
          4,
          AppSelect<String>(
            hint: '—',
            value: r.make,
            items: SampleMasterOptions.makes,
            onChanged: (v) => widget.onPatch(SampleRowField.make, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        6,
        _ordered(
          5,
          AppSelect<String>(
            hint: '—',
            value: r.model,
            items: modelItems,
            onChanged: (v) => widget.onPatch(SampleRowField.model, v),
            size: AppInputSize.sm,
            enabled: r.make != null && r.make!.isNotEmpty,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        7,
        _ordered(
          6,
          AppSelect<String>(
            hint: '—',
            value: r.typeOfSample,
            items: SampleMasterOptions.typeOfSample,
            onChanged: (v) => widget.onPatch(SampleRowField.typeOfSample, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        8,
        _ordered(
          7,
          AppSelect<String>(
            hint: '—',
            value: r.natureOfSample,
            items: SampleMasterOptions.natureOfSample,
            onChanged: (v) => widget.onPatch(SampleRowField.natureOfSample, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        9,
        _ordered(
          8,
          AppInput(
            controller: _runningHrs,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.runningHrs, _parseDouble(v)),
          ),
        ),
      ),
      _wrapCell(
        10,
        _ordered(
          9,
          AppInput(
            controller: _subAsmNo,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.subAssemblyNo, v),
          ),
        ),
      ),
      _wrapCell(
        11,
        _ordered(
          10,
          AppInput(
            controller: _subAsmHrs,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.subAssemblyHrs, _parseDouble(v)),
          ),
        ),
      ),
      _wrapCell(
        12,
        _dateField(r.samplingDate, SampleRowField.samplingDate, 11),
      ),
      _wrapCell(
        13,
        _ordered(
          12,
          AppSelect<String>(
            hint: '—',
            value: r.brandOfOil,
            items: SampleMasterOptions.brandOfOil,
            onChanged: (v) => widget.onPatch(SampleRowField.brandOfOil, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        14,
        _ordered(
          13,
          AppSelect<String>(
            hint: '—',
            value: r.grade,
            items: SampleMasterOptions.grade,
            onChanged: (v) => widget.onPatch(SampleRowField.grade, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        15,
        _ordered(
          14,
          AppInput(
            controller: _lubeHrs,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.lubeHrs, _parseDouble(v)),
          ),
        ),
      ),
      _wrapCell(
        16,
        _ordered(
          15,
          AppInput(
            controller: _topUp,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.topUpVolume, _parseDouble(v)),
          ),
        ),
      ),
      _wrapCell(
        17,
        _ordered(
          16,
          AppInput(
            controller: _sump,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.sumpCapacity, _parseDouble(v)),
          ),
        ),
      ),
      _wrapCell(
        18,
        _ordered(
          17,
          AppSelect<String>(
            hint: '—',
            value: r.samplingFrom,
            items: SampleMasterOptions.samplingFrom,
            onChanged: (v) => widget.onPatch(SampleRowField.samplingFrom, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        19,
        _dateField(r.reportExpected, SampleRowField.reportExpected, 18),
      ),
      _wrapCell(
        20,
        _ordered(
          19,
          AppInput(
            controller: _qty,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.qty, _parseDouble(v)),
          ),
        ),
      ),
      _wrapCell(
        21,
        _ordered(
          20,
          AppSelect<String>(
            hint: '—',
            value: r.typeOfBottle,
            items: SampleMasterOptions.typeOfBottle,
            onChanged: (v) => widget.onPatch(SampleRowField.typeOfBottle, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        22,
        _ordered(
          21,
          AppSelect<String>(
            hint: '—',
            value: r.problem,
            items: SampleMasterOptions.problem,
            onChanged: (v) => widget.onPatch(SampleRowField.problem, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        23,
        _ordered(
          22,
          AppSelect<String>(
            hint: '—',
            value: r.comments,
            items: SampleMasterOptions.comments,
            onChanged: (v) => widget.onPatch(SampleRowField.comments, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        24,
        _ordered(
          23,
          AppInput(
            controller: _customerNote,
            hint: '—',
            size: AppInputSize.sm,
            maxLines: 1,
            onChanged: (v) => widget.onPatch(SampleRowField.customerNote, v),
          ),
        ),
      ),
      _wrapCell(
        25,
        _ordered(
          24,
          AppSelect<String>(
            hint: '—',
            value: r.severity,
            items: SampleMasterOptions.severity,
            onChanged: (v) => widget.onPatch(SampleRowField.severity, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        26,
        _ordered(
          25,
          AppSelect<String>(
            hint: '—',
            value: r.oilDrained,
            items: SampleMasterOptions.oilDrained,
            onChanged: (v) => widget.onPatch(SampleRowField.oilDrained, v),
            size: AppInputSize.sm,
            isSearchable: false,
            openOverlayWhenFocused: true,
          ),
        ),
      ),
      _wrapCell(
        27,
        _ordered(
          26,
          SampleAttachmentCell(
            filename: r.imageAttachment,
            onPickMock: (f) =>
                widget.onPatch(SampleRowField.imageAttachment, f),
            dense: true,
            prefix: 'img',
          ),
        ),
      ),
      _wrapCell(
        28,
        _ordered(
          27,
          SampleAttachmentCell(
            filename: r.ftrAttachment,
            onPickMock: (f) =>
                widget.onPatch(SampleRowField.ftrAttachment, f),
            dense: true,
            prefix: 'ftr',
          ),
        ),
      ),
      _wrapCell(
        29,
        SizedBox(
          height: AppTokens.inputHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _ordered(
                  28,
                  AppSelect<String>(
                    hint: '—',
                    value: r.invoiceStatus,
                    items: SampleMasterOptions.invoiceStatus,
                    onChanged: (v) =>
                        widget.onPatch(SampleRowField.invoiceStatus, v),
                    size: AppInputSize.sm,
                    isSearchable: false,
                    openOverlayWhenFocused: true,
                  ),
                ),
              ),
              SizedBox(width: AppTokens.space1),
              Tooltip(
                message: 'Attach invoice',
                child: _ordered(
                  29,
                  SizedBox(
                    width: AppTokens.inputHeight,
                    height: AppTokens.inputHeight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: AppTokens.inputHeight,
                        height: AppTokens.inputHeight,
                      ),
                      onPressed: () {
                        final name =
                            'inv-${DateTime.now().millisecondsSinceEpoch}.pdf';
                        widget.onPatch(
                            SampleRowField.invoiceAttachment, name);
                      },
                      icon: Icon(
                        LucideIcons.fileUp,
                        size: AppTokens.iconButtonIconSm,
                        color: AppTokens.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Material(
      color: AppTokens.transparent,
      child: InkWell(
        canRequestFocus: false,
        onTap: widget.isActive ? null : widget.onActivate,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: rowBgColor,
            border: Border(
              left: widget.isActive
                  ? const BorderSide(
                      color: AppTokens.accent500,
                      width: 3,
                    )
                  : BorderSide.none,
              bottom: bottomBorder,
            ),
          ),
          child: SizedBox(
            height: SampleDataGridLayout.dataEntryRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        key: ObjectKey(_hScroll),
                        controller: _hScroll,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        clipBehavior: Clip.hardEdge,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTokens.space2,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                for (var i = 0;
                                    i < scrollCells.length;
                                    i++) ...[
                                  if (i > 0) SizedBox(width: gap),
                                  scrollCells[i],
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildActionColumn(rowBgColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
