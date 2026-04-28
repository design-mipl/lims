import 'package:flutter/material.dart';

/// Single source of truth for visual design tokens. Reference only [AppTokens]
/// from UI code—no hardcoded colors, spacing, or sizes.
abstract final class AppTokens {
  const AppTokens._();

  /// Primary UI font (loaded via google_fonts in [AppTheme]).
  static const String fontFamily = 'Poppins';

  // ---------------------------------------------------------------------------
  // Brand — Primary (navy)
  // ---------------------------------------------------------------------------

  static const Color primary900 = Color(0xFF0D1626);
  static const Color primary800 = Color(0xFF1A2744);
  static const Color primary700 = Color(0xFF1F3057);
  static const Color primary600 = Color(0xFF243669);
  static const Color primary500 = Color(0xFF2D4694);
  static const Color primary100 = Color(0xFFD0D5E8);
  static const Color primary50  = Color(0xFFEEF1F8);

  // ---------------------------------------------------------------------------
  // Brand — Accent (red)
  // ---------------------------------------------------------------------------

  static const Color accent600 = Color(0xFFCC2B2B);
  static const Color accent500 = Color(0xFFE53935);
  static const Color accent100 = Color(0xFFF5C4B3);
  static const Color accent50  = Color(0xFFFDF0EE);

  // ---------------------------------------------------------------------------
  // Neutral greys
  // ---------------------------------------------------------------------------

  static const Color neutral900 = Color(0xFF111318);
  static const Color neutral800 = Color(0xFF1E2128);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50  = Color(0xFFF9FAFB);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color success500 = Color(0xFF16A34A);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success50  = Color(0xFFF0FDF4);

  static const Color warning500 = Color(0xFFD97706);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning50  = Color(0xFFFFFBEB);

  static const Color error500 = Color(0xFFDC2626);
  static const Color error100 = Color(0xFFFEE2E2);
  static const Color error50  = Color(0xFFFEF2F2);

  static const Color info500 = Color(0xFF2563EB);
  static const Color info100 = Color(0xFFDBEAFE);
  static const Color info50  = Color(0xFFEFF6FF);

  // ---------------------------------------------------------------------------
  // Surface & background
  // ---------------------------------------------------------------------------

  static const Color white         = Color(0xFFFFFFFF);
  static const Color surfaceCard   = Color(0xFFFFFFFF);
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color pageBg        = Color(0xFFF0F2F5);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  /// App-wide page background (same as [primary50]).
  static const Color background = primary50;

  static const Color filledSecondarySurface = Color(0xFFE8EAF0);

  // ---------------------------------------------------------------------------
  // Border
  // ---------------------------------------------------------------------------

