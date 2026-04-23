# FLUTTER_CLAUDE.md

Canonical guardrails for the **limsv1** Flutter codebase. Rules match **what exists in the repository today** (design system + shell preview). Items not present in `lib/` or `pubspec.yaml` are labeled **TO BE BUILT** with the intended pattern.

---

## 1. What this project is

**Ultra LIMS** (`MaterialApp` title in `lib/main.dart`) is a Flutter app scaffolded as a **laboratory information management–style portal**. The runnable app today is a **shell preview**: `AppShell` with sample `NavItem`s and placeholder page content—**no business features, API, or routing layer** are implemented yet.

**Product modules (target areas, not yet under `lib/features/`):** the repo does not define sub-module folders or counts. When feature work starts, a typical seven-area LIMS split aligned with the route naming guide (Section 13) is:

| # | Module        | Implemented sub-modules in repo |
|---|---------------|-----------------------------------|
| 1 | Dashboard     | **0** |
| 2 | Transactions  | **0** |
| 3 | Masters       | **0** |
| 4 | Housekeeping  | **0** |
| 5 | Reports       | **0** |
| 6 | Users         | **0** |
| 7 | Settings      | **0** |

Treat sub-module counts as **to be established** when `lib/features/<module>/` is added.

---

## 2. Tech stack

Exact dependency constraints from `pubspec.yaml` (SDK and declared packages):

| Package | Role |
|---------|------|
| `flutter` (SDK `^3.11.5`) | UI framework |
| `cupertino_icons` `^1.0.8` | Optional Cupertino icon font (default template dep) |
| `shared_preferences` `^2.5.3` | Persists sidebar expanded state (`AppShell`) and theme config (`ThemeConfig` / `ThemeNotifier` in `app_theme.dart`) |
| `lucide_flutter` `^1.7.0` | Sidebar, topbar, listing, error icons |
| `flutter_test` (SDK) | Unit/widget tests |
| `flutter_lints` `^6.0.0` | Static analysis rules |

**Not in `pubspec.yaml` yet (TO BE BUILT):** `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, code generation packages, etc.

**Fonts:** `AppTheme` sets `fontFamily: 'Inter'`. The pubspec does **not** declare Inter font assets or `google_fonts`; ensure Inter is bundled or switch to a registered family before shipping.

---

## 3. Project structure

**Actual tree** (only paths that exist). `lib/core/` and `lib/features/` **do not exist** yet.

```text
lib/
  main.dart
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
      templates/
        auth_template.dart
        dashboard_template.dart
        detail_template.dart
        error_template.dart
        section_card.dart
        template_pulse.dart
