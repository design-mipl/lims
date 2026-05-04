import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../user_management/shared/audit_cell.dart';
import '../data/courier_model.dart';
import '../state/courier_provider.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key});

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  CourierProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<CourierProvider>();
      _provider!.addListener(_onProviderChanged);
    });
  }

  void _onProviderChanged() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final message = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, CourierModel row) async {
    final label = row.companyName.trim().isNotEmpty
        ? row.companyName
        : row.personName;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Courier',
      message: 'Delete "$label" (${row.code})? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CourierProvider>().delete(row.id);
  }

  Future<void> _confirmDeactivate(BuildContext context, CourierModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Deactivate Courier',
      message:
          'Deactivate "${row.companyName.isNotEmpty ? row.companyName : row.personName}"?',
      confirmLabel: 'Deactivate',
      variant: AppConfirmDialogVariant.warning,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CourierProvider>().toggleStatus(row.id);
  }

  Future<void> _confirmActivate(BuildContext context, CourierModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Activate Courier',
      message:
          'Activate "${row.companyName.isNotEmpty ? row.companyName : row.personName}"?',
      confirmLabel: 'Activate',
      variant: AppConfirmDialogVariant.info,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CourierProvider>().toggleStatus(row.id);
  }

  void _handleExport(BuildContext context, {List<CourierModel>? rows}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          rows != null
              ? 'Exporting ${rows.length} records...'
              : 'Exporting all records...',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _primaryCourierTitle(CourierModel r) =>
      r.companyName.trim().isNotEmpty ? r.companyName : r.personName;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CourierProvider>();

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<CourierModel>(
        title: 'Courier Master',
        subtitle: 'Pickup and delivery partners',
        primaryActionLabel: '+ Add Courier',
        onPrimaryAction: () => context.push('/couriers/create'),
        showCheckboxes: true,
        showKpis: false,
        showExport: true,
        showColumnToggle: true,
        onExport: () => _handleExport(context),
        bulkRowId: (r) => r.id,
        tabs: [
          TabConfig(label: 'All', count: p.couriers.length),
          TabConfig(label: 'Active', count: p.activeCount),
          TabConfig(label: 'Inactive', count: p.inactiveCount),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setStatusFilterByTab,
        searchHint: 'Search by company name, person, mobile...',
        onSearch: p.setSearchQuery,
        onBulkActivate: (ids) => p.bulkActivate(ids.cast<String>()),
        onBulkDeactivate: (ids) => p.bulkDeactivate(ids.cast<String>()),
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        onBulkExport: (rows) async =>
            _handleExport(context, rows: rows.cast<CourierModel>().toList()),
        emptyMessage: 'No couriers found',
        emptyWidget: Padding(
          padding: EdgeInsets.all(AppTokens.space8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No couriers found',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.pageTitleSize,
                  fontWeight: AppTokens.weightSemibold,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space2),
              Text(
                'Create your first courier to manage pickup and delivery mappings.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textSecondary,
                ),
              ),
              SizedBox(height: AppTokens.space4),
              AppButton(
                label: 'Add Courier',
                variant: AppButtonVariant.primary,
                icon: LucideIcons.plus,
                onPressed: () => context.push('/couriers/create'),
              ),
            ],
          ),
        ),
        columns: [
          TableColumn<CourierModel>(
            key: 'courier',
            label: 'Courier',
            flex: 1,
            sortable: true,
            sortValue: (r) => _primaryCourierTitle(r).toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) =>
                '${r.companyName} ${r.personName}',
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _primaryCourierTitle(r),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.personName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    color: AppTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TableColumn<CourierModel>(
            key: 'contact',
            label: 'Contact',
            width: 160,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) =>
                '${r.mobiles.join(' ')} ${r.emails.join(' ')}',
            cellBuilder: (r) {
              final m = r.mobiles.isNotEmpty ? r.mobiles.first : '—';
              final e = r.emails.isNotEmpty ? r.emails.first : '—';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    m,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.tableCellSize,
                      fontWeight: AppTokens.weightMedium,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  Text(
                    e,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      color: AppTokens.textMuted,
                    ),
                  ),
                ],
              );
            },
          ),
          TableColumn<CourierModel>(
            key: 'location',
            label: 'Location',
            width: 140,
            sortable: true,
            sortValue: (r) => r.city.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => '${r.city} ${r.state}',
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.city.isEmpty ? '—' : r.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.state.isEmpty ? '' : r.state,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    color: AppTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TableColumn<CourierModel>(
            key: 'areas',
            label: 'Areas',
            width: 96,
            sortable: false,
            numeric: false,
            cellBuilder: (r) => Center(
              child: AppBadge(
                label: '${r.areaMappings.length} Areas',
                color: AppBadgeColor.neutral,
              ),
            ),
          ),
          TableColumn<CourierModel>(
            key: 'contactsMap',
            label: 'Contacts',
            width: 104,
            sortable: false,
            cellBuilder: (r) => Center(
              child: AppBadge(
                label: '${r.contactMappings.length} Contacts',
                color: AppBadgeColor.neutral,
              ),
            ),
          ),
          TableColumn<CourierModel>(
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
            filterSelectValue: (r) => r.status,
            cellBuilder: (r) => Center(child: StatusChip(status: r.status)),
          ),
          TableColumn<CourierModel>(
            key: 'audit',
            label: 'Audit',
            width: 160,
            sortable: true,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) =>
                AuditCell(name: r.updatedBy, date: r.updatedAt),
          ),
        ],
        rows: p.pagedRows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _primaryCourierTitle(r),
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.tableCellSize,
                      fontWeight: AppTokens.weightSemibold,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ),
                StatusChip(status: r.status),
              ],
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              r.personName,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            Wrap(
              spacing: AppTokens.space2,
              runSpacing: AppTokens.space2,
              children: [
                AppBadge(
                  label: '${r.areaMappings.length} Areas',
                  color: AppBadgeColor.neutral,
                ),
                AppBadge(
                  label: '${r.contactMappings.length} Contacts',
                  color: AppBadgeColor.neutral,
                ),
              ],
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<CourierModel>(
            key: 'view',
            label: 'View Details',
            icon: const Icon(LucideIcons.eye),
            onTap: (row) => context.push('/couriers/${row.id}'),
          ),
          RowAction<CourierModel>(
            key: 'edit',
            label: 'Edit',
            icon: const Icon(LucideIcons.pencil),
            onTap: (row) => context.push(
              '/couriers/${row.id}',
              extra: {'startEdit': true},
            ),
          ),
          RowAction<CourierModel>(
            key: 'delete',
            label: 'Delete',
            icon: const Icon(LucideIcons.trash2),
            isDanger: true,
            onTap: (row) => _confirmDelete(context, row),
          ),
          RowAction<CourierModel>(
            key: 'deactivate',
            label: 'Deactivate',
            icon: const Icon(LucideIcons.ban),
            isEnabled: (row) => row.status == 'active',
            onTap: (row) => _confirmDeactivate(context, row),
          ),
          RowAction<CourierModel>(
            key: 'activate',
            label: 'Activate',
            icon: const Icon(LucideIcons.check),
            isEnabled: (row) => row.status == 'inactive',
            onTap: (row) => _confirmActivate(context, row),
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
