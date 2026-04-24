import 'package:flutter/material.dart';

/// Single source of truth for visual design tokens. Reference only [AppTokens]
/// from UI code—no hardcoded colors, spacing, or sizes.
///
/// Grouping follows: primary / accent / neutral / semantic / surface colors,
/// spacing, radius, typography, sizing, shadows (see section comments).
abstract final class AppTokens {
  const AppTokens._();

  // --- Primary brand (navy) ---

  /// Darkest navy; high-contrast headers and chrome.
  static const Color primary900 = Color(0xFF0D1626);

  /// Main brand navy; primary fills and key UI accents.
  static const Color primary800 = Color(0xFF1A2744);

  /// Interactive hover / pressed states on navy controls.
  static const Color primary700 = Color(0xFF1F3057);

  /// Secondary navy surfaces and emphasis blocks.
  static const Color primary600 = Color(0xFF253972);

  /// Lighter navy for borders and tertiary emphasis on dark UI.
  static const Color primary500 = Color(0xFF2D4694);

  /// Soft navy tint for selected rows and subtle highlights.
  static const Color primary100 = Color(0xFFD0D5E8);

  /// Lightest navy tint; default app page background.
  static const Color primary50 = Color(0xFFEEF1F8);

  // --- Accent (red: active nav, danger, CTA) ---

  /// Dark accent red; pressed states and strong danger emphasis.
  static const Color accent600 = Color(0xFFCC2B2B);

  /// Primary accent red; CTAs, active navigation, error emphasis (brighter red).
  static const Color accent500 = Color(0xFFE53935);

  /// Light accent wash for badges and soft warnings.
  static const Color accent100 = Color(0xFFF5C4B3);

  /// Subtle accent background for alerts and hover chips.
  static const Color accent50 = Color(0xFFFDF0EE);

  // --- Neutral greys ---

  /// Near-black; primary text on light surfaces.
  static const Color neutral900 = Color(0xFF111318);

  /// Dark grey; secondary text and icons.
  static const Color neutral800 = Color(0xFF1E2128);

  /// Tertiary text and de-emphasized labels.
  static const Color neutral700 = Color(0xFF374151);

  /// Muted body copy and table metadata.
  static const Color neutral600 = Color(0xFF4B5563);

  /// Placeholder text and disabled icons.
  static const Color neutral500 = Color(0xFF6B7280);

  /// Borders on dark surfaces and dividers.
  static const Color neutral400 = Color(0xFF9CA3AF);

  /// Default input borders and hairline dividers.
  static const Color neutral300 = Color(0xFFD1D5DB);

  /// Table grid lines and card outlines.
  static const Color neutral200 = Color(0xFFE5E7EB);

  /// Subtle panel backgrounds and zebra striping.
  static const Color neutral100 = Color(0xFFF3F4F6);

  /// Near-white canvas for nested cards.
  static const Color neutral50 = Color(0xFFF9FAFB);

  // --- Semantic ---

  /// Success text and solid success indicators.
  static const Color success500 = Color(0xFF16A34A);

  /// Success background for banners and toasts.
  static const Color success100 = Color(0xFFDCFCE7);

  /// Subtle success wash for inline validation pass states.
  static const Color success50 = Color(0xFFF0FDF4);

  /// Warning text and icons for cautionary states.
  static const Color warning500 = Color(0xFFD97706);

  /// Warning background chips and inline alerts.
  static const Color warning100 = Color(0xFFFEF3C7);

  /// Soft warning tint for form field hints.
  static const Color warning50 = Color(0xFFFFFBEB);

  /// Error text and destructive action emphasis.
  static const Color error500 = Color(0xFFDC2626);

  /// Error field backgrounds and validation banners.
  static const Color error100 = Color(0xFFFEE2E2);

  /// Subtle error wash for invalid rows.
  static const Color error50 = Color(0xFFFEF2F2);

  /// Informational links and info banners.
  static const Color info500 = Color(0xFF2563EB);

  /// Info callout backgrounds.
  static const Color info100 = Color(0xFFDBEAFE);

