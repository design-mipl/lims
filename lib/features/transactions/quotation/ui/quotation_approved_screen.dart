import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/quotation_model.dart';
import '../state/quotation_provider.dart';

/// Approved quotations register with export / convert stubs.
class QuotationApprovedScreen extends StatefulWidget {
  const QuotationApprovedScreen({super.key});

  @override
  State<QuotationApprovedScreen> createState() =>
      _QuotationApprovedScreenState();
}

class _QuotationApprovedScreenState extends State<QuotationApprovedScreen> {
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

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _confirmDelete(BuildContext context, QuotationRecord row) async {
    final ok = await AppConfirmDialog.show(
      context: context,
      title: 'Delete quotation?',
      message: 'Remove ${row.quoteNo}?',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (ok == true && context.mounted) {
      await context.read<QuotationProvider>().deleteQuote(row.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuotationProvider>();
    final all = p.approvedOnly;
    final rows = p.pagedApprovedRows();
    final page = p.effectiveApprovedPage(all.length);

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<QuotationRecord>(
        title: 'Approved quotations',
        subtitle:
            'Executed proposals ready for PDF export or conversion to orders.',
        primaryActionLabel: 'Main quotation hub',
        onPrimaryAction: () => context.go('/transactions/quotation/pending'),
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: (ids) => p.bulkDelete(ids.cast<String>()),
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: 1100,
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
        searchHint: 'Search approved quotes…',
        onSearch: p.setSearchQuery,
        columns: [
          TableColumn<QuotationRecord>(
            key: 'quoteNo',
            label: 'Quote No.',
            width: 128,
            sortValue: (r) => r.quoteNo.toLowerCase(),
            cellBuilder: (r) => Text(
              r.quoteNo,
              style: GoogleFonts.poppins(fontWeight: AppTokens.weightMedium),
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'enquiryNo',
            label: 'Enquiry',
            width: 116,
            sortValue: (r) => r.enquiryNo.toLowerCase(),
            cellBuilder: (r) => Text(r.enquiryNo),
          ),
          TableColumn<QuotationRecord>(
            key: 'customer',
            label: 'Customer',
            width: 200,
            sortValue: (r) => r.customerName.toLowerCase(),
            cellBuilder: (r) => Text(
              r.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'grand',
            label: 'Grand total',
            width: 112,
            numeric: true,
            sortValue: (r) => r.grandTotal,
            cellBuilder: (r) =>
                Text(r.grandTotal.toStringAsFixed(2)),
          ),
          TableColumn<QuotationRecord>(
            key: 'approvedOn',
            label: 'Updated',
            width: 112,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => Text(_formatDate(r.updatedAt)),
          ),
          TableColumn<QuotationRecord>(
            key: 'status',
            label: 'Status',
            width: 120,
            cellBuilder: (r) =>
                const StatusChip(status: 'completed', customLabel: 'Approved'),
          ),
        ],
        rows: rows,
        mobileCardBuilder: (r) => Text(r.quoteNo),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<QuotationRecord>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) =>
                context.push('/transactions/quotation/${row.id}/sales-review'),
          ),
          RowAction<QuotationRecord>(
            key: 'history',
            label: 'History',
            icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
            onTap: (row) =>
                context.push('/transactions/quotation/${row.id}/history'),
          ),
          RowAction<QuotationRecord>(
            key: 'pdf',
            label: 'Download PDF',
            icon: Icon(LucideIcons.download, size: AppTokens.iconButtonIconMd),
            onTap: (row) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF export stub — ${row.quoteNo}'),
                ),
              );
            },
          ),
          RowAction<QuotationRecord>(
            key: 'convert',
            label: 'Convert to order',
            icon: Icon(LucideIcons.arrowRight, size: AppTokens.iconButtonIconMd),
            onTap: (row) async {
              await p.convertToOrder(row.id);
              if (!context.mounted) return;
              await context.push(
                '/transactions/sample-intake/create?enquiryId=${row.enquiryId}&quotationId=${row.id}',
              );
            },
          ),
          RowAction<QuotationRecord>(
            key: 'delete',
            label: 'Delete',
            isDanger: true,
            icon: Icon(LucideIcons.trash2, size: AppTokens.iconButtonIconMd),
            onTap: (row) => _confirmDelete(context, row),
          ),
        ],
        totalCount: all.length,
        currentPage: page,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No approved quotations',
      ),
    );
  }
}
