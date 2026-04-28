━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLUTTER_CLAUDE.md — COMPLETE CONTENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# FLUTTER_CLAUDE.md
# Ultra LIMS — Flutter Development Rules
# Version 2.0 — April 2026
# Read this file before touching ANY file.

---

## 1. PROJECT OVERVIEW

App: Ultra LIMS — Laboratory Information
     Management System
Framework: Flutter 3.x, Dart 3.x
Material: Material 3 (useMaterial3: true)
State: Provider + GetIt
Router: GoRouter with ShellRoute
Font: Poppins (google_fonts)
Icons: lucide_flutter
HTTP: Dio (ApiClient)

---

## 2. ABSOLUTE RULES
## Break these = broken app

### 2.1 No hardcoded values EVER
❌ Color(0xFF1A2744)     → ✅ AppTokens.primary800
❌ Color(0xFFE53935)     → ✅ AppTokens.accent500
❌ Colors.blue           → ✅ AppTokens.kpiBlue
❌ EdgeInsets.all(16)    → ✅ EdgeInsets.all(AppTokens.space4)
❌ SizedBox(height: 48)  → ✅ SizedBox(height: AppTokens.topbarHeight)
❌ FontWeight.w600       → ✅ AppTokens.pageTitleWeight
❌ fontSize: 18          → ✅ AppTokens.pageTitleSize
❌ TextStyle(...)        → ✅ GoogleFonts.poppins(...)

### 2.2 No raw Flutter widgets in feature code
❌ DropdownButtonFormField → ✅ AppSelect<T>
❌ DropdownButton          → ✅ AppSelect<T>
❌ TextField               → ✅ AppInput or AppTextarea
❌ TextFormField           → ✅ AppInput
❌ Switch                  → ✅ AppToggleSwitch
❌ ElevatedButton          → ✅ AppButton(variant: primary)
❌ TextButton              → ✅ AppButton(variant: tertiary)
❌ OutlinedButton          → ✅ AppButton(variant: secondary)

Exception: PopupMenuButton is allowed
for rows-per-page in pagination only.

### 2.3 No colorScheme for text or surfaces
❌ Theme.of(context).colorScheme.primary
❌ Theme.of(context).textTheme.bodyLarge
✅ AppTokens.textPrimary
✅ GoogleFonts.poppins(fontSize: AppTokens.bodySize)

### 2.4 Screens inside ShellRoute
❌ Scaffold inside ShellRoute
❌ AppBar inside ShellRoute
✅ Return content widget directly from build()
✅ Wrap root in Material(type: MaterialType.transparency)

### 2.5 No setState for server data
❌ setState(() => _items = response.data)
✅ All async state in Provider (extends BaseProvider)
✅ Services and APIs registered in GetIt (sl)
❌ Never inject UI providers into GetIt

### 2.6 Import only from barrel
✅ import 'package:limsv1/design_system/components/components.dart'
❌ import 'package:limsv1/design_system/components/primitives/app_button.dart'

**Exception (until barrel is extended):** `KpiCard` / `KpiMetricTile` live in
`lib/design_system/components/display/kpi_metric.dart` and are **not** exported
from `components.dart` yet. Screens that need KPI types may import
`package:limsv1/design_system/components/display/kpi_metric.dart` until that
export is added to the barrel.

---

## 3. DESIGN TOKENS

Single source of truth: lib/design_system/tokens.dart
All values are static const on AppTokens class.

### 3.1 Brand Colors
primary800 = #1A2744  ← main navy, sidebar, primary button
primary700 = #1F3057  ← hover on navy
primary600 = #243669
primary100 = #D0D5E8
primary50  = #EEF1F8  ← lightest navy tint

accent500  = #E53935  ← active nav, danger, focus
accent600  = #CC2B2B  ← danger hover
accent100  = #F5C4B3

### 3.2 Surface Colors
pageBg        = #F0F2F5  ← page background
cardBg        = #FFFFFF  ← card/container background
surfaceSubtle = #F8FAFC  ← table header, bulk bar empty

### 3.3 Border Colors
borderDefault = #E2E8F0  ← all input/card borders
borderStrong  = #CBD5E1
borderFocus   = #1A2744  ← focused input border

### 3.4 Text Colors
textPrimary   = #111827  ← body text, values
textSecondary = #6B7280  ← subtitles, muted labels
textMuted     = #9CA3AF  ← hints, placeholders
textDisabled  = #D1D5DB
textOnDark    = #FFFFFF
labelColor    = #374151  ← field labels
hintColor     = #9CA3AF  ← input placeholders

### 3.5 Semantic Colors
success500 = #16A34A, success100 = #DCFCE7
warning500 = #D97706, warning100 = #FEF3C7
error500   = #DC2626, error100   = #FEE2E2
info500    = #2563EB, info100    = #DBEAFE

