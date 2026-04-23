import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import 'nav_item.dart';

/// Collapsible / drawer sidebar with section labels, nav tree, and Help.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.navItems,
    required this.currentPath,
    required this.isRailExpanded,
    required this.isDrawer,
    required this.onPathSelected,
    this.onExpandFromLogo,
    this.onToggleEdgeExpand,
    required this.showEdgeChevron,
    required this.appName,
    required this.logoWidget,
    this.appSubtitle,
    this.appVersion = '1.0.0',
  });

  final List<NavItem> navItems;
  final String currentPath;
  final bool isRailExpanded;
  final bool isDrawer;
  final void Function(String path) onPathSelected;
  final VoidCallback? onExpandFromLogo;
  final VoidCallback? onToggleEdgeExpand;
  final bool showEdgeChevron;
  final String appName;
  final Widget logoWidget;
  final String? appSubtitle;
  final String appVersion;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late final Set<String> _expandedForChildren;

  @override
  void initState() {
    super.initState();
    _expandedForChildren = <String>{};
    _syncExpandForPath();
  }

  void _syncExpandForPath() {
    for (final item in widget.navItems) {
      if (item.isExpandable) {
        final hasActiveChild = item.children!.any(
          (c) => c.path == widget.currentPath,
        );
        if (hasActiveChild) {
          _expandedForChildren.add(item.path);
        }
      }
    }
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      _syncExpandForPath();
      setState(() {});
    }
  }

  void _onParentTap(NavItem item) {
    if (item.isExpandable) {
      setState(() {
        if (_expandedForChildren.contains(item.path)) {
          _expandedForChildren.remove(item.path);
        } else {
          _expandedForChildren.add(item.path);
        }
      });
    } else {
      widget.onPathSelected(item.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.primary800,
      child: SizedBox(
        width: _sidebarWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LogoRow(
                  isRailExpanded: _labelsVisible,
                  isDrawer: widget.isDrawer,
                  onExpandFromLogo: widget.onExpandFromLogo,
                  appName: widget.appName,
                  appSubtitle: widget.appSubtitle,
                  logo: widget.logoWidget,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: AppTokens.space2),
                    children: _buildNavWidgets(),
                  ),
                ),
                _BottomBlock(
                  isRailExpanded: _labelsVisible,
                  appVersion: widget.appVersion,
                ),
              ],
            ),
            if (widget.showEdgeChevron) _edgeChevron(),
          ],
        ),
      ),
    );
  }

  bool get _labelsVisible {
    if (widget.isDrawer) return true;
    return widget.isRailExpanded;
  }

  double get _sidebarWidth {
    if (widget.isDrawer) return AppTokens.sidebarExpanded;
    return widget.isRailExpanded
        ? AppTokens.sidebarExpanded
        : AppTokens.sidebarCollapsed;
  }

  List<Widget> _buildNavWidgets() {
    final out = <Widget>[];
    String? prevSection;
    for (final item in widget.navItems) {
      if (item.sectionLabel != prevSection) {
        if (item.sectionLabel != null) {
          out.add(_SectionOrDivider(
            isRailExpanded: _labelsVisible,
            label: item.sectionLabel!,
          ));
        }
        prevSection = item.sectionLabel;
      }
      out.add(
        _ParentTile(
          item: item,
          isRailExpanded: _labelsVisible,
          currentPath: widget.currentPath,
          navExpanded: _expandedForChildren.contains(item.path),
          onParentTap: () => _onParentTap(item),
        ),
      );
      if (item.isExpandable &&
          _labelsVisible &&
          _expandedForChildren.contains(item.path)) {
        for (final c in item.children!) {
          out.add(
            _ChildTile(
              item: c,
              currentPath: widget.currentPath,
              onPathSelected: widget.onPathSelected,
            ),
          );
        }
      }
    }
    return out;
  }

  Widget _edgeChevron() {
    final h = AppTokens.space12 + AppTokens.space2;
    final t = (h - AppTokens.avatarSizeSm) / 2;
    return Positioned(
      top: t,
      right: -AppTokens.space2,
      child: Material(
        color: AppTokens.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: AppTokens.neutral200,
            width: AppTokens.borderWidthSm,
          ),
        ),
        child: InkWell(
          onTap: widget.onToggleEdgeExpand,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppTokens.avatarSizeSm,
            height: AppTokens.avatarSizeSm,
            child: Center(
              child: Icon(
                widget.isRailExpanded
                    ? LucideIcons.chevronLeft
                    : LucideIcons.chevronRight,
                size: AppTokens.iconButtonIconSm,
                color: AppTokens.neutral600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoRow extends StatelessWidget {
  const _LogoRow({
    required this.isRailExpanded,
    required this.isDrawer,
    this.onExpandFromLogo,
    required this.appName,
    this.appSubtitle,
    required this.logo,
  });

  final bool isRailExpanded;
  final bool isDrawer;
  final VoidCallback? onExpandFromLogo;
  final String appName;
  final String? appSubtitle;
  final Widget logo;

  @override
  Widget build(BuildContext context) {
    final h = AppTokens.space12 + AppTokens.space2;
    if (!isRailExpanded && !isDrawer) {
      return SizedBox(
        height: h,
        child: Center(
          child: InkWell(
            onTap: onExpandFromLogo,
            child: _LogoBox(logo: logo),
          ),
        ),
      );
    }
    return SizedBox(
      height: h,
      child: InkWell(
        onTap: onExpandFromLogo,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              _LogoBox(logo: logo),
              SizedBox(width: AppTokens.space2),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppTokens.textMd,
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.white,
                      ),
                    ),
                    if (appSubtitle != null && appSubtitle!.isNotEmpty) ...[
                      Text(
                        appSubtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTokens.textXs,
                          color: AppTokens.neutral400,
                        ),
                      ),
                    ],
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

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.logo});

  final Widget logo;
  static double get _d =>
      AppTokens.tableRowHeight - AppTokens.space3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _d,
      height: _d,
      child: FittedBox(child: logo),
    );
  }
}

