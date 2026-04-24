import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../data/module_model.dart';
import '../state/modules_provider.dart';
import 'module_form_drawer.dart';

/// Modules listing with KPIs, filters, and CRUD (mock API).
class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  ModulesProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _provider = context.read<ModulesProvider>();
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

  Future<void> _confirmDelete(BuildContext context, ModuleModel row) async {
    final p = context.read<ModulesProvider>();
    if (!p.moduleCanDelete(row)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            row.hasChildrenAmong(p.items)
                ? 'Cannot delete a module that has child modules.'
                : 'Cannot delete a module linked to permissions.',
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
            'Delete module?',
            style: theme.textTheme.titleSmall,
          ),
          content: Text(
            'This will permanently remove "${row.name}" (${row.code}). '
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
      await context.read<ModulesProvider>().deleteModule(row.id);
    }
  }

  String _yesNo(bool v) => v ? 'Yes' : 'No';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ModulesProvider>();
    final filteredTotal = p.filteredItems.length;

    return AppListingScreen<ModuleModel>(
      title: 'Modules',
      subtitle: 'Define navigation entries and permission scope',
      primaryActionLabel: '+ Add Module',
      onPrimaryAction: () => ModuleFormDrawer.show(context),
      showCheckboxes: false,
      kpiCards: [
        KpiCard(
          label: 'Total Modules',
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
              : (i == 1
                  ? ModuleStatus.active
                  : ModuleStatus.inactive),
        );
      },
      columns: [
        TableColumn<ModuleModel>(
          key: 'name',
          label: 'Module Name',
          cellBuilder: (r) => Text(
            r.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<ModuleModel>(
          key: 'parent',
          label: 'Parent Module',
          width: 160,
          cellBuilder: (r) => Text(
            p.parentNameFor(r.parentId) ?? '—',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<ModuleModel>(
          key: 'route',
          label: 'Route',
          cellBuilder: (r) => Text(
            r.route,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<ModuleModel>(
          key: 'nav',
          label: 'Show in Navigation',
          width: 150,
          cellBuilder: (r) => Text(_yesNo(r.showInNavigation)),
        ),
        TableColumn<ModuleModel>(
          key: 'perm',
          label: 'Permission Enabled',
          width: 150,
          cellBuilder: (r) => Text(_yesNo(r.permissionEnabled)),
        ),
        TableColumn<ModuleModel>(
          key: 'sort',
          label: 'Sort Order',
          numeric: true,
          width: 100,
          cellBuilder: (r) => Text('${r.sortOrder}'),
        ),
        TableColumn<ModuleModel>(
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
              p.parentNameFor(r.parentId) ?? 'Root',
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
                  'Nav: ${_yesNo(r.showInNavigation)}',
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
      emptyMessage: 'No modules match your filters',
      onSearch: p.setSearchQuery,
      searchHint: 'Search by name, code, route, or parent…',
      rowActions: [
        RowAction<ModuleModel>(
          key: 'edit',
          label: 'Edit',
          icon: const Icon(LucideIcons.pencil),
          onTap: (row) => ModuleFormDrawer.show(context, existing: row),
        ),
        RowAction<ModuleModel>(
          key: 'toggle',
          label: 'Activate / deactivate',
          icon: const Icon(LucideIcons.refreshCw),
          onTap: (row) async {
            await context.read<ModulesProvider>().toggleModuleStatus(row.id);
          },
        ),
        RowAction<ModuleModel>(
          key: 'delete',
          label: 'Delete',
          icon: const Icon(LucideIcons.trash2),
          isDanger: true,
          isEnabled: (row) => p.moduleCanDelete(row),
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