### 3.6 KPI Accent Colors
kpiBlue   = #2563EB
kpiGreen  = #16A34A
kpiOrange = #D97706
kpiRed    = #DC2626
kpiPurple = #7C3AED
kpiTeal   = #0891B2

### 3.7 Sidebar Colors
sidebarBg           = #1A2744
sidebarActiveItem   = #E53935
sidebarInactiveText = #A8B3C7
sidebarActiveText   = #FFFFFF
sidebarSectionLabel = #A8B3C7
sidebarIcon         = #FFFFFF

### 3.8 Sizing — Compact Enterprise Scale
topbarHeight     = 48px
sidebarExpanded  = 210px
sidebarCollapsed = 56px
navItemHeight    = 34px

inputHeight      = 34px
inputRadius      = 6px
buttonHeightSm   = 26px
buttonHeightMd   = 30px
buttonHeightLg   = 36px
buttonRadius     = 6px

tableRowHeight         = 38px
tableHeaderHeight      = 34px
tableActionsColumnWidth = 72px

cardRadius    = 8px
drawerWidth   = 560px
formPageMaxWidth = 960px
chipHeight    = 20px
chipRadius    = 10px

### 3.9 Spacing Scale
space1=4, space2=8, space3=12, space4=16,
space5=20, space6=24, space8=32, space10=40

### 3.10 Typography Scale
pageTitleSize=18, pageTitleWeight=w600
pageSubtitleSize=12, pageSubtitleWeight=w400
sectionTitleSize=12, sectionTitleWeight=w600
fieldLabelSize=11, fieldLabelWeight=w500
bodySize=13, bodyWeight=w400
bodySmSize=12
tableCellSize=12, tableHeaderSize=11
tableHeaderWeight=w600
captionSize=11, captionWeight=w400
chipSize=11, chipWeight=w500

---

## 4. TYPOGRAPHY

RULE: Always use GoogleFonts.poppins() explicitly.
Never inherit from Theme.textTheme in feature code.

### Usage by context:
Page title:
  GoogleFonts.poppins(
    fontSize: AppTokens.pageTitleSize,
    fontWeight: AppTokens.pageTitleWeight,
    color: AppTokens.textPrimary,
    decoration: TextDecoration.none)

Page subtitle:
  GoogleFonts.poppins(
    fontSize: AppTokens.pageSubtitleSize,
    fontWeight: AppTokens.pageSubtitleWeight,
    color: AppTokens.textSecondary,
    decoration: TextDecoration.none)

Section title:
  GoogleFonts.poppins(
    fontSize: AppTokens.sectionTitleSize,
    fontWeight: AppTokens.sectionTitleWeight,
    color: AppTokens.textPrimary)

Field label (above input):
  GoogleFonts.poppins(
    fontSize: AppTokens.fieldLabelSize,
    fontWeight: AppTokens.fieldLabelWeight,
    color: AppTokens.labelColor)

Table header:
  GoogleFonts.poppins(
    fontSize: AppTokens.tableHeaderSize,
    fontWeight: AppTokens.tableHeaderWeight,
    color: AppTokens.textSecondary,
    letterSpacing: 0.3)
  + .toUpperCase() on string

Table cell:
  GoogleFonts.poppins(
    fontSize: AppTokens.tableCellSize,
    fontWeight: FontWeight.w400,
    color: AppTokens.textPrimary)

CRITICAL: decoration: TextDecoration.none
MUST be set on title and subtitle text
to prevent inherited underline from
button ancestors.

---

## 5. COMPONENT LIBRARY

Import everything from:
lib/design_system/components/components.dart

### 5.1 Input Components

AppInput — single line text input
  Required props: label, hint
  Optional: controller, onChanged, validator,
            isRequired, errorText, enabled,
            obscureText, prefixIcon, suffixIcon,
            maxLines, keyboardType, size
  Implementation: SizedBox(height) +
    isCollapsed:true + Positioned icon overlay
  NEVER use: expands, isDense, prefixIcon
    inside InputDecoration for icons
  Icon rendering: Stack + Positioned(left:10)
    for prefix, Positioned(right:10) for suffix
  All sizes use same pattern — obscureText
    fields get same height as normal fields

AppTextarea — multiline text input
  Same label/border style as AppInput
  NO fixed height — auto expands
  minLines: 3 default, maxLines: 6 default
  contentPadding: horizontal 10, vertical 8

AppSelect<T> — anchored overlay dropdown
  NEVER use DropdownButtonFormField
  NEVER use showDialog or showModalBottomSheet
  Opens as OverlayEntry anchored BELOW field
  Trigger: GestureDetector + Container
    visually identical to AppInput
  Dropdown: white bg, border, 8px radius,
    shadowMd, max 240px, scrollable
  Search: shown when items.length > 5
  Items: 32px height, 10px padding
  Selected: primary50 bg, primary800 text

### 5.2 Button Components

