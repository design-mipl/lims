import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/sample_master_options.dart';
import '../../data/sample_row_model.dart';
import '../../state/sample_intake_provider.dart';
import 'sample_attachment_cell.dart';
import 'sample_data_grid_layout.dart';

typedef SampleFieldCallback = void Function(SampleRowField field, dynamic value);

class SampleDataEntryRow extends StatefulWidget {
  const SampleDataEntryRow({
    super.key,
    required this.row,
    required this.listIndex,
    required this.isActive,
    required this.onActivate,
    required this.onPatch,
    required this.onSaveRow,
    required this.onPickDate,
  });

  final SampleRowModel row;
  final int listIndex;
  final bool isActive;
  final VoidCallback onActivate;
  final SampleFieldCallback onPatch;
  final VoidCallback onSaveRow;
  final Future<void> Function(SampleRowField field) onPickDate;

  @override
  State<SampleDataEntryRow> createState() => _SampleDataEntryRowState();
}

class _SampleDataEntryRowState extends State<SampleDataEntryRow> {
  late final TextEditingController _equipSr;
  late final TextEditingController _equipId;
  late final TextEditingController _site;
  late final TextEditingController _running;
  late final TextEditingController _subAsmHrs;
  late final TextEditingController _lube;
  late final TextEditingController _topUp;
  late final TextEditingController _sump;
  late final TextEditingController _qty;
  late final TextEditingController _customerNote;

  @override
  void initState() {
    super.initState();
    _equipSr = TextEditingController();
    _equipId = TextEditingController();
    _site = TextEditingController();
    _running = TextEditingController();
    _subAsmHrs = TextEditingController();
    _lube = TextEditingController();
    _topUp = TextEditingController();
    _sump = TextEditingController();
    _qty = TextEditingController();
    _customerNote = TextEditingController();
    _applyControllers();
  }

