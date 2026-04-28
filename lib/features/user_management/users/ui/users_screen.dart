import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/audit_cell.dart';
import '../data/user_model.dart';
import '../state/users_provider.dart';

/// Users listing with KPIs, filters, and CRUD (mock API).
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  UsersProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _provider = context.read<UsersProvider>();
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

  Future<void> _confirmDelete(BuildContext context, UserModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete User',
      message: 'Delete "${row.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && context.mounted) {
      await context.read<UsersProvider>().deleteUser(row.id);
    }
  }

  void _handleExport(BuildContext context, {List<UserModel>? rows}) {
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
    final p = context.watch<UsersProvider>();
    final filteredTotal = p.filteredItems.length;

    return AppListingScreen<UserModel>(
      title: 'Users',
      subtitle: 'Create accounts, assign departments, and control access',
      primaryActionLabel: '+ Add User',
      onPrimaryAction: () => context.push('/user-management/users/create'),
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onExport: () => _handleExport(context),
      onBulkActivate: (ids) async => p.bulkActivate(ids.cast<String>()),
      onBulkDeactivate: (ids) async => p.bulkDeactivate(ids.cast<String>()),
      onBulkDelete: (ids) async => p.bulkDelete(ids.cast<String>()),
      onBulkExport: (rows) async => _handleExport(
            context,
            rows: rows.cast<UserModel>().toList(),
          ),
      kpiCards: [
        KpiCard(
          label: 'Total Users',
          value: p.totalCount.toString(),
          icon: LucideIcons.users,
          iconColor: AppTokens.kpiBlue,
        ),
        KpiCard(
          label: 'Active',
          value: p.activeCount.toString(),
          icon: LucideIcons.userCheck,
          iconColor: AppTokens.kpiGreen,
        ),
        KpiCard(
          label: 'Inactive',
          value: p.inactiveCount.toString(),
          icon: LucideIcons.userX,
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
              : (i == 1 ? UserStatus.active : UserStatus.inactive),
        );
      },
      columns: [
        TableColumn<UserModel>(
          key: 'user',
          label: 'User',
          width: 220,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => '${r.name} ${r.email}',
          cellBuilder: (r) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppAvatar(
                name: r.name,
                size: AppAvatarSize.sm,
              ),
              SizedBox(width: AppTokens.space2),
              Expanded(
                child: Column(
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
                      r.email,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        fontWeight: FontWeight.w400,
                        color: AppTokens.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableColumn<UserModel>(
          key: 'role',
          label: 'Role',
          width: 140,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.roleName,
          cellBuilder: (r) => Text(
            r.roleName.isEmpty ? '—' : r.roleName,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: FontWeight.w400,
              color: AppTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
          key: 'dept',
          label: 'Department',
          width: 140,
          sortable: false,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.departmentName,
          cellBuilder: (r) => Text(
            r.departmentName.isEmpty ? '—' : r.departmentName,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: FontWeight.w400,
              color: AppTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
          key: 'employeeId',
          label: 'Employee ID',
          width: 100,
          sortable: false,
          cellBuilder: (r) => Text(
            r.employeeId ?? '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: FontWeight.w400,
              color: AppTokens.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
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
        TableColumn<UserModel>(
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
        TableColumn<UserModel>(
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
            Row(
              children: [
                AppAvatar(name: r.name, size: AppAvatarSize.sm),
                SizedBox(width: AppTokens.space2),
                Expanded(
                  child: Column(
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
                      Text(
                        r.email,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.captionSize,
                          fontWeight: FontWeight.w400,
                          color: AppTokens.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space2),
            Row(
              children: [
                StatusChip(status: r.status.name),
                SizedBox(width: AppTokens.space3),
                Expanded(
                  child: Text(
                    '${r.roleName.isEmpty ? '—' : r.roleName} · '
                    '${r.departmentName.isEmpty ? '—' : r.departmentName}',
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
      emptyMessage: 'No users match your filters',
      onSearch: p.setSearchQuery,
      searchHint: 'Search by name, email, phone, department, or role…',
      rowActions: [
        RowAction<UserModel>(
          key: 'edit',
          label: 'Edit',
          icon: const Icon(LucideIcons.pencil),
          onTap: (row) =>
              context.push('/user-management/users/${row.id}/edit'),
        ),
        RowAction<UserModel>(
          key: 'permissions',
          label: 'Manage Permissions',
          icon: const Icon(LucideIcons.shieldCheck),
          onTap: (row) => context.push(
            '/user-management/users/${row.id}/permissions',
            extra: <String, dynamic>{
              'name': row.name,
              'role': row.roleName,
              'isAdmin': row.roleName == 'Admin',
            },
          ),
        ),
        RowAction<UserModel>(
          key: 'toggle',
          label: 'Activate',
          icon: const Icon(LucideIcons.checkCircle),
          labelBuilder: (row) => row.status == UserStatus.active
              ? 'Deactivate'
              : 'Activate',
          iconBuilder: (row) => Icon(
            row.status == UserStatus.active
                ? LucideIcons.xCircle
                : LucideIcons.checkCircle,
          ),
          onTap: (row) async {
            await context.read<UsersProvider>().toggleUserStatus(row.id);
          },
        ),
        RowAction<UserModel>(
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
