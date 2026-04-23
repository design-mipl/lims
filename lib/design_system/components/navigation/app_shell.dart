import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';
import 'nav_item.dart';

const String _kSidebarExpanded = 'interics:sidebar_expanded';

/// Core layout for authenticated areas: shell navigation, top bar, and page [child].
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.currentPath,
    required this.appName,
    required this.logoWidget,
    required this.onPathSelected,
    this.appSubtitle,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.currentUser,
    this.onProfileTap,
    this.onSettingsTap,
    this.onSignOutTap,
    this.onSearchTap,
    this.appVersion = '1.0.0',
  });

  final Widget child;
  final List<NavItem> navItems;
  final String currentPath;
  final String appName;
  final Widget logoWidget;
  final void Function(String path) onPathSelected;
  final String? appSubtitle;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final UserInfo? currentUser;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSignOutTap;
  final VoidCallback? onSearchTap;
  final String appVersion;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sidebarExpanded = true;
  @override
  void initState() {
    super.initState();
    unawaited(_loadSidebarPref());
  }

  Future<void> _loadSidebarPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    if (prefs.containsKey(_kSidebarExpanded)) {
      setState(() {
        _sidebarExpanded = prefs.getBool(_kSidebarExpanded)!;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final w = MediaQuery.sizeOf(context).width;
        if (w < 600) {
          return;
        }
        setState(() {
          _sidebarExpanded = w >= 1024;
        });
      });
    }
  }

  Future<void> _persistExpanded(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSidebarExpanded, v);
  }

  void _setExpanded(bool v) {
    setState(() {
      _sidebarExpanded = v;
    });
    unawaited(_persistExpanded(v));
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final w = MediaQuery.sizeOf(context).width;
        if (AppBreakpoints.isMobileWidth(w)) {
          _scaffoldKey.currentState?.closeDrawer();
        }
      });
    }
  }

  void _onNavPath(String path) {
    widget.onPathSelected(path);
    if (!mounted) {
      return;
    }
    final w = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isMobileWidth(w)) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  double _searchPillWidth(double w) {
    if (w < 600) {
      return AppTokens.buttonHeightMd + AppTokens.space1;
    }
    if (w < 1024) {
      return AppTokens.topbarSearchWidthTablet;
    }
    return AppTokens.topbarSearchWidthDesktop;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final mobile = AppBreakpoints.isMobileWidth(w);
    final desktop = AppBreakpoints.isDesktopWidth(w);
    if (mobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: Drawer(
          width: AppTokens.sidebarExpanded,
          child: AppSidebar(
            navItems: widget.navItems,
            currentPath: widget.currentPath,
            isRailExpanded: true,
            isDrawer: true,
            onPathSelected: _onNavPath,
            showEdgeChevron: false,
            onExpandFromLogo: null,
            onToggleEdgeExpand: null,
            appName: widget.appName,
            appSubtitle: widget.appSubtitle,
            logoWidget: widget.logoWidget,
            appVersion: widget.appVersion,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTopbar(
              searchWidth: _searchPillWidth(w),
              showMenuButton: true,
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              onSearchTap: widget.onSearchTap,
              notificationCount: widget.notificationCount,
              onNotificationTap: widget.onNotificationTap,
              currentUser: widget.currentUser,
              onProfileTap: widget.onProfileTap,
              onSettingsTap: widget.onSettingsTap,
              onSignOutTap: widget.onSignOutTap,
              showUserText: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: widget.child,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox.expand(
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            navItems: widget.navItems,
            currentPath: widget.currentPath,
            isRailExpanded: _sidebarExpanded,
            isDrawer: false,
            onPathSelected: _onNavPath,
            showEdgeChevron: desktop,
            onExpandFromLogo: () {
              if (!_sidebarExpanded) {
                _setExpanded(true);
              }
            },
            onToggleEdgeExpand: () {
              _setExpanded(!_sidebarExpanded);
            },
            appName: widget.appName,
            appSubtitle: widget.appSubtitle,
            logoWidget: widget.logoWidget,
            appVersion: widget.appVersion,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTopbar(
                  searchWidth: _searchPillWidth(w),
                  onSearchTap: widget.onSearchTap,
                  notificationCount: widget.notificationCount,
                  onNotificationTap: widget.onNotificationTap,
                  currentUser: widget.currentUser,
                  onProfileTap: widget.onProfileTap,
                  onSettingsTap: widget.onSettingsTap,
                  onSignOutTap: widget.onSignOutTap,
                  showUserText: desktop,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
