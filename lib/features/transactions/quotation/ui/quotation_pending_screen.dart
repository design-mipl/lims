import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/quotation_model.dart';
import '../state/quotation_provider.dart';

/// Pending preparation + in-review + approved tabs (main quotation hub).
class QuotationPendingScreen extends StatefulWidget {
  const QuotationPendingScreen({super.key});

  @override
  State<QuotationPendingScreen> createState() => _QuotationPendingScreenState();
}

class _QuotationPendingScreenState extends State<QuotationPendingScreen> {
  QuotationProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<QuotationProvider>();
      _provider!.addListener(_onErr);
      _provider!.loadItems();
    });
  }

  void _onErr() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final m = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || m == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: AppTokens.error500),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onErr);
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, QuotationRecord row) async {
    final ok = await AppConfirmDialog.show(
      context: context,
      title: 'Delete quotation?',
      message: 'Remove ${row.quoteNo} from the mock listing.',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (ok == true && context.mounted) {
      await context.read<QuotationProvider>().deleteQuote(row.id);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  StatusChip _statusChip(QuotationRecord r) {
    final label = switch (r.status) {
      QuotationStatus.pendingPrep => 'Pending prep',
      QuotationStatus.changesRequested => 'Changes',
      QuotationStatus.inReview => 'In review',
      QuotationStatus.approved => 'Approved',
      _ => r.status,
    };
    final key = switch (r.status) {
      QuotationStatus.pendingPrep => 'pending',
      QuotationStatus.changesRequested => 'pending',
      QuotationStatus.inReview => 'inReview',
      QuotationStatus.approved => 'completed',
      _ => r.status,
    };
    return StatusChip(status: key, customLabel: label);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuotationProvider>();
    final rows = p.pagedRows;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<QuotationRecord>(
        title: 'Quotation',
        subtitle:
            'Prepare pricing, send for sales review, and approve proposals.',
        extraActions: [
          AppButton(
            label: 'Create quotation',
            variant: AppButtonVariant.primary,
            size: AppButtonSize.md,
            onPressed: () => context.push('/transactions/quotation/create'),
          ),
        ],
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: 1180,
        toolbarAfterSearch: [
          Tooltip(
            message: 'Approved register',
            child: IconButton(
              onPressed: () =>
                  context.push('/transactions/quotation/approved'),
              icon: Icon(
                LucideIcons.clipboardCheck,
                size: AppTokens.iconButtonIconMd,
              ),
            ),
          ),
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
          TabConfig(label: 'Pending prep', count: p.countForTab(0)),
          TabConfig(label: 'In review', count: p.countForTab(1)),
          TabConfig(label: 'Approved', count: p.countForTab(2)),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: p.setTabByIndex,
        searchHint: 'Search quote no., enquiry, customer…',
        onSearch: p.setSearchQuery,
        columns: [
          TableColumn<QuotationRecord>(
            key: 'quoteNo',
            label: 'Quote No.',
            width: 128,
            sortable: true,
            sortValue: (r) => r.quoteNo.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.quoteNo,
            cellBuilder: (r) => Text(
              r.quoteNo,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightMedium,
              ),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'enquiryNo',
            label: 'Enquiry',
            width: 120,
            sortable: true,
            sortValue: (r) => r.enquiryNo.toLowerCase(),
            cellBuilder: (r) => Text(
              r.enquiryNo,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'customer',
            label: 'Customer',
            width: 200,
            sortable: true,
            sortValue: (r) => r.customerName.toLowerCase(),
            cellBuilder: (r) => Text(
              r.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'site',
            label: 'Site',
            width: 160,
            sortable: true,
            sortValue: (r) => r.siteName.toLowerCase(),
            cellBuilder: (r) => Text(
              r.siteName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'sample',
            label: 'Sample type',
            width: 140,
            sortable: true,
            sortValue: (r) => r.typeOfSample.toLowerCase(),
            cellBuilder: (r) => Text(
              r.typeOfSample,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: AppTokens.captionSize),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'updated',
            label: 'Updated',
            width: 112,
            sortable: true,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => Text(
              _formatDate(r.updatedAt),
              style: GoogleFonts.poppins(fontSize: AppTokens.captionSize),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'total',
            label: 'Grand total',
            width: 120,
            numeric: true,
            sortable: true,
            sortValue: (r) => r.grandTotal,
            cellBuilder: (r) => Text(
              r.grandTotal.toStringAsFixed(2),
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'status',
            label: 'Status',
            width: 132,
            sortable: true,
            sortValue: (r) => r.status,
            cellBuilder: (r) => _statusChip(r),
          ),
          TableColumn<QuotationRecord>(
            key: 'prepared',
            label: 'Prepared by',
            width: 132,
            sortable: true,
            sortValue: (r) => r.preparedBy.toLowerCase(),
            cellBuilder: (r) => Text(
              r.preparedBy,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
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
              r.quoteNo,
              style: GoogleFonts.poppins(
                fontWeight: AppTokens.weightSemibold,
              ),
            ),
            Text(
              '${r.customerName} · ${r.enquiryNo}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<QuotationRecord>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) {
              final st = row.status;
              if (st == QuotationStatus.inReview ||
                  st == QuotationStatus.approved ||
                  st == QuotationStatus.changesRequested) {
                context.push('/transactions/quotation/${row.id}/sales-review');
              } else {
                context.push('/transactions/quotation/${row.id}/history');
              }
            },
          ),
          RowAction<QuotationRecord>(
            key: 'edit',
            label: 'Edit',
            icon: Icon(LucideIcons.pencilLine, size: AppTokens.iconButtonIconMd),
            isEnabled: (r) =>
                r.status == QuotationStatus.pendingPrep ||
                r.status == QuotationStatus.changesRequested,
            onTap: (row) =>
                context.push('/transactions/quotation/${row.id}/workspace'),
          ),
          RowAction<QuotationRecord>(
            key: 'viewSales',
            label: 'Sales review',
            icon: Icon(LucideIcons.fileSearch, size: AppTokens.iconButtonIconMd),
            isEnabled: (r) =>
                r.status == QuotationStatus.inReview ||
                r.status == QuotationStatus.approved ||
                r.status == QuotationStatus.changesRequested,
            onTap: (row) => context.push(
              '/transactions/quotation/${row.id}/sales-review',
            ),
          ),
          RowAction<QuotationRecord>(
            key: 'pdf',
            label: 'Download PDF',
            icon: Icon(LucideIcons.fileDown, size: AppTokens.iconButtonIconMd),
            onTap: (row) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF export stub — ${row.quoteNo}')),
              );
            },
          ),
          RowAction<QuotationRecord>(
            key: 'history',
            label: 'History',
            icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
            onTap: (row) =>
                context.push('/transactions/quotation/${row.id}/history'),
          ),
          RowAction<QuotationRecord>(
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
        emptyMessage: 'No quotations in this tab',
      ),
    );
  }
}
