import 'package:flutter/material.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../cards/app_card.dart';
import '../display/app_badge.dart';
import 'template_pulse.dart';

/// Status pill metadata for the detail header.
class StatusInfo {
  const StatusInfo({
    required this.label,
    required this.color,
  });

  final String label;
  final AppBadgeColor color;
}

/// Metric shown in the desktop detail header.
class DetailHeaderStat {
  const DetailHeaderStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

/// One tab in [DetailTemplate].
class DetailTab {
  const DetailTab({
    required this.key,
    required this.label,
    this.icon,
    required this.content,
  });

  /// Logical tab id (not a [Widget] key).
  final String key;
  final String label;
  final Widget? icon;
  final Widget content;
}

/// Standard detail / record view with tabs and optional right panel.
class DetailTemplate extends StatefulWidget {
  const DetailTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.breadcrumbParent,
    this.onBreadcrumbTap,
    this.avatar,
    this.statusBadges,
    this.headerStats,
    this.headerActions,
    required this.tabs,
    this.initialTab = 0,
    this.sidePanel,
    this.sidePanelWidth = AppTokens.listingFilterPanelWidth,
    this.isLoading = false,
  });

  final String title;
  final String? subtitle;
  final String breadcrumbParent;
  final VoidCallback? onBreadcrumbTap;
  final Widget? avatar;
  final List<StatusInfo>? statusBadges;
  final List<DetailHeaderStat>? headerStats;
  final List<Widget>? headerActions;
  final List<DetailTab> tabs;
  final int initialTab;
  final Widget? sidePanel;
  final double sidePanelWidth;
  final bool isLoading;

  @override
  State<DetailTemplate> createState() => _DetailTemplateState();
}

