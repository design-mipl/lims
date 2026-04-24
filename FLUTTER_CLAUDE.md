# FLUTTER_CLAUDE.md

Canonical guardrails for the **limsv1** Flutter codebase. Rules match **what exists in the repository today** (design system + `GoRouter` placeholder, Provider + GetIt). Items not present in `lib/` or `pubspec.yaml` are labeled **TO BE BUILT** with the intended pattern.

---

## 1. What this project is

**Ultra LIMS** (`MaterialApp.router` title in `lib/main.dart`) is a Flutter app scaffolded as a **laboratory information management–style portal**. The runnable app today shows a **GoRouter placeholder** at `/` (`lib/core/router/app_router.dart`); the **AppShell** design system and templates exist but are **not wired** as a home screen yet—**no business features or API** are implemented yet.

**Product modules (target areas, not yet under `lib/features/`):** the repo does not define sub-module folders or counts. When feature work starts, a typical seven-area LIMS split aligned with the route naming guide (Section 13) is:

| # | Module        | Implemented sub-modules in repo |
|---|---------------|-----------------------------------|
| 1 | Dashboard     | **0** |
| 2 | Transactions  | **0** |
| 3 | Masters       | **0** |
| 4 | Housekeeping  | **0** |
| 5 | Reports       | **0** |
| 6 | Users         | **User Management** scaffold under `lib/features/user_management/` (Departments CRUD + placeholders for Users/Roles/Modules) |
| 7 | Settings      | **0** |

Treat sub-module counts as **to be established** when `lib/features/<module>/` is added.

---

## 2. Tech stack

Exact dependency constraints from `pubspec.yaml` (SDK and declared packages):

| Package | Role |
|---------|------|
| `flutter` (SDK `^3.11.5`) | UI framework |
| `cupertino_icons` `^1.0.8` | Optional Cupertino icon font (default template dep) |
| `shared_preferences` `^2.5.3` | Persists sidebar expanded state (`AppShell`) and theme config (`ThemeConfig` / `ThemeNotifier` in `app_theme.dart`); registered in GetIt as `sl<SharedPreferences>()` |
| `lucide_flutter` `^1.7.0` | Sidebar, topbar, listing, error icons |
| `provider` `^6.1.2` | State management (`ChangeNotifier`; app-level `ThemeNotifier`, route-level feature providers) |
| `get_it` `^8.0.0` | Dependency injection / service locator (`lib/core/di/service_locator.dart`) |
| `go_router` `^16.0.0` | Declarative routing; `appRouter` in `lib/core/router/app_router.dart` (placeholder) |
| `dio` `^5.7.0` | HTTP client (available for future API wiring) |
| `google_fonts` `^6.2.1` | Loads **Poppins** for `AppTheme` / `textTheme` |
| `flutter_test` (SDK) | Unit/widget tests |
| `flutter_lints` `^6.0.0` | Static analysis rules |

**Not in `pubspec.yaml` yet (TO BE BUILT):** `flutter_secure_storage`, code generation packages, etc.

**Fonts:** `AppTheme` applies **Poppins** via `google_fonts` (`GoogleFonts.poppinsTextTheme`). `AppTokens.fontFamily` is `'Poppins'`. Do not use Material’s default Roboto for product UI—inherit from theme or set `AppTokens.fontFamily` explicitly when building standalone `TextStyle`s.

---

## 3. Project structure

**Actual tree** (only paths that exist). Feature modules live under `lib/features/`.

```text
lib/
  main.dart
  features/
    coming_soon/
      coming_soon_screen.dart
    dev/
      form_template_preview_screen.dart   # temporary; remove before production
    shell/
      shell_screen.dart
    user_management/
      departments/
        data/department_model.dart
        data/departments_api.dart
        state/departments_provider.dart
        ui/departments_screen.dart
        ui/department_form_drawer.dart
      users/ui/users_screen.dart
      roles/ui/roles_screen.dart
      modules/ui/modules_screen.dart
      shared/ui/user_management_section_placeholder.dart
  core/
    di/
      service_locator.dart
    providers/
      base_provider.dart
    router/
      app_router.dart   # full GoRouter; ShellRoute + module GoRoutes
  design_system/
    tokens.dart
    app_theme.dart
    breakpoints.dart
    components/
      components.dart
      cards/
        app_card.dart
      display/
        app_avatar.dart
        app_badge.dart
        kpi_metric.dart
        status_chip.dart
      listing/
        app_listing_screen.dart
        bulk_action.dart
        filter_config.dart
        table_column.dart
      navigation/
        app_shell.dart
        app_sidebar.dart
        app_topbar.dart
        nav_item.dart
      primitives/
        app_button.dart
        app_icon_button.dart
        app_input.dart
        app_select.dart
        app_textarea.dart
        app_segmented_control.dart
      forms/
        app_form_drawer.dart
        app_form_field_row.dart
        app_form_modal.dart
        app_form_page.dart
        app_form_section.dart
      templates/
        auth_template.dart
        dashboard_template.dart
        detail_template.dart
        error_template.dart
        section_card.dart
        template_pulse.dart
```

**Planned (not created yet under `lib/core/` or as additional `lib/features/` modules):**

- `lib/core/api/` — shared API client, env config, auth helpers.
- `lib/features/<module>/` — additional folders per product module as they are built (beyond `coming_soon`, `shell`, `user_management`, and internal `dev/` previews).

### User Management and other large modules (sub-module folders)

When a product module spans **several product sub-areas** (e.g. Departments, Users, Roles), **do not** collect all `data/` / `state/` / `ui/` files in a single flat layer under `lib/features/<module>/`. Instead:

- Give **each sub-module** its own tree: `lib/features/<module>/<sub_module>/data/`, `state/`, `ui/` as needed (example: `user_management/departments/…`).
- Put **shared** screens, placeholders, and cross-cutting widgets for that module only under `lib/features/<module>/shared/` (example: `user_management/shared/ui/`).
- **Do not** place future Users/Roles/Modules implementation files in a global `user_management/data/` or `user_management/state/` folder at the module root—add them under `users/`, `roles/`, `modules/` (or new sibling sub-module folders) respectively.

