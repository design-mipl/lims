import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../data/role_model.dart';
import '../state/roles_provider.dart';
import 'role_form_drawer.dart';

/// Roles listing with KPIs, filters, and CRUD (mock API).
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  RolesProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _provider = context.read<RolesProvider>();
      _provider!.addListener(_onProviderChanged);
    });
  }

  void _onProviderChanged() {
    final p = _provider;
    if (p == null || !p.hasError || !mounted) {
      return;
    }
    final message = p.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || message == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      p.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  String _typeLabel(RoleType t) {
    switch (t) {
      case RoleType.system:
        return 'System';
      case RoleType.custom:
        return 'Custom';
    }
  }

  Future<void> _confirmDelete(BuildContext context, RoleModel row) async {
    if (!row.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            row.type == RoleType.system
                ? 'System roles cannot be deleted.'
                : 'Cannot delete a role while users are assigned to it.',
          ),
        ),
      );
      return;
    }
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Delete role?',
            style: theme.textTheme.titleSmall,
          ),
          content: Text(
            'This will permanently remove "${row.name}". '
            'This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(ctx).pop(false),
              variant: AppButtonVariant.tertiary,
              size: AppButtonSize.md,
            ),
            AppButton(
              label: 'Delete',
              onPressed: () => Navigator.of(ctx).pop(true),
              variant: AppButtonVariant.danger,
              size: AppButtonSize.md,
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await context.read<RolesProvider>().deleteRole(row.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RolesProvider>();
    final filteredTotal = p.filteredItems.length;

    return AppListingScreen<RoleModel>(
      title: 'Roles',
      subtitle: 'Define access tiers and assign them to users',
      primaryActionLabel: '+ Add Role',
      onPrimaryAction: () => RoleFormDrawer.show(context),
      showCheckboxes: false,
      kpiCards: [
        KpiCard(
          label: 'Total Roles',
          value: '${p.totalCount}',
        ),
        KpiCard(
          label: 'Active',
          value: '${p.activeCount}',
        ),
        KpiCard(
          label: 'Inactive',
          value: '${p.inactiveCount}',
        ),
      ],
      tabs: [
        TabConfig(label: 'All', count: p.tabAllCount),
        TabConfig(label: 'Active', count: p.activeCount),
        TabConfig(label: 'Inactive', count: p.inactiveCount),
      ],
      initialTabIndex: p.statusTabIndex,
      onTabChanged: (i) {
        p.setStatusFilter(
          i == 0
              ? null
              : (i == 1 ? RoleStatus.active : RoleStatus.inactive),
        );
      },
      columns: [
        TableColumn<RoleModel>(
          key: 'name',
          label: 'Role Name',
          cellBuilder: (r) => Text(
            r.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<RoleModel>(
          key: 'level',
          label: 'Level',
          width: 140,
          cellBuilder: (r) => Text(
            RoleModel.labelForLevel(r.level),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<RoleModel>(
          key: 'description',
          label: 'Description',
          cellBuilder: (r) => Text(
            r.description ?? '—',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<RoleModel>(
          key: 'type',
          label: 'Type',
          width: 100,
          cellBuilder: (r) => Text(_typeLabel(r.type)),
        ),
        TableColumn<RoleModel>(
          key: 'users',
          label: 'Users Count',
          numeric: true,
          width: 120,
          cellBuilder: (r) => Text('${r.usersCount}'),
        ),
        TableColumn<RoleModel>(
          key: 'status',
          label: 'Status',
          width: 120,
          sortable: false,
          cellBuilder: (r) => StatusChip(status: r.status.name),
        ),
      ],
      rows: p.pagedRows,
      mobileCardBuilder: (r) {
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: theme.textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              RoleModel.labelForLevel(r.level),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppTokens.neutral400
                    : AppTokens.neutral600,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            Row(
              children: [
                StatusChip(status: r.status.name),
                SizedBox(width: AppTokens.space3),
                Text(
                  _typeLabel(r.type),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTokens.neutral500,
                  ),
                ),
                SizedBox(width: AppTokens.space3),
                Text(
                  '${r.usersCount} users',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTokens.neutral500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      isLoading: p.isLoading,
      emptyMessage: 'No roles match your filters',
      onSearch: p.setSearchQuery,
      searchHint: 'Search by name, description, or level…',
      rowActions: [
        RowAction<RoleModel>(
          key: 'edit',
          label: 'Edit',
          icon: const Icon(LucideIcons.pencil),
          onTap: (row) => RoleFormDrawer.show(context, existing: row),
        ),
        RowAction<RoleModel>(
          key: 'toggle',
          label: 'Activate / deactivate',
          icon: const Icon(LucideIcons.refreshCw),
          onTap: (row) async {
            await context.read<RolesProvider>().toggleRoleStatus(row.id);
          },
        ),
        RowAction<RoleModel>(
          key: 'delete',
          label: 'Delete',
          icon: const Icon(LucideIcons.trash2),
          isDanger: true,
          isEnabled: (row) => row.canDelete,
          onTap: (row) => _confirmDelete(context, row),
        ),
      ],
      totalCount: filteredTotal,
      currentPage: p.effectiveCurrentPage,
      pageSize: p.pageSize,
      onPageChanged: p.setPage,
      onPageSizeChanged: p.setPageSize,
    );
  }
}
