import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../design_system/components/components.dart';
import '../../../design_system/tokens.dart';
import '../../user_management/shared/audit_cell.dart';
import 'master_status.dart';
import 'simple_master_config.dart';
import 'simple_master_form_modal.dart';
import 'simple_master_model.dart';
import 'simple_master_provider.dart';

class SimpleMasterScreen extends StatefulWidget {
  const SimpleMasterScreen({super.key, required this.config});

  final SimpleMasterConfig config;

  @override
  State<SimpleMasterScreen> createState() => _SimpleMasterScreenState();
}

class _SimpleMasterScreenState extends State<SimpleMasterScreen> {
  SimpleMasterProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<SimpleMasterProvider>();
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

  Future<void> _confirmDelete(
    BuildContext context,
    SimpleMasterModel row,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: widget.config.deleteTitle,
      message: widget.config.deleteMessage(row),
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && context.mounted) {
      await context.read<SimpleMasterProvider>().delete(row.id);
    }
  }

  void _handleExport(BuildContext context, {List<SimpleMasterModel>? rows}) {
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
    final p = context.watch<SimpleMasterProvider>();
    final config = widget.config;
    final filteredTotal = p.filteredItems.length;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<SimpleMasterModel>(
        title: config.title,
        subtitle: config.subtitle,
        primaryActionLabel: config.primaryActionLabel,
        onPrimaryAction: () => SimpleMasterFormModal.show(
          context,
          config: config,
        ),
        showCheckboxes: true,
        showKpis: false,
        bulkRowId: (r) => r.id,
        onExport: () => _handleExport(context),
        onBulkActivate: (ids) async => p.bulkActivate(ids.cast<String>()),
        onBulkDeactivate: (ids) async => p.bulkDeactivate(ids.cast<String>()),
        onBulkDelete: (ids) async => p.bulkDelete(ids.cast<String>()),
        onBulkExport: (rows) async => _handleExport(
          context,
          rows: rows.cast<SimpleMasterModel>().toList(),
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
          TableColumn<SimpleMasterModel>(
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
          TableColumn<SimpleMasterModel>(
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
          TableColumn<SimpleMasterModel>(
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
          TableColumn<SimpleMasterModel>(
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
          TableColumn<SimpleMasterModel>(
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
        emptyMessage: config.emptyMessage,
        onSearch: p.setSearchQuery,
        searchHint: config.searchHint,
        rowActions: [
          RowAction<SimpleMasterModel>(
            key: 'edit',
            label: 'Edit',
            icon: const Icon(LucideIcons.pencil),
            onTap: (row) => SimpleMasterFormModal.show(
              context,
              config: config,
              existing: row,
            ),
          ),
          RowAction<SimpleMasterModel>(
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
              await context.read<SimpleMasterProvider>().toggleStatus(row.id);
            },
          ),
          RowAction<SimpleMasterModel>(
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
