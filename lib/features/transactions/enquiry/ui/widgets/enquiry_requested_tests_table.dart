import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../design_system/tokens.dart';
import '../../data/enquiry_model.dart';

/// Compact read-only requested-tests grid for enquiry view sections.
class EnquiryRequestedTestsTable extends StatelessWidget {
  const EnquiryRequestedTestsTable({super.key, required this.tests});

  final List<EnquiryRequestedTestRow> tests;

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Text(
          'No requested tests added.',
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
            0: FixedColumnWidth(44),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1.4),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(color: AppTokens.neutral50),
              children: [
                _headerCell('Sel', headerStyle),
                _headerCell('Code', headerStyle),
                _headerCell('Test', headerStyle),
                _headerCell('Priority', headerStyle),
                _headerCell('Remarks', headerStyle),
              ],
            ),
            for (var i = 0; i < tests.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  border: i < tests.length - 1
                      ? Border(
                          bottom: BorderSide(color: AppTokens.borderDefault),
                        )
                      : null,
                ),
                children: [
                  _bodyCell(tests[i].selected ? 'Yes' : '—', cellStyle),
                  _bodyCell(tests[i].testCode, cellStyle),
                  _bodyCell(tests[i].testName, cellStyle),
                  _bodyCell(tests[i].priority, cellStyle),
                  _bodyCell(
                    tests[i].remarks.isEmpty ? '—' : tests[i].remarks,
                    cellStyle,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, TextStyle style) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space2,
      ),
      child: Text(text, style: style),
    );
  }

  Widget _bodyCell(String text, TextStyle style) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space2,
      ),
      child: Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