AppButton — 4 variants, 3 sizes
  Variants:
    primary   — navy filled, white text
    secondary — surfaceSubtle + border
    tertiary  — transparent ghost
    danger    — error100 bg, error500 text/border
    outlined  — alias for secondary (compat)
  Sizes: sm(26px) md(30px) lg(36px)
  Implementation: InkWell + AnimatedContainer
    NOT ElevatedButton/TextButton
  Loading: CircularProgressIndicator 14px
  Disabled: borderDefault bg, textMuted text

AppIconButton — same variants and sizes
  Square, icon only, tooltip required
  Lives in app_icon_button.dart

### 5.3 Toggle Components

AppSegmentedControl — binary/multi choice
  Auto-width: IntrinsicWidth wrapper
  Height: 28px ALWAYS
  NOT full-width — fits content only
  Selected: primary800 bg, white text
  Unselected: transparent, textSecondary
  Icons: 11px only
  Animation: 150ms
  Use for: Status field in forms (Active/Inactive)
  Wrap in AppFormFullWidth for form sections

AppToggleSwitch — on/off switch
  Flutter Switch scaled 0.8
  activeColor: primary800
  activeTrackColor: primary100
  Shows label text right of switch
  Use for: flags, settings,
           Show in Navigation,
           Permission Enabled

### 5.4 Display Components

StatusChip — read-only status pill
  Height: 20px, radius: 10px
  NO border — filled bg only
  Colors:
    active/completed → success100/success500
    inactive/disabled → surfaceSubtle/textSecondary
    pending → warning100/warning500
    error/cancelled → error100/error500
    draft → primary50/primary800
    inReview → info100/info500

KpiCard — metric display card (data class; tile widget: `KpiMetricTile`)
  Required: label, value
  Optional: icon, iconColor, sublabel (optional in API; required by project policy below)
  Layout: label top-left, value below,
          icon top-right in 32x32 container
  Label: uppercase, 11px w500 textSecondary
  Value: 22px w700 textPrimary
         GoogleFonts.poppins HARDCODED
         never from theme
  Icon container: iconColor.withOpacity(0.12)
  Always pass icon + iconColor for every
  KpiCard in feature screens

AppAvatar — initials/image avatar
  5 sizes, hash-based colors, image support

AppBadge — inline badge
  6 colors, 3 variants, dot mode

### 5.5 Form Components

AppFormSection — card with 2-col grid
  Props:
    title: String
    child: Widget      ← single child, no grid
    children: List<Widget> ← 2-col Wrap grid
  
  When using children:
    Uses Wrap with spacing + runSpacing
    Each child: SizedBox(width: colWidth)
    colWidth = (maxWidth - space3) / 2
    AppFormFullWidth spans full maxWidth
    Mobile < 600px: all children full width
  
  Visual: white cardBg, border, 8px radius,
          shadowSm, 16px padding

AppFormFullWidth — full-width marker
  Wraps a child to span both columns
  in AppFormSection grid

AppFormDrawer — right side drawer
  Width: 560px desktop, full width mobile
  Header: 52px, cardBg, bottom border
  Content: scrollable, pageBg background
           (sections appear as white cards)
  Footer: 52px sticky, cardBg, top border
          Cancel (tertiary) + Save (primary)
          right aligned, space2 gap
  Animation: 250ms slide from right

AppFormModal — centered modal
  Width: 480px, radius 12px, shadowLg
  Single column layout (≤6 fields)
  Scrollable content
  Footer: Cancel + Save right aligned

AppFormPage — full screen form
  No Scaffold — inside ShellRoute
  Header: cardBg, back arrow + title +
          subtitle + action buttons top-right
  Content: pageBg, scrollable, 20px padding
  Uses AppFormPageLayout for 2-panel

AppFormPageLayout — 2-panel layout
  Breakpoint: 800px
  Desktop ≥800px: Row with Flexible(55) +
                  Flexible(45)
  Mobile <800px: Column stacked
  leftPanel: List<Widget> of AppFormSection
  rightPanel: List<Widget> of AppFormSection
  Panel gap: space4

AppConfirmDialog — confirm/alert dialog
  Width: 400px, radius 12px
  Variants: danger, warning, info
  Use: `AppConfirmDialog.show(context: context, ...)` (named `context:`)
  Enum: `AppConfirmDialogVariant` (danger / warning / info)
  Returns `Future<bool?>`

Form tier decision rules:
  ≤6 fields, simple     → AppFormModal
  7–15 fields, sections → AppFormDrawer
  15+ fields, complex,
  has nested tables      → AppFormPage

2-column field pairing rule:
  Short paired fields → place side by side
    (auto-paired by AppFormSection grid)
  Always full-width:
    - Description / Notes / Address
    - AppTextarea fields
    - AppSegmentedControl (status)
    - AppToggleSwitch flags
    - Single important field on create

---

## 6. APP SHELL & NAVIGATION

