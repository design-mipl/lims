import 'package:flutter/material.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../cards/app_card.dart';
import '../display/kpi_metric.dart';
import 'template_pulse.dart';

/// Content block for [DashboardTemplate] section grid.
class DashboardSection {
  const DashboardSection({
    required this.title,
    this.actionLabel,
    this.onAction,
    required this.content,
    this.fullWidth = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget content;
  final bool fullWidth;
}

/// Standard dashboard / overview page layout.
class DashboardTemplate extends StatelessWidget {
  const DashboardTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.headerActions,
    this.kpiCards,
    required this.sections,
    this.isLoading = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? headerActions;
  final List<KpiCard>? kpiCards;
  final List<DashboardSection> sections;
  final bool isLoading;

  EdgeInsets _scrollPadding(double width) {
    final desktop = AppBreakpoints.isDesktopWidth(width);
    if (desktop) {
      return EdgeInsets.fromLTRB(
        AppTokens.space6,
        AppTokens.space4,
        AppTokens.space6,
        AppTokens.space4,
      );
    }
    return EdgeInsets.all(AppTokens.space4);
  }

  int _kpiColumns(double width) {
    if (AppBreakpoints.isDesktopWidth(width)) {
      return 4;
    }
    return 2;
  }

  bool _useCompactKpi(double width) =>
      AppBreakpoints.isMobileWidth(width);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SingleChildScrollView(
          padding: _scrollPadding(width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardPageHeader(
                theme: theme,
                title: title,
                subtitle: subtitle,
                headerActions: headerActions,
              ),
              SizedBox(height: AppTokens.space6),
              if (isLoading) ...[
                TemplatePulse(
                  child: _KpiSkeletonGrid(
                    width: width,
                    columns: _kpiColumns(width),
                  ),
                ),
                SizedBox(height: AppTokens.space6),
                TemplatePulse(
                  child: _SectionSkeletonGrid(width: width),
                ),
              ] else ...[
                if (kpiCards != null && kpiCards!.isNotEmpty) ...[
                  _DashboardKpiGrid(
                    cards: kpiCards!,
                    compact: _useCompactKpi(width),
                  ),
                  SizedBox(height: AppTokens.space6),
                ],
                _DashboardSectionsGrid(
                  theme: theme,
                  width: width,
                  sections: sections,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DashboardPageHeader extends StatelessWidget {
  const _DashboardPageHeader({
    required this.theme,
    required this.title,
    this.subtitle,
    this.headerActions,
  });

  final ThemeData theme;
  final String title;
  final String? subtitle;
  final List<Widget>? headerActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : AppTokens.neutral900,
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
                ],
              ),
            ),
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
      ],
    );
  }
}

class _DashboardKpiGrid extends StatelessWidget {
  const _DashboardKpiGrid({
    required this.cards,
    required this.compact,
  });

  final List<KpiCard> cards;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = AppBreakpoints.isDesktopWidth(width) ? 4 : 2;
    final aspect = compact ? 2.0 : 2.4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppTokens.space4,
        crossAxisSpacing: AppTokens.space4,
        childAspectRatio: aspect,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) =>
          KpiMetricTile(card: cards[i], compact: compact),
    );
  }
}

class _KpiSkeletonGrid extends StatelessWidget {
  const _KpiSkeletonGrid({
    required this.width,
    required this.columns,
  });

  final double width;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral200;
    final bg2 = theme.brightness == Brightness.dark
        ? AppTokens.neutral800
        : AppTokens.neutral100;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppTokens.space4,
        crossAxisSpacing: AppTokens.space4,
        childAspectRatio: AppBreakpoints.isMobileWidth(width) ? 2.0 : 2.4,
      ),
      itemCount: 4,
      itemBuilder: (context, i) {
        return AppCard(
          padding: EdgeInsets.all(AppTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: AppTokens.space3,
                width: AppTokens.space10 * 2,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              SizedBox(height: AppTokens.space2),
              Container(
                height: AppTokens.space4,
                width: AppTokens.space10 * 3,
                decoration: BoxDecoration(
                  color: bg2,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionSkeletonGrid extends StatelessWidget {
  const _SectionSkeletonGrid({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral200;

    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppTokens.space4),
          child: AppCard(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: AppTokens.space3,
                  width: AppTokens.space10 * 4,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Container(
                  height: AppTokens.space3,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
                SizedBox(height: AppTokens.space2),
                Container(
                  height: AppTokens.space3,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _DashboardSectionsGrid extends StatelessWidget {
  const _DashboardSectionsGrid({
    required this.theme,
    required this.width,
    required this.sections,
  });

  final ThemeData theme;
  final double width;
  final List<DashboardSection> sections;

  Color get _dividerColor => theme.brightness == Brightness.dark
      ? AppTokens.neutral700
      : AppTokens.neutral100;

  @override
  Widget build(BuildContext context) {
    final desktop = AppBreakpoints.isDesktopWidth(width);

    if (!desktop || sections.isEmpty) {
      return Column(
        children: [
          for (final s in sections) ...[
            _DashboardSectionCard(
              theme: theme,
              dividerColor: _dividerColor,
              section: s,
            ),
            SizedBox(height: AppTokens.space4),
          ],
        ],
      );
    }

    final children = <Widget>[];
    final queue = List<DashboardSection>.from(sections);

    while (queue.isNotEmpty) {
      final next = queue.removeAt(0);
      if (next.fullWidth) {
        children.add(
          _DashboardSectionCard(
            theme: theme,
            dividerColor: _dividerColor,
            section: next,
          ),
        );
        children.add(SizedBox(height: AppTokens.space4));
        continue;
      }
      final pair = <DashboardSection>[next];
      if (queue.isNotEmpty && !queue.first.fullWidth) {
        pair.add(queue.removeAt(0));
      }
      if (pair.length == 1) {
        children.add(
          _DashboardSectionCard(
            theme: theme,
            dividerColor: _dividerColor,
            section: pair.single,
          ),
        );
      } else {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DashboardSectionCard(
                  theme: theme,
                  dividerColor: _dividerColor,
                  section: pair[0],
                ),
              ),
              SizedBox(width: AppTokens.space4),
              Expanded(
                child: _DashboardSectionCard(
                  theme: theme,
                  dividerColor: _dividerColor,
                  section: pair[1],
                ),
              ),
            ],
          ),
        );
      }
      children.add(SizedBox(height: AppTokens.space4));
    }

    return Column(children: children);
  }
}

class _DashboardSectionCard extends StatelessWidget {
  const _DashboardSectionCard({
    required this.theme,
    required this.dividerColor,
    required this.section,
  });

  final ThemeData theme;
  final Color dividerColor;
  final DashboardSection section;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space4,
              AppTokens.space4,
              AppTokens.space4,
              AppTokens.space2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.title.toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral400
                          : AppTokens.neutral700,
                      fontWeight: AppTokens.weightSemibold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (section.actionLabel != null &&
                    section.onAction != null)
                  TextButton(
                    onPressed: section.onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTokens.accent500,
                      padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      section.actionLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTokens.accent500,
                        fontWeight: AppTokens.weightMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: AppTokens.borderWidthHairline,
            thickness: AppTokens.borderWidthHairline,
            color: dividerColor,
          ),
          Padding(
            padding: EdgeInsets.all(AppTokens.space4),
            child: section.content,
          ),
        ],
      ),
    );
  }
}
