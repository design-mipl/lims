import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../user_management/shared/audit_cell.dart';
import '../../shared/master_status.dart';
import '../models/item_master_model.dart';
import '../state/item_master_provider.dart';
import 'item_master_form_modal.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({super.key});

  @override
  State<ItemMasterScreen> createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
  ItemMasterProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<ItemMasterProvider>();
      _provider!.addListener(_onProviderChanged);
    });
  }

  void _onProviderChanged() {
    final p = _provider;
    if (p == null || !p.hasError || !mounted) return;
    final message = p.error;
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
      p.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, ItemMasterModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete item',
      message: 'Delete "${row.code}" — ${row.name}?',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && context.mounted) {
      await context.read<ItemMasterProvider>().delete(row.id);
    }
  }

  void _handleExport(BuildContext context, {List<ItemMasterModel>? rows}) {
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ItemMasterProvider>();
    final filteredTotal = p.filteredItems.length;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<ItemMasterModel>(
        title: 'Item Master',
        subtitle: 'Lubricants and consumables',
        primaryActionLabel: '+ Add Item',
        onPrimaryAction: () => ItemMasterFormModal.show(context),
        showCheckboxes: true,
        showKpis: false,
        bulkRowId: (r) => r.id,
        onExport: () => _handleExport(context),
        onBulkActivate: (ids) async => p.bulkActivate(ids.cast<String>()),
        onBulkDeactivate: (ids) async => p.bulkDeactivate(ids.cast<String>()),
        onBulkDelete: (ids) async => p.bulkDelete(ids.cast<String>()),
        onBulkExport: (rows) async => _handleExport(
          context,
          rows: rows.cast<ItemMasterModel>().toList(),
        ),
        tabs: [
          TabConfig(label: 'All', count: p.activeCount + p.inactiveCount),
          TabConfig(label: 'Active', count: p.activeCount),
          TabConfig(label: 'Inactive', count: p.inactiveCount),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: (i) {
          p.setStatusFilter(
            i == 0
                ? null
                : (i == 1 ? MasterStatus.active : MasterStatus.inactive),
          );
        },
        columns: [
          TableColumn<ItemMasterModel>(
            key: 'code',
            label: 'Code',
            width: 120,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.code,
            cellBuilder: (r) => Text(
              r.code,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: FontWeight.w500,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<ItemMasterModel>(
            key: 'name',
            label: 'Name',
            width: 180,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.name,
            cellBuilder: (r) => Text(
              r.name,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TableColumn<ItemMasterModel>(
            key: 'description',
            label: 'Description',
            flex: 1,
            sortable: false,
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
          TableColumn<ItemMasterModel>(
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
          TableColumn<ItemMasterModel>(
            key: 'createdBy',
            label: 'Created By',
            width: 150,
            sortable: true,
            sortValue: (r) => r.createdAt.millisecondsSinceEpoch,
            cellBuilder: (r) => AuditCell(
              name: r.createdBy,
              date: r.createdAt,
            ),
          ),
          TableColumn<ItemMasterModel>(
            key: 'updatedBy',
            label: 'Updated By',
            width: 150,
            sortable: true,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => AuditCell(
              name: r.updatedBy,
              date: r.updatedAt,
            ),
          ),
        ],
        rows: p.pagedRows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: FontWeight.w500,
                color: AppTokens.textPrimary,
              ),
            ),
            Text(
              r.code,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            StatusChip(status: r.status.name),
          ],
        ),
        isLoading: p.isLoading,
        emptyMessage: 'No items match your filters',
        onSearch: p.setSearchQuery,
        searchHint: 'Search by code, name, or description…',
        rowActions: [
          RowAction<ItemMasterModel>(
            key: 'edit',
            label: 'Edit',
            icon: const Icon(LucideIcons.pencil),
            onTap: (row) => ItemMasterFormModal.show(context, existing: row),
          ),
          RowAction<ItemMasterModel>(
            key: 'toggle',
            label: 'Activate',
            labelBuilder: (row) => row.status == MasterStatus.active
                ? 'Deactivate'
                : 'Activate',
            icon: const Icon(LucideIcons.checkCircle),
            iconBuilder: (row) => Icon(
              row.status == MasterStatus.active
                  ? LucideIcons.xCircle
                  : LucideIcons.checkCircle,
            ),
            onTap: (row) async {
              await context.read<ItemMasterProvider>().toggleStatus(row.id);
            },
          ),
          RowAction<ItemMasterModel>(
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
      ),
    );
  }
}