### 6.1 Responsive Breakpoints
Desktop ≥1024px: persistent sidebar 210px
Tablet 600-1023px: collapsed rail 56px
Mobile <600px: hamburger + drawer

### 6.2 Sidebar Rules
Background: sidebarBg (#1A2744)
ALL icons: white always
Active item: solid accent500 pill
Active parent section: accent500 40% opacity
Inactive text: sidebarInactiveText
Section labels: uppercase, hidden collapsed
Accordion: ONE parent open at a time
Children: indented, no icons, 30px height
Active child: left red border 2px + white text
Collapse arrow: inside sidebar top-right
Width animation: 250ms easeInOut

### 6.3 Router Rules
ShellRoute wraps all authenticated routes
Screens inside ShellRoute:
  ❌ NO Scaffold
  ❌ NO AppBar
  ✅ Return content widget directly
  ✅ Wrap with Material(type: transparency)

---

## 7. LISTING SCREENS

### 7.1 AppListingScreen Structure
ALL listing screens use AppListingScreen<T>.
The component renders everything in ONE
single rounded container:

Container (cardBg, borderDefault, cardRadius)
  └── Column
        ├── TabBar (if tabs provided)
        ├── Toolbar row
        ├── Bulk action bar (ALWAYS visible)
        ├── Table (header + rows)
        └── Pagination row

Page layout outside container:
Column
  ├── Page header (title + subtitle + button)
  ├── KpiRow (if showKpis: true)
  └── Container (everything above)

### 7.2 Toolbar Rules
Height: 44px, cardBg, bottom border
LEFT: search input 220px wide
RIGHT: Export button + Columns button
       (grouped together, space2 gap)
Export shown ONLY when onExport != null
Columns always shown

### 7.3 Bulk Action Bar Rules
ALWAYS rendered between toolbar and table.
NEVER hidden. NEVER replaces toolbar.
Height: 36px, bottom border

Empty state (no rows selected):
  bg: surfaceSubtle
  text: "Select rows to perform bulk actions"
        textMuted 11px
  Buttons: visible but opacity 0.35,
           pointer events disabled

Active state (rows selected):
  bg: Color(0xFFFFFBEB) warm amber
  border color: Color(0xFFFDE68A)
  Left: checkbox indicator + "N rows selected"
        + "✕ Clear" link
  Right: active bulk action buttons

Bulk action buttons (24px height, 11px font):
  Export    → onBulkExport handler
  Activate  → onBulkActivate handler
  Deactivate → onBulkDeactivate handler
  [divider]
  Delete    → onBulkDelete handler (danger style)
  Only show button if handler is provided

Selected rows: bg Color(0xFFFFFBEB) amber

### 7.4 Table Rules
Header row:
  height: tableHeaderHeight (34px)
  bg: surfaceSubtle
  bottom border: 1px borderDefault
  
Header cell:
  font: tableHeaderSize (11px) w600
        textSecondary uppercase letterSpacing 0.3
  Sort icon: chevronsUpDown 12px textMuted
             active: chevronUp/Down primary800
  Filter icon: listFilter 11px textMuted
               active filter: accent500
               ONLY shown when column.filter set

Data row:
  height: tableRowHeight (38px)
  bg: cardBg
  selected bg: Color(0xFFFFFBEB)
  hover bg: surfaceSubtle
  bottom border: 1px Color(0xFFF1F5F9)

Data cell:
  padding: horizontal 12px, vertical 0
  font: tableCellSize (12px) w400 textPrimary
  maxLines: 1, overflow: ellipsis

### 7.5 Sticky Actions Column
Actions column is FIXED RIGHT — not scrollable.
Width: tableActionsColumnWidth (72px)
Label: "ACTIONS" centered
Border-left: 1px borderDefault
bg: same as row bg

Implementation: Row with 3 parts:
  1. Checkbox cell — fixed 40px left
  2. Data columns — Expanded +
     SingleChildScrollView horizontal
     with SHARED ScrollController
  3. Actions cell — fixed 72px right

CRITICAL: All rows (header + data) share
ONE ScrollController for horizontal scroll.
Never create separate controllers per row.

**Implementation note:** the listing table uses the `linked_scroll_controller`
package (`LinkedScrollControllerGroup`) so the header and every data row stay
horizontally locked to the same offset (same rule as a single shared controller).

### 7.6 Per-Column Filter — Complete Pattern

Step 1: Add AppColumnFilter to TableColumn

  TableColumn<T>(
    key: 'status',
    label: 'Status',
    cellBuilder: (row) => ...,

    // Step 1a: Define filter type + options
    filter: AppColumnFilter(
      type: AppColumnFilterType.select,
      options: [
        AppSelectItem(
          value: 'active',
          label: 'Active'),
        AppSelectItem(
          value: 'inactive',
          label: 'Inactive'),
      ],
    ),

    // Step 1b: Define value extractor
    // REQUIRED when filter is set
    filterSelectValue: (row) =>
      row.status.name,
  )

For text filter:
  TableColumn<T>(
    key: 'name',
    label: 'Name',
    cellBuilder: (row) => ...,
    filter: AppColumnFilter(
      type: AppColumnFilterType.text),
    filterTextValue: (row) =>
      '${row.name} ${row.code}',
  )

RULES:
  ❌ Never set filter: without also
     setting filterTextValue or
     filterSelectValue
  ❌ If filter is set but extractor
     is null — filter is silently skipped
  ✅ text filter → filterTextValue
  ✅ select filter → filterSelectValue

Step 2: Filter types

  AppColumnFilterType.text
    → Shows AppInput + Apply + Reset
    → Case-insensitive contains match

  AppColumnFilterType.select
    → Shows checkbox list + Reset + OK
    → Exact match on value string
    → options: List<AppSelectItem<String>>

Step 3: Standard filter columns per module

  All listing screens MUST add filters
  to these columns when they exist:

  Name/title column:
    type: text
    filterTextValue: name + code/sub

  Status column:
    type: select
    options: Active + Inactive
    filterSelectValue: status.name

  Type/level columns:
    type: select
    options: all enum values

  Parent/reference columns:
    type: text
    filterTextValue: related name

Step 4: Active filter indicator
  - Funnel icon: AppTokens.textMuted
  - Active filter: AppTokens.accent500
  - Column filter active when
    _activeFilters[column.key] != null

### 7.7 Column Selector
Triggered by Columns button.
OverlayEntry anchored below Columns button.
Width: 220px, right-aligned
Search field + checkbox list + grip handles
Dismiss: tap outside

### 7.8 KPI Card Rules
showKpis: true  → Masters, Transactions,
                   Dashboard, Reports
showKpis: false → ALL User Management screens
                   (Departments, Roles,
                    Modules, Users)

Every KpiCard MUST pass icon + iconColor:
  KpiCard(
    label: '...',
    value: '...',
    icon: LucideIcons.xxx,    ← required
    iconColor: AppTokens.kpiXxx, ← required
  )

### 7.9 Pagination Rules
Height: 38px, cardBg, top border
Left: rows per page selector
      Use PopupMenuButton — NOT DropdownButton
      NOT AppSelect (overlay conflicts)
Right: "X–Y of Z" + prev/next buttons

### 7.10 Required Handlers
Every listing screen MUST provide:
  onExport: () => _handleExport(provider)
  onBulkActivate: (ids) => provider.bulkActivate(...)
  onBulkDeactivate: (ids) => provider.bulkDeactivate(...)
  onBulkDelete: (ids) => provider.bulkDelete(...)
  onBulkExport: (rows) => _handleExport(...)

### 7.11 Audit Columns Rule
ALL listing screens must include audit columns **after Status** and **before** row actions:

**Created By** column:
  - label: `'Created By'`
  - width: `160`
  - cellBuilder: `AuditCell(name: row.createdBy, date: row.createdAt)`

**Updated By** column:
  - label: `'Updated By'`
  - width: `160`
  - cellBuilder: `AuditCell(name: row.updatedBy, date: row.updatedAt)`

Shared widget: `lib/features/user_management/shared/audit_cell.dart`

ALL list models must include (auto-populated by backend; never on forms; always on listings):
  - `String? createdBy`
  - `DateTime createdAt` (required once persisted)
  - `String? updatedBy`
  - `DateTime updatedAt` (required once persisted)

### 7.12 Column Type Rules

Every TableColumn must follow ONE of these
type-driven contracts:

Text columns (name, description, email,
code, reference):
  sortable: false
  filter: AppColumnFilter(type: text)
  filterTextValue: (r) => r.fieldName
  sortValue: null

Number columns (count, level, order,
amount):
  sortable: true
  sortValue: (r) => r.numberField
  filter: null

Status columns:
  sortable: false
  filter: AppColumnFilter(type: select)
  filterSelectValue: (r) => r.status.name
  sortValue: null

Date columns (createdAt, updatedAt):
  sortable: true
  sortValue: (r) =>
    r.date.millisecondsSinceEpoch
  filter: null
  (Audit columns labelled "Created By" /
  "Updated By" still use AuditCell but
  sort by the date timestamp.)

Reference columns (parent, role, dept):
  sortable: false
  filter: AppColumnFilter(type: text)
  filterTextValue: (r) => r.refName ?? ''
  sortValue: null

### 7.13 Sort Behavior

3-state cycle: asc → desc → unsorted
Single column sort only.
Number columns: numeric comparison
  (`num.compareTo`).
String columns: case-insensitive
  (`toLowerCase().compareTo(...)`).
Date columns: compare
  `millisecondsSinceEpoch` as int.

Sort state resets on tab change.
Sort is client-side over the currently
paged rows; server-side sort is opt-in
via `onSortChanged`.

Sort icon (always 12px / `AppTokens.textSm`):
  Inactive column:
    LucideIcons.chevronsUpDown
    color: AppTokens.textMuted
  Active asc:
    LucideIcons.chevronUp
    color: AppTokens.primary800
  Active desc:
    LucideIcons.chevronDown
    color: AppTokens.primary800

### 7.14 Filter + Sort together

A column should NEVER have both filter
and sort at the same time.

  ✅ text column     → filter only
  ✅ number column   → sort only
  ✅ status column   → filter only
  ✅ date column     → sort only
  ✅ reference col   → filter only
  ❌ never both on same column

EXCEPTION (documented):
Ordinal/enum-numeric columns (e.g.
Roles → Level, where the value is
a small integer mapped to a named
bucket like Admin/Power User/...)
MAY have a select filter for
bucketed values **and** numeric
sort. This is the only allowed
exception; do not extend it to
free-text or general numeric
columns.

---

## 8. STATE MANAGEMENT

### 8.1 Provider Pattern
All feature providers extend BaseProvider.
BaseProvider has runAsync() pattern.
All async state changes via runAsync.

### 8.2 GetIt Service Locator
lib/core/di/service_locator.dart
All API classes registered as lazy singletons.
All providers registered if needed globally.
NEVER register UI providers in GetIt.

### 8.3 Bulk Operation Methods
Every provider with status must have:
  bulkActivate(List<String> ids)
  bulkDeactivate(List<String> ids)
  bulkDelete(List<String> ids)
All use runAsync + loop + fetchAll().

---

## 9. FILE STRUCTURE

lib/
├── main.dart
├── app.dart
├── design_system/
│   ├── tokens.dart          ← single source of truth
│   ├── app_theme.dart       ← Material 3 ThemeData
│   ├── breakpoints.dart
│   └── components/
│       ├── components.dart  ← BARREL — always import this
│       ├── primitives/
│       │   ├── app_button.dart
│       │   ├── app_icon_button.dart
│       │   ├── app_input.dart
│       │   ├── app_textarea.dart
│       │   ├── app_select.dart
│       │   ├── app_segmented_control.dart
│       │   └── app_toggle_switch.dart
│       ├── display/
│       │   ├── app_badge.dart
│       │   ├── app_avatar.dart
│       │   ├── status_chip.dart
│       │   └── kpi_metric.dart
│       ├── cards/
│       │   └── app_card.dart
│       ├── navigation/
│       │   ├── app_shell.dart
│       │   ├── app_sidebar.dart
│       │   └── app_topbar.dart
│       ├── listing/
│       │   ├── app_listing_screen.dart
│       │   ├── table_column.dart
│       │   ├── filter_config.dart
│       │   └── bulk_action.dart
│       ├── forms/
│       │   ├── app_form_modal.dart
│       │   ├── app_form_drawer.dart
│       │   ├── app_form_page.dart
│       │   ├── app_form_section.dart
│       │   ├── app_form_field_row.dart   ← includes AppFormFullWidth
│       │   └── app_confirm_dialog.dart
│       └── templates/
│           ├── dashboard_template.dart
│           ├── detail_template.dart
│           ├── auth_template.dart
│           └── error_template.dart
├── core/
│   ├── di/service_locator.dart
│   ├── router/app_router.dart
│   ├── providers/base_provider.dart
│   └── api/client.dart
└── features/
    ├── shell/shell_screen.dart
    ├── ui_kit/ui_kit_screen.dart
    ├── auth/
    ├── dashboard/
    ├── user_management/
    │   ├── shared/
    │   │   ├── audit_cell.dart    ← reusable audit table cell
    │   │   └── audit_fields.dart  ← shared audit JSON fields
    │   ├── departments/
    │   │   ├── data/
    │   │   ├── state/
    │   │   └── ui/
    │   ├── roles/
    │   ├── modules/
    │   └── users/
    ├── masters/
    ├── transactions/
    ├── housekeeping/
    └── reports/

Feature folder structure (every module):
  data/
    {name}_model.dart
    {name}_api.dart
  state/
    {name}_provider.dart
  ui/
    {name}_screen.dart
    {name}_form_drawer.dart   ← or _form_page.dart
    {name}_view_page.dart     ← optional

---

## 10. MODULE SCAFFOLDING GUIDE

When building a new module, follow this order:

### Step 1 — Model
lib/features/{module}/data/{name}_model.dart
  - Plain Dart class, fromJson/toJson
  - Enums for status, type fields
  - No UI dependencies
  - **Always include audit fields:** `createdBy`, `createdAt`,
    `updatedBy`, `updatedAt` (see §7.11; use
    `lib/features/user_management/shared/audit_fields.dart`
    for JSON parsing where applicable)

### Step 2 — API
lib/features/{module}/data/{name}_api.dart
  - Injected via GetIt: final _client = sl<ApiClient>()
  - Methods: fetchAll, fetchById, create,
             update, delete, updateStatus
  - Mock data for now — real API wired later

### Step 3 — Provider
lib/features/{module}/state/{name}_provider.dart
  - extends BaseProvider
  - Uses runAsync for all async operations
  - Computed getters: totalCount, activeCount,
                      inactiveCount
  - Bulk methods: bulkActivate, bulkDeactivate,
                  bulkDelete
  - Register in service_locator.dart

### Step 4 — Screen
lib/features/{module}/ui/{name}_screen.dart
  - AppListingScreen<ModelType>
  - showKpis: true for masters/transactions
    showKpis: false for user management
  - All columns with filter: where relevant
  - All bulk handlers wired
  - onExport handler
  - Status column uses StatusChip
  - Name column uses 2-line (name + code/sub)
  - **User Management listings:** always add **Created By** and
    **Updated By** columns using `AuditCell` (§7.11), placed after
    Status and before actions

### Step 5 — Form
Drawer (7–15 fields):
  lib/features/{module}/ui/{name}_form_drawer.dart
  - AppFormDrawer wrapper
  - AppFormSection with children (2-col grid)
  - AppInput, AppSelect, AppTextarea
  - AppSegmentedControl for status (AppFormFullWidth)
  - AppToggleSwitch for boolean flags
  - Pre-fills when editing (widget.model != null)
  - Validates before save

Full Page (15+ fields / complex):
  lib/features/{module}/ui/{name}_form_page.dart
  - AppFormPage wrapper
  - AppFormPageLayout (leftPanel + rightPanel)
  - AppFormSection in each panel
  - Action buttons top-right in header

### Step 6 — Router
In app_router.dart:
  - Add route inside ShellRoute
  - Replace ComingSoonScreen
  - Named route constant

### Step 7 — Navigation
In shell_screen.dart:
  - Add NavItem to correct section

---

## 11. FORM IMPLEMENTATION PATTERNS

### 11.1 Standard Drawer Form Pattern
class _NameFormDrawerState extends State<NameFormDrawer> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  String? _nameError;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.model?.name ?? '');
    _status = widget.model?.status.name ?? 'active';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameCtrl.text.isEmpty
        ? 'Required' : null;
    });
    return _nameError == null;
  }

  Future<void> _onSave() async {
    if (!_validate()) return;
    // call provider method
    // close drawer on success
  }
}

