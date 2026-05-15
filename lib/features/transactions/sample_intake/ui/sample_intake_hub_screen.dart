import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/sample_intake_model.dart';
import '../state/sample_intake_provider.dart';
import 'widgets/quick_receipt_entry_modal.dart';

/// Sample Intake hub — operational queue + completed history ([ListingTabStrip]).
class SampleIntakeHubScreen extends StatefulWidget {
  const SampleIntakeHubScreen({
    super.key,
    this.initialHubTab = SampleIntakeHubTab.receiptTracking,
  });

  final SampleIntakeHubTab initialHubTab;

  @override
  State<SampleIntakeHubScreen> createState() => _SampleIntakeHubScreenState();
}

class _SampleIntakeHubScreenState extends State<SampleIntakeHubScreen> {
  SampleIntakeProvider? _provider;

  static const double _kColW = 220;
  static const int _kOpCols = 12;
  static const int _kDoneCols = 8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pr = context.read<SampleIntakeProvider>();
      _provider = pr;
      _provider!.setHubTab(widget.initialHubTab);
      _provider!.addListener(_onProviderChanged);
      _provider!.loadReceipts();
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

  String _formatDateNullable(DateTime? d) {
    if (d == null) return '—';
    return _formatDate(d);
  }

  bool _canEditSampleReceipt(SampleIntakeModel r) =>
      r.status != SampleIntakeStatus.completed &&
      r.status != SampleIntakeStatus.forwardedToLab;

  Future<void> _confirmDelete(BuildContext context, SampleIntakeModel row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete receipt',
      message: 'Delete receipt "${row.lotNo}"? This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SampleIntakeProvider>().deleteReceipt(row.id);
  }

  Future<void> _openQuickReceipt(BuildContext context) async {
    await QuickReceiptEntryModal.show(context);
    if (context.mounted) {
      await context.read<SampleIntakeProvider>().refresh();
    }
  }