Apply the same pattern to **future large features** that naturally split into sub-domains, so ownership stays clear and imports stay local to the sub-module.

---

## 4. Design tokens — CRITICAL

All visual constants live on **`AppTokens`** (`lib/design_system/tokens.dart`): flat static getters only (no nested `AppTokens.colors` object).

### How to use tokens

**Colors (examples):** `AppTokens.primary900` … `primary50`, `accent600` … `accent50`, `neutral900` … `neutral50`, `success500` / `success100` / `success50`, `warning500` / `warning100` / `warning50`, `error500` / `error100` / `error50`, `info500` / `info100` / `info50`, `white`, `surfaceCard`, `background`, `border`, `borderLight`, **`borderDefault`**, **`surfaceSubtle`**, **`labelColor`**, **`hintColor`**, **`textPrimary`**, **`textSecondary`**, **`textMuted`**, **`tableRowDivider`**, `filledSecondarySurface`, `sidebarBg`, `sidebarActiveItem`, `sidebarInactiveText`, `sidebarActiveText`, `sidebarSectionLabel`, `sidebarIcon`.

**Spacing (4px base):** `space0`, `space1` (4), `space2` (8), `space3` (12), `space4` (16), `space5` (20), `space6` (24), `space8` (32), `space10` (40), `space12` (48).

**Radius:** `radiusSm`, `radiusMd`, `radiusLg`, `radiusXl`, `radiusFull`.

**Typography sizes:** `textXs` … `text3xl`. **Weights:** `weightRegular`, `weightMedium`, `weightSemibold`, `weightBold`.

**Typography roles (pair with Poppins / theme):** `pageTitleSize` / `pageTitleWeight`, `pageSubtitleSize` / `pageSubtitleWeight`, `sectionTitleSize` / `sectionTitleWeight`, `fieldLabelSize` / `fieldLabelWeight`, `bodySize` / `bodyWeight`, `captionSize` / `captionWeight`.

**Sizing / chrome:** `buttonHeightSm` / `Md` / `Lg`, `inputHeight`, `inputHeightLg`, `tableRowHeight`, `listingSearchWidthTablet` / `Desktop`, `listingFilterPanelWidth`, `formDrawerWidthDesktop`, `formModalMaxWidth`, `formPageContentMaxWidth`, `tableCheckboxColumnWidth`, `tableActionsColumnWidth`, `tableToggleColumnWidth`, `topbarHeight`, `topbarSearchWidthTablet` / `Desktop`, `sidebarExpanded`, `sidebarCollapsed`, `navItemHeight`, border widths, `focusRingWidth`, `iconSizeMd`, `iconButtonIconSm` / `Md`, `inlineProgressIndicatorSize`, `inlineProgressIndicatorStrokeWidth`, `badgeHeight`, `avatarSizeXs` / `Sm`, `disabledOpacity`, `opacityFull`, `statusChipHeight`, `luminanceInkThreshold`, `elevationPopupMenu`, `overlayPrimaryAlpha` (focus ring color: `focusRingColor`).

**Shadows:** `AppTokens.shadowSm`, `shadowMd`, `shadowLg` — each is `List<BoxShadow>`.

**Semantic / theme colors:** Prefer `Theme.of(context).colorScheme` / `textTheme` for values that must track light/dark (Section 5). Use `AppTokens` for explicit brand neutrals and layout metrics.

### Color token reference

| Token | Hex | Usage |
|-------|-----|--------|
| `accent500` | `#E53935` | Primary accent red—CTAs, active navigation emphasis, strong interactive highlights. |
| `sidebarBg` | `#1A2744` | Sidebar background. |
| `sidebarActiveItem` | `#E53935` | Active nav item background. |
| `sidebarInactiveText` | `#A8B3C7` | Inactive nav item text. |
| `sidebarActiveText` | `#FFFFFF` | Active nav item text. |
| `sidebarSectionLabel` | `#A8B3C7` | Section label (CORE, ENTITIES). |
| `sidebarIcon` | `#FFFFFF` | All nav icons, active and inactive. |
| `sidebarActiveItem.withOpacity(0.40)` | — | Active parent/section background (use in widgets; not a separate token). |

### Sidebar color tokens

| Token | Value | Usage |
|-------|-------|-------|
| sidebarBg | #1A2744 | Sidebar background |
| sidebarActiveItem | #E53935 | Active nav item bg |
| sidebarActiveItem.withOpacity(0.40) | — | Active parent/section bg |
| sidebarInactiveText | #A8B3C7 | Inactive nav item text |
| sidebarActiveText | #FFFFFF | Active nav item text |
| sidebarSectionLabel | #A8B3C7 | Section label (CORE, ENTITIES) |
| sidebarIcon | #FFFFFF | All nav icons, active and inactive |

### Rules (enforce strictly)

- **Never hardcode a color literal** for UI chrome. Use `AppTokens` or theme-derived colors.

  ```dart
  // WRONG
  Container(color: const Color(0xFF1A2744))

  // RIGHT
  Container(color: AppTokens.primary800)
  ```

- **Never hardcode spacing** with raw numbers when the value maps to the scale.

  ```dart
  // WRONG
  Padding(padding: const EdgeInsets.all(16))

  // RIGHT
  Padding(padding: const EdgeInsets.all(AppTokens.space4))
  ```

- **Never hardcode layout sizes** that already exist on `AppTokens`.

  ```dart
  // WRONG
  const SizedBox(height: 48)

  // RIGHT
  const SizedBox(height: AppTokens.topbarHeight)
  ```

- **Opacity variants:** ❌ NEVER create a separate color token for opacity variants — use `.withOpacity()` directly:

  - ✅ `AppTokens.sidebarActiveItem.withOpacity(0.40)`
  - ❌ `AppTokens.sidebarSectionActiveBg`

### FONT

