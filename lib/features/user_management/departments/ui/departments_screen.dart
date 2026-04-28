import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/audit_cell.dart';
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
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Department',
      message: 'Delete "${row.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && context.mounted) {
      await context.read<DepartmentsProvider>().deleteDepartment(row.id);
    }
  }

  void _handleExport(BuildContext context, {List<DepartmentModel>? rows}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          rows != null
              ? 'Exporting ${rows.length} records...'
              : 'Exporting all records...',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textBase,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
        duration: const Duration(seconds: 2),
      ),
    );
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
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onExport: () => _handleExport(context),
      onBulkActivate: (ids) async => p.bulkActivate(ids.cast<String>()),
      onBulkDeactivate: (ids) async => p.bulkDeactivate(ids.cast<String>()),
      onBulkDelete: (ids) async => p.bulkDelete(ids.cast<String>()),
      onBulkExport: (rows) async => _handleExport(
            context,
            rows: rows.cast<DepartmentModel>().toList(),
          ),
      kpiCards: [
        KpiCard(
          label: 'Total Departments',
          value: p.totalCount.toString(),
          icon: LucideIcons.building2,
          iconColor: AppTokens.kpiBlue,
        ),
        KpiCard(
          label: 'Active',
          value: p.activeCount.toString(),
          icon: LucideIcons.checkCircle,
          iconColor: AppTokens.kpiGreen,
        ),
        KpiCard(
          label: 'Inactive',
          value: p.inactiveCount.toString(),
          icon: LucideIcons.xCircle,
          iconColor: AppTokens.kpiOrange,
        ),
      ],
      showKpis: false,
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
          width: 200,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => '${r.name} ${r.code}',
          cellBuilder: (r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                r.name,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.tableCellSize,
                  fontWeight: FontWeight.w500,
                  color: AppTokens.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                r.code,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'description',
          label: 'Description',
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.description ?? '',
          cellBuilder: (r) => Text(
            r.description ?? '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              color: AppTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'users',
          label: 'Users',
          width: 80,
          sortable: true,
          sortValue: (r) => r.usersCount,
          cellBuilder: (r) => Center(
            child: Text(
              r.usersCount.toString(),
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: FontWeight.w500,
                color: AppTokens.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'status',
          label: 'Status',
          width: 90,
          sortable: false,
          filter: const AppColumnFilter(
            type: AppColumnFilterType.select,
            options: [
              AppSelectItem<String>(value: 'active', label: 'Active'),
              AppSelectItem<String>(value: 'inactive', label: 'Inactive'),
            ],
          ),
          filterSelectValue: (r) => r.status.name,
          cellBuilder: (r) => Center(
            child: StatusChip(status: r.status.name),
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'createdBy',
          label: 'Created By',
          width: 160,
          sortable: true,
          sortValue: (r) => r.createdAt.millisecondsSinceEpoch,
          cellBuilder: (r) => AuditCell(
            name: r.createdBy,
            date: r.createdAt,
          ),
        ),
        TableColumn<DepartmentModel>(
          key: 'updatedBy',
          label: 'Updated By',
          width: 160,
          sortable: true,
          sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
          cellBuilder: (r) => AuditCell(
            name: r.updatedBy,
            date: r.updatedAt,
          ),
        ),
      ],
      rows: p.pagedRows,
      mobileCardBuilder: (r) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: FontWeight.w500,
                color: AppTokens.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              r.code,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                fontWeight: FontWeight.w400,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            Row(
              children: [
                StatusChip(status: r.status.name),
                SizedBox(width: AppTokens.space3),
                Text(
                  '${r.usersCount} users',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    fontWeight: FontWeight.w400,
                    color: AppTokens.textSecondary,
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
          label: 'Activate',
          icon: const Icon(LucideIcons.checkCircle),
          labelBuilder: (row) => row.status == DepartmentStatus.active
              ? 'Deactivate'
              : 'Activate',
          iconBuilder: (row) => Icon(
            row.status == DepartmentStatus.active
                ? LucideIcons.xCircle
                : LucideIcons.checkCircle,
          ),
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