### 11.2 Status Field Pattern (always)
AppFormFullWidth(
  child: AppSegmentedControl(
    label: 'Status',
    value: _status,
    options: [
      AppSegmentOption(
        value: 'active',
        label: 'Active',
        icon: LucideIcons.check,
      ),
      AppSegmentOption(
        value: 'inactive',
        label: 'Inactive',
        icon: LucideIcons.ban,
      ),
    ],
    onChanged: (v) =>
      setState(() => _status = v),
  ),
)

### 11.3 Delete Confirm Pattern (always)
final confirmed = await AppConfirmDialog.show(
  context: context,
  title: 'Delete [Name]',
  message: 'Delete "${item.name}"? '
    'This cannot be undone.',
  confirmLabel: 'Delete',
  variant: AppConfirmDialogVariant.danger,
);
if (confirmed == true) {
  await provider.delete(item.id);
}

---

## 12. KNOWN ISSUES & LESSONS LEARNED

### 12.1 Things that broke and were fixed
- AppInput height inconsistency:
  CAUSE: expands:true + prefixIcon in
  InputDecoration
  FIX: isCollapsed:true + SizedBox(height)
  + Positioned icon overlay
  NEVER use: expands, isDense, prefixIcon
  inside InputDecoration

- Material widget error:
  CAUSE: TextField/InkWell without Material
  ancestor inside ShellRoute
  FIX: wrap component root with
  Material(type: MaterialType.transparency)