- Font family: **Poppins** (via `google_fonts` in `AppTheme`).
- Never rely on Flutter’s default (Roboto) for product UI—use theme `textTheme` or `AppTokens.fontFamily`.

### INPUT RULES

- Always use **`AppInput`** for single-line text fields.
- Always use **`AppSelect`** for dropdowns — **never** `DropdownButtonFormField` in `lib/features/` (the primitive may wrap it internally in `app_select.dart` only).
- Always use **`AppTextarea`** for multiline fields.
- All of the above use the **full bordered box** style (outline, 6px radius)—never underline-only inputs.

### FORM LAYOUT RULES

- **`AppFormSection`** default body should use a **two-column** layout on desktop via **`AppFormFieldRow`** / **`ResponsiveGridRow`** (same widget; `ResponsiveGridRow` is a typedef).
- Wrap fields that must span the full width in **`AppFormFullWidth`**.
- Section card: **`surfaceSubtle`** background, **`borderDefault`** border, **8px** radius (`radiusLg`), **16px** padding.

### TYPOGRAPHY RULES

- Page title: **20px**, **w600** (`pageTitleSize` / `pageTitleWeight`).
- Page subtitle: **13px**, **w400**, muted (`pageSubtitleSize` / `textMuted`).
- Section title: **13px**, **w600** (`sectionTitleSize` / `sectionTitleWeight`).
- Field label: **12px**, **w500** — rendered **above** the field as a `Text` widget, **not** as `InputDecoration.labelText`.
- Body text: **13px**, **w400** (`bodySize` / `bodyWeight`).
- Caption / helper / tight meta: **11px**, **w400** (`captionSize` / `captionWeight`).

### KPI CARD RULES

- Always use **`KpiMetricTile`** with **`KpiCard`** data.
- Label: **uppercase 11px**, **w500**, letter-spacing **0.5**, **`textSecondary`**.
- Value: **24px**, **w700**, **`textPrimary`** (or on-surface in dark mode).
- Icon: **top-right**, **20px** glyph inside a **36×36** rounded tile at **~10%** `primary800` tint.
- Optional sub-label / trend: **12px**, muted (`textMuted` / semantic trend color).

### TABLE RULES (listings)

- Header row: **uppercase 11px**, **w600**, **`textSecondary`**, background **`surfaceSubtle`**, bottom border **`borderDefault`**.
- Cell padding: **12px** horizontal, **10px** vertical; row height from **`AppTokens.tableRowHeight`**.
- Row hover: **`surfaceSubtle`**; row divider: **`tableRowDivider`**.
- Text alignment: **left** default, **center** for status columns, **right** for actions / numeric columns.

---

## 5. Import rules — CRITICAL

### Design system components

Prefer the barrel:

```dart
import 'package:limsv1/design_system/components/components.dart';
```

**Exception (current repo state):** `lib/design_system/components/components.dart` does **not** export `display/kpi_metric.dart`. Until an export is added, use:

```dart
import 'package:limsv1/design_system/components/display/kpi_metric.dart';
```

**Do not** deep-import other primitives if the barrel already exports them.

`lib/main.dart` imports `core/di/service_locator.dart`, `core/router/app_router.dart`, and `design_system/app_theme.dart`—when adding shell or feature routes, prefer the components barrel for design-system imports.

### Cross-feature imports

- Allowed: relative imports within the same **feature sub-module** (e.g. under `user_management/departments/`); imports from that module’s **`shared/`** tree when appropriate; `package:limsv1/core/...` for shared core.
- Forbidden: `../../other_feature/...` imports across **top-level** feature boundaries (e.g. from `user_management/` into `shell/` via relative `../` hops). Prefer `package:limsv1/...` for intentional cross-feature APIs when they exist.

### Theme access

- Prefer `Theme.of(context).colorScheme.*` and `Theme.of(context).textTheme.*` for semantic text and surfaces.
- **App theme + brand color:** `context.watch<ThemeNotifier>()` (from `package:provider/provider.dart`) in widgets; `sl<ThemeNotifier>()` from GetIt only **outside** the widget tree (never `sl()` in `build()`). `ThemeNotifier` is registered in `setupServiceLocator()`.
- Avoid raw `Colors.*` from `material/colors.dart` for app styling.
- Avoid ad-hoc `TextStyle(fontSize: 14)` when a `textTheme` role fits; pair with `AppTokens` font sizes when you need fine tuning consistent with the system.

---

## 6. Component usage rules

### AppButton (`AppButtonVariant`, `AppButtonSize`)

Constructors: `label`, `onPressed`, `variant` (default `primary`), `size` (default `md`), optional `leadingIcon`, `trailingIcon`, `fullWidth`, `isLoading`.

- **Variants:** `primary` → `ElevatedButton`; `secondary` → `FilledButton`; `tertiary` → `TextButton`; `danger` → `OutlinedButton` with error outline/text.
- **Sizes:** `sm` / `md` / `lg` map to `AppTokens.buttonHeightSm/Md/Lg` and stepped font sizes.
- **Loading:** `isLoading: true` shows a small `CircularProgressIndicator`; button is non-interactive.
- **Disabled:** pass `onPressed: null` — opacity uses `AppTokens.disabledOpacity`.

```dart
AppButton(
  label: 'Save',
  onPressed: () {},
  variant: AppButtonVariant.primary,
  size: AppButtonSize.md,
)
AppButton(label: 'Cancel', onPressed: () {}, variant: AppButtonVariant.secondary)
AppButton(label: 'Discard', onPressed: () {}, variant: AppButtonVariant.tertiary)
AppButton(label: 'Delete', onPressed: () {}, variant: AppButtonVariant.danger)
AppButton(label: 'Saving…', onPressed: () {}, isLoading: true)
```

**Rule:** At most **one** primary action per screen / toolbar (product convention; listing header already uses one primary slot).

### AppInput (`AppInputSize`)

Parameters include `label`, `hint`, `helperText`, `errorText`, `controller`, `prefixIcon`, `suffixIcon`, `required`, `enabled`, `readOnly`, `obscureText`, `size` (`sm` / `md` / `lg`), `maxLines`, `maxLength`, etc.

