import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:limsv1/design_system/tokens.dart';

/// Two-line table cell: user name + formatted date (audit columns).
class AuditCell extends StatelessWidget {
  const AuditCell({super.key, this.name, this.date});

  final String? name;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    if (name == null && date == null) {
      return Text(
        '—',
        style: GoogleFonts.poppins(
          fontSize: AppTokens.tableCellSize,
          color: AppTokens.textMuted,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name ?? '—',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.tableCellSize,
            fontWeight: FontWeight.w500,
            color: AppTokens.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (date != null)
          Text(
            _formatDate(date!),
            style: GoogleFonts.poppins(
              fontSize: AppTokens.captionSize,
              color: AppTokens.textMuted,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
