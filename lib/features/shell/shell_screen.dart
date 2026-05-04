import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../design_system/components/components.dart';
import '../../design_system/tokens.dart';

/// Side navigation config for the authenticated app shell.
const List<NavItem> appNavItems = [
  NavItem(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icon(LucideIcons.layoutDashboard, size: 16),
    sectionLabel: 'CORE',
  ),
  NavItem(
    path: '/transactions',
    label: 'Transactions',
    icon: Icon(LucideIcons.arrowLeftRight, size: AppTokens.iconButtonIconMd),
    sectionLabel: 'TRANSACTIONS',
    children: [
      NavItem(
        path: '/transactions/sample-intake',
        label: 'Sample Intake & Data Entry',
        icon: Icon(LucideIcons.clipboardList, size: AppTokens.iconButtonIconMd),
      ),
      NavItem(
        path: '/transactions/lab-code',
        label: 'Lab Code',
        icon: Icon(LucideIcons.hash, size: AppTokens.iconButtonIconMd),
      ),
      NavItem(
        path: '/transactions/lab-assignment',
        label: 'Lab Manager Assignment',
        icon: Icon(LucideIcons.users, size: AppTokens.iconButtonIconMd),
      ),
      NavItem(
        path: '/transactions/verification',
        label: 'Verification',
        icon: Icon(LucideIcons.checkCircle, size: AppTokens.iconButtonIconMd),
      ),
      NavItem(
        path: '/transactions/report-review',
        label: 'Report Review & Authorization',
        icon: Icon(LucideIcons.fileCheck, size: AppTokens.iconButtonIconMd),
      ),
      NavItem(
        path: '/transactions/action-taken',
        label: 'Action Taken',
        icon: Icon(LucideIcons.activity, size: AppTokens.iconButtonIconMd),
      ),
    ],
  ),
  NavItem(
    path: '/masters',
    label: 'Masters',
    icon: Icon(LucideIcons.database, size: 16),
    sectionLabel: 'MASTERS',
    children: [
      NavItem(
        path: '/customers',
        label: 'Customer Master',
        icon: Icon(LucideIcons.users, size: 16),
      ),
      NavItem(
        path: '/sites',
        label: 'Site Master',
        icon: Icon(LucideIcons.mapPin, size: 16),
      ),
      NavItem(
        path: '/couriers',
        label: 'Courier Master',
        icon: Icon(LucideIcons.truck, size: 16),
      ),
      NavItem(
        path: '/plants',
        label: 'Plant Master',
        icon: Icon(LucideIcons.factory, size: 16),
      ),
      NavItem(
        path: '/masters/bank',
        label: 'Bank Master',
        icon: Icon(LucideIcons.landmark, size: 16),
      ),
      NavItem(
        path: '/masters/item',
        label: 'Item Master',
        icon: Icon(LucideIcons.package, size: 16),
      ),
      NavItem(
        path: '/masters/equipment',
        label: 'Equipment Master',
        icon: Icon(LucideIcons.wrench, size: 16),
      ),
      NavItem(
        path: '/masters/sample-type',
        label: 'Type of Sample Master',
        icon: Icon(LucideIcons.testTube, size: 16),
      ),
      NavItem(
        path: '/masters/grade',
        label: 'Grade Master',
        icon: Icon(LucideIcons.star, size: 16),
      ),
      NavItem(
        path: '/masters/department',
        label: 'Department Master',
        icon: Icon(LucideIcons.building2, size: 16),
      ),
      NavItem(
        path: '/masters/designation',
        label: 'Designation Master',
        icon: Icon(LucideIcons.briefcase, size: 16),
      ),
      NavItem(
        path: '/masters/test',
        label: 'Test Master',
        icon: Icon(LucideIcons.clipboardList, size: 16),
      ),
      NavItem(
        path: '/masters/method',
        label: 'Method Master',
        icon: Icon(LucideIcons.bookOpen, size: 16),
      ),
      NavItem(
        path: '/masters/instrument',
        label: 'Instrument Master',
        icon: Icon(LucideIcons.gauge, size: 16),
      ),
      NavItem(
        path: '/masters/parameter',
        label: 'Parameter Master',
        icon: Icon(LucideIcons.sliders, size: 16),
      ),
      NavItem(
        path: '/masters/unit',
        label: 'Unit Master',
        icon: Icon(LucideIcons.ruler, size: 16),
      ),
      NavItem(
        path: '/masters/problem',
        label: 'Problem Master',
        icon: Icon(LucideIcons.alertCircle, size: 16),
      ),
      NavItem(
        path: '/masters/sub-assembly',
        label: 'Sub Assembly Master',
        icon: Icon(LucideIcons.layers, size: 16),
      ),
      NavItem(
        path: '/masters/ferrography',
        label: 'Ferrography Master',
        icon: Icon(LucideIcons.microscope, size: 16),
      ),
      NavItem(
        path: '/masters/hsn',
        label: 'HSN Master',
        icon: Icon(LucideIcons.hash, size: 16),
      ),
      NavItem(
        path: '/masters/storage',
        label: 'Storage Master',
        icon: Icon(LucideIcons.archive, size: 16),
      ),
    ],
  ),
  NavItem(
    path: '/housekeeping',
    label: 'Housekeeping',
    icon: Icon(LucideIcons.clipboardCheck, size: 16),
    sectionLabel: 'HOUSEKEEPING',
  ),
  NavItem(
    path: '/reports',
    label: 'Reports',
    icon: Icon(LucideIcons.barChart2, size: 16),
    sectionLabel: 'REPORTS',
  ),
  NavItem(
    path: '/user-management',
    label: 'User Management',
    icon: Icon(LucideIcons.userCog, size: 16),
    sectionLabel: 'SYSTEM',
    children: [
      NavItem(
        path: '/user-management/departments',
        label: 'Departments',
        icon: Icon(LucideIcons.building2, size: 16),
      ),
      NavItem(
        path: '/user-management/users',
        label: 'Users',
        icon: Icon(LucideIcons.users, size: 16),
      ),
      NavItem(
        path: '/user-management/roles',
        label: 'Roles',
        icon: Icon(LucideIcons.shieldCheck, size: 16),
      ),
      NavItem(
        path: '/user-management/modules',
        label: 'Modules',
        icon: Icon(LucideIcons.layoutGrid, size: 16),
      ),
    ],
  ),
  NavItem(
    path: '/ui-kit',
    label: 'UI Kit',
    icon: Icon(LucideIcons.palette, size: 16),
  ),
];

/// Mounts [AppShell] with real navigation for all authenticated routes.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.state.uri.path;
  }

  @override
  void didUpdateWidget(ShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.uri != widget.state.uri) {
      setState(() {
        _currentPath = widget.state.uri.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navItems: appNavItems,
      currentPath: _currentPath,
      appName: 'Ultra Labs',
      appSubtitle: 'LIMS Portal',
      logoWidget: _buildLogo(),
      currentUser: const UserInfo(
        name: 'Admin User',
        id: 'r-001',
        initials: 'AU',
      ),
      notificationCount: 0,
      onPathSelected: (path) {
        context.go(path);
        setState(() => _currentPath = path);
      },
      child: widget.child,
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTokens.accent500,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: const Icon(
        LucideIcons.flaskConical,
        color: AppTokens.white,
        size: 18,
      ),
    );
  }
}
