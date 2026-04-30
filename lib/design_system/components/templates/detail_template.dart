import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';

/// Full-page layout for master-detail screens (breadcrumb, header card, tabs).
class DetailTemplate extends StatelessWidget {
  const DetailTemplate({
    super.key,
    required this.parentLabel,
    required this.parentRoute,
    required this.currentLabel,
    required this.headerCard,
    required this.tabLabels,
    required this.tabViews,
    required this.tabController,
    this.lockNonOverviewTabs = false,
    this.overviewTabIndex = 0,
  }) : assert(
          tabLabels.length == tabViews.length,
          'tabLabels and tabViews must have the same length',
        ),
       assert(overviewTabIndex >= 0, 'overviewTabIndex must be non-negative');

  final String parentLabel;
  final String parentRoute;
  final String currentLabel;
  final Widget headerCard;
  final List<String> tabLabels;
  final List<Widget> tabViews;
  final TabController tabController;

  /// When true, non-overview tabs show disabled styling and forbidden cursor.
  final bool lockNonOverviewTabs;

  /// Index of the overview / primary tab (usually `0`).
  final int overviewTabIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BreadcrumbRow(
            parentLabel: parentLabel,
            parentRoute: parentRoute,
            currentLabel: currentLabel,
          ),
          SizedBox(height: AppTokens.space3),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTokens.white,
              border: Border.all(color: AppTokens.border),
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            ),
            padding: EdgeInsets.all(AppTokens.space4),
            child: headerCard,
          ),
          SizedBox(height: AppTokens.space3),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTokens.white,
                border: Border.all(color: AppTokens.border),
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    controller: tabController,
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    tabs: List.generate(tabLabels.length, (i) {
                      final label = tabLabels[i];
                      final locked =
                          lockNonOverviewTabs && i != overviewTabIndex;
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
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: tabViews,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbRow extends StatelessWidget {
  const _BreadcrumbRow({
    required this.parentLabel,
    required this.parentRoute,
    required this.currentLabel,
  });

  final String parentLabel;
  final String parentRoute;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
          color: AppTokens.primary800,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: AppTokens.iconButtonIconMd + AppTokens.space2,
            minHeight: AppTokens.iconButtonIconMd + AppTokens.space2,
          ),
          iconSize: AppTokens.iconButtonIconMd,
          visualDensity: VisualDensity.compact,
        ),
        InkWell(
          onTap: () => context.go(parentRoute),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppTokens.spaceHalf,
              horizontal: AppTokens.space1,
            ),
            child: Text(
              parentLabel,
              style: GoogleFonts.poppins(
                color: AppTokens.primary800,
                fontWeight: AppTokens.weightMedium,
                fontSize: AppTokens.bodySize,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
          child: Icon(
            LucideIcons.chevronRight,
            size: AppTokens.iconButtonIconSm,
            color: AppTokens.textMuted,
          ),
        ),
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