For dense Stripe-style forms (Section 9), prefer **`AppInputSize.sm`** when layout allows.

```dart
AppInput(
  label: 'Display name',
  hint: 'e.g. Sample A-12',
  required: true,
  controller: _nameCtrl,
  prefixIcon: const Icon(LucideIcons.tag),
  errorText: _nameError,
)
```

### AppBadge vs StatusChip

- **`AppBadge`:** General labels, counts, metadata. Configure `AppBadgeColor` and `AppBadgeVariant` (`filled`, `subtle`, `outline`), optional `dot`.

  ```dart
  const AppBadge(label: '12', color: AppBadgeColor.neutral, variant: AppBadgeVariant.subtle)
  ```

- **`StatusChip`:** Row-level workflow status in tables. Pass machine-friendly `status` (`active`, `inactive`, `pending`, `in_review` / `inreview`, `completed`, `cancelled`, `draft`, etc.—normalization strips spaces/underscores/hyphens). Optional `customLabel`.

  ```dart
  StatusChip(status: 'active')
  StatusChip(status: 'in_review', customLabel: 'QA review')
  ```

### AppAvatar (`AppAvatarSize`)

`imageUrl`, `name` (initials), optional `customInitials`, `backgroundColor`, `size`: `xs`, `sm`, `md`, `lg`, `xl`.

```dart
AppAvatar(imageUrl: user.photoUrl, name: user.displayName, size: AppAvatarSize.md)
AppAvatar(name: 'Avery Chen', size: AppAvatarSize.lg)
```

### AppCard

`child`, optional `padding`, `onTap`, `hasBorder`, `shadow` (`List<BoxShadow>?`, default `AppTokens.shadowSm`), `backgroundColor`, `borderRadius`.

```dart
AppCard(child: Text('Hello', style: Theme.of(context).textTheme.bodyMedium))

AppCard(
  onTap: () {},
  child: const Text('Tappable card'),
)

AppCard(
  shadow: AppTokens.shadowMd,
  child: const Text('Elevated'),
)
```

---

## 7. App Shell usage

### NavItem configuration

`NavItem` fields: `path`, `label`, `icon` (required `Widget`), optional `sectionLabel`, optional `children` (nested `NavItem` list). **Expandable** when `children` is non-empty. Section headers render when `sectionLabel` changes between consecutive items.

`AppSidebar` bottom includes **Help & Docs** (fixed row; `onTap` is currently empty in `_HelpRow`—wire when needed). **In-app use:** the shell is mounted for authenticated app routes: `appRouter` uses a `ShellRoute` whose builder returns `ShellScreen`, which wraps page content in `AppShell` (see Section 13). Build new screens in `lib/features/<module>/` and register them in `app_router` / `appNavItems` when ready.

Example:

```dart
navItems: [
  NavItem(
    path: '/dashboard',
    label: 'Dashboard',
    sectionLabel: 'CORE',
    icon: Icon(LucideIcons.layoutDashboard,
        size: AppTokens.iconButtonIconMd, color: AppTokens.sidebarIcon),
  ),
  NavItem(
    path: '/samples',
    label: 'Samples',
    sectionLabel: 'LAB',
    icon: Icon(LucideIcons.testTube2,
        size: AppTokens.iconButtonIconMd, color: AppTokens.sidebarIcon),
  ),
  NavItem(
    path: '/assays',
    label: 'Assays',
    icon: Icon(LucideIcons.microscope,
        size: AppTokens.iconButtonIconMd, color: AppTokens.sidebarIcon),
    children: const [
      NavItem(path: '/assays/panels', label: 'Panels', icon: SizedBox.shrink()),
      NavItem(path: '/assays/runs', label: 'Runs', icon: SizedBox.shrink()),
    ],
  ),
],
```

### UserInfo

From `nav_item.dart`:

```dart
const UserInfo(
  name: 'Avery Chen',
  id: 'r-001',
  avatarUrl: null,   // optional
  initials: 'AC',    // optional; passed to AppAvatar as customInitials in topbar
)
```

### AppShell wiring

`AppShell` requires: `child`, `navItems`, `currentPath`, `appName`, `logoWidget`, `onPathSelected`. Optional: `appSubtitle`, notification callbacks, `currentUser`, profile/settings/sign-out/search callbacks, `appVersion`.

**With GoRouter:** the live `ShellScreen` holds `_currentPath`, initialized and updated from `GoRouterState.uri.path` (`didUpdateWidget` on route changes) and in `onPathSelected` along with `context.go(path)` (see Section 13).

```dart
AppShell(
  appName: 'Ultra Labs',
  appSubtitle: 'LIMS Portal',
  logoWidget: const FlutterLogo(size: 32),
  currentPath: currentPath,
  onPathSelected: (p) => context.go(p),
  currentUser: const UserInfo(name: 'Avery Chen', id: 'r-001', initials: 'AC'),
  onProfileTap: () {},
  onSettingsTap: () {},
  onSignOutTap: () {},
  onSearchTap: () {},
  navItems: navItems,
  child: child,
)
```

### Sidebar behavior (implemented)

- **Desktop** (`≥1024px`): Persistent sidebar, expanded (`210px`) default when no saved preference (first frame uses width). Collapse arrow **inside** the sidebar, top-right of the logo row. Logo click when collapsed → expands. Arrow click → toggles expand/collapse. State persisted to `SharedPreferences` key `interics:sidebar_expanded`.
- **Tablet** (`600–1023px`): Persistent sidebar, collapsed (`56px`) default when no saved preference. Same toggle behavior as desktop. No hamburger menu (sidebar is always visible).
- **Mobile** (`<600px`): No persistent sidebar. Hamburger in `AppTopbar` opens the drawer (`210px` width). `AppShell` closes the drawer on route change (`didUpdateWidget` when `currentPath` changes) and after `onPathSelected` on mobile.

**Accordion rules:**