  /// Subtle info tint for tooltips and hints.
  static const Color info50 = Color(0xFFEFF6FF);

  // --- Surface ---

  /// Pure white; cards and modals on tinted backgrounds.
  static const Color white = Color(0xFFFFFFFF);

  /// Default card and panel surface on the page background.
  static const Color surfaceCard = Color(0xFFFFFFFF);

  /// App-wide page background (same as [primary50]).
  static const Color background = primary50;

  /// Standard border color for inputs and tables (same as [neutral200]).
  static const Color border = neutral200;

  /// Hairline borders and separators (same as [neutral100]).
  static const Color borderLight = neutral100;

  /// Muted fill for secondary [FilledButton] backgrounds (light theme).
  static const Color filledSecondarySurface = Color(0xFFE8EAF0);

  // --- Sidebar ---

  /// Sidebar panel background (matches [primary800]).
  static const Color sidebarBg = Color(0xFF1A2744);

  /// Active nav item background (solid accent fill).
  static const Color sidebarActiveItem = Color(0xFFE53935);

  // Active parent section = sidebarActiveItem.withOpacity(0.40)
  // Do NOT create a separate token for this —
  // use sidebarActiveItem.withOpacity(0.40) directly in the widget.

  /// Inactive nav item text.
  static const Color sidebarInactiveText = Color(0xFFA8B3C7);

  /// Active nav item text.
  static const Color sidebarActiveText = Color(0xFFFFFFFF);

  /// Section label (e.g. CORE, ENTITIES).
  static const Color sidebarSectionLabel = Color(0xFFA8B3C7);

  // All icons white regardless of active/inactive state
  /// All nav icons in the sidebar rail.
  static const Color sidebarIcon = Color(0xFFFFFFFF);

  // --- Spacing (4px base) ---

  /// Tight inline padding and dense icon gaps.
  static const double space1 = 4.0;

  /// Compact padding inside chips and small controls.
  static const double space2 = 8.0;

  /// Default gap between related inline elements.
  static const double space3 = 12.0;

  /// Standard section padding and list item vertical inset.
  static const double space4 = 16.0;

  /// Comfortable spacing between form groups.
  static const double space5 = 20.0;

  /// Section breaks and card internal padding.
  static const double space6 = 24.0;

  /// Large section spacing and empty-state margins.
  static const double space8 = 32.0;

  /// Major layout gutters on wide screens.
  static const double space10 = 40.0;

  /// Hero spacing and page-level vertical rhythm.
  static const double space12 = 48.0;

  // --- Border radius ---

  /// Small controls and table cells.
  static const double radiusSm = 4.0;

  /// Default inputs and dropdown tiles.
  static const double radiusMd = 6.0;

  /// Cards and dialogs.
  static const double radiusLg = 8.0;

  /// Large panels and marketing tiles.
  static const double radiusXl = 12.0;

  /// Circular avatars and pill-shaped tags.
  static const double radiusFull = 999.0;

  // --- Typography (sizes & weights; family in ThemeData) ---

  /// Caption and table footer labels.
  static const double textXs = 11.0;

  /// Secondary meta text and compact tables.
  static const double textSm = 12.0;

  /// Default body copy for dense enterprise UI.
  static const double textBase = 13.0;

  /// Emphasized body and list titles.
  static const double textMd = 14.0;

  /// Section headings inside cards.
  static const double textLg = 16.0;

  /// Page subheaders and dialog titles.
  static const double textXl = 18.0;

  /// Major section titles.
  static const double text2xl = 20.0;

  /// Display / hero headings.
  static const double text3xl = 24.0;

  /// Default paragraph weight.
  static const FontWeight weightRegular = FontWeight.w400;

  /// Subheadings and emphasized labels.
  static const FontWeight weightMedium = FontWeight.w500;

  /// Titles, table headers, and primary actions.
  static const FontWeight weightSemibold = FontWeight.w600;

  // --- Sizing (compact enterprise chrome) ---

  /// Compact icon-only or inline buttons.
  static const double buttonHeightSm = 28.0;

