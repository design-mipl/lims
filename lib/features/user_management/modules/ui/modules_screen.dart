import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/audit_cell.dart';
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
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Module',
      message: 'Delete "${row.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && context.mounted) {
      await context.read<ModulesProvider>().deleteModule(row.id);
    }
  }

  void _handleExport(BuildContext context, {List<ModuleModel>? rows}) {
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
    final p = context.watch<ModulesProvider>();
    final filteredTotal = p.filteredItems.length;

    return AppListingScreen<ModuleModel>(
      title: 'Modules',
      subtitle: 'Define navigation entries and permission scope',
      primaryActionLabel: '+ Add Module',
      onPrimaryAction: () => ModuleFormDrawer.show(context),
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onExport: () => _handleExport(context),
      onBulkActivate: (ids) async => p.bulkActivate(ids.cast<String>()),
      onBulkDeactivate: (ids) async => p.bulkDeactivate(ids.cast<String>()),
      onBulkDelete: (ids) async => p.bulkDelete(ids.cast<String>()),
      onBulkExport: (rows) async => _handleExport(
            context,
            rows: rows.cast<ModuleModel>().toList(),
          ),
      kpiCards: [
        KpiCard(
          label: 'Total Modules',
          value: p.totalCount.toString(),
          icon: LucideIcons.layoutGrid,
          iconColor: AppTokens.kpiTeal,
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
                  ? ModuleStatus.active
                  : ModuleStatus.inactive),
        );
      },
      columns: [
        TableColumn<ModuleModel>(
          key: 'name',
          label: 'Module Name',
          width: 200,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.name,
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
              if (r.parentName != null)
                Text(
                  r.parentName!,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    color: AppTokens.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        TableColumn<ModuleModel>(
          key: 'parent',
          label: 'Parent Module',
          width: 140,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.parentName ?? '',
          cellBuilder: (r) => Text(
            r.parentName ?? '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              color: AppTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<ModuleModel>(
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
        TableColumn<ModuleModel>(
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
        TableColumn<ModuleModel>(
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
            if (r.parentName != null) ...[
              SizedBox(height: AppTokens.space1),
              Text(
                r.parentName!,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: AppTokens.space2),
            StatusChip(status: r.status.name),
          ],
        );
      },
      isLoading: p.isLoading,
      emptyMessage: 'No modules match your filters',
      onSearch: p.setSearchQuery,
      searchHint: 'Search by name or parent…',
      rowActions: [
        RowAction<ModuleModel>(
          key: 'edit',
          label: 'Edit',
          icon: const Icon(LucideIcons.pencil),
          onTap: (row) => ModuleFormDrawer.show(context, existing: row),
        ),
        RowAction<ModuleModel>(
          key: 'toggle',
          label: 'Activate',
          icon: const Icon(LucideIcons.checkCircle),
          labelBuilder: (row) => row.status == ModuleStatus.active
              ? 'Deactivate'
              : 'Activate',
          iconBuilder: (row) => Icon(
            row.status == ModuleStatus.active
                ? LucideIcons.xCircle
                : LucideIcons.checkCircle,
          ),
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