  @override
  void didUpdateWidget(covariant SampleDataEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.sampleId != widget.row.sampleId) {
      _applyControllers();
    } else if (!widget.isActive) {
      _applyControllers();
    }
  }

  void _applyControllers() {
    final r = widget.row;
    _equipSr.text = r.equipSrNo;
    _equipId.text = r.equipIdNo;
    _site.text = r.siteName;
    _running.text = r.runningHrs?.toString() ?? '';
    _subAsmHrs.text = r.subAssemblyHrs?.toString() ?? '';
    _lube.text = r.lubeHrs?.toString() ?? '';
    _topUp.text = r.topUpVolume?.toString() ?? '';
    _sump.text = r.sumpCapacity?.toString() ?? '';
    _qty.text = r.qty?.toString() ?? '';
    _customerNote.text = r.customerNote;
  }

  double? _parseNum(String v) =>
      v.trim().isEmpty ? null : double.tryParse(v.trim());

  @override
  void dispose() {
    _equipSr.dispose();
    _equipId.dispose();
    _site.dispose();
    _running.dispose();
    _subAsmHrs.dispose();
    _lube.dispose();
    _topUp.dispose();
    _sump.dispose();
    _qty.dispose();
    _customerNote.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  TextStyle get _muted => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textMuted,
      );

  TextStyle get _body => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textPrimary,
      );

  Widget _spacing() => SizedBox(width: AppTokens.space2);

  Widget _inactiveText(String text) {
    return Text(
      text.isEmpty ? '—' : text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: text.isEmpty ? _muted : _body,
    );
  }

  String? _ddlLabel(List<AppSelectItem<String>> items, String? value) {
    if (value == null) return null;
    for (final e in items) {
      if (e.value == value) return e.label;
    }
    return value;
  }

  Widget _inactiveSelect(List<AppSelectItem<String>> items, String? value) {
    return _inactiveText(_ddlLabel(items, value) ?? '');
  }

  Widget _dateCellActive(DateTime? current, SampleRowField field) {
    return InkWell(
      onTap: () => widget.onPickDate(field),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space2,
        ),
        decoration: BoxDecoration(
          color: AppTokens.cardBg,
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          border: Border.all(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(_dateLabel(current), style: _body)),
            Icon(
              LucideIcons.calendar,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widths = SampleDataGridLayout.columnWidths;
    final r = widget.row;
    final modelItems =
        context.read<SampleIntakeProvider>().getModelsForMake(r.make ?? '');

    assert(widths.length == 31);

    final rowBgColor = widget.isActive
        ? AppTokens.primary50
        : widget.row.isCompleted
            ? AppTokens.success50
            : AppTokens.transparent;

    final rowRadius = BorderRadius.circular(AppTokens.radiusSm);
    final stripeWidth = widget.isActive
        ? AppTokens.borderWidthMd
        : AppTokens.borderWidthSm;
    final stripeColor =
        widget.isActive ? AppTokens.accent500 : AppTokens.borderDefault;

    Widget wrapCell(int idx, Widget child) {
      return SizedBox(
        width: widths[idx],
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
          child: child,
        ),
      );
    }

    Widget indexCell() {
      return wrapCell(
        0,
        Row(
          children: [
            Text('${r.index}', style: _body),
            if (widget.row.isCompleted) ...[
              SizedBox(width: AppTokens.space2),
              Icon(
                LucideIcons.circleCheckBig,
                size: AppTokens.iconButtonIconSm,
                color: AppTokens.success500,
              ),
            ],
          ],
        ),
      );
    }

    List<Widget> cells;

    if (widget.isActive) {
      cells = [
        indexCell(),
        wrapCell(
          1,
          Padding(
            padding: EdgeInsets.only(top: AppTokens.space2),
            child: Text(r.sampleId, style: _body),
          ),
        ),
        wrapCell(
          2,
          AppInput(
            controller: _equipSr,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.equipSrNo, v),
          ),
        ),
        wrapCell(
          3,
          AppInput(
            controller: _equipId,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.equipIdNo, v),
          ),
        ),
        wrapCell(
          4,
          AppInput(
            controller: _site,
            hint: '—',
            size: AppInputSize.sm,
            onChanged: (v) => widget.onPatch(SampleRowField.siteName, v),
          ),
        ),
        wrapCell(
          5,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.makes,
            value: r.make,
            isSearchable: false,
            countLabel: 'makes',
            onChanged: (v) => widget.onPatch(SampleRowField.make, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          6,
          AppSelect<String>(
            key: ValueKey<String>('model-${r.sampleId}-${r.make ?? ""}'),
            hint: '',
            items: modelItems,
            value: r.model,
            isSearchable: false,
            countLabel: 'models',
            onChanged: (v) => widget.onPatch(SampleRowField.model, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          7,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.typeOfSample,
            value: r.typeOfSample,
            isSearchable: false,
            onChanged: (v) =>
                widget.onPatch(SampleRowField.typeOfSample, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          8,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.natureOfSample,
            value: r.natureOfSample,
            isSearchable: false,
            onChanged: (v) =>
                widget.onPatch(SampleRowField.natureOfSample, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          9,
          AppInput(
            controller: _running,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.runningHrs, _parseNum(v)),
          ),
        ),
        wrapCell(
          10,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.subAssembly,
            value: r.subAssemblyNo.isEmpty ? null : r.subAssemblyNo,
            isSearchable: false,
            onChanged: (v) =>
                widget.onPatch(SampleRowField.subAssemblyNo, v ?? ''),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          11,
          AppInput(
            controller: _subAsmHrs,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')),
            ],
            onChanged: (v) => widget.onPatch(
              SampleRowField.subAssemblyHrs,
              _parseNum(v),
            ),
          ),
        ),
        wrapCell(
          12,
          _dateCellActive(r.samplingDate, SampleRowField.samplingDate),
        ),
        wrapCell(
          13,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.brandOfOil,
            value: r.brandOfOil,
            isSearchable: false,
            onChanged: (v) => widget.onPatch(SampleRowField.brandOfOil, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          14,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.grade,
            value: r.grade,
            isSearchable: false,
            onChanged: (v) => widget.onPatch(SampleRowField.grade, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          15,
          AppInput(
            controller: _lube,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.lubeHrs, _parseNum(v)),
          ),
        ),
        wrapCell(
          16,
          AppInput(
            controller: _topUp,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.topUpVolume, _parseNum(v)),
          ),
        ),
        wrapCell(
          17,
          AppInput(
            controller: _sump,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')),
            ],
            onChanged: (v) =>
                widget.onPatch(SampleRowField.sumpCapacity, _parseNum(v)),
          ),
        ),
        wrapCell(
          18,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.samplingFrom,
            value: r.samplingFrom,
            isSearchable: false,
            onChanged: (v) =>
                widget.onPatch(SampleRowField.samplingFrom, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          19,
          _dateCellActive(r.reportExpected, SampleRowField.reportExpected),
        ),
        wrapCell(
          20,
          AppInput(
            controller: _qty,
            hint: '—',
            size: AppInputSize.sm,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')),
            ],
            onChanged: (v) => widget.onPatch(SampleRowField.qty, _parseNum(v)),
          ),
        ),
        wrapCell(
          21,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.typeOfBottle,
            value: r.typeOfBottle,
            isSearchable: false,
            onChanged: (v) =>
                widget.onPatch(SampleRowField.typeOfBottle, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          22,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.problem,
            value: r.problem,
            isSearchable: false,
            onChanged: (v) => widget.onPatch(SampleRowField.problem, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          23,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.comments,
            value: r.comments,
            isSearchable: false,
            onChanged: (v) => widget.onPatch(SampleRowField.comments, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          24,
          AppTextarea(
            controller: _customerNote,
            hint: '—',
            minLines: 1,
            maxLines: 4,
            onChanged: (v) =>
                widget.onPatch(SampleRowField.customerNote, v),
          ),
        ),
        wrapCell(
          25,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.severity,
            value: r.severity,
            isSearchable: false,
            onChanged: (v) => widget.onPatch(SampleRowField.severity, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          26,
          AppSelect<String>(
            hint: '',
            items: SampleMasterOptions.oilDrained,
            value: r.oilDrained,
            isSearchable: false,
            onChanged: (v) => widget.onPatch(SampleRowField.oilDrained, v),
            size: AppInputSize.sm,
          ),
        ),
        wrapCell(
          27,
          SampleAttachmentCell(
            filename: r.imageAttachment,
            dense: true,
            prefix: 'img',
            onPickMock: (v) =>
                widget.onPatch(SampleRowField.imageAttachment, v),
          ),
        ),
        wrapCell(
          28,
          SampleAttachmentCell(
            filename: r.ftrAttachment,
            dense: true,
            prefix: 'ftr',
            onPickMock: (v) =>
                widget.onPatch(SampleRowField.ftrAttachment, v),
          ),
        ),
        wrapCell(
          29,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSelect<String>(
                hint: '',
                items: SampleMasterOptions.invoiceStatus,
                value: r.invoiceStatus,
                isSearchable: false,
                onChanged: (v) =>
                    widget.onPatch(SampleRowField.invoiceStatus, v),
                size: AppInputSize.sm,
              ),
              SizedBox(height: AppTokens.space2),
              SampleAttachmentCell(
                filename: r.invoiceAttachment,
                dense: true,
                prefix: 'inv',
                onPickMock: (v) =>
                    widget.onPatch(SampleRowField.invoiceAttachment, v),
              ),
            ],
          ),
        ),
        wrapCell(
          30,
          AppButton(
            label: 'Save',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.primary,
            onPressed: widget.onSaveRow,
          ),
        ),
      ];
    } else {
      cells = [
        indexCell(),
        wrapCell(
          1,
          Padding(
            padding: EdgeInsets.only(top: AppTokens.space2),
            child: _inactiveText(r.sampleId),
          ),
        ),
        wrapCell(2, _inactiveText(r.equipSrNo)),
        wrapCell(3, _inactiveText(r.equipIdNo)),
        wrapCell(4, _inactiveText(r.siteName)),
        wrapCell(
          5,
          _inactiveSelect(SampleMasterOptions.makes, r.make),
        ),
        wrapCell(6, _inactiveText(r.model ?? '')),
        wrapCell(
          7,
          _inactiveSelect(
            SampleMasterOptions.typeOfSample,
            r.typeOfSample,
          ),
        ),
        wrapCell(
          8,
          _inactiveSelect(
            SampleMasterOptions.natureOfSample,
            r.natureOfSample,
          ),
        ),
        wrapCell(
          9,
          _inactiveText(r.runningHrs?.toString() ?? ''),
        ),
        wrapCell(
          10,
          _inactiveSelect(
            SampleMasterOptions.subAssembly,
            r.subAssemblyNo.isEmpty ? null : r.subAssemblyNo,
          ),
        ),
        wrapCell(
          11,
          _inactiveText(r.subAssemblyHrs?.toString() ?? ''),
        ),
        wrapCell(12, _inactiveText(_dateLabel(r.samplingDate))),
        wrapCell(
          13,
          _inactiveSelect(
            SampleMasterOptions.brandOfOil,
            r.brandOfOil,
          ),
        ),
        wrapCell(14, _inactiveSelect(SampleMasterOptions.grade, r.grade)),
        wrapCell(15, _inactiveText(r.lubeHrs?.toString() ?? '')),
        wrapCell(16, _inactiveText(r.topUpVolume?.toString() ?? '')),
        wrapCell(17, _inactiveText(r.sumpCapacity?.toString() ?? '')),
        wrapCell(
          18,
          _inactiveSelect(
            SampleMasterOptions.samplingFrom,
            r.samplingFrom,
          ),
        ),
        wrapCell(
          19,
          _inactiveText(_dateLabel(r.reportExpected)),
        ),
        wrapCell(20, _inactiveText(r.qty?.toString() ?? '')),
        wrapCell(
          21,
          _inactiveSelect(
            SampleMasterOptions.typeOfBottle,
            r.typeOfBottle,
          ),
        ),
        wrapCell(
          22,
          _inactiveSelect(SampleMasterOptions.problem, r.problem),
        ),
        wrapCell(
          23,
          _inactiveSelect(SampleMasterOptions.comments, r.comments),
        ),
        wrapCell(24, _inactiveText(r.customerNote)),
        wrapCell(
          25,
          _inactiveSelect(SampleMasterOptions.severity, r.severity),
        ),
        wrapCell(
          26,
          _inactiveSelect(SampleMasterOptions.oilDrained, r.oilDrained),
        ),
        wrapCell(27, _inactiveText(r.imageAttachment ?? '')),
        wrapCell(28, _inactiveText(r.ftrAttachment ?? '')),
        wrapCell(
          29,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _inactiveSelect(
                SampleMasterOptions.invoiceStatus,
                r.invoiceStatus,
              ),
              SizedBox(height: AppTokens.space1),
              _inactiveText(r.invoiceAttachment ?? ''),
            ],
          ),
        ),
        wrapCell(30, const SizedBox.shrink()),
      ];
    }

    assert(cells.length == 31);

    final rowCells = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) _spacing(),
          cells[i],
        ],
      ],
    );

    return Material(
      color: AppTokens.transparent,
      child: InkWell(
        borderRadius: rowRadius,
        onTap: widget.isActive ? null : widget.onActivate,
        child: ClipRRect(
          borderRadius: rowRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: rowBgColor,
              border: Border.all(
                color: AppTokens.tableRowDivider,
                width: AppTokens.borderWidthSm,
              ),
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: stripeWidth,
                  child: ColoredBox(color: stripeColor),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: stripeWidth + AppTokens.space2,
                    end: AppTokens.space2,
                  ),
                  child: rowCells,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