- Only one parent with children can be expanded at a time; expanding one closes all others.
- Children are hidden when the sidebar is collapsed (rail); parent rows show icons only with a tooltip for the label.
- Active child row: white label and a `2px` left border in `AppTokens.sidebarActiveItem`.

**Icon and color rules:**

- All sidebar chrome icons use `AppTokens.sidebarIcon` (white) always.
- Active leaf item: solid red background `AppTokens.sidebarActiveItem` (`#E53935`).
- Active parent (expanded with an active child): `AppTokens.sidebarActiveItem.withOpacity(0.40)` background.
- Inactive labels: `AppTokens.sidebarInactiveText` (`#A8B3C7`).
- Section labels: `AppTokens.sidebarSectionLabel`, uppercase, shown only when expanded; when collapsed they are replaced by a thin horizontal divider (`AppTokens.neutral700`).

---

## 8. Listing screen usage

### Basic example (`AppListingScreen<T>`)

Key types live in the same library: `TabConfig`, `RowAction`, `TableColumn`, `BulkAction`, `FilterField`, `ActiveFilter`, `KpiCard` (import `kpi_metric.dart` for `KpiCard` / `KpiMetricTile`).

```dart
class Sample {
  Sample({required this.id, required this.name, required this.status});
  final String id;
  final String name;
  final String status;
}

AppListingScreen<Sample>(
  title: 'Samples',
  subtitle: 'Registered specimens',
  columns: [
    TableColumn<Sample>(
      key: 'id',
      label: 'ID',
      width: 120,
      cellBuilder: (r) => Text(r.id),
    ),
    TableColumn<Sample>(
      key: 'name',
      label: 'Name',
      cellBuilder: (r) => Text(r.name),
    ),
    TableColumn<Sample>(
      key: 'status',
      label: 'Status',
      sortable: false,
      cellBuilder: (r) => StatusChip(status: r.status),
    ),
  ],
  rows: samples,
  mobileCardBuilder: (r) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(r.name, style: Theme.of(context).textTheme.titleSmall),
      Text(r.id, style: Theme.of(context).textTheme.bodySmall),
      StatusChip(status: r.status),
    ],
  ),
  rowActions: [
    RowAction<Sample>(
      key: 'view',
      label: 'View',
      icon: const Icon(LucideIcons.eye),
      onTap: (row) {},
    ),
    RowAction<Sample>(
      key: 'edit',
      label: 'Edit',
      icon: const Icon(LucideIcons.pencil),
      onTap: (row) {},
    ),
    RowAction<Sample>(
      key: 'delete',
      label: 'Delete',
      icon: const Icon(LucideIcons.trash2),
      isDanger: true,
      onTap: (row) {},
    ),
  ],
  onSearch: (q) => _applySearch(q),
  totalCount: total,
  currentPage: page,
  pageSize: pageSize,
  onPageChanged: (p) => setState(() => page = p),
  onPageSizeChanged: (s) => setState(() => pageSize = s),
  onSortChanged: (sort) => _refetch(sort: sort),
)
```

### Column definition rules

- **Sortable:** default `sortable: true`. Set `sortable: false` for non-sortable columns. Parent must pass **`onSortChanged`** to react to user sort changes (otherwise only local indicators update).
- **Numeric:** `numeric: true` right-aligns header and cells.
- **Fixed width:** set `width: double` (logical pixels).
- **Flex columns:** `width: null` — shares remaining width after fixed columns and chrome.

### Filter system

`FilterField` types: `FilterType.text`, `multiSelect` (requires `options`), `dateRange`.

```dart
filterFields: const [
  FilterField(key: 'q', label: 'Keyword', type: FilterType.text),
  FilterField(
    key: 'lab',
    label: 'Laboratory',
    type: FilterType.multiSelect,
    options: ['East', 'West', 'Central'],
  ),
  FilterField(key: 'received', label: 'Received', type: FilterType.dateRange),
],
activeFilters: active,
onFiltersChanged: (next) => setState(() => active = next),
```

`ActiveFilter`: `key`, `label`, `value` (display string), `rawValue` (`dynamic` — `String`, `List` for multi-select, `Map` with `'from'` / `'to'` `DateTime?` for date range).

### Bulk actions

```dart
bulkActions: [
  BulkAction<Sample>(
    key: 'archive',
    label: 'Archive',
    icon: const Icon(LucideIcons.archive),
    onTap: (selectedRows) => _archiveMany(selectedRows),
  ),
],
```

`onTap` receives **`List<T>`** of selected row values.

### KpiCard

```dart
kpiCards: [
  KpiCard(
    label: 'Open',
    value: '128',
    icon: const Icon(LucideIcons.inbox),
    trend: '+6.2%',
    trendPositive: true,
  ),
],
```

### TabConfig

```dart
tabs: const [
  TabConfig(label: 'All', count: 120),
  TabConfig(label: 'Pending', count: 8),
],
initialTabIndex: 0,
onTabChanged: (i) => _reloadTab(i),
```

---

## 9. Form Template Rules

Shared form UI lives under `lib/design_system/components/forms/` and is exported from `components.dart`. Use **`AppTokens`**, **`AppBreakpoints`**, and **`Theme.of(context)`** for layout and color—never hardcode colors, spacing, radii, or shadows on these surfaces.

### Form tiers

| Tier | Component | Use when | Examples |
|------|-------------|----------|----------|
| Tier 1 | `AppFormModal` | ≤ 6 fields, simple data entry | Add Grade, Add Bank |
| Tier 2 | `AppFormDrawer` | 7–15 fields, sectioned data, no nested tables | Add Customer, Add User |
| Tier 3 | `AppFormPage` | 15+ fields, complex workflows, nested tables / line items | Sample Receipt |
| Confirm | `AppConfirmDialog` | Destructive confirmation | Delete, Disable |

**Confirm tier:** `AppConfirmDialog` is **not implemented** yet. Until it exists, use `AlertDialog` (or `showDialog`) with **`AppButton`** (`danger` for confirm when appropriate) and the same token/theme rules.

