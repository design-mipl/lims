import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/enquiry_model.dart';

/// Compact read-only sample-requirements grid (create form listing + detail view).
class EnquirySampleRequirementsTable extends StatelessWidget {
  const EnquirySampleRequirementsTable({
    super.key,
    required this.rows,
    this.onDelete,
    this.showDelete = false,
  });

  final List<EnquirySampleRequirementRow> rows;
  final ValueChanged<int>? onDelete;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space3),
        child: Text(
          'No tests added',
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
          columnWidths: showDelete
              ? const {
                  0: FlexColumnWidth(1.35),
                  1: FlexColumnWidth(0.75),
                  2: FlexColumnWidth(1.1),
                  3: FlexColumnWidth(0.9),
                  4: FlexColumnWidth(1.2),
                  5: FixedColumnWidth(52),
                }
              : const {
                  0: FlexColumnWidth(1.35),
                  1: FlexColumnWidth(0.75),
                  2: FlexColumnWidth(1.1),
                  3: FlexColumnWidth(0.9),
                  4: FlexColumnWidth(1.2),
                },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppTokens.neutral50),
              children: [
                _headerCell('Type of Sample', headerStyle),
                _headerCell('Sample Count', headerStyle),
                _headerCell('Expected Timeline', headerStyle),
                _headerCell('Priority', headerStyle),
                _headerCell('Remarks', headerStyle),
                if (showDelete)
                  _headerCell('Action', headerStyle, center: true),
              ],
            ),
            for (var i = 0; i < rows.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  border: i < rows.length - 1
                      ? const Border(
                          bottom: BorderSide(color: AppTokens.borderDefault),
                        )
                      : null,
                ),
                children: [
                  _bodyCell(rows[i].typeOfSample, cellStyle),
                  _bodyCell('${rows[i].sampleCount}', cellStyle),
                  _bodyCell(
                    rows[i].expectedTimeline.isEmpty
                        ? '—'
                        : rows[i].expectedTimeline,
                    cellStyle,
                  ),
                  _bodyCell(rows[i].priority, cellStyle),
                  _bodyCell(
                    rows[i].remarks.isEmpty ? '—' : rows[i].remarks,
                    cellStyle,
                  ),
                  if (showDelete)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTokens.space1 + 2,
                        vertical: AppTokens.space1,
                      ),
                      child: Center(
                        child: AppIconButton(
                          tooltip: 'Delete row',
                          icon: Icon(
                            LucideIcons.trash2,
                            color: AppTokens.error500,
                          ),
                          variant: AppIconButtonVariant.outlined,
                          size: AppIconButtonSize.sm,
                          onPressed: onDelete == null
                              ? null
                              : () => onDelete!(i),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(
    String text,
    TextStyle style, {
    bool center = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space1 + 2,
      ),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(text, style: style),
      ),
    );
  }

  Widget _bodyCell(String text, TextStyle style) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: AppTokens.space1 + 2,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: style,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
