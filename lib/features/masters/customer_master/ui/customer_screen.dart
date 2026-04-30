import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../user_management/shared/audit_cell.dart';
import '../data/customer_model.dart';
import '../state/customer_provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CustomerProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerProvider>();
    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<CustomerModel>(
        title: 'Customer Master',
        subtitle: 'Manage customers, contacts, and sample tests',
        primaryActionLabel: '+ Add Customer',
        onPrimaryAction: () => context.push('/customers/create'),
        showCheckboxes: true,
        showKpis: false,
        bulkRowId: (r) => r.id,
        tabs: [
          TabConfig(label: 'All', count: p.customers.length),
          TabConfig(label: 'Active', count: p.activeCount),
          TabConfig(label: 'Inactive', count: p.inactiveCount),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setStatusFilterByTab,
        searchHint: 'Search by company or GST...',
        onSearch: p.setSearchQuery,
        onExport: () {},
        onBulkActivate: (ids) => p.bulkActivate(ids.cast<String>()),
        onBulkDeactivate: (ids) => p.bulkDeactivate(ids.cast<String>()),
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        onBulkExport: (_) async {},
        columns: [
          TableColumn<CustomerModel>(
            key: 'companyName',
            label: 'Company Name',
            width: 220,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.companyName,
            cellBuilder: (r) => Text(
              r.companyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
                fontWeight: AppTokens.weightMedium,
              ),
            ),
          ),
          TableColumn<CustomerModel>(
            key: 'displayName',
            label: 'Display Name',
            width: 160,
            sortable: false,
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
          TableColumn<CustomerModel>(
            key: 'city',
            label: 'City',
            width: 130,
            sortable: false,
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
          TableColumn<CustomerModel>(
            key: 'gstNo',
            label: 'GST No.',
            width: 160,
            sortable: false,
            cellBuilder: (r) => Text(
              r.gstNo ?? '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<CustomerModel>(
            key: 'billingCycle',
            label: 'Billing Cycle',
            width: 120,
            sortable: false,
            cellBuilder: (r) => Text(
              r.billingCycle ?? '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<CustomerModel>(
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
          TableColumn<CustomerModel>(
            key: 'createdBy',
            label: 'Created By',
            width: 160,
            sortable: true,
            sortValue: (r) => r.createdAt.millisecondsSinceEpoch,
            cellBuilder: (r) => AuditCell(name: r.createdBy, date: r.createdAt),
          ),
          TableColumn<CustomerModel>(
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
              r.companyName,
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
        emptyMessage: 'No customers found',
        rowActions: [
          RowAction<CustomerModel>(
            key: 'details',
            label: 'View Details',
            icon: const Icon(LucideIcons.eye),
            onTap: (row) => context.push('/customers/${row.id}'),
          ),
          RowAction<CustomerModel>(
            key: 'edit',
            label: 'Edit',
            icon: const Icon(LucideIcons.pencil),
            onTap: (row) => context.push(
              '/customers/${row.id}',
              extra: {'tab': 'overview', 'edit': true},
            ),
          ),
          RowAction<CustomerModel>(
            key: 'contacts',
            label: 'View Contacts',
            icon: const Icon(LucideIcons.contactRound),
            onTap: (row) => context.push(
              '/customers/${row.id}',
              extra: {'tab': 'contacts'},
            ),
          ),
          RowAction<CustomerModel>(
            key: 'samples',
            label: 'View Sample Types',
            icon: const Icon(LucideIcons.flaskConical),
            onTap: (row) =>
                context.push('/customers/${row.id}', extra: {'tab': 'samples'}),
          ),
          RowAction<CustomerModel>(
            key: 'delete',
            label: 'Delete',
            icon: const Icon(LucideIcons.trash2),
            isDanger: true,
            onTap: (row) => p.delete(row.id),
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
