import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';

/// Full-page layout for master-detail screens (breadcrumb, header card, tabs).
///
/// When [tabLabels] has a single entry, the tab strip is omitted and [tabViews.first]
/// fills the lower panel — no [tabController] is needed (pass `null`).
/// When there are multiple tabs, [tabController] must be non-null.
class DetailTemplate extends StatelessWidget {
  const DetailTemplate({
    super.key,
    required this.parentLabel,
    required this.parentRoute,
    required this.currentLabel,
    this.headerCard,
    required this.tabLabels,
    required this.tabViews,
    this.tabController,
    this.lockNonOverviewTabs = false,
    this.overviewTabIndex = 0,
    this.plainTabPanel = false,
    this.onBreadcrumbBack,

    /// Optional left-most crumb (e.g. `Transactions` → [parent] → [current]).
    this.rootBreadcrumbLabel,
    this.rootBreadcrumbRoute,
  }) : assert(
         tabLabels.length == tabViews.length,
         'tabLabels and tabViews must have the same length',
       ),
       assert(overviewTabIndex >= 0, 'overviewTabIndex must be non-negative'),
       assert(
         tabLabels.length == 1 ||
             (tabLabels.length > 1 && tabController != null),
         'DetailTemplate: use tabController when tabLabels.length > 1; '
         'omit tabController when tabLabels.length == 1',
       ),
       assert(
         tabLabels.length > 1 || tabViews.length == 1,
         'DetailTemplate: single-tab mode expects exactly one tab view',
       ),
       assert(
         (rootBreadcrumbLabel == null && rootBreadcrumbRoute == null) ||
             (rootBreadcrumbLabel != null && rootBreadcrumbRoute != null),
         'DetailTemplate: set both rootBreadcrumbLabel and rootBreadcrumbRoute, or neither',
       );

  final String parentLabel;
  final String parentRoute;
  final String currentLabel;

  /// When set with [rootBreadcrumbRoute], breadcrumb is:
  /// `[root]` > `[parentLabel]` > `[currentLabel]`.
  final String? rootBreadcrumbLabel;
  final String? rootBreadcrumbRoute;

  /// Optional summary/header region below the breadcrumb. When null, the spacing
  /// and container for this block are omitted so the tab panel sits flush under
  /// the breadcrumb (used by embedded workspaces).
  final Widget? headerCard;
  final List<String> tabLabels;
  final List<Widget> tabViews;
  final TabController? tabController;

  /// When true, non-overview tabs show disabled styling and forbidden cursor.
  final bool lockNonOverviewTabs;

  /// Index of the overview / primary tab (usually `0`).
  final int overviewTabIndex;

  /// When true with a single tab, tab content is not wrapped in the bordered white
  /// panel — embedders compose their own section chrome ([SupervisorReviewWorkspaceScreen]).
  final bool plainTabPanel;

  /// When set, invoked instead of [Navigator.pop] when the breadcrumb back
  /// button is pressed (e.g. GoRouter with a fallback route).
  final VoidCallback? onBreadcrumbBack;

  @override
  Widget build(BuildContext context) {
    final multiTab = tabLabels.length > 1;
    final controller = tabController;

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BreadcrumbRow(
              rootLabel: rootBreadcrumbLabel,
              rootRoute: rootBreadcrumbRoute,
              parentLabel: parentLabel,
              parentRoute: parentRoute,
              currentLabel: currentLabel,
              onBack: onBreadcrumbBack,
            ),
            SizedBox(height: AppTokens.space3),
            if (headerCard != null) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTokens.white,
                  border: Border.all(color: AppTokens.border),
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                padding: EdgeInsets.all(AppTokens.space4),
                child: headerCard!,
              ),
              SizedBox(height: AppTokens.space3),
            ],
            Expanded(
              child: plainTabPanel && !multiTab
                  ? tabViews.first
                  : Container(
                      decoration: BoxDecoration(
                        color: AppTokens.white,
                        border: Border.all(color: AppTokens.border),
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (multiTab) ...[
                            TabBar(
                              controller: controller!,
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              tabs: List.generate(tabLabels.length, (i) {
                                final label = tabLabels[i];
                                final locked =
                                    lockNonOverviewTabs &&
                                    i != overviewTabIndex;
                                if (!locked) {
                                  return Tab(text: label);
                                }
                                return Tab(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.forbidden,
                                    child: Text(
                                      label,
                                      style: GoogleFonts.poppins(
                                        fontSize: AppTokens.textBase,
                                        fontWeight: AppTokens.weightRegular,
                                        color: AppTokens.textDisabled,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              indicatorColor: AppTokens.accent500,
                              labelColor: AppTokens.accent500,
                              unselectedLabelColor: AppTokens.textMuted,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppTokens.textBase,
                                fontWeight: AppTokens.weightMedium,
                              ),
                              unselectedLabelStyle: GoogleFonts.poppins(
                                fontSize: AppTokens.textBase,
                                fontWeight: AppTokens.weightRegular,
                              ),
                            ),
                            Divider(
                              height: AppTokens.borderWidthSm,
                              thickness: AppTokens.borderWidthSm,
                              color: AppTokens.border,
                            ),
                          ],
                          Expanded(
                            child: multiTab
                                ? TabBarView(
                                    controller: controller!,
                                    children: tabViews,
                                  )
                                : tabViews.first,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbRow extends StatelessWidget {
  const _BreadcrumbRow({
    this.rootLabel,
    this.rootRoute,
    required this.parentLabel,
    required this.parentRoute,
    required this.currentLabel,
    this.onBack,
  });

  final String? rootLabel;
  final String? rootRoute;
  final String parentLabel;
  final String parentRoute;
  final String currentLabel;
  final VoidCallback? onBack;

  Widget _crumbLink(BuildContext context, String label, String route) {
    return Flexible(
      flex: 2,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppTokens.spaceHalf,
            horizontal: AppTokens.space1,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppTokens.primary800,
              fontWeight: AppTokens.weightMedium,
              fontSize: AppTokens.bodySize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chevron() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
      child: Icon(
        LucideIcons.chevronRight,
        size: AppTokens.iconButtonIconSm,
        color: AppTokens.textMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRoot = rootLabel != null && rootRoute != null;
    return Row(
      children: [
        IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (onBack != null) {
              onBack!();
              return;
            }
            Navigator.of(context).pop();
          },
          color: AppTokens.primary800,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: AppTokens.iconButtonIconMd + AppTokens.space2,
            minHeight: AppTokens.iconButtonIconMd + AppTokens.space2,
          ),
          iconSize: AppTokens.iconButtonIconMd,
          visualDensity: VisualDensity.compact,
        ),
        if (hasRoot) ...[
          _crumbLink(context, rootLabel!, rootRoute!),
          _chevron(),
        ],
        _crumbLink(context, parentLabel, parentRoute),
        _chevron(),
        Expanded(
          child: Text(
            currentLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppTokens.textMuted,
              fontWeight: AppTokens.weightRegular,
              fontSize: AppTokens.bodySize,
            ),
          ),
        ),
      ],
    );
  }
}
