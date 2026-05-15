import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/enquiry_model.dart';
import '../state/enquiry_provider.dart';
import '../../quotation/data/quotation_api.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  EnquiryProvider? _provider;

  /// Uniform data columns — matches Lab Code listing rhythm.
  static const double _kListingColWidth = 220;
  static const int _kDataColumnCount = 11;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<EnquiryProvider>();
      _provider!.addListener(_onProviderChanged);
      _provider!.loadItems();
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

  Future<void> _confirmDelete(BuildContext context, EnquiryRecord row) async {
    final ok = await AppConfirmDialog.show(
      context: context,
      title: 'Delete enquiry?',
      message:
          'This will remove ${row.enquiryNo} from the mock listing. This cannot be undone.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (ok == true && context.mounted) {
      await context.read<EnquiryProvider>().deleteEnquiry(row.id);
    }
  }

  Future<void> _createQuotation(BuildContext context, EnquiryRecord row) async {
    try {
      final q = await sl<QuotationApi>().createDraftFromEnquiry(row.id);
      if (!context.mounted) return;
      context.push('/transactions/quotation/${q.id}/workspace');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not create quotation: $e',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
    }
  }

  StatusChip _statusChip(EnquiryRecord r) {
    final label = switch (r.status) {
      EnquiryStatus.pending => 'Pending',
      EnquiryStatus.submitted => 'Submitted',
      EnquiryStatus.converted => 'Converted',
      _ => r.status,
    };
    final key = switch (r.status) {
      EnquiryStatus.pending => 'pending',
      EnquiryStatus.submitted => 'inReview',
      EnquiryStatus.converted => 'completed',
      _ => r.status,
    };
    return StatusChip(status: key, customLabel: label);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnquiryProvider>();
    final rows = p.pagedRows;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<EnquiryRecord>(
        title: 'Enquiry',
        subtitle: 'Capture customer enquiries before quotation and sample intake.',
        primaryActionLabel: 'Create enquiry',
        onPrimaryAction: () => context.push('/transactions/enquiry/create'),
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth:
            _kListingColWidth * _kDataColumnCount + AppTokens.space4,
        toolbarAfterSearch: [
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              onPressed: p.isLoading ? null : () => p.refresh(),
              icon: Icon(
                LucideIcons.refreshCw,
                size: AppTokens.iconButtonIconMd,
              ),
            ),
          ),
        ],
        tabs: [
          TabConfig(label: 'Pending', count: p.countForTab(0)),
          TabConfig(label: 'Submitted', count: p.countForTab(1)),
          TabConfig(label: 'Converted', count: p.countForTab(2)),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: p.setTabByIndex,
        searchHint:
            'Search enquiry no., customer, site, sample type, creator…',
        onSearch: p.setSearchQuery,
        columns: [
          TableColumn<EnquiryRecord>(
            key: 'enquiryNo',
            label: 'Enquiry No.',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.enquiryNo.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.enquiryNo,
            cellBuilder: (r) => Text(
              r.enquiryNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightMedium,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'enquiryDate',
            label: 'Date',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.enquiryDate.millisecondsSinceEpoch,
            cellBuilder: (r) => Text(
              _formatDate(r.enquiryDate),
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'customer',
            label: 'Customer',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.customerName.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.customerName,
            cellBuilder: (r) => Text(
              r.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'site',
            label: 'Site',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.siteName.toLowerCase(),
            cellBuilder: (r) => Text(
              r.siteName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'source',
            label: 'Source',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.enquirySource.toLowerCase(),
            cellBuilder: (r) => Text(
              r.enquirySource,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textMuted,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'sampleType',
            label: 'Sample type',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.typeOfSample.toLowerCase(),
            cellBuilder: (r) => Text(
              r.typeOfSample,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'samples',
            label: 'Samples',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.sampleCount,
            cellBuilder: (r) => Text(
              '${r.sampleCount}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'tests',
            label: 'Requested tests',
            width: _kListingColWidth,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.requestedTestsSummary,
            cellBuilder: (r) => Text(
              r.requestedTestsSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textMuted,
              ),
            ),
          ),
          TableColumn<EnquiryRecord>(
            key: 'status',
            label: 'Status',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.status,
            cellBuilder: (r) => _statusChip(r),
          ),
          TableColumn<EnquiryRecord>(
            key: 'createdBy',
            label: 'Created by',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.createdBy.toLowerCase(),
            cellBuilder: (r) => Text(
              r.createdBy,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textMuted,
              ),
            ),
          ),
        ],
        rows: rows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.enquiryNo,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              '${r.customerName} · ${r.siteName}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<EnquiryRecord>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) =>
                context.push('/transactions/enquiry/${row.id}/view'),
          ),
          RowAction<EnquiryRecord>(
            key: 'edit',
            label: 'Edit',
            icon: Icon(LucideIcons.pencil, size: AppTokens.iconButtonIconMd),
            onTap: (row) =>
                context.push('/transactions/enquiry/${row.id}/edit'),
          ),
          RowAction<EnquiryRecord>(
            key: 'quote',
            label: 'Create quotation',
            icon: Icon(LucideIcons.fileText, size: AppTokens.iconButtonIconMd),
            isEnabled: (row) => row.status != EnquiryStatus.converted,
            onTap: (row) => _createQuotation(context, row),
          ),
          RowAction<EnquiryRecord>(
            key: 'delete',
            label: 'Delete',
            isDanger: true,
            icon: Icon(LucideIcons.trash2, size: AppTokens.iconButtonIconMd),
            onTap: (row) => _confirmDelete(context, row),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No enquiries in this tab',
      ),
    );
  }
}