  static const Color border        = neutral200;
  static const Color borderLight   = neutral100;
  static const Color borderDefault = Color(0xFFE2E8F0);
  static const Color borderStrong  = Color(0xFFCBD5E1);
  static const Color borderFocus   = Color(0xFF1A2744);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFF9CA3AF);
  static const Color textDisabled  = Color(0xFFD1D5DB);
  static const Color textOnDark    = Color(0xFFFFFFFF);
  static const Color labelColor    = Color(0xFF374151);
  static const Color hintColor     = Color(0xFF9CA3AF);

  static const Color tableRowDivider = Color(0xFFF1F5F9);

  /// Bottom border for the bulk action bar when rows are selected (warm amber).
  static const Color bulkBarActiveBottomBorder = Color(0xFFFDE68A);

  // ---------------------------------------------------------------------------
  // Listing screen chrome (AppListingScreen)
  // ---------------------------------------------------------------------------

  static const double listingTabBarHeight        = 38.0;
  static const double listingToolbarHeight       = 44.0;
  static const double listingBulkBarHeight       = 36.0;
  static const double listingPaginationHeight    = 38.0;
  static const double listingPaginationDropdownHeight = 24.0;
  static const double listingToolbarSearchWidth  = 220.0;
  static const double listingToolbarSearchHeight = 28.0;
  static const double listingToolbarActionsGap   = 6.0;
  static const double listingPaginationLabelGap  = 6.0;
  static const double listingPaginationRangeGap  = 8.0;
  static const double listingToolbarDotSize      = 7.0;
  static const double bulkBarGreyedOpacity       = 0.35;
  static const double bulkBarMiniCheckSize       = 14.0;
  static const double bulkBarMiniCheckRadius     = 3.0;
  static const double bulkActionButtonHeight     = 24.0;
  static const double bulkActionButtonRadius     = 5.0;
  static const double bulkActionIconSize         = 11.0;
  static const double bulkActionFontSize         = 11.0;
  static const double columnFilterPopoverWidth   = 200.0;
  static const double columnPickerPopoverWidth    = 220.0;
  static const double columnPickerPopoverMaxHeight = 320.0;
  static const double columnFilterSelectRowHeight = 30.0;

  // ---------------------------------------------------------------------------
  // Sidebar
  // ---------------------------------------------------------------------------

  static const Color sidebarBg           = Color(0xFF1A2744);
  static const Color sidebarActiveItem   = Color(0xFFE53935);
  static const Color sidebarInactiveText = Color(0xFFA8B3C7);
  static const Color sidebarActiveText   = Color(0xFFFFFFFF);
  static const Color sidebarSectionLabel = Color(0xFFA8B3C7);
  static const Color sidebarIcon         = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // KPI card accent colors
  // ---------------------------------------------------------------------------

  static const Color kpiBlue   = Color(0xFF2563EB);
  static const Color kpiGreen  = Color(0xFF16A34A);
  static const Color kpiOrange = Color(0xFFD97706);
  static const Color kpiRed    = Color(0xFFDC2626);
  static const Color kpiPurple = Color(0xFF7C3AED);
  static const Color kpiTeal   = Color(0xFF0891B2);

  // ---------------------------------------------------------------------------
  // Focus / interaction
  // ---------------------------------------------------------------------------

  static const Color focusRingColor  = Color(0xFF1A2744);
  static const double focusRingWidth = 1.5;
  static const Color overlayHover    = Color(0x08000000);
  static const Color overlayPressed  = Color(0x14000000);

  // ---------------------------------------------------------------------------
  // Spacing (4 px base)
  // ---------------------------------------------------------------------------

  static const double space0  = 0.0;
  static const double spaceHalf = 2.0;
  static const double space1  = 4.0;
  static const double space2  = 8.0;
  static const double space3  = 12.0;
  static const double space4  = 16.0;
  static const double space5  = 20.0;
  static const double space6  = 24.0;
  static const double space8  = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;

  // ---------------------------------------------------------------------------
  // Border radius
  // ---------------------------------------------------------------------------

  static const double radiusSm   = 4.0;
  static const double radiusMd   = 6.0;
  static const double radiusLg   = 8.0;
  static const double radiusXl   = 12.0;
  static const double radiusFull = 999.0;

  // ---------------------------------------------------------------------------
  // Typography scale
  // ---------------------------------------------------------------------------

  static const double textXs   = 11.0;
  static const double textSm   = 12.0;
  static const double textBase = 13.0;
  static const double textMd   = 14.0;
  static const double textLg   = 16.0;
  static const double textXl   = 18.0;
  static const double text2xl  = 20.0;
  static const double text3xl  = 24.0;

  static const FontWeight weightRegular  = FontWeight.w400;
  static const FontWeight weightMedium   = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold     = FontWeight.w700;

  // --- Typography roles ---

  static const double pageTitleSize         = 18.0;
  static const FontWeight pageTitleWeight   = FontWeight.w600;

  static const double pageSubtitleSize         = 12.0;
  static const FontWeight pageSubtitleWeight   = FontWeight.w400;

  static const double sectionTitleSize         = 12.0;
  static const FontWeight sectionTitleWeight   = FontWeight.w600;

  static const double fieldLabelSize           = 11.0;
  static const FontWeight fieldLabelWeight     = FontWeight.w500;

  static const double bodySize                 = 13.0;
  static const FontWeight bodyWeight           = FontWeight.w400;
  static const double bodySmSize               = 12.0;

  static const double tableCellSize            = 12.0;
  static const double tableHeaderSize          = 11.0;
  static const FontWeight tableHeaderWeight    = FontWeight.w600;

  static const double captionSize              = 11.0;
  static const FontWeight captionWeight        = FontWeight.w400;

  static const double chipSize                 = 11.0;
  static const FontWeight chipWeight           = FontWeight.w500;

  // --- User permissions matrix ---

  static const double permissionMatrixColumnWidth = 60.0;
  static const double permissionPageHeaderHeight = 56.0;
  static const double permissionFooterHeight = 52.0;
  static const double permissionMatrixHeaderFontSize = 10.0;
  static const FontWeight permissionMatrixHeaderWeight = FontWeight.w600;
  static const double permissionCheckboxSize = 18.0;
  static const double permissionCheckboxRadius = 3.0;
  static const double permissionEmptyStateIconSize = 32.0;
  static const double permissionMatrixMinScrollWidth = 520.0;

  // ---------------------------------------------------------------------------
  // Sizing — compact enterprise chrome
  // ---------------------------------------------------------------------------

  static const double topbarHeight    = 48.0;
  static const double sidebarExpanded = 210.0;
  static const double sidebarCollapsed = 56.0;
  static const double navItemHeight   = 34.0;

  static const double inputHeight   = 34.0;
  static const double inputHeightLg = 44.0;
  static const double inputRadius   = 6.0;

  static const double buttonHeightSm = 26.0;
  static const double buttonHeightMd = 30.0;
  static const double buttonHeightLg = 36.0;
  static const double buttonRadius   = 6.0;

  static const double tableRowHeight    = 38.0;
  static const double tableHeaderHeight = 34.0;

  static const double cardRadius       = 8.0;
  static const double drawerWidth      = 560.0;
  static const double formPageMaxWidth = 960.0;

  static const double chipHeight = 20.0;
  static const double chipRadius = 10.0;

  static const double badgeHeight      = 20.0;
  static const double statusChipHeight = 24.0;

  static const double avatarSizeXs = 20.0;
  static const double avatarSizeSm = 24.0;

  // --- Table helpers ---

  static const double tableCheckboxColumnWidth        = 40.0;
  static const double tableActionsColumnWidth         = 72.0;
  static const double tableStatusColumnPreferredWidth = 100.0;
  static const double tableToggleColumnWidth          = 52.0;

  // --- Search / filter widths ---

  static const double listingSearchWidthTablet  = 200.0;
  static const double listingSearchWidthDesktop = 260.0;
  static const double listingFilterPanelWidth   = 280.0;
  static const double topbarSearchWidthTablet   = 180.0;
  static const double topbarSearchWidthDesktop  = 240.0;

  // --- Form layout ---

  static const double formDrawerWidthDesktop  = 560.0;
  static const double formModalMaxWidth       = 600.0;
  static const double formPageContentMaxWidth = 960.0;

  // --- Borders ---

  static const double borderWidthHairline = 0.5;
  static const double borderWidthSm       = 1.0;
  static const double borderWidthMd       = 1.5;

  // --- Icons ---

  static const double iconSizeMd        = 18.0;
  static const double iconButtonIconSm  = 14.0;
  static const double iconButtonIconMd  = 16.0;

  // --- Progress indicators ---

  static const double inlineProgressIndicatorSize        = 14.0;
  static const double inlineProgressIndicatorStrokeWidth = 2.0;

  // --- Misc ---

  static const double disabledOpacity      = 0.5;
  static const double opacityFull          = 1.0;
  static const double luminanceInkThreshold = 0.55;
  static const double elevationPopupMenu   = 4.0;
  static const double overlayPrimaryAlpha  = 0.12;

  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