class _DetailTemplateState extends State<DetailTemplate> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = _clampTab(widget.initialTab);
  }

  @override
  void didUpdateWidget(covariant DetailTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabIndex = _clampTab(widget.initialTab);
    }
  }

  int _clampTab(int i) {
    if (widget.tabs.isEmpty) {
      return 0;
    }
    if (i < 0) {
      return 0;
    }
    if (i >= widget.tabs.length) {
      return widget.tabs.length - 1;
    }
    return i;
  }

  Color _divider(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral200;
  }

  Color _breadcrumbBorder(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral100;
  }

  EdgeInsets _tabContentPadding() {
    return EdgeInsets.symmetric(
      horizontal: AppTokens.space6,
      vertical: AppTokens.space4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final desktop = AppBreakpoints.isDesktopWidth(width);
    final hasSide = widget.sidePanel != null;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailBreadcrumbBar(
            theme: theme,
            parentLabel: widget.breadcrumbParent,
            currentTitle: widget.title,
            onParentTap: widget.onBreadcrumbTap,
            borderColor: _breadcrumbBorder(context),
          ),
          if (widget.isLoading)
            Expanded(
              child: TemplatePulse(
                child: _DetailLoadingBody(
                  theme: theme,
                  tabContentPadding: _tabContentPadding(),
                ),
              ),
            )
          else ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space6,
                vertical: AppTokens.space4,
              ),
              child: _DetailEntityHeader(
                theme: theme,
                title: widget.title,
                subtitle: widget.subtitle,
                avatar: widget.avatar,
                statusBadges: widget.statusBadges,
                headerStats: widget.headerStats,
                headerActions: widget.headerActions,
                showStats: desktop,
              ),
            ),
            _DetailTabStrip(
              theme: theme,
              tabs: widget.tabs,
              selected: _tabIndex,
              onSelect: (i) => setState(() => _tabIndex = i),
              dividerColor: _divider(context),
            ),
            Expanded(
              child: widget.tabs.isEmpty
                  ? const SizedBox.shrink()
                  : _DetailTabBody(
                      theme: theme,
                      desktop: desktop,
                      hasSidePanel: hasSide,
                      sidePanelWidth: widget.sidePanelWidth,
                      sidePanel: widget.sidePanel,
                      tab: widget.tabs[_tabIndex],
                      tabContentPadding: _tabContentPadding(),
                      dividerColor: _divider(context),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailBreadcrumbBar extends StatelessWidget {
  const _DetailBreadcrumbBar({
    required this.theme,
    required this.parentLabel,
    required this.currentTitle,
    this.onParentTap,
    required this.borderColor,
  });

  final ThemeData theme;
  final String parentLabel;
  final String currentTitle;
  final VoidCallback? onParentTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: AppTokens.borderWidthHairline,
          ),
        ),
      ),
      child: SizedBox(
        height: AppTokens.space10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space6),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '\u2190 ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.neutral500
                            : AppTokens.neutral400,
                      ),
                    ),
                    if (onParentTap != null)
                      TextButton(
                        onPressed: onParentTap,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTokens.space2,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          parentLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? AppTokens.neutral300
                                : AppTokens.neutral600,
                            fontWeight: AppTokens.weightMedium,
                          ),
                        ),
                      )
                    else
                      Text(
                        parentLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? AppTokens.neutral400
                              : AppTokens.neutral500,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
                      child: Text(
                        '>',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? AppTokens.neutral500
                              : AppTokens.neutral400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : AppTokens.neutral900,
                          fontWeight: AppTokens.weightMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailEntityHeader extends StatelessWidget {
  const _DetailEntityHeader({
    required this.theme,
    required this.title,
    this.subtitle,
    this.avatar,
    this.statusBadges,
    this.headerStats,
    this.headerActions,
    required this.showStats,
  });

  final ThemeData theme;
  final String title;
  final String? subtitle;
  final Widget? avatar;
  final List<StatusInfo>? statusBadges;
  final List<DetailHeaderStat>? headerStats;
  final List<Widget>? headerActions;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (avatar != null) ...[
            SizedBox(
              width: AppTokens.buttonHeightLg,
              height: AppTokens.buttonHeightLg,
              child: Center(
                child: avatar,
              ),
            ),
            SizedBox(width: AppTokens.space4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.onSurface
                        : AppTokens.neutral900,
                    fontWeight: AppTokens.weightSemibold,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: AppTokens.space1),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral400
                          : AppTokens.neutral500,
                    ),
                  ),
                ],
                if (statusBadges != null && statusBadges!.isNotEmpty) ...[
                  SizedBox(height: AppTokens.space2),
                  Wrap(
                    spacing: AppTokens.space2,
                    runSpacing: AppTokens.space2,
                    children: [
                      for (final s in statusBadges!)
                        AppBadge(
                          label: s.label,
                          color: s.color,
                          variant: AppBadgeVariant.subtle,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (showStats &&
              headerStats != null &&
              headerStats!.isNotEmpty) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < headerStats!.length; i++) ...[
                  if (i > 0) ...[
                    SizedBox(
                      height: AppTokens.space8,
                      child: VerticalDivider(
                        width: AppTokens.borderWidthHairline,
                        thickness: AppTokens.borderWidthHairline,
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.neutral700
                            : AppTokens.neutral200,
                      ),
                    ),
                    SizedBox(width: AppTokens.space4),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        headerStats![i].label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? AppTokens.neutral400
                              : AppTokens.neutral500,
                        ),
                      ),
                      SizedBox(height: AppTokens.space1),
                      Text(
                        headerStats![i].value,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: headerStats![i].valueColor ??
                              (theme.brightness == Brightness.dark
                                  ? theme.colorScheme.onSurface
                                  : AppTokens.neutral900),
                          fontWeight: AppTokens.weightSemibold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            SizedBox(width: AppTokens.space4),
          ],
          if (headerActions != null && headerActions!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < headerActions!.length; i++) ...[
                  if (i > 0) SizedBox(width: AppTokens.space2),
                  headerActions![i],
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailTabStrip extends StatelessWidget {
  const _DetailTabStrip({
    required this.theme,
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.dividerColor,
  });

  final ThemeData theme;
  final List<DetailTab> tabs;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final transparent =
        theme.colorScheme.surface.withValues(alpha: AppTokens.space0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppTokens.inputHeightLg,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space6),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final t = tabs[i];
                final active = i == selected;
                return InkWell(
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTokens.space3,
                      AppTokens.space2,
                      AppTokens.space3,
                      AppTokens.space2,
                    ),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (t.icon != null) ...[
                                IconTheme(
                                  data: IconThemeData(
                                    size: AppTokens.iconSizeMd,
                                    color: active
                                        ? AppTokens.accent500
                                        : AppTokens.neutral500,
                                  ),
                                  child: t.icon!,
                                ),
                                SizedBox(width: AppTokens.space2),
                              ],
                              Text(
                                t.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: active
                                      ? AppTokens.weightSemibold
                                      : AppTokens.weightRegular,
                                  color: active
                                      ? AppTokens.accent500
                                      : AppTokens.neutral500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTokens.space2),
                          Container(
                            height: AppTokens.borderWidthSm * 2,
                            color: active ? AppTokens.accent500 : transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Divider(
          height: AppTokens.borderWidthHairline,
          thickness: AppTokens.borderWidthHairline,
          color: dividerColor,
        ),
      ],
    );
  }
}

class _DetailTabBody extends StatelessWidget {
  const _DetailTabBody({
    required this.theme,
    required this.desktop,
    required this.hasSidePanel,
    required this.sidePanelWidth,
    this.sidePanel,
    required this.tab,
    required this.tabContentPadding,
    required this.dividerColor,
  });

  final ThemeData theme;
  final bool desktop;
  final bool hasSidePanel;
  final double sidePanelWidth;
  final Widget? sidePanel;
  final DetailTab tab;
  final EdgeInsets tabContentPadding;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final panel = sidePanel;
    final paddedTab = Padding(
      padding: tabContentPadding,
      child: tab.content,
    );

    if (desktop && hasSidePanel && panel != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: paddedTab,
            ),
          ),
          SizedBox(
            width: sidePanelWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTokens.white,
                border: Border(
                  left: BorderSide(
                    color: dividerColor,
                    width: AppTokens.borderWidthHairline,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTokens.space4),
                child: panel,
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          paddedTab,
          if (panel != null) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppTokens.white,
                border: Border(
                  top: BorderSide(
                    color: dividerColor,
                    width: AppTokens.borderWidthHairline,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTokens.space4),
                child: panel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailLoadingBody extends StatelessWidget {
  const _DetailLoadingBody({
    required this.theme,
    required this.tabContentPadding,
  });

  final ThemeData theme;
  final EdgeInsets tabContentPadding;

  @override
  Widget build(BuildContext context) {
    final bg = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space6,
            vertical: AppTokens.space4,
          ),
          child: AppCard(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Row(
              children: [
                Container(
                  width: AppTokens.buttonHeightLg,
                  height: AppTokens.buttonHeightLg,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                SizedBox(width: AppTokens.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: AppTokens.space3,
                        width: AppTokens.space10 * 4,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                      ),
                      SizedBox(height: AppTokens.space2),
                      Container(
                        height: AppTokens.space3,
                        width: AppTokens.space10 * 5,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space6),
          child: Row(
            children: List.generate(
              4,
              (i) => Padding(
                padding: EdgeInsets.only(right: AppTokens.space4),
                child: Container(
                  width: AppTokens.space10 * 2,
                  height: AppTokens.space3,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: AppTokens.borderWidthHairline,
          thickness: AppTokens.borderWidthHairline,
          color: theme.brightness == Brightness.dark
              ? AppTokens.neutral700
              : AppTokens.neutral200,
        ),
        Expanded(
          child: Padding(
            padding: tabContentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                6,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: AppTokens.space2),
                  child: Container(
                    height: AppTokens.space3,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
