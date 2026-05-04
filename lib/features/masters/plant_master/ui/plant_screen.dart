import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../user_management/shared/audit_cell.dart';
import '../data/plant_model.dart';
import '../state/plant_provider.dart';
import 'plant_master_form_modal.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key});

  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  PlantProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<PlantProvider>();
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

  Future<void> _confirmDelete(BuildContext context, PlantModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Plant',
      message: 'Delete "${row.plant}" (${row.code})? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    final p = context.read<PlantProvider>();
    await p.delete(row.id);
  }

  void _handleExport(BuildContext context, {List<PlantModel>? rows}) {
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
    final p = context.watch<PlantProvider>();

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<PlantModel>(
        title: 'Plant Master',
        subtitle: 'Production plants and locations',
        primaryActionLabel: '+ Add Plant',
        onPrimaryAction: () => PlantMasterFormModal.show(context),
        showCheckboxes: true,
        showKpis: false,
        showExport: true,
        onExport: () => _handleExport(context),
        bulkRowId: (r) => r.id,
        tabs: [
          TabConfig(label: 'All', count: p.plants.length),
          TabConfig(label: 'Active', count: p.activeCount),
          TabConfig(label: 'Inactive', count: p.inactiveCount),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setStatusFilterByTab,
        searchHint: 'Search by code or plant...',
        onSearch: p.setSearchQuery,
        onBulkActivate: (ids) => p.bulkActivate(ids.cast<String>()),
        onBulkDeactivate: (ids) => p.bulkDeactivate(ids.cast<String>()),
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        onBulkExport: (rows) async =>
            _handleExport(context, rows: rows.cast<PlantModel>().toList()),
        columns: [
          TableColumn<PlantModel>(
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
                fontWeight: AppTokens.weightMedium,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<PlantModel>(
            key: 'plant',
            label: 'Plant',
            flex: 1,
            sortable: true,
            sortValue: (r) => r.plant.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.plant,
            cellBuilder: (r) => Text(
              r.plant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<PlantModel>(
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
          TableColumn<PlantModel>(
            key: 'createdBy',
            label: 'Created By',
            width: 160,
            sortable: true,
            sortValue: (r) => r.createdAt.millisecondsSinceEpoch,
            cellBuilder: (r) => AuditCell(name: r.createdBy, date: r.createdAt),
          ),
          TableColumn<PlantModel>(
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
              r.plant,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              r.code,
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
        emptyMessage: 'No plants found',
        rowActions: [
          RowAction<PlantModel>(
            key: 'edit',
            label: 'Edit',
            icon: const Icon(LucideIcons.pencil),
            onTap: (row) =>
                PlantMasterFormModal.show(context, existing: row),
          ),
          RowAction<PlantModel>(
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
