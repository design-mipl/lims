import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../design_system/tokens.dart';
import '../../data/order_form_model.dart';

/// Read-only sample/test lines grid for the order confirmation form.
class OrderSampleLinesTable extends StatelessWidget {
  const OrderSampleLinesTable({super.key, required this.lines});

  final List<OrderSampleLine> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space3),
        child: Text(
          'Select a quotation to load sample and test lines.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.textMuted,
          ),
        ),
      );
    }

    final headerStyle = GoogleFonts.poppins(
      fontSize: AppTokens.captionSize,
      fontWeight: AppTokens.weightSemibold,
      color: AppTokens.textMuted,
    );
    final cellStyle = GoogleFonts.poppins(
      fontSize: AppTokens.textSm,
      color: AppTokens.textPrimary,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppTokens.borderDefault),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(0.7),
            2: FlexColumnWidth(1.35),
            3: FlexColumnWidth(0.85),
            4: FlexColumnWidth(1.0),
            5: FlexColumnWidth(0.75),
            6: FlexColumnWidth(0.75),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppTokens.neutral50),
              children: [
                _headerCell('Type of Sample', headerStyle),
                _headerCell('Sample Count', headerStyle),
                _headerCell('Test Name', headerStyle),
                _headerCell('Priority', headerStyle),
                _headerCell('Expected Timeline', headerStyle),
                _headerCell('Rate', headerStyle, align: TextAlign.right),
                _headerCell('Amount', headerStyle, align: TextAlign.right),
              ],
            ),
            for (var i = 0; i < lines.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  border: i < lines.length - 1
                      ? const Border(
                          bottom: BorderSide(color: AppTokens.borderDefault),
                        )
                      : null,
                ),
                children: [
                  _dataCell(lines[i].typeOfSample, cellStyle),
                  _dataCell('${lines[i].sampleCount}', cellStyle),
                  _dataCell(lines[i].testName, cellStyle),
                  _dataCell(lines[i].priority, cellStyle),
                  _dataCell(lines[i].expectedTimeline, cellStyle),
                  _dataCell(
                    lines[i].rate.toStringAsFixed(2),
                    cellStyle,
                    align: TextAlign.right,
                  ),
                  _dataCell(
                    lines[i].amount.toStringAsFixed(2),
                    cellStyle,
                    align: TextAlign.right,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static Widget _headerCell(
    String label,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space2,
      ),
      child: Text(label, style: style, textAlign: align),
    );
  }

  static Widget _dataCell(
    String value,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space2,
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        style: style,
        textAlign: align,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
