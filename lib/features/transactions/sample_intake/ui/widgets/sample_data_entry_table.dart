import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/tokens.dart';
import '../../data/sample_row_model.dart';
import '../../state/sample_intake_provider.dart';
import 'sample_data_entry_row.dart';
import 'sample_data_grid_layout.dart';

/// Horizontal + vertical scrolling sample data grid.
class SampleDataEntryTable extends StatefulWidget {
  const SampleDataEntryTable({super.key});

  @override
  State<SampleDataEntryTable> createState() => _SampleDataEntryTableState();
}

class _SampleDataEntryTableState extends State<SampleDataEntryTable> {
  late final ScrollController _hCtrl;
  late final ScrollController _vCtrl;

  @override
  void initState() {
    super.initState();
    _hCtrl = ScrollController();
    _vCtrl = ScrollController();
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    int listIndex,
    SampleRowField field,
  ) async {
    final row = context.read<SampleIntakeProvider>().sampleRows[listIndex];
    final initial = field == SampleRowField.samplingDate
        ? row.samplingDate ?? DateTime.now()
        : row.reportExpected ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && context.mounted) {
      context
          .read<SampleIntakeProvider>()
          .updateRowField(listIndex, field, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();
    final labels = SampleDataGridLayout.columnLabels;
    final widths = SampleDataGridLayout.columnWidths;
    final columnsRunW = SampleDataGridLayout.columnsRunWidth;
    final totalW = SampleDataGridLayout.totalWidth;

    Widget headerCell(int i) {
      return SizedBox(
        width: widths[i],
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space2),
          child: Text(
            labels[i],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableHeaderSize,
              fontWeight: AppTokens.tableHeaderWeight,
              color: AppTokens.textSecondary,
            ),
          ),
        ),
      );
    }

    final headerRow = SizedBox(
      width: totalW,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: columnsRunW,
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: AppTokens.surfaceSubtle),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) SizedBox(width: AppTokens.space2),
                  headerCell(i),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final bodyRows = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        SizedBox(height: AppTokens.space2),
        ...List<Widget>.generate(p.sampleRows.length, (listIndex) {
          final row = p.sampleRows[listIndex];
          final isActive = p.activeRowIndex == listIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space2),
            child: SampleDataEntryRow(
              key: ValueKey<String>('${row.sampleId}_$listIndex'),
              row: row,
              listIndex: listIndex,
              isActive: isActive,
              onActivate: () => p.setActiveRow(listIndex),
              onPatch: (field, value) =>
                  p.updateRowField(listIndex, field, value),
              onSaveRow: () => p.saveRow(listIndex),
              onPickDate: (field) =>
                  _pickDate(context, listIndex, field),
            ),
          );
        }),
      ],
    );

    return Expanded(
      child: Scrollbar(
        controller: _hCtrl,
        thumbVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: _hCtrl,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalW,
            child: Scrollbar(
              controller: _vCtrl,
              thumbVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: _vCtrl,
                child: bodyRows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