**APIs:** `AppFormModal.show(…)` and `AppFormDrawer.show(…)` wrap `showDialog` / `showGeneralDialog` with sticky footers. `AppFormPage` is an in-shell layout: it uses a **`Column`** with **`Expanded`** for the scroll body—when the parent is scrollable (e.g. `AppShell` body), wrap it in a **`SizedBox`** with an explicit height derived from the viewport minus chrome so the footer stays sticky.

### Drawer rules

- Width: **`AppTokens.formDrawerWidthDesktop`** (720px) on desktop (`AppBreakpoints.isDesktopWidth`).
- Tablet / mobile: full usable width (responsive, max available).
- Sticky footer always visible; body scrolls independently.
- Prefer **`AppFormFieldRow`** for a 2-column field grid on desktop and 1 column on mobile.
- Use **`AppFormSection`** for medium/large forms: light surface, subtle border/shadow, compact padding.

### Section rules

- Every medium/large form should use **`AppFormSection`** (or equivalent sectioning)—avoid long flat forms.
- Section supports **title**, optional **description**, and optional **`trailing`** inline action (e.g. `+ Add Address`, **Fetch Details**, `+ Add Bank`).
- Inline actions belong in the section header row, not buried in the body copy.

### Field rules

- Keep fields **compact** (Stripe-like): prefer **`AppInputSize.sm`** in dense forms where it fits.
- **Labels above inputs** (`AppInput` already stacks label → field → helper/error).
- **Required:** set **`required: true`** per field only when needed; the label shows a red asterisk (`*`).
- Do **not** mark every field required globally.
- Use **`helperText`** / **`errorText`** below the field when needed.

### Footer rules

- **Modal:** sticky footer with **Cancel** (tertiary) + **primary** action (`AppButton.primary`); primary may use **`isLoading`**.
- **Drawer:** same pattern—Cancel + Save/Submit.
- **Page:** optional top **`actions`**; bottom sticky footer for **Cancel**, optional **Save & continue** (`secondary`), and **Save** (`primary`) when the corresponding callbacks are non-null.

### Token rules

- Never hardcode colors, spacing, sizes, shadows, or radius on form templates—use **`AppTokens`** and **`Theme.of(context)`**.
- Do not use raw Flutter **`Colors.*`** for chrome (except **`Colors.transparent`** where the project already allows it, e.g. barriers).

### Preview route

- Temporary dev-only route: **`/dev/form-preview`** (`FormTemplatePreviewScreen`)—registered in **`ShellRoute`** only; **not** in the sidebar `navItems`.
- **Remove before production** (screen file header comment).

---

## 10. Screen templates

### DashboardTemplate

`title`, optional `subtitle`, `headerActions`, `kpiCards` (`List<KpiCard>?`), required `sections` (`List<DashboardSection>`), `isLoading`.

`DashboardSection`: `title`, optional `actionLabel` / `onAction`, `content`, `fullWidth` (desktop: full-width row vs two-column grid pair).

Uses **`LayoutBuilder`** internally for padding and KPI density.

```dart
DashboardTemplate(
  title: 'Operations',
  subtitle: 'Today at a glance',
  isLoading: loading,
  headerActions: [
    AppButton(label: 'Refresh', onPressed: _load, variant: AppButtonVariant.secondary),
  ],
  kpiCards: [
    KpiCard(label: 'Throughput', value: '842', trend: '+3%', trendPositive: true),
  ],
  sections: [
    DashboardSection(
      title: 'Queue depth',
      fullWidth: true,
      content: const Text('Chart placeholder'),
    ),
    DashboardSection(
      title: 'Exceptions',
      actionLabel: 'View all',
      onAction: () {},
      content: const Text('List placeholder'),
    ),
  ],
)
```

### DetailTemplate

`title`, optional `subtitle`, `breadcrumbParent`, optional `onBreadcrumbTap`, optional `avatar` (`Widget?`—often `AppAvatar`), `statusBadges` (`List<StatusInfo>?` with `AppBadgeColor`), `headerStats` (`List<DetailHeaderStat>?`, stats row **desktop only**), `headerActions`, required `tabs` (`List<DetailTab>`: `key`, `label`, optional `icon`, `content`), `initialTab`, optional `sidePanel`, `sidePanelWidth` (default `AppTokens.listingFilterPanelWidth`), `isLoading`.

Side panel: shown to the right on desktop with scroll; below main tab content on smaller widths.

### AuthTemplate

`logoWidget`, `appName`, optional `appSubtitle`, `formTitle`, optional `formSubtitle`, `formContent`, optional `footerText`, `footerAction`. Split brand / form on **desktop** (`AppBreakpoints.isDesktopWidth`); stacked on mobile.

### ErrorTemplate

`ErrorTemplateType`: `notFound`, `unauthorized`, `serverError`, `noInternet`, `empty`. Optional `title`, `message`. Optional primary `actionLabel` + `onAction`; optional **`onBack`** adds a tertiary **Go Back** button with chevron.

```dart
ErrorTemplate(type: ErrorTemplateType.notFound)
ErrorTemplate(
  type: ErrorTemplateType.serverError,
  actionLabel: 'Retry',
  onAction: () => _retry(),
  onBack: () => context.pop(),
)
```

### SectionCard

`title`, optional `actionLabel` / `onAction` or `headerRight`, `child`, optional `contentPadding`, `noPadding` (use for tables inside the card), `isLoading`.

```dart
SectionCard(title: 'Audit trail', child: const Text('…'))

SectionCard(
  title: 'Results',
  noPadding: true,
  child: DataTable(/* … */),
)
```

---

## 11. Responsive design rules

### Breakpoints (`lib/design_system/breakpoints.dart`)

Constants are **private** inside the class; use helpers only:

- **Mobile:** `AppBreakpoints.isMobileWidth(w)` → `w < 600`
- **Tablet:** `AppBreakpoints.isTabletWidth(w)` → `600 <= w < 1024`
- **Desktop:** `AppBreakpoints.isDesktopWidth(w)` → `w >= 1024`