- M3 color bleed (amber/orange text):
  CAUSE: ColorScheme.fromSeed generates
  tonal colors that bleed into text
  FIX: Use ColorScheme.light() with all
  explicit AppTokens values, no fromSeed
  Explicitly set every textTheme style
  color to AppTokens.textPrimary

- Yellow underline on text:
  CAUSE: Text widget inside button ancestor
  inherits TextDecoration.underline
  FIX: decoration: TextDecoration.none
  on ALL page title and subtitle TextStyles
  Wrap in plain Column not button widget

- Tabs outside container:
  CAUSE: Tab bar rendered above the
  container widget in widget tree
  FIX: Tab bar must be FIRST child
  inside the container Column

- Horizontal scroll desync:
  CAUSE: Each row had its own
  ScrollController
  FIX: ONE shared ScrollController
  for header row + all data rows

- DropdownButton Material error:
  CAUSE: DropdownButton needs Material
  ancestor, conflicts with custom layout
  FIX: Use PopupMenuButton for
  rows-per-page in pagination ONLY

### 12.2 Rules derived from lessons
- decoration: TextDecoration.none is MANDATORY
  on title/subtitle text in page headers
- ALL input components must have
  Material(type: transparency) as root
- NEVER use expands:true for AppInput
- ONE linked horizontal scroll group per table
  (shared across header + all rows; see §7.5)
