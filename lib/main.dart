import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'design_system/app_theme.dart';
import 'design_system/components/navigation/app_shell.dart';
import 'design_system/components/navigation/nav_item.dart';
import 'design_system/tokens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultra LIMS',
      theme: AppTheme.light(),
      home: const _ShellPreview(),
    );
  }
}

class _ShellPreview extends StatefulWidget {
  const _ShellPreview();

  @override
  State<_ShellPreview> createState() => _ShellPreviewState();
}

class _ShellPreviewState extends State<_ShellPreview> {
  String _path = '/';
  int _n = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppShell(
      appName: 'Ultra Labs',
      appSubtitle: 'LIMS Portal',
      logoWidget: const FlutterLogo(size: 32),
      currentPath: _path,
      onPathSelected: (p) => setState(() => _path = p),
      onNotificationTap: () => setState(() => _n = _n + 1),
      notificationCount: _n,
      onSearchTap: () {},
      currentUser: const UserInfo(
        name: 'Avery Chen',
        id: 'r-001',
        initials: 'AC',
      ),
      onProfileTap: () {},
      onSettingsTap: () {},
      onSignOutTap: () {},
      navItems: [
        NavItem(
          path: '/',
          label: 'Home',
          sectionLabel: 'CORE',
          icon: Icon(
            LucideIcons.layoutDashboard,
            size: AppTokens.iconButtonIconMd,
            color: AppTokens.neutral400,
          ),
        ),
        NavItem(
          path: '/samples',
          label: 'Samples',
          sectionLabel: 'ENTITIES',
          icon: Icon(
            LucideIcons.testTube2,
            size: AppTokens.iconButtonIconMd,
            color: AppTokens.neutral400,
          ),
        ),
        NavItem(
          path: '/assays',
          label: 'Assays',
          icon: Icon(
            LucideIcons.microscope,
            size: AppTokens.iconButtonIconMd,
            color: AppTokens.neutral400,
          ),
          children: [
            const NavItem(
              path: '/assays/panels',
              label: 'Panels',
              icon: _ChildNavIcon(),
            ),
            const NavItem(
              path: '/assays/runs',
              label: 'Runs',
              icon: _ChildNavIcon(),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space6),
        child: const Center(
          child: Text('Page content (placeholder)'),
        ),
      ),
      ),
    );
  }
}

/// [NavItem] requires a widget; child rows in the shell only render the label.
class _ChildNavIcon extends StatelessWidget {
  const _ChildNavIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 0,
      height: 0,
    );
  }
}