There is **no** `AppBreakpoints.isMobile(context)` — pass **`MediaQuery.sizeOf(context).width`** (or `constraints.maxWidth` from `LayoutBuilder`).

### Usage

```dart
final w = MediaQuery.sizeOf(context).width;
if (AppBreakpoints.isMobileWidth(w)) { /* … */ }
```

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final w = constraints.maxWidth;
    return AppBreakpoints.isDesktopWidth(w)
        ? const _DesktopLayout()
        : const _StackedLayout();
  },
)
```

**Templates with internal responsiveness:** `DashboardTemplate`, `DetailTemplate`, `AuthTemplate`, `AppShell`, `AppListingScreen` (table vs mobile cards, filter panel vs bottom sheet).

---

## 12. State management — Provider + GetIt

### GetIt service locator

All singletons are registered in:

- `lib/core/di/service_locator.dart`

Access from anywhere **outside the widget tree**:

```text
sl<ThemeNotifier>()
sl<SharedPreferences>()
sl<ApiClient>()          ← TO BE BUILT
```

### Provider (widget tree)

Feature-scoped `ChangeNotifier` providers. **Register at the route level, not the app level** (except `ThemeNotifier`, which is app-wide via `ChangeNotifierProvider<ThemeNotifier>.value` in `main.dart`).

**Pattern for every feature provider:**

```dart
class XProvider extends BaseProvider {
  List<XModel> _items = [];
  List<XModel> get items => _items;

  Future<void> fetchAll() async {
    await runAsync(() async {
      _items = await sl<XApi>().fetchAll();
      notifyListeners();
    });
  }

  Future<void> create(XDto dto) async {
    await runAsync(() async {
      await sl<XApi>().create(dto);
      await fetchAll();
    });
  }
}
```

**Intended feature layout (small single-domain feature):**

```text
features/<name>/
  data/<name>_api.dart
  state/<name>_provider.dart
  state/<name>_state.dart   // optional
  ui/<name>_screen.dart
```

**Large module with product sub-areas** (e.g. User Management): use **`features/<module>/<sub_module>/data|state|ui/`** plus **`features/<module>/shared/`** for module-local shared UI—see **§3 User Management and other large modules** above. Do not default to `ui/sub_modules/…` for new work in those cases.

**How to provide at route level:**

```dart
ChangeNotifierProvider(
  create: (_) => XProvider()..fetchAll(),
  child: const XScreen(),
)
```

**How to consume in widgets:**

```dart
// Watch (rebuilds on change):
final provider = context.watch<XProvider>();

