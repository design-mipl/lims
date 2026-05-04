import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../user_management/shared/audit_cell.dart';
import '../data/site_model.dart';
import '../state/site_provider.dart';

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SiteProvider>().fetchAll();
    });
  }

  Future<void> _confirmDelete(BuildContext context, SiteModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Site',
      message:
          'Delete "${row.displayName ?? row.code}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SiteProvider>().delete(row.id);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SiteProvider>();
    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<SiteModel>(
        title: 'Site Master',
        subtitle: 'Manage customer sites and locations',
        primaryActionLabel: '+ Add Site',
        onPrimaryAction: () => context.push('/sites/create'),
        showCheckboxes: true,
        showKpis: false,
        showExport: true,
        onExport: () {},
        bulkRowId: (r) => r.id,
        tabs: [
          TabConfig(label: 'All', count: p.sites.length),
          TabConfig(label: 'Active', count: p.activeCount),
          TabConfig(label: 'Inactive', count: p.inactiveCount),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setStatusFilterByTab,
        searchHint: 'Search by code or name...',
        onSearch: p.setSearchQuery,
        onBulkActivate: (ids) => p.bulkActivate(ids.cast<String>()),
        onBulkDeactivate: (ids) => p.bulkDeactivate(ids.cast<String>()),
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        onBulkExport: (_) async {},
        columns: [
          TableColumn<SiteModel>(
            key: 'code',
            label: 'Code',
            width: 120,
            sortable: true,
            sortValue: (r) => r.code.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.code,
            cellBuilder: (r) => Text(
              r.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
                fontWeight: AppTokens.weightMedium,
              ),
            ),
          ),
          TableColumn<SiteModel>(
            key: 'displayName',
            label: 'Display Name',
            width: 160,
            sortable: true,
            sortValue: (r) => (r.displayName ?? '').toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.displayName ?? '',
            cellBuilder: (r) => Text(
              r.displayName ?? '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SiteModel>(
            key: 'company',
            label: 'Company',
            flex: 1,
            sortable: true,
            sortValue: (r) =>
                (r.companyLabel ?? r.companyName ?? '').toLowerCase(),
            cellBuilder: (r) => Text(
              r.companyLabel ?? r.companyName ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SiteModel>(
            key: 'city',
            label: 'City',
            width: 130,
            sortable: true,
            sortValue: (r) => (r.city ?? '').toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.city ?? '',
            cellBuilder: (r) => Text(
              r.city ?? '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SiteModel>(
            key: 'state',
            label: 'State',
            width: 140,
            sortable: true,
            sortValue: (r) => (r.state ?? '').toLowerCase(),
            cellBuilder: (r) => Text(
              r.state ?? '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SiteModel>(
            key: 'status',
            label: 'Status',
            width: 100,
            sortable: false,
            filter: const AppColumnFilter(
              type: AppColumnFilterType.select,
              options: [
                AppSelectItem<String>(value: 'active', label: 'Active'),
                AppSelectItem<String>(value: 'inactive', label: 'Inactive'),
              ],
            ),
            filterSelectValue: (r) => r.status,
            cellBuilder: (r) => Center(child: StatusChip(status: r.status)),
          ),
          TableColumn<SiteModel>(
            key: 'createdBy',
            label: 'Created By',
            width: 160,
            sortable: true,
            sortValue: (r) => r.createdAt.millisecondsSinceEpoch,
            cellBuilder: (r) => AuditCell(name: r.createdBy, date: r.createdAt),
          ),
          TableColumn<SiteModel>(
            key: 'updatedBy',
            label: 'Updated By',
            width: 160,
            sortable: true,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => AuditCell(name: r.updatedBy, date: r.updatedAt),
          ),
        ],
        rows: p.pagedRows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.displayName ?? r.code,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              r.city ?? '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            StatusChip(status: r.status),
          ],
        ),
        isLoading: p.isLoading,
        emptyMessage: 'No sites found',
        rowActions: [
          RowAction<SiteModel>(
            key: 'details',
            label: 'View Details',
            icon: const Icon(LucideIcons.eye),
            onTap: (row) => context.push('/sites/${row.id}'),
          ),
          RowAction<SiteModel>(
            key: 'edit',
            label: 'Edit',
            icon: const Icon(LucideIcons.pencil),
            onTap: (row) =>
                context.push('/sites/${row.id}', extra: {'startEdit': true}),
          ),
          RowAction<SiteModel>(
            key: 'delete',
            label: 'Delete',
            icon: const Icon(LucideIcons.trash2),
            isDanger: true,
            onTap: (row) => _confirmDelete(context, row),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
      ),
    );
  }
}
