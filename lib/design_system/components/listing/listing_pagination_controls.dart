import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import '../primitives/app_icon_button.dart';

/// Layout variant for [ListingPaginationControls].
enum ListingPaginationPlacement {
  /// Full-width footer row with spacer before range/arrows.
  footer,

  /// Compact horizontal strip for embedding in the listing toolbar row.
  toolbar,
}

/// Rows-per-page dropdown, range label, and prev/next controls shared by the
/// listing footer and optional toolbar placement.
class ListingPaginationControls extends StatelessWidget {
  const ListingPaginationControls({
    super.key,
    required this.placement,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final ListingPaginationPlacement placement;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final start = totalCount == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final end = totalCount == 0
        ? 0
        : (currentPage * pageSize).clamp(0, totalCount);
    final canPrev = currentPage > 1;
    final lastPage = totalCount == 0 ? 1 : ((totalCount - 1) ~/ pageSize) + 1;
    final canNext = totalCount > 0 && currentPage < lastPage;
    final resolvedSize = pageSizeOptions.contains(pageSize)
        ? pageSize
        : pageSizeOptions.first;

    final dropdown = PopupMenuButton<int>(
      initialValue: resolvedSize,
      onSelected: onPageSizeChanged,
      itemBuilder: (context) => pageSizeOptions
          .map(
            (n) => PopupMenuItem<int>(
              value: n,
              height: AppTokens.space8,
              child: Text(
                n.toString(),
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textSm,
                  color: AppTokens.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: AppTokens.listingPaginationDropdownHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space2,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          color: AppTokens.cardBg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              resolvedSize.toString(),
              style: GoogleFonts.poppins(
                fontSize: AppTokens.textXs,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(width: AppTokens.space1),
            Icon(
              LucideIcons.chevronDown,
              size: AppTokens.textXs,
              color: AppTokens.textMuted,
            ),
          ],
        ),
      ),
    );

    final rowsPerPage = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rows per page:',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            fontWeight: AppTokens.weightRegular,
            color: AppTokens.textSecondary,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(width: AppTokens.listingPaginationLabelGap),
        dropdown,
      ],
    );

    final rangeNav = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$start–$end of $totalCount',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            fontWeight: AppTokens.weightRegular,
            color: AppTokens.textSecondary,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(width: AppTokens.listingPaginationRangeGap),
        AppIconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: canPrev ? () => onPageChanged(currentPage - 1) : null,
          variant: AppIconButtonVariant.outlined,
          size: AppIconButtonSize.sm,
          tooltip: 'Previous page',
        ),
        AppIconButton(
          icon: const Icon(LucideIcons.chevronRight),
          onPressed: canNext ? () => onPageChanged(currentPage + 1) : null,
          variant: AppIconButtonVariant.outlined,
          size: AppIconButtonSize.sm,
          tooltip: 'Next page',
        ),
      ],
    );

    switch (placement) {
      case ListingPaginationPlacement.footer:
        return Row(
          children: [
            rowsPerPage,
            const Spacer(),
            rangeNav,
          ],
        );
      case ListingPaginationPlacement.toolbar:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            rowsPerPage,
            SizedBox(width: AppTokens.space3),
            rangeNav,
          ],
        );
    }
  }
}