- NEVER use DropdownButton in feature code

---

## 13. SELF-CHECK BEFORE EVERY FILE

Run through this list before writing
or submitting any file:

IMPORTS:
  ☐ Only importing from components.dart barrel?
  ☐ No direct component file imports?
     (Exception: `kpi_metric.dart` for `KpiCard` — see §2.6 until exported.)

COLORS & STYLING:
  ☐ All colors via AppTokens?
  ☐ No Color(0xFF...) literals?
  ☐ No Colors.* usage?
  ☐ No Theme.of(context).colorScheme.*?
  ☐ All text via GoogleFonts.poppins()?
  ☐ No raw TextStyle() without GoogleFonts?

INPUTS & FORMS:
  ☐ No DropdownButtonFormField?
  ☐ No raw TextField or TextFormField?
  ☐ No raw Switch widget?
  ☐ AppInput has Material(transparency) root?
  ☐ AppSelect has Material(transparency) root?
  ☐ Form in drawer? → AppFormSection children
  ☐ Form full page? → AppFormPageLayout panels
  ☐ Status field? → AppSegmentedControl
                     in AppFormFullWidth
  ☐ Boolean flag? → AppToggleSwitch
                     in AppFormFullWidth

SCREENS:
  ☐ Inside ShellRoute? No Scaffold/AppBar?
  ☐ Has Material(type:transparency) root?