class _SectionOrDivider extends StatelessWidget {
  const _SectionOrDivider({
    required this.isRailExpanded,
    required this.label,
  });

  final bool isRailExpanded;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (isRailExpanded) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppTokens.space3,
          AppTokens.space4,
          AppTokens.space3,
          AppTokens.space1,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTokens.textXs,
              color: AppTokens.neutral400,
              fontWeight: AppTokens.weightSemibold,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      child: const Divider(
        color: AppTokens.neutral500,
        height: AppTokens.borderWidthSm,
        thickness: AppTokens.borderWidthSm,
      ),
    );
  }
}

class _ParentTile extends StatefulWidget {
  const _ParentTile({
    required this.item,
    required this.isRailExpanded,
    required this.currentPath,
    required this.navExpanded,
    required this.onParentTap,
  });

  final NavItem item;
  final bool isRailExpanded;
  final String currentPath;
  final bool navExpanded;
  final VoidCallback onParentTap;

  @override
  State<_ParentTile> createState() => _ParentTileState();
}

class _ParentTileState extends State<_ParentTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isExpandable = item.isExpandable;
    final hasChildActive = item.children
            ?.any((c) => c.path == widget.currentPath) ==
        true;

    final selfMatch = widget.currentPath == item.path;
    final fullAccent = selfMatch && ( !isExpandable || !hasChildActive);
    final subtleAccent = isExpandable && hasChildActive;
    final idleHover = _hovering && !fullAccent && !subtleAccent;

    final Color bg = fullAccent
        ? AppTokens.accent500
        : subtleAccent
        ? AppTokens.accent500.withValues(alpha: 0.15)
        : idleHover
        ? AppTokens.neutral700
        : AppTokens.primary800;

    const iconDim = AppTokens.neutral300;
    final onAccent = (fullAccent || subtleAccent) ? AppTokens.white : iconDim;
    const iconSize = AppTokens.iconButtonIconMd;

    final row = Row(
      mainAxisAlignment: widget.isRailExpanded
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: IconTheme.merge(
            data: IconThemeData(
              size: AppTokens.iconButtonIconMd,
              color: onAccent,
            ),
            child: item.icon,
          ),
        ),
        if (widget.isRailExpanded) ...[
          SizedBox(width: AppTokens.space2),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AppTokens.textBase,
                color: (fullAccent || subtleAccent) ? AppTokens.white : AppTokens.neutral300,
                fontWeight: AppTokens.weightRegular,
              ),
            ),
          ),
          if (isExpandable)
            Icon(
              widget.navExpanded
                  ? LucideIcons.chevronDown
                  : LucideIcons.chevronRight,
              size: AppTokens.iconButtonIconSm,
              color: onAccent,
            ),
        ],
      ],
    );

    final content = Material(
      color: bg,
      child: MouseRegion(
        onEnter: (_) {
          if (!fullAccent && !subtleAccent) {
            setState(() => _hovering = true);
          }
        },
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onParentTap,
          hoverColor: Colors.transparent,
          splashColor: AppTokens.primary700.withValues(alpha: 0.2),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
            child: SizedBox(
              height: AppTokens.navItemHeight,
              child: row,
            ),
          ),
        ),
      ),
    );

    final r = (fullAccent || subtleAccent) ? AppTokens.radiusMd : AppTokens.space0;
    final padded = Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space1),
      child: r > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(r),
              child: content,
            )
          : content,
    );

    if (!widget.isRailExpanded) {
      return Tooltip(
        message: item.label,
        child: padded,
      );
    }
    return padded;
  }
}

