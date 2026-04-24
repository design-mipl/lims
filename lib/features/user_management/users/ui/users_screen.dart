import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/components/display/kpi_metric.dart';
import '../../../../design_system/tokens.dart';
import '../data/user_model.dart';
import '../state/users_provider.dart';

String _formatLastLogin(DateTime? d) {
  if (d == null) {
    return '—';
  }
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final h = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$y-$m-$day $h:$min';
}

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
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Delete user?',
            style: theme.textTheme.titleSmall,
          ),
          content: Text(
            'This will permanently remove "${row.name}" (${row.email}). '
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
      await context.read<UsersProvider>().deleteUser(row.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UsersProvider>();
    final filteredTotal = p.filteredItems.length;
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark
        ? AppTokens.neutral400
        : AppTokens.neutral600;

    return AppListingScreen<UserModel>(
      title: 'Users',
      subtitle: 'Create accounts, assign departments, and control access',
      primaryActionLabel: '+ Add User',
      onPrimaryAction: () => context.push('/user-management/users/create'),
      showCheckboxes: false,
      kpiCards: [
        KpiCard(
          label: 'Total Users',
          value: '${p.totalCount}',
        ),
        KpiCard(
          label: 'Active Users',
          value: '${p.activeCount}',
        ),
        KpiCard(
          label: 'Inactive Users',
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
              : (i == 1 ? UserStatus.active : UserStatus.inactive),
        );
      },
      columns: [
        TableColumn<UserModel>(
          key: 'name',
          label: 'Name',
          cellBuilder: (r) => Row(
            children: [
              AppAvatar(
                name: r.name,
                size: AppAvatarSize.sm,
              ),
              SizedBox(width: AppTokens.space2),
              Expanded(
                child: Text(
                  r.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        TableColumn<UserModel>(
          key: 'contact',
          label: 'Email / Phone',
          cellBuilder: (r) => Text.rich(
            TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(text: r.email),
                if (r.phone != null && r.phone!.isNotEmpty)
                  TextSpan(
                    text: ' · ${r.phone}',
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
              ],
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
          key: 'dept',
          label: 'Department',
          width: 140,
          cellBuilder: (r) => Text(
            r.departmentName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
          key: 'role',
          label: 'Role',
          width: 140,
          cellBuilder: (r) => Text(
            r.roleName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
          key: 'lastLogin',
          label: 'Last Login',
          width: 150,
          cellBuilder: (r) => Text(
            _formatLastLogin(r.lastLogin),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<UserModel>(
          key: 'status',
          label: 'Status',
          width: 120,
          sortable: false,
          cellBuilder: (r) => StatusChip(status: r.status.name),
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
                  child: Text(
                    r.name,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              r.email,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            if (r.phone != null && r.phone!.isNotEmpty)
              Text(
                r.phone!,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            SizedBox(height: AppTokens.space2),
            Row(
              children: [
                StatusChip(status: r.status.name),
                SizedBox(width: AppTokens.space3),
                Expanded(
                  child: Text(
                    r.departmentName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTokens.neutral500,
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
          key: 'view',
          label: 'View',
          icon: const Icon(LucideIcons.eye),
          onTap: (row) => context.push('/user-management/users/${row.id}'),
        ),
        RowAction<UserModel>(
          key: 'edit',
          label: 'Edit',
          icon: const Icon(LucideIcons.pencil),
          onTap: (row) =>
              context.push('/user-management/users/${row.id}/edit'),
        ),
        RowAction<UserModel>(
          key: 'toggle',
          label: 'Activate / Deactivate',
          icon: const Icon(LucideIcons.refreshCw),
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
