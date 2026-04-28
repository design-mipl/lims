import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/audit_cell.dart';
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
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Role',
      message: 'Delete "${row.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && context.mounted) {
      await context.read<RolesProvider>().deleteRole(row.id);
    }
  }

  void _handleExport(BuildContext context, {List<RoleModel>? rows}) {
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
    final p = context.watch<RolesProvider>();
    final filteredTotal = p.filteredItems.length;

    return AppListingScreen<RoleModel>(
      title: 'Roles',
      subtitle: 'Define access tiers and assign them to users',
      primaryActionLabel: '+ Add Role',
      onPrimaryAction: () => RoleFormDrawer.show(context),
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onExport: () => _handleExport(context),
      onBulkActivate: (ids) async => p.bulkActivate(ids.cast<String>()),
      onBulkDeactivate: (ids) async => p.bulkDeactivate(ids.cast<String>()),
      onBulkDelete: (ids) async => p.bulkDelete(ids.cast<String>()),
      onBulkExport: (rows) async => _handleExport(
            context,
            rows: rows.cast<RoleModel>().toList(),
          ),
      kpiCards: [
        KpiCard(
          label: 'Total Roles',
          value: p.totalCount.toString(),
          icon: LucideIcons.shield,
          iconColor: AppTokens.kpiPurple,
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
              : (i == 1 ? RoleStatus.active : RoleStatus.inactive),
        );
      },
      columns: [
        TableColumn<RoleModel>(
          key: 'name',
          label: 'Role Name',
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
              Text(
                _typeLabel(r.type),
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        TableColumn<RoleModel>(
          key: 'level',
          label: 'Level',
          width: 120,
          sortable: true,
          sortValue: (r) => r.level,
          filter: const AppColumnFilter(
            type: AppColumnFilterType.select,
            options: [
              AppSelectItem<String>(value: '0', label: 'Admin'),
              AppSelectItem<String>(value: '1', label: 'Power User'),
              AppSelectItem<String>(value: '2', label: 'Project User'),
              AppSelectItem<String>(value: '3', label: 'Viewer'),
            ],
          ),
          filterSelectValue: (r) => r.level.clamp(0, 3).toString(),
          cellBuilder: (r) => Text(
            RoleModel.labelForLevel(r.level),
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: FontWeight.w400,
              color: AppTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<RoleModel>(
          key: 'description',
          label: 'Description',
          sortable: false,
          cellBuilder: (r) => Text(
            r.description ?? '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: FontWeight.w400,
              color: AppTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<RoleModel>(
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
        TableColumn<RoleModel>(
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
        TableColumn<RoleModel>(
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
              _typeLabel(r.type),
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
                Expanded(
                  child: Text(
                    RoleModel.labelForLevel(r.level),
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      fontWeight: FontWeight.w400,
                      color: AppTokens.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
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
          isEnabled: (row) => !row.isSystemRole,
          onTap: (row) => RoleFormDrawer.show(context, existing: row),
        ),
        RowAction<RoleModel>(
          key: 'toggle',
          label: 'Activate',
          icon: const Icon(LucideIcons.checkCircle),
          labelBuilder: (row) => row.status == RoleStatus.active
              ? 'Deactivate'
              : 'Activate',
          iconBuilder: (row) => Icon(
            row.status == RoleStatus.active
                ? LucideIcons.xCircle
                : LucideIcons.checkCircle,
          ),
          isEnabled: (row) => !row.isSystemRole,
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
