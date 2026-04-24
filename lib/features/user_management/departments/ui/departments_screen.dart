import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../data/department_model.dart';
import '../state/departments_provider.dart';
import 'department_form_drawer.dart';

/// Departments listing with KPIs, filters, and CRUD (mock API).
class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  DepartmentsProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _provider = context.read<DepartmentsProvider>();
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

  Future<void> _confirmDelete(BuildContext context, DepartmentModel row) async {
    if (!row.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot delete a department while users are assigned to it.',
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
            'Delete department?',
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
      await context.read<DepartmentsProvider>().deleteDepartment(row.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DepartmentsProvider>();
    final filteredTotal = p.filteredItems.length;

    return AppListingScreen<DepartmentModel>(
      title: 'Departments',
      subtitle: 'Organize users by department',
      primaryActionLabel: '+ Add Department',
      onPrimaryAction: () => DepartmentFormDrawer.show(context),
      showCheckboxes: false,
      kpiCards: [
        KpiCard(
          label: 'Total Departments',
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
                  ? DepartmentStatus.active
                  : DepartmentStatus.inactive),
        );
      },
      columns: [
        TableColumn<DepartmentModel>(
          key: 'name',
          label: 'Department Name',
          cellBuilder: (r) => Text(
            r.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'code',
          label: 'Department Code',
          width: 120,
          cellBuilder: (r) => Text(
            r.code,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'description',
          label: 'Description',
          cellBuilder: (r) => Text(
            r.description ?? '—',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'users',
          label: 'Users Count',
          numeric: true,
          width: 120,
          cellBuilder: (r) => Text('${r.usersCount}'),
        ),
        TableColumn<DepartmentModel>(
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
              r.code,
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
      emptyMessage: 'No departments match your filters',
      onSearch: p.setSearchQuery,
      searchHint: 'Search by name, code, or description…',
      rowActions: [
        RowAction<DepartmentModel>(
          key: 'edit',
          label: 'Edit',
          icon: const Icon(LucideIcons.pencil),
          onTap: (row) => DepartmentFormDrawer.show(context, existing: row),
        ),
        RowAction<DepartmentModel>(
          key: 'toggle',
          label: 'Activate / deactivate',
          icon: const Icon(LucideIcons.refreshCw),
          onTap: (row) async {
            await context.read<DepartmentsProvider>().toggleDepartmentStatus(
                  row.id,
                );
          },
        ),
        RowAction<DepartmentModel>(
          key: 'delete',
          label: 'Delete',
          icon: const Icon(LucideIcons.trash2),
          isDanger: true,
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
