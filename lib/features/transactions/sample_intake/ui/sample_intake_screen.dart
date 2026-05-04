import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/sample_intake_model.dart';
import '../state/sample_intake_provider.dart';

class SampleIntakeScreen extends StatefulWidget {
  const SampleIntakeScreen({super.key});

  @override
  State<SampleIntakeScreen> createState() => _SampleIntakeScreenState();
}

class _SampleIntakeScreenState extends State<SampleIntakeScreen> {
  SampleIntakeProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<SampleIntakeProvider>().loadReceipts();
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

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _confirmDelete(BuildContext context, SampleIntakeModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete receipt',
      message:
          'Delete lot "${row.lotNo}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SampleIntakeProvider>().deleteReceipt(row.id);
  }

  Future<void> _openCreate(BuildContext context) async {
    await context.push('/transactions/sample-intake/create');
    if (context.mounted) {
      await context.read<SampleIntakeProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<SampleIntakeModel>(
        title: 'Sample Intake & Data Entry',
        subtitle:
            'Receipt lots, customer and site details, and sample data entry progress.',
        primaryActionLabel: 'Create Receipt',
        onPrimaryAction: () => _openCreate(context),
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: (ids) => p.bulkDeleteReceipts(ids),
        showKpis: false,
        showExport: false,
        tabs: [
          TabConfig(label: 'All', count: p.allCount),
          TabConfig(
            label: 'Draft',
            count: p.countForStatus(SampleIntakeStatus.draft),
          ),
          TabConfig(
            label: 'Pending',
            count: p.countForStatus(SampleIntakeStatus.dataEntryPending),
          ),
          TabConfig(
            label: 'In progress',
            count: p.countForStatus(SampleIntakeStatus.inProgress),
          ),
          TabConfig(
            label: 'Completed',
            count: p.countForStatus(SampleIntakeStatus.completed),
          ),
          TabConfig(
            label: 'To lab',
            count: p.countForStatus(SampleIntakeStatus.forwardedToLab),
          ),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setStatusFilterByTab,
        searchHint: 'Search by lot, customer, site, courier, work order...',
        onSearch: p.setSearchQuery,
        onRowTap: (row) => context.push('/transactions/sample-intake/${row.id}'),
        columns: [
          TableColumn<SampleIntakeModel>(
            key: 'lot',
            label: 'Lot No.',
            width: 120,
            sortable: true,
            sortValue: (r) => r.lotNo.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.lotNo,
            cellBuilder: (r) => Text(
              r.lotNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightMedium,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SampleIntakeModel>(
            key: 'receipt',
            label: 'Receipt Date & Time',
            width: 140,
            sortable: true,
            sortValue: (r) =>
                r.receiptDate.millisecondsSinceEpoch + r.receiptTime.hashCode,
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(r.receiptDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.receiptTime,
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
          TableColumn<SampleIntakeModel>(
            key: 'customer',
            label: 'Customer / Company',
            flex: 1,
            sortable: true,
            sortValue: (r) => r.customerName.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => '${r.customerName} ${r.customerCompany}',
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.customerCompany,
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
          TableColumn<SampleIntakeModel>(
            key: 'site',
            label: 'Site Contact / Site Company',
            flex: 1,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => '${r.siteContactPerson} ${r.siteCompany}',
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.siteContactPerson,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.siteCompany,
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
          TableColumn<SampleIntakeModel>(
            key: 'courier',
            label: 'Courier / POD No.',
            width: 140,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => '${r.courierName} ${r.podNo}',
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.courierName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.podNo,
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
          TableColumn<SampleIntakeModel>(
            key: 'samples',
            label: 'No. of Samples',
            width: 112,
            sortable: true,
            sortValue: (r) => r.noOfSamples,
            numeric: true,
            cellBuilder: (r) => Text(
              '${r.noOfSamples}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SampleIntakeModel>(
            key: 'progress',
            label: 'Data Entry Progress',
            width: 150,
            sortable: true,
            sortValue: (r) => r.dataEntryCompletedCount,
            cellBuilder: (r) => Text(
              '${r.dataEntryCompletedCount} / ${r.noOfSamples} Completed',
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SampleIntakeModel>(
            key: 'workOrder',
            label: 'Work Order No.',
            width: 120,
            sortable: true,
            sortValue: (r) => r.workOrderNo.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.workOrderNo,
            cellBuilder: (r) => Text(
              r.workOrderNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<SampleIntakeModel>(
            key: 'status',
            label: 'Status',
            width: 140,
            sortable: false,
            filter: const AppColumnFilter(
              type: AppColumnFilterType.select,
              options: [
                AppSelectItem<String>(
                  value: SampleIntakeStatus.draft,
                  label: 'Draft',
                ),
                AppSelectItem<String>(
                  value: SampleIntakeStatus.dataEntryPending,
                  label: 'Data entry pending',
                ),
                AppSelectItem<String>(
                  value: SampleIntakeStatus.inProgress,
                  label: 'In progress',
                ),
                AppSelectItem<String>(
                  value: SampleIntakeStatus.completed,
                  label: 'Completed',
                ),
                AppSelectItem<String>(
                  value: SampleIntakeStatus.forwardedToLab,
                  label: 'Forwarded to lab',
                ),
              ],
            ),
            filterSelectValue: (r) => r.status,
            cellBuilder: (r) => Center(child: StatusChip(status: r.status)),
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
                    r.lotNo,
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
              r.customerName,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<SampleIntakeModel>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push('/transactions/sample-intake/${row.id}'),
          ),
          RowAction<SampleIntakeModel>(
            key: 'enterData',
            label: 'Enter Data',
            icon: Icon(LucideIcons.keyboard, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push(
              '/transactions/sample-intake/${row.id}/enter-data',
            ),
          ),
          RowAction<SampleIntakeModel>(
            key: 'edit',
            label: 'Edit Receipt',
            icon: Icon(LucideIcons.pencil, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push(
              '/transactions/sample-intake/${row.id}/edit',
            ),
          ),
          RowAction<SampleIntakeModel>(
            key: 'delete',
            label: 'Delete',
            icon: Icon(LucideIcons.trash2, size: AppTokens.iconButtonIconMd),
            isDanger: true,
            onTap: (row) => _confirmDelete(context, row),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No sample receipts found',
      ),
    );
  }
}