// Read (no rebuild, for actions):
context.read<XProvider>().create(dto);
```

`AppListingScreen` should receive `rows` / callbacks from a widget that **`context.watch`**es the feature provider.

#### NEVER

- `setState` for server data in real features
- Direct API calls from widgets (use providers + `sl<…Api>()`)
- Global variables for app state
- **App-level providers for feature data** (only `ThemeNotifier` is app-level)

**Never (for server-backed data):** global mutable singletons for **session** state—use GetIt-registered services and a dedicated auth session pattern when built.

---

## 13. Navigation — GoRouter rules

`MaterialApp.router` in `lib/main.dart` uses **`appRouter`** from `lib/core/router/app_router.dart` (`initialLocation: '/dashboard'`; `/` redirects to `/dashboard`).

**From widgets:** use `context.go` / `context.push`; avoid raw `Navigator.push` for app-level navigation.

### Route structure

All authenticated routes are wrapped in **`ShellRoute`**, which mounts **`AppShell`** via **`ShellScreen`**.

**`ShellScreen`:**

- Exposes the full **nav config** as `appNavItems` in `lib/features/shell/shell_screen.dart` (kept in sync with registered routes).
- Passes the **`child`** from the `ShellRoute` builder (nested navigator outlet) to **`AppShell`**. That child is the active **`GoRoute`** page (e.g. a module screen or `ComingSoonScreen`).
- On nav item selection, calls **`context.go(path)`** and updates **`_currentPath`** for active state in the sidebar.
- Tracks **`_currentPath`** from **`GoRouterState.uri.path`** so the shell stays aligned when the location changes (including `didUpdateWidget` when the router state updates).

**Auth guard:** redirect unauthenticated users to `/login` using auth state (e.g. a `Listenable` / `ChangeNotifier` + `GoRouter`’s `refreshListenable`). **TO BE BUILT.**

### All routes (current)

| Path | Notes |
|------|--------|
| `/` | Redirects to `/dashboard` |
| `/dashboard` | |
| `/transactions` | |
| `/transactions/sample-receipt` | |
| `/transactions/lab-code` | |
| `/masters` | |
| `/masters/customer` | |
| `/masters/site` | |
| `/masters/courier` | |
| `/masters/plant` | |
| `/masters/bank` | |
| `/masters/item` | |
| `/masters/equipment` | |
| `/masters/sample-type` | |
| `/masters/grade` | |
| `/masters/department` | |
| `/masters/designation` | |
| `/masters/test` | |
| `/masters/method` | |
| `/masters/instrument` | |
| `/masters/parameter` | |
| `/masters/unit` | |
| `/masters/storage` | |
| `/housekeeping` | |
| `/reports` | |
| `/users` | |
| `/login` | **TO BE BUILT** (auth phase) |
| `/settings` | **Not registered yet** — add when product needs it |

### Coming soon pattern

Any module that is not implemented yet is represented by a **`GoRoute`** whose builder returns **`ComingSoonScreen(moduleName: '…', subtitle: '…')`**.

- Do **not** leave a **route** without a **builder** (or equivalent).
- Do **not** use a one-off **placeholder** `Scaffold` directly in **`app_router.dart`**; use **`ComingSoonScreen`**.

### Adding a new route

1. Add a **`GoRoute`** to **`appRouter`**, inside the **`ShellRoute`’s `routes`**, with the full path and builder (or **`ComingSoonScreen`** until the real UI exists).
2. Add a matching **`NavItem`** to **`appNavItems`** in **`shell_screen.dart`** (path and label; optional **`sectionLabel`** and **`children`** for nested items).
3. When the feature is ready, **replace** **`ComingSoonScreen`** in that route’s **builder** with the real **screen** widget.

---

## 14. Dependency injection — GetIt rules

**Register order in `setupServiceLocator()`:**

1. `SharedPreferences` (async singleton)
2. `ThemeNotifier` (singleton, needs config loaded; uses persisted `ThemeConfig`)
3. `ApiClient` (singleton, needs prefs for token) — **TO BE BUILT**
4. Feature APIs (lazy singletons) — **TO BE BUILT** per feature

- Services and APIs **→** GetIt (`sl`)
- UI state **→** Provider (`ChangeNotifier` / `BaseProvider`)
- **Never** inject UI providers into GetIt
- **Never** use `sl()` inside the `build()` method — use `context.watch` / `context.read` for UI-facing state

---

## 15. API layer rules

**TO BE BUILT** — no `lib/core/api/client.dart`, no feature APIs, no Dio.

**Intended conventions:**

- `lib/core/api/client.dart` — shared `Dio` (or chosen HTTP client).
- `lib/features/<x>/data/<x>_api.dart` — feature endpoints (or `lib/features/<module>/<sub_module>/data/…` when the module is split by sub-domain, e.g. `user_management/departments/data/departments_api.dart`).
- Base URL from environment / flavor config; auth token from secure storage; centralized **401** → clear session → **login** redirect; timeouts (e.g. connect 10s, receive 30s) as project policy.
- Each API function: single responsibility; return **typed models** (not `Map<String, dynamic>`); throw **typed** errors, not raw `DioException`.

---

## 16. Self-check before every file

**Architecture**

- Import design-system widgets from **`components.dart`** where exported; **`kpi_metric.dart`** until barrel includes it.
- **`AppTokens`** for colors, spacing, and layout sizes that exist on tokens.
- **`Theme.of(context)`** for semantic scheme / text roles where appropriate.
- No stray hex colors / arbitrary pixel literals for things covered by tokens.
- No cross-feature imports (when features exist).
- **ShellRoute / `AppShell` child screens:**
  - ☐ Screen is inside **`ShellRoute`**? → **No** `Scaffold`, **no** `AppBar`. → Return the **content** widget directly. → **`Column`** must use **`mainAxisSize: MainAxisSize.min`**, or sit inside **`Expanded`** / **`SingleChildScrollView`** (the shell body is scrollable—avoid nested unbounded `Scaffold` + `Center` + `Column`).
  - `ShellScreen` + `AppShell` already provide chrome. Use **`Center`**, **`SingleChildScrollView`**, **`Column`** as needed (see Section 7 / `AppShell` scroll).

**Components**

- Prefer **`AppButton`** over raw `ElevatedButton` / `FilledButton` for product UI.
- Prefer **`AppInput`** over raw `TextField` for forms.
- **`StatusChip`** in table status cells; **`AppBadge`** for compact labels/counts.
- Form tier rules (Section 9 — Form Template Rules).

**Responsive**

- Exercise **375 / 768 / 1280** widths while building screens.
- Use **`AppBreakpoints` width helpers**, not magic `600` / `1024` literals.

**State**

- No `setState`-driven server lists in real features.
- Async data in feature `ChangeNotifier` providers extending `BaseProvider`, with APIs from `sl<…>()`.

**Quality**

- `flutter analyze` clean on changed files.
- Explicit types on public APIs.

---

## 17. Module scaffolding guide

Use when adding **`lib/features/<module>/…`** for the first time.

1. Create `data/`, `state/`, `ui/` under the module (or under **`features/<module>/<sub_module>/`** when the module has multiple product sub-areas; see §3). Prefer **`shared/`** for module-local shared UI instead of `ui/sub_modules/` when splitting by sub-domain.
2. **API:** class with client, `fetchAll`, `fetchById`, `create`, `update`, `delete` as required; register the API in GetIt (lazy singleton) and inject `ApiClient` / prefs as needed.
3. **Provider:** `ChangeNotifier` extending `BaseProvider`; `fetchAll` in `runAsync`; route-level `ChangeNotifierProvider` wraps the screen.
4. **Screen:** default **`AppListingScreen<Model>`** with columns, `rowActions`, `mobileCardBuilder`, forms (`AppFormModal` / `AppFormDrawer` / `AppFormPage` per Section 9), or `AlertDialog` + **`AppButton`** for destructive confirm until **`AppConfirmDialog`** exists.

   **IMPORTANT:** Routes registered **inside** the shell (`ShellRoute`) must **not** use **`Scaffold`** or **`AppBar`**. The shell already provides layout and top bar. Start the screen with content only, for example:

   - **Do:** `return SingleChildScrollView(child: …);`, `return Column(children: […]);` (with `mainAxisSize: MainAxisSize.min` or proper scroll/expanded when needed).
   - **Don’t:** `return Scaffold(body: …);` or an `AppBar` in the feature screen.

5. **Register** GoRouter route(s).
6. **Add** `NavItem` to shell `navItems`.

---

## 18. Common Claude Code prompts

Start prompts with:

> Read FLUTTER_CLAUDE.md first. Then: …

**New master sub-module**

> Read FLUTTER_CLAUDE.md. Add a new master sub-module called [Name] with fields: […]. Follow the module scaffolding guide. Use the form tier that matches field count (Section 9 — `AppFormModal` / `AppFormDrawer` / `AppFormPage`).

**Audit**

> Read FLUTTER_CLAUDE.md. Audit `lib/` for hardcoded colors/spacing, direct component imports, cross-feature imports, `Colors.*`, raw `TextField`/`ElevatedButton`. List violations and fix.

**Reset drift**

> Stop. Read FLUTTER_CLAUDE.md again. You broke rule [section]: [issue]. Rewrite to match the document.

---

*End of FLUTTER_CLAUDE.md*
