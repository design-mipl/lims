import 'dart:math' as math;

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
    required this.isExpanded,
    required this.isDrawer,
    required this.onPathSelected,
    this.onExpandFromLogo,
    this.onToggle,
    required this.appName,
    required this.logoWidget,
    this.appSubtitle,
    this.appVersion = '1.0.0',
  });

  final List<NavItem> navItems;
  final String currentPath;
  final bool isExpanded;
  final bool isDrawer;
  final void Function(String path) onPathSelected;
  final VoidCallback? onExpandFromLogo;
  final VoidCallback? onToggle;
  final String appName;
  final Widget logoWidget;
  final String? appSubtitle;
  final String appVersion;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  String? _expandedParentPath;

  static const double _logoBoxSize =
      AppTokens.tableRowHeight - AppTokens.space3;

  @override
  void initState() {
    super.initState();
    _syncExpandForPath();
  }

  void _syncExpandForPath() {
    String? found;
    for (final item in widget.navItems) {
      if (item.isExpandable &&
          item.children!.any((c) => c.path == widget.currentPath)) {
        found = item.path;
        break;
      }
    }
    _expandedParentPath = found;
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
        if (_expandedParentPath == item.path) {
          _expandedParentPath = null;
        } else {
          _expandedParentPath = item.path;
        }
      });
    } else {
      widget.onPathSelected(item.path);
    }
  }

  /// Full nav labels only when the rail has finished (or nearly finished)
  /// widening—avoids expanded [Row] layout during [AnimatedContainer] width
  /// animation (56 → 210), which caused RenderFlex overflow.
  bool _effectiveRailLabelsVisible(double maxWidth) {
    if (widget.isDrawer) return true;
    return widget.isExpanded &&
        maxWidth >= AppTokens.sidebarExpanded - 0.5;
  }

  double get _sidebarWidth {
    if (widget.isDrawer) return AppTokens.sidebarExpanded;
    return widget.isExpanded
        ? AppTokens.sidebarExpanded
        : AppTokens.sidebarCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _sidebarWidth,
      child: Material(
        color: AppTokens.sidebarBg,
        elevation: 0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final railLabels = _effectiveRailLabelsVisible(
              constraints.maxWidth,
            );
            return ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LogoRow(
                    isExpanded: railLabels,
                    isDrawer: widget.isDrawer,
                    onExpandFromLogo: widget.onExpandFromLogo,
                    onToggle: widget.onToggle,
                    appName: widget.appName,
                    appSubtitle: widget.appSubtitle,
                    logo: widget.logoWidget,
                    logoBoxSize: _logoBoxSize,
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(bottom: AppTokens.space2),
                      children: _buildNavWidgets(railLabels),
                    ),
                  ),
                  _BottomBlock(
                    isRailExpanded: railLabels,
                    appVersion: widget.appVersion,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildNavWidgets(bool isRailExpanded) {
    final out = <Widget>[];
    String? prevSection;
    for (final item in widget.navItems) {
      if (item.sectionLabel != prevSection) {
        if (item.sectionLabel != null) {
          out.add(_SectionOrDivider(
            isRailExpanded: isRailExpanded,
            label: item.sectionLabel!,
          ));
        }
        prevSection = item.sectionLabel;
      }
      out.add(
        _NavParentBlock(
          item: item,
          isRailExpanded: isRailExpanded,
          currentPath: widget.currentPath,
          navExpanded: _expandedParentPath == item.path,
          onParentTap: () => _onParentTap(item),
          onPathSelected: widget.onPathSelected,
        ),
      );
    }
    return out;
  }
}

class _LogoRow extends StatelessWidget {
  const _LogoRow({
    required this.isExpanded,
    required this.isDrawer,
    this.onExpandFromLogo,
    this.onToggle,
    required this.appName,
    this.appSubtitle,
    required this.logo,
    required this.logoBoxSize,
  });

  final bool isExpanded;
  final bool isDrawer;
  final VoidCallback? onExpandFromLogo;
  final VoidCallback? onToggle;
  final String appName;
  final String? appSubtitle;
  final Widget logo;
  final double logoBoxSize;

  static double get _rowHeight => AppTokens.space12 + AppTokens.space2;

  @override
  Widget build(BuildContext context) {
    final showToggle = !isDrawer && onToggle != null;

    if (!isExpanded && !isDrawer) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: Center(
              child: GestureDetector(
                onTap: onExpandFromLogo,
                child: _LogoBox(logo: logo, size: logoBoxSize),
              ),
            ),
          ),
          if (showToggle)
            SizedBox(
              height: 32,
              child: Center(
                child: GestureDetector(
                  onTap: onToggle!,
                  child: const Icon(
                    LucideIcons.chevronRight,
                    color: AppTokens.sidebarIcon,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (isDrawer) {
      return SizedBox(
        height: _rowHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Row(
            children: [
              _LogoBox(logo: logo, size: logoBoxSize),
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
                          color: AppTokens.sidebarInactiveText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
        child: Row(
          children: [
            _LogoBox(logo: logo, size: logoBoxSize),
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
                        color: AppTokens.sidebarInactiveText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showToggle)
              GestureDetector(
                onTap: onToggle!,
                child: const Icon(
                  LucideIcons.chevronLeft,
                  color: AppTokens.sidebarIcon,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.logo, required this.size});

  final Widget logo;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
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
              color: AppTokens.sidebarSectionLabel,
              fontWeight: AppTokens.weightSemibold,
              letterSpacing: 0.8,
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
        color: AppTokens.neutral700,
        height: AppTokens.borderWidthHairline,
        thickness: AppTokens.borderWidthHairline,
      ),
    );
  }
}

/// Parent row plus animated children list (accordion block).
class _NavParentBlock extends StatelessWidget {
  const _NavParentBlock({
    required this.item,
    required this.isRailExpanded,
    required this.currentPath,
    required this.navExpanded,
    required this.onParentTap,
    required this.onPathSelected,
  });

  final NavItem item;
  final bool isRailExpanded;
  final String currentPath;
  final bool navExpanded;
  final VoidCallback onParentTap;
  final void Function(String path) onPathSelected;

  static const double _childRowHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    final showChildren = item.isExpandable &&
        isRailExpanded &&
        navExpanded &&
        item.children != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParentTile(
          item: item,
          isRailExpanded: isRailExpanded,
          currentPath: currentPath,
          navExpanded: navExpanded,
          onParentTap: onParentTap,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: showChildren
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in item.children!)
                      _ChildTile(
                        item: c,
                        currentPath: currentPath,
                        rowHeight: _childRowHeight,
                        onPathSelected: onPathSelected,
                      ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AccordionChevron extends StatefulWidget {
  const _AccordionChevron({
    required this.expanded,
    required this.iconColor,
  });

  final bool expanded;
  final Color iconColor;

  @override
  State<_AccordionChevron> createState() => _AccordionChevronState();
}

class _AccordionChevronState extends State<_AccordionChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _turn = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.expanded) {
      _ctrl.value = 1;
    }
  }

  @override
  void didUpdateWidget(_AccordionChevron oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expanded != widget.expanded) {
      if (widget.expanded) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _turn,
      builder: (context, _) {
        return Transform.rotate(
          angle: _turn.value * math.pi / 2,
          child: Icon(
            LucideIcons.chevronRight,
            size: AppTokens.iconButtonIconSm,
            color: widget.iconColor,
          ),
        );
      },
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
    final isActiveParent = selfMatch || hasChildActive;

    final Color bg;
    if (isActiveParent) {
      bg = AppTokens.sidebarActiveItem;
    } else if (_hovering && !isActiveParent) {
      bg = AppTokens.neutral700;
    } else {
      bg = Colors.transparent;
    }

    final labelColor = isActiveParent
        ? AppTokens.sidebarActiveText
        : AppTokens.sidebarInactiveText;

    const iconSize = AppTokens.iconButtonIconMd;
    const iconColor = AppTokens.sidebarIcon;
    final iconTheme = IconThemeData(
      size: AppTokens.iconButtonIconMd,
      color: iconColor,
    );

    final hasRoundedBg = isActiveParent;
    Widget clipIfNeeded(Widget child) => hasRoundedBg
        ? ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: child,
          )
        : child;

    final material = Material(
      color: bg,
      child: MouseRegion(
        onEnter: (_) {
          if (!isActiveParent) {
            setState(() => _hovering = true);
          }
        },
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onParentTap,
          hoverColor: Colors.transparent,
          splashColor: AppTokens.primary700.withValues(alpha: 0.2),
          child: widget.isRailExpanded
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
                  child: SizedBox(
                    height: AppTokens.navItemHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: IconTheme.merge(
                            data: iconTheme,
                            child: item.icon,
                          ),
                        ),
                        SizedBox(width: AppTokens.space2),
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AppTokens.textBase,
                              color: labelColor,
                              fontWeight: isActiveParent
                                  ? AppTokens.weightSemibold
                                  : AppTokens.weightRegular,
                            ),
                          ),
                        ),
                        if (isExpandable)
                          _AccordionChevron(
                            expanded: widget.navExpanded,
                            iconColor: iconColor,
                          ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: AppTokens.sidebarCollapsed,
                  height: AppTokens.navItemHeight,
                  child: Center(
                    child: IconTheme.merge(
                      data: iconTheme,
                      child: item.icon,
                    ),
                  ),
                ),
        ),
      ),
    );

    if (!widget.isRailExpanded) {
      return Tooltip(
        message: item.label,
        child: clipIfNeeded(material),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space1),
      child: clipIfNeeded(material),
    );
  }
}

class _ChildTile extends StatefulWidget {
  const _ChildTile({
    required this.item,
    required this.currentPath,
    required this.rowHeight,
    required this.onPathSelected,
  });

  final NavItem item;
  final String currentPath;
  final double rowHeight;
  final void Function(String path) onPathSelected;

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isActiveChild = widget.currentPath == item.path;
    return InkWell(
      onTap: () => widget.onPathSelected(item.path),
      hoverColor: Colors.transparent,
      splashColor: AppTokens.primary700.withValues(alpha: 0.2),
      child: Container(
        height: widget.rowHeight,
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space2),
        padding: EdgeInsets.only(
          left: AppTokens.space6,
          right: AppTokens.space2,
        ),
        decoration: BoxDecoration(
          color: isActiveChild
              // ignore: deprecated_member_use — spec: sidebarActiveItem.withOpacity(0.40)
              ? AppTokens.sidebarActiveItem.withOpacity(0.40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActiveChild
                    ? AppTokens.sidebarActiveText
                    : AppTokens.sidebarInactiveText,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTokens.textSm,
                  color: isActiveChild
                      ? AppTokens.sidebarActiveText
                      : AppTokens.sidebarInactiveText,
                  fontWeight: isActiveChild
                      ? AppTokens.weightSemibold
                      : AppTokens.weightRegular,
                ),
              ),
            ),
          ],
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
          color: AppTokens.neutral700,
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
                  color: AppTokens.sidebarInactiveText,
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
        color: _hover ? AppTokens.neutral700 : Colors.transparent,
        child: InkWell(
          onTap: () {},
          hoverColor: Colors.transparent,
          splashColor: AppTokens.primary700.withValues(alpha: 0.2),
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
                            color: AppTokens.sidebarIcon,
                          ),
                          SizedBox(width: AppTokens.space2),
                          Text(
                            'Help & Docs',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AppTokens.textBase,
                              color: AppTokens.sidebarInactiveText,
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
                            color: AppTokens.sidebarIcon,
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