  /// Default toolbar and form buttons.
  static const double buttonHeightMd = 32.0;

  /// Primary CTAs and prominent actions.
  static const double buttonHeightLg = 40.0;

  /// Single-line text fields and selects.
  static const double inputHeight = 36.0;

  /// Data grid and list row hit target.
  static const double tableRowHeight = 40.0;

  /// Listing toolbar search field width (tablet).
  static const double listingSearchWidthTablet = 200.0;

  /// Listing toolbar search field width (desktop).
  static const double listingSearchWidthDesktop = 260.0;

  /// Desktop filter drawer width beside the listing table.
  static const double listingFilterPanelWidth = 280.0;

  /// Checkbox column width in listing tables.
  static const double tableCheckboxColumnWidth = 40.0;

  /// Row actions column width in listing tables.
  static const double tableActionsColumnWidth = 80.0;

  /// Toggle column width in listing tables.
  static const double tableToggleColumnWidth = 52.0;

  /// Application top bar / header strip.
  static const double topbarHeight = 48.0;

  /// Topbar search field width (tablet).
  static const double topbarSearchWidthTablet = 180.0;

  /// Topbar search field width (desktop).
  static const double topbarSearchWidthDesktop = 240.0;

  /// Sidebar width when labels are visible.
  static const double sidebarExpanded = 210.0;

  /// Sidebar rail width when collapsed to icons only.
  static const double sidebarCollapsed = 56.0;

  /// Vertical nav item height in the sidebar.
  static const double navItemHeight = 34.0;

  /// Zero spacing (dividers, collapsed leading width).
  static const double space0 = 0.0;

  /// Hairline stroke for cards, inputs, and dividers.
  static const double borderWidthHairline = 0.5;

  /// Standard stroke for outlines and errors.
  static const double borderWidthSm = 1.0;

  /// Strong focus ring stroke on inputs.
  static const double borderWidthMd = 1.5;

  /// Default inline icon size (app bars, dense lists).
  static const double iconSizeMd = 18.0;

  /// Dense icon-only control glyph (matches small icon button spec).
  static const double iconButtonIconSm = 14.0;

  /// Default icon-only control glyph.
  static const double iconButtonIconMd = 16.0;

  /// Inline button / field loading indicator square size.
  static const double inlineProgressIndicatorSize = 14.0;

  /// Stroke for inline [CircularProgressIndicator] on compact controls.
  static const double inlineProgressIndicatorStrokeWidth = 2.0;

  /// Large single-line text field height.
  static const double inputHeightLg = 44.0;

  /// Pill badge minimum height.
  static const double badgeHeight = 20.0;

  /// Extra-small avatar diameter.
  static const double avatarSizeXs = 20.0;

  /// Small avatar diameter.
  static const double avatarSizeSm = 24.0;

  /// Opacity applied to disabled interactive controls.
  static const double disabledOpacity = 0.5;

  /// Full opacity for enabled controls.
  static const double opacityFull = 1.0;

  /// Status chip row height (more prominent than [badgeHeight]).
  static const double statusChipHeight = 24.0;

  /// Luminance boundary for choosing dark vs light ink on fills.
  static const double luminanceInkThreshold = 0.55;

  /// Material elevation for popup menus.
  static const double elevationPopupMenu = 4.0;

  /// Primary overlay alpha for pressed/hovered elevated buttons.
  static const double overlayPrimaryAlpha = 0.12;

  // Focus / Keyboard navigation

  /// Focus ring stroke width for keyboard-focused controls.
  static const double focusRingWidth = 2.0;

  /// Focus ring color (matches [accent500]).
  static const Color focusRingColor = Color(0xFFE53935);

  // --- Shadows (neutral900 base, opacity in ARGB) ---

  /// Subtle lift for cards at rest; 1px blur, ~6% neutral900.
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0F111318),
      offset: Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  /// Medium depth for menus and popovers; 4px blur, ~8% neutral900.
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14111318),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Strong elevation for modals; 8px blur, ~10% neutral900.
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A111318),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