```

**Planned (not created):**

- `lib/core/` — shared API client, env config, auth helpers.
- `lib/features/<module>/` — one folder per product module when implemented.

---

## 4. Design tokens — CRITICAL

All visual constants live on **`AppTokens`** (`lib/design_system/tokens.dart`): flat static getters only (no nested `AppTokens.colors` object).

### How to use tokens

**Colors (examples):** `AppTokens.primary900` … `primary50`, `accent600` … `accent50`, `neutral900` … `neutral50`, `success500` / `success100` / `success50`, `warning500` / `warning100` / `warning50`, `error500` / `error100` / `error50`, `info500` / `info100` / `info50`, `white`, `surfaceCard`, `background`, `border`, `borderLight`, `filledSecondarySurface`.

**Spacing (4px base):** `space0`, `space1` (4), `space2` (8), `space3` (12), `space4` (16), `space5` (20), `space6` (24), `space8` (32), `space10` (40), `space12` (48).

**Radius:** `radiusSm`, `radiusMd`, `radiusLg`, `radiusXl`, `radiusFull`.

**Typography sizes:** `textXs` … `text3xl`. **Weights:** `weightRegular`, `weightMedium`, `weightSemibold`.

**Sizing / chrome:** `buttonHeightSm` / `Md` / `Lg`, `inputHeight`, `inputHeightLg`, `tableRowHeight`, `listingSearchWidthTablet` / `Desktop`, `listingFilterPanelWidth`, `tableCheckboxColumnWidth`, `tableActionsColumnWidth`, `tableToggleColumnWidth`, `topbarHeight`, `topbarSearchWidthTablet` / `Desktop`, `sidebarExpanded`, `sidebarCollapsed`, `navItemHeight`, border widths, `iconSizeMd`, `iconButtonIconSm` / `Md`, `inlineProgressIndicatorSize`, `inlineProgressIndicatorStrokeWidth`, `badgeHeight`, `avatarSizeXs` / `Sm`, `disabledOpacity`, `opacityFull`, `statusChipHeight`, `luminanceInkThreshold`, `elevationPopupMenu`, `overlayPrimaryAlpha`.

**Shadows:** `AppTokens.shadowSm`, `shadowMd`, `shadowLg` — each is `List<BoxShadow>`.

**Semantic / theme colors:** Prefer `Theme.of(context).colorScheme` / `textTheme` for values that must track light/dark (Section 5). Use `AppTokens` for explicit brand neutrals and layout metrics.

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

`lib/main.dart` currently imports `app_shell.dart` and `nav_item.dart` directly—when touching `main.dart`, align with the barrel rule above.

### Cross-feature imports

**TO BE BUILT** — no `lib/features/` yet. Intended rule:

- Allowed: relative imports within the same feature; `package:limsv1/core/...` for shared core.
- Forbidden: `../../other_feature/...` imports across feature boundaries.

### Theme access

- Prefer `Theme.of(context).colorScheme.*` and `Theme.of(context).textTheme.*` for semantic text and surfaces.
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

`AppSidebar` bottom includes **Help & Docs** (fixed row; `onTap` is currently empty in `_HelpRow`—wire when needed).

Example:

```dart
navItems: [
  NavItem(
    path: '/dashboard',
    label: 'Dashboard',
    sectionLabel: 'CORE',
    icon: Icon(LucideIcons.layoutDashboard,
        size: AppTokens.iconButtonIconMd, color: AppTokens.neutral400),
  ),
  NavItem(
    path: '/samples',
    label: 'Samples',
    sectionLabel: 'LAB',
    icon: Icon(LucideIcons.testTube2,
        size: AppTokens.iconButtonIconMd, color: AppTokens.neutral400),
  ),
  NavItem(
    path: '/assays',
    label: 'Assays',
    icon: Icon(LucideIcons.microscope,
        size: AppTokens.iconButtonIconMd, color: AppTokens.neutral400),
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

**TO BE BUILT (GoRouter):** today `main.dart` uses `setState` to swap `_path`. With GoRouter, pass `currentPath` from `GoRouterState.uri.path` (or similar) and in `onPathSelected` call `context.go(path)` (see Section 13).

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

- **Desktop** (`width >= 1024`): Persistent sidebar + edge chevron. Default expanded if no saved preference (first frame uses width). **Logo row** calls `onExpandFromLogo` when collapsed to expand. **Chevron** toggles expand/collapse and persists to `SharedPreferences` key `interics:sidebar_expanded`.
- **Tablet** (`600–1023`): Persistent **rail**; initial expansion from same preference logic (collapsed when width `< 1024` on first load if no key). Logo tap expands from collapsed rail; chevron hidden on non-desktop in shell (chevron only when `showEdgeChevron: desktop`).
- **Mobile** (`width < 600`): **Drawer**; menu button on `AppTopbar` opens it; `AppShell` closes drawer on route change (`didUpdateWidget` when `currentPath` changes) and after `onPathSelected` on mobile.

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

## 9. Form templates — CRITICAL DECISION RULES

The following files are **not present** in the repository:  
`app_form_modal.dart`, `app_form_drawer.dart`, `app_form_page.dart`, `app_form_section.dart`, `app_form_field_row.dart`, `app_confirm_dialog.dart`.

**Status: TO BE BUILT.** Intended tiering (keep when implementing):

| Scenario | Component |
|----------|-------------|
| ≤6 fields, simple | `AppFormModal` |
| 7–15 fields, sectioned | `AppFormDrawer` |
| Nested tables / line items | `AppFormPage` |
| Destructive confirm only | `AppConfirmDialog` |

Until those widgets exist, use Flutter’s `showDialog` / `showModalBottomSheet` / full routes with **`AppInput`**, **`AppButton`**, and **`AppTokens`** styling, or add the shared form components under `lib/design_system/components/forms/` and export them from `components.dart`.

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

## 12. State management — Riverpod patterns

**TO BE BUILT** — Riverpod is not a dependency yet; `main.dart` uses `StatefulWidget` + `setState` for the shell preview only.

**Intended layout:**

```text
features/<name>/
  data/<name>_api.dart
  state/<name>_provider.dart
  state/<name>_state.dart   // optional
  ui/<name>_screen.dart
  ui/sub_modules/<sub_name>/   // when needed
```

**Intended patterns:**

- **`AsyncNotifierProvider`** (or equivalent) for list + detail loads.
- **`AppListingScreen`** receives `rows` / callbacks from a widget that **`ref.watch`**es the provider.

**Never (for server-backed data):**

- `setState` as the primary pattern for fetched lists/details in real features.
- Direct `Dio` / HTTP calls inside leaf widgets.
- Global mutable singletons for session data.

---

## 13. Navigation — GoRouter rules

**TO BE BUILT** — the app uses `MaterialApp(home: …)` without `go_router`.

**Target path conventions:**

- `/dashboard`
- `/transactions`, `/transactions/:id`
- `/masters`, `/masters/:subModule`, `/masters/:subModule/:id`
- `/housekeeping`
- `/reports`
- `/users`
- `/settings`
- `/login`

**Auth guard:** redirect unauthenticated users to `/login` based on auth state (Riverpod + `GoRouter` refresh). **TO BE BUILT.**

**From widgets (when GoRouter exists):** use `context.go` / `context.push`; avoid raw `Navigator.push` for app-level navigation.

---

## 14. API layer rules

**TO BE BUILT** — no `lib/core/api/client.dart`, no feature APIs, no Dio.

**Intended conventions:**

- `lib/core/api/client.dart` — shared `Dio` (or chosen HTTP client).
- `lib/features/<x>/data/<x>_api.dart` — feature endpoints.
- Base URL from environment / flavor config; auth token from secure storage; centralized **401** → clear session → **login** redirect; timeouts (e.g. connect 10s, receive 30s) as project policy.
- Each API function: single responsibility; return **typed models** (not `Map<String, dynamic>`); throw **typed** errors, not raw `DioException`.

---

## 15. Self-check before every file

**Architecture**

- Import design-system widgets from **`components.dart`** where exported; **`kpi_metric.dart`** until barrel includes it.
- **`AppTokens`** for colors, spacing, and layout sizes that exist on tokens.
- **`Theme.of(context)`** for semantic scheme / text roles where appropriate.
- No stray hex colors / arbitrary pixel literals for things covered by tokens.
- No cross-feature imports (when features exist).

**Components**

- Prefer **`AppButton`** over raw `ElevatedButton` / `FilledButton` for product UI.
- Prefer **`AppInput`** over raw `TextField` for forms.
- **`StatusChip`** in table status cells; **`AppBadge`** for compact labels/counts.
- Form tier rules (Section 9) once form components exist.

**Responsive**

- Exercise **375 / 768 / 1280** widths while building screens.
- Use **`AppBreakpoints` width helpers**, not magic `600` / `1024` literals.

**State**

- No `setState`-driven server lists in real features (preview-only today).
- Async data in providers once Riverpod lands.

**Quality**

- `flutter analyze` clean on changed files.
- Explicit types on public APIs.

---

## 16. Module scaffolding guide

Use when adding **`lib/features/<module>/…`** for the first time.

1. Create `data/`, `state/`, `ui/` (and `ui/sub_modules/` if needed).
2. **API:** class with client, `fetchAll`, `fetchById`, `create`, `update`, `delete` as required.
3. **Provider:** `AsyncNotifier` + provider; `build()` loads list; mutations refresh.
4. **Screen:** default **`AppListingScreen<Model>`** with columns, `rowActions`, `mobileCardBuilder`, forms (`AppFormModal` / … when built), `AppConfirmDialog` for delete when available.
5. **Register** GoRouter route(s).
6. **Add** `NavItem` to shell `navItems`.

---

## 17. Common Claude Code prompts

Start prompts with:

> Read FLUTTER_CLAUDE.md first. Then: …

**New master sub-module**

> Read FLUTTER_CLAUDE.md. Add a new master sub-module called [Name] with fields: […]. Follow the module scaffolding guide. Use the form tier that matches field count (forms TO BE BUILT — implement or use interim dialogs).

**Audit**

> Read FLUTTER_CLAUDE.md. Audit `lib/` for hardcoded colors/spacing, direct component imports, cross-feature imports, `Colors.*`, raw `TextField`/`ElevatedButton`. List violations and fix.

**Reset drift**

> Stop. Read FLUTTER_CLAUDE.md again. You broke rule [section]: [issue]. Rewrite to match the document.

---

*End of FLUTTER_CLAUDE.md*