LISTING SCREENS:
  ☐ Using AppListingScreen<T>?
  ☐ showKpis correct for this module?
  ☐ All KpiCards have icon + iconColor?
  ☐ onExport provided?
  ☐ onBulkActivate provided?
  ☐ onBulkDeactivate provided?
  ☐ onBulkDelete provided?
  ☐ onBulkExport provided?
  ☐ Status column uses StatusChip?
  ☐ Name column is 2-line (name + sub)?
  ☐ Filterable columns have filter: set?
  ☐ Provider has bulkActivate/Deactivate/Delete?

MASTERS SCREENS CHECKLIST:
  ☐ showKpis: true (when KPIs decided)
  ☐ showCheckboxes: true
  ☐ bulkRowId: (r) => r.id
  ☐ onExport provided
  ☐ onBulkActivate provided
  ☐ onBulkDeactivate provided
  ☐ onBulkDelete provided
  ☐ Audit columns (Created By, Updated By)
  ☐ Column type rules followed
  ☐ No sort on text/status columns
  ☐ No filter on number/date columns

MASTERS FORMS CHECKLIST:
  ☐ Correct tier (≤6 Modal, 7+ Drawer)
  ☐ No raw TextField anywhere
  ☐ No DropdownButtonFormField anywhere
  ☐ Every field has hint: text
  ☐ Status uses AppSegmentedControl
  ☐ Status inside AppFormFullWidth
  ☐ AppFormSection 2-col grid used
  ☐ Audit fields in model

STATE:
  ☐ No setState for server data?
  ☐ All async in Provider runAsync?
  ☐ API registered in GetIt?

FINAL:
  ☐ flutter analyze — zero issues?

---

## 14. CURRENT BUILD STATUS

### Done ✅
- Design system (tokens, theme, components)
- App shell (sidebar, topbar, routing)
- All input components (Input, Textarea,
  Select, SegmentedControl, ToggleSwitch)
- Button system (4 variants, 3 sizes)
- Form templates (Modal, Drawer, Page,
  Section, FullWidth, PageLayout)
- Listing engine (all features)
- Display components (StatusChip, KpiCard,
  Avatar, Badge)
- User Management (Departments, Roles,
  Modules, Users)
- UI Kit screen at /ui-kit

### In Progress 🔧
- Permissions matrix (next)
- Wire bulk handlers in UM screens

### Pending ⏳
- Auth / Login screen
- Masters (17 sub-modules)
- Transactions
- Housekeeping
- Reports
- Dashboard

---

## 15. PROMPT TEMPLATES

### Start every Claude Code session:
"Read FLUTTER_CLAUDE.md first. Then: [request]"

### New feature module:
"Read FLUTTER_CLAUDE.md first.
Build [Name] master sub-module.
Fields: [list].
Form tier: [Modal/Drawer/Page].
Follow module scaffolding guide exactly."

### Audit for violations:
"Read FLUTTER_CLAUDE.md. Audit lib/ for
all violations. Fix them."

### If Claude Code drifts:
"Stop. Read FLUTTER_CLAUDE.md again.
You broke rule [N]: [what was wrong].
Rewrite following FLUTTER_CLAUDE.md exactly."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
END OF FLUTTER_CLAUDE.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VALIDATION:
1. FLUTTER_CLAUDE.md completely rewritten
2. All 15 sections present
3. No code files changed
4. All rules from current codebase
   accurately reflected