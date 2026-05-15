import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../design_system/tokens.dart';
import '../../../shared/activity_timeline_models.dart';

/// Vertical activity list for enquiry detail and quotation screens.
class QuotationActivityTimeline extends StatelessWidget {
  const QuotationActivityTimeline({
    super.key,
    required this.entries,
    this.emptyMessage = 'No activity recorded.',
  });

  final List<ActivityTimelineEntry> entries;

  /// Shown when [entries] is empty (e.g. invoice audit has no records).
  final String emptyMessage;

  String _formatDt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space3),
        child: Text(
          emptyMessage,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.textMuted,
          ),
        ),
      );
    }
    final sorted = List<ActivityTimelineEntry>.from(entries)
      ..sort((a, b) => b.at.compareTo(a.at));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sorted.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppTokens.space2,
                child: Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTokens.primary500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < sorted.length - 1)
                      Container(width: 2, height: 40, color: AppTokens.border),
                  ],
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sorted[i].message,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.tableCellSize,
                        fontWeight: AppTokens.weightMedium,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTokens.spaceHalf),
                    Text(
                      '${sorted[i].actorLabel} · ${_formatDt(sorted[i].at)}',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        color: AppTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (i < sorted.length - 1) SizedBox(height: AppTokens.space2),
        ],
      ],
    );
  }
}