  Future<void> _openCreateSamples(BuildContext context) async {
    await context.push('/transactions/sample-intake/create-samples');
    if (context.mounted) {
      await context.read<SampleIntakeProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space5,
              AppTokens.space4,
              AppTokens.space5,
              AppTokens.space2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample intake',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.pageTitleSize,
                          fontWeight: AppTokens.pageTitleWeight,
                          color: AppTokens.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: AppTokens.space1),
                      Text(
                        'Receipt tracking queue and completed intake records.',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.pageSubtitleSize,
                          fontWeight: AppTokens.pageSubtitleWeight,
                          color: AppTokens.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Create Sample Receipt',
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.md,
                  onPressed: () => _openCreateSamples(context),
                ),
              ],
            ),
          ),
          ListingTabStrip(
            tabs: [
              TabConfig(
                label: 'Receipt Tracking',
                count: p.hubReceiptTrackingCount(),
              ),
              TabConfig(
                label: 'Sample Receipt',
                count: p.hubSampleReceiptCount(),
              ),
              TabConfig(
                label: 'Completed Receipt',
                count: p.hubCompletedReceiptCount(),
              ),
            ],
            selected: p.hubTabIndex,
            onSelect: p.setHubTabIndex,
          ),
          Expanded(
            child: switch (p.hubTab) {
              SampleIntakeHubTab.receiptTracking =>
                _operationalListing(context, p),
              SampleIntakeHubTab.sampleReceipt =>
                _operationalListing(context, p),
              SampleIntakeHubTab.completedReceipt =>
                _completedListing(context, p),
            },
          ),
        ],
      ),
    );
  }

  Widget _operationalListing(BuildContext context, SampleIntakeProvider p) {
    final emptyMessage = p.hubTab == SampleIntakeHubTab.receiptTracking
        ? 'No receipts in tracking'
        : 'No sample receipts in queue';

    return AppListingScreen<SampleIntakeModel>(
      showPageHeader: false,
      title: '',
      subtitle: '',
      extraActions: [
        AppButton(
          label: 'Quick receipt',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: () => _openQuickReceipt(context),
        ),
      ],
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onBulkDelete: (ids) => p.bulkDeleteReceipts(ids),
      showKpis: false,
      showExport: false,
      showTableHorizontalScrollbar: true,
      showActionsColumnLeadingBorder: false,
      tableScrollableMinWidth: _kColW * _kOpCols + AppTokens.space4,
      tableBodyFillsViewport: true,
      searchHint:
          'Search sample ID, receipt, customer, site, sample type...',
      onSearch: p.setSearchQuery,
      columns: [
        TableColumn<SampleIntakeModel>(
          key: 'sampleId',
          label: 'Sample ID',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.primarySampleId,
          cellBuilder: (r) => Text(
            r.primarySampleId.isEmpty ? '—' : r.primarySampleId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'lot',
          label: 'Receipt No.',
          width: _kColW,
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
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'customer',
          label: 'Customer',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.customerName,
          cellBuilder: (r) => Text(
            r.customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'site',
          label: 'Site',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.siteCompany,
          cellBuilder: (r) => Text(
            r.siteCompany.isEmpty ? '—' : r.siteCompany,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'courier',
          label: 'Courier / Hand',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => '${r.courierName} ${r.receiptMode}',
          cellBuilder: (r) => Text(
            r.courierOrHandDisplay.isEmpty ? '—' : r.courierOrHandDisplay,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'type',
          label: 'Type of Sample',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.typeOfSample,
          cellBuilder: (r) => Text(
            r.typeOfSample.isEmpty ? '—' : r.typeOfSample,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'samples',
          label: 'Sample Count',
          width: _kColW,
          sortValue: (r) => r.noOfSamples,
          cellBuilder: (r) => Text(
            '${r.noOfSamples}',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'receiptDate',
          label: 'Receipt Date',
          width: _kColW,
          sortValue: (r) => r.receiptDate.millisecondsSinceEpoch,
          cellBuilder: (r) => Text(
            _formatDate(r.receiptDate),
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'datasheet',
          label: 'Datasheet Status',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.datasheetStatusDisplay,
          cellBuilder: (r) => Text(
            r.datasheetStatusDisplay,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'labCode',
          label: 'Lab Code Status',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.labCodeStatusDisplay,
          cellBuilder: (r) => Text(
            r.labCodeStatusDisplay,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'receivedBy',
          label: 'Received By',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.receivedBy,
          cellBuilder: (r) => Text(
            r.receivedBy.isEmpty ? '—' : r.receivedBy,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'status',
          label: 'Status',
          width: _kColW,
          filter: const AppColumnFilter(
            type: AppColumnFilterType.select,
            options: [
              AppSelectItem<String>(
                value: SampleIntakeStatus.trackingDraft,
                label: 'Tracking draft',
              ),
              AppSelectItem<String>(
                value: SampleIntakeStatus.receiptComplete,
                label: 'Receipt complete',
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
              AppSelectItem<String>(
                value: SampleIntakeStatus.dataEntryPending,
                label: 'Data entry pending',
              ),
            ],
          ),
          filterSelectValue: (r) => r.status,
          cellBuilder: (r) =>
              Center(child: StatusChip(status: r.status)),
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
                  ),
                ),
              ),
              StatusChip(status: r.status),
            ],
          ),
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
          key: 'datasheet',
          label: 'Sample Data Entry Sheet',
          icon: Icon(LucideIcons.table, size: AppTokens.iconButtonIconMd),
          onTap: (row) => context.push(
            '/transactions/sample-intake/${row.id}/datasheet',
          ),
        ),
        RowAction<SampleIntakeModel>(
          key: 'view',
          label: 'View',
          icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
          onTap: (row) => context.push(
            '/transactions/sample-intake/${row.id}/view',
          ),
        ),
        RowAction<SampleIntakeModel>(
          key: 'edit',
          label: 'Edit',
          icon: Icon(LucideIcons.pencilLine, size: AppTokens.iconButtonIconMd),
          isEnabled: (row) => _canEditSampleReceipt(row),
          onTap: (row) => context.push(
            '/transactions/sample-intake/${row.id}/edit',
          ),
        ),
        RowAction<SampleIntakeModel>(
          key: 'history',
          label: 'View History',
          icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
          onTap: (row) =>
              context.push('/transactions/sample-intake/${row.id}/history'),
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
      emptyMessage: emptyMessage,
    );
  }

  Widget _completedListing(BuildContext context, SampleIntakeProvider p) {
    return AppListingScreen<SampleIntakeModel>(
      showPageHeader: false,
      title: '',
      subtitle: '',
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onBulkDelete: (ids) => p.bulkDeleteReceipts(ids),
      showKpis: false,
      showExport: false,
      showTableHorizontalScrollbar: true,
      showActionsColumnLeadingBorder: false,
      tableScrollableMinWidth: _kColW * _kDoneCols + AppTokens.space4,
      tableBodyFillsViewport: true,
      searchHint: 'Search lab code, sample id, customer...',
      onSearch: p.setSearchQuery,
      columns: [
        TableColumn<SampleIntakeModel>(
          key: 'labCode',
          label: 'Lab Code',
          width: _kColW,
          cellBuilder: (r) => Text(
            r.status == SampleIntakeStatus.forwardedToLab
                ? 'Assigned'
                : '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              color: AppTokens.textPrimary,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'sampleId',
          label: 'Sample ID',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.primarySampleId,
          cellBuilder: (r) => Text(
            r.primarySampleId.isEmpty ? '—' : r.primarySampleId,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'lot',
          label: 'Receipt No.',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.lotNo,
          cellBuilder: (r) => Text(
            r.lotNo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'customer',
          label: 'Customer',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.customerName,
          cellBuilder: (r) => Text(
            r.customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'site',
          label: 'Site',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.siteCompany,
          cellBuilder: (r) => Text(
            r.siteCompany.isEmpty ? '—' : r.siteCompany,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'completedAt',
          label: 'Intake Completed Date',
          width: _kColW,
          sortValue: (r) =>
              r.intakeCompletedAt?.millisecondsSinceEpoch ?? 0,
          cellBuilder: (r) => Text(
            _formatDateNullable(r.intakeCompletedAt),
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'generatedBy',
          label: 'Generated By',
          width: _kColW,
          filter: const AppColumnFilter(type: AppColumnFilterType.text),
          filterTextValue: (r) => r.generatedBy,
          cellBuilder: (r) => Text(
            r.generatedBy.isEmpty ? '—' : r.generatedBy,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
            ),
          ),
        ),
        TableColumn<SampleIntakeModel>(
          key: 'status',
          label: 'Status',
          width: _kColW,
          cellBuilder: (r) =>
              Center(child: StatusChip(status: r.status)),
        ),
      ],
      rows: p.pagedRows,
      mobileCardBuilder: (r) => Text(r.lotNo),
      isLoading: p.isLoading,
      rowActions: [
        RowAction<SampleIntakeModel>(
          key: 'datasheet',
          label: 'Sample Data Entry Sheet',
          icon: Icon(LucideIcons.table, size: AppTokens.iconButtonIconMd),
          onTap: (row) =>
              context.push('/transactions/sample-intake/${row.id}/datasheet'),
        ),
        RowAction<SampleIntakeModel>(
          key: 'view',
          label: 'View',
          icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
          onTap: (row) =>
              context.push('/transactions/sample-intake/${row.id}/view'),
        ),
        RowAction<SampleIntakeModel>(
          key: 'edit',
          label: 'Edit',
          icon: Icon(LucideIcons.pencilLine, size: AppTokens.iconButtonIconMd),
          isEnabled: (row) => _canEditSampleReceipt(row),
          onTap: (row) => context.push(
            '/transactions/sample-intake/${row.id}/edit',
          ),
        ),
        RowAction<SampleIntakeModel>(
          key: 'history',
          label: 'View History',
          icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
          onTap: (row) =>
              context.push('/transactions/sample-intake/${row.id}/history'),
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
      emptyMessage: 'No completed intake records',
    );
  }
}