class _ChildTile extends StatefulWidget {
  const _ChildTile({
    required this.item,
    required this.currentPath,
    required this.onPathSelected,
  });

  final NavItem item;
  final String currentPath;
  final void Function(String path) onPathSelected;

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final active = widget.currentPath == item.path;
    final h = AppTokens.navItemHeight - AppTokens.space1;
    return Padding(
      padding: EdgeInsets.only(
        left: AppTokens.space8,
        right: AppTokens.space3,
      ),
      child: MouseRegion(
        onEnter: (_) {
          if (!active) {
            setState(() => _hover = true);
          }
        },
        onExit: (_) {
          if (!active) {
            setState(() => _hover = false);
          }
        },
        child: Material(
          color: !active && _hover
              ? AppTokens.neutral700
              : AppTokens.primary800,
          child: InkWell(
            onTap: () => widget.onPathSelected(item.path),
            hoverColor: Colors.transparent,
            splashColor: AppTokens.primary700.withValues(alpha: 0.2),
            child: SizedBox(
              height: h,
              child: Row(
                children: [
                  if (active) ...[
                    Container(
                      width: AppTokens.borderWidthSm * 2,
                      height: h,
                      decoration: const BoxDecoration(
                        color: AppTokens.accent500,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppTokens.radiusSm),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTokens.space2),
                  ] else
                    SizedBox(
                      width: AppTokens.borderWidthSm * 2 + AppTokens.space2,
                    ),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppTokens.textSm,
                        color: active
                            ? AppTokens.white
                            : AppTokens.neutral400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBlock extends StatelessWidget {
  const _BottomBlock({
    required this.isRailExpanded,
    required this.appVersion,
  });

  final bool isRailExpanded;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(
          color: AppTokens.neutral500,
          height: AppTokens.borderWidthHairline,
          thickness: AppTokens.borderWidthHairline,
        ),
        _HelpRow(
          isRailExpanded: isRailExpanded,
        ),
        if (isRailExpanded) ...[
          Padding(
            padding: EdgeInsets.only(
              top: AppTokens.space2,
              bottom: AppTokens.space4,
            ),
            child: Center(
              child: Text(
                'v$appVersion',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTokens.textXs,
                  color: AppTokens.neutral500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HelpRow extends StatefulWidget {
  const _HelpRow({required this.isRailExpanded});

  final bool isRailExpanded;

  @override
  State<_HelpRow> createState() => _HelpRowState();
}

class _HelpRowState extends State<_HelpRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space1),
      child: Material(
        color: _hover ? AppTokens.neutral700 : AppTokens.primary800,
        child: InkWell(
          onTap: () {},
          hoverColor: AppTokens.neutral700,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
              child: SizedBox(
                height: AppTokens.navItemHeight,
                child: widget.isRailExpanded
                    ? const Row(
                        children: [
                          Icon(
                            LucideIcons.helpCircle,
                            size: AppTokens.iconButtonIconMd,
                            color: AppTokens.neutral300,
                          ),
                          SizedBox(width: AppTokens.space2),
                          Text(
                            'Help & Docs',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AppTokens.textBase,
                              color: AppTokens.neutral300,
                            ),
                          ),
                        ],
                      )
                    : const Tooltip(
                        message: 'Help & Docs',
                        child: Center(
                          child: Icon(
                            LucideIcons.helpCircle,
                            size: AppTokens.iconButtonIconMd,
                            color: AppTokens.neutral300,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
