import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import 'module_history_models.dart';

/// Compact operational activity list (read-only).
class ModuleHistoryTimeline extends StatelessWidget {
  const ModuleHistoryTimeline({
    super.key,
    required this.entries,
  });

  final List<ModuleHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Text(
          'No activity recorded.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.tableCellSize,
            color: AppTokens.textMuted,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: AppTokens.borderWidthSm,
              color: AppTokens.borderDefault,
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.space1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppTokens.space3,
                  child: Column(
                    children: [
                      Container(
                        width: AppTokens.space2,
                        height: AppTokens.space2,
                        decoration: const BoxDecoration(
                          color: AppTokens.primary500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i < entries.length - 1)
                        Container(
                          width: AppTokens.borderWidthSm,
                          height: AppTokens.space4,
                          color: AppTokens.borderDefault,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: AppTokens.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              entries[i].actionPerformed,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                                fontWeight: AppTokens.weightSemibold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                          ),
                          if (entries[i].statusBadgeKey != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppTokens.space2,
                              ),
                              child: StatusChip(
                                status: entries[i].statusBadgeKey!,
                                customLabel: entries[i].statusBadgeLabel,
                              ),
                            ),
                        ],
                      ),
                      if (entries[i].oldValue != null ||
                          entries[i].newValue != null)
                        Padding(
                          padding: EdgeInsets.only(top: AppTokens.spaceHalf),
                          child: Text(
                            '${entries[i].oldValue ?? '—'} → ${entries[i].newValue ?? '—'}',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.captionSize,
                              color: AppTokens.textSecondary,
                              height: 1.25,
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(top: AppTokens.spaceHalf),
                        child: Text(
                          '${entries[i].actorLabel} · ${ModuleHistoryFormat.dateTimeLine(entries[i].at)}',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.captionSize,
                            color: AppTokens.textMuted,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (entries[i].remarks != null &&
                          entries[i].remarks!.trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: AppTokens.spaceHalf),
                          child: Text(
                            entries[i].remarks!.trim(),
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.captionSize,
                              color: AppTokens.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
