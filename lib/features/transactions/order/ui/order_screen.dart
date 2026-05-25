import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../quotation/data/quotation_model.dart';
import '../data/order_model.dart';
import '../state/order_provider.dart';
import 'widgets/order_version_history_dialog.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderProvider? _provider;

  static const double _kColWidth = 200;
  static const double _kColWidthSm = 140;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<OrderProvider>();
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

  String _money(double v) => v.toStringAsFixed(2);

  Widget _cellText(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: AppTokens.tableCellSize,
          color: AppTokens.textPrimary,
        ),
      );

  StatusChip _orderStatusChip(String status) {
    final label = switch (status) {
      OrderStatus.draft => 'Draft',
      OrderStatus.emailSent => 'Email sent',
      OrderStatus.underDiscussion => 'Under review',
      OrderStatus.discountRevised => 'Discount revised',
      OrderStatus.convertedOrder => 'Converted',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.rejected => 'Rejected',
      _ => status,
    };
    final key = switch (status) {
      OrderStatus.confirmed || OrderStatus.convertedOrder => 'completed',
      OrderStatus.rejected => 'critical',
      OrderStatus.emailSent || OrderStatus.underDiscussion => 'inReview',
      OrderStatus.discountRevised => 'pending',
      _ => 'draft',
    };
    return StatusChip(status: key, customLabel: label);
  }

  Widget _centeredStatus(String status) => Center(
        child: _orderStatusChip(status),
      );

  StatusChip _approvalChip(String approval) {
    final normalized = approval.trim().toLowerCase();
    final key = switch (normalized) {
      'approved' => 'completed',
      'rejected' => 'critical',
      _ => 'pending',
    };
    return StatusChip(status: key, customLabel: approval);
  }

  void _showStub(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
        ),
      ),
    );
  }

  void _openCreateOrder() => context.push('/transactions/order/create');

  List<RowAction<OrderRecord>> _confirmedRowActions(BuildContext context) {
    return [
      RowAction<OrderRecord>(
        key: 'view',
        label: 'View order',
        icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
        onTap: (row) => context.push(
          '/transactions/order/create?quotationId=${row.quotationId}',
        ),
      ),
      RowAction<OrderRecord>(
        key: 'versions',
        label: 'View version history',
        icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
        onTap: (row) => showOrderVersionHistoryDialog(context, order: row),
      ),
      RowAction<OrderRecord>(
        key: 'pdf',
        label: 'Export PDF',
        icon: Icon(LucideIcons.fileDown, size: AppTokens.iconButtonIconMd),
        onTap: (row) => _showStub(
          context,
          'PDF export stub — ${row.orderNo}',
        ),
      ),
      RowAction<OrderRecord>(
        key: 'email',
        label: 'Send email',
        icon: Icon(LucideIcons.mail, size: AppTokens.iconButtonIconMd),
        onTap: (row) => _showStub(
          context,
          'Send email stub — ${row.orderNo}',
        ),
      ),
      RowAction<OrderRecord>(
        key: 'status',
        label: 'Convert status',
        icon: Icon(LucideIcons.arrowRightLeft, size: AppTokens.iconButtonIconMd),
        onTap: (row) => _showStub(
          context,
          'Convert status stub — ${row.orderNo}',
        ),
      ),
      RowAction<OrderRecord>(
        key: 'timeline',
        label: 'View timeline',
        icon: Icon(LucideIcons.activity, size: AppTokens.iconButtonIconMd),
        onTap: (row) => showOrderVersionHistoryDialog(context, order: row),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    if (p.tabIndex == 0) {
      return _buildPendingTab(context, p);
    }
    return _buildConfirmedTab(context, p);
  }

  Widget _buildPendingTab(BuildContext context, OrderProvider p) {
    final rows = p.pagedPending;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<QuotationRecord>(
        title: 'Order',
        subtitle:
            'Convert quotations in sales review into confirmed orders with version tracking.',
        primaryActionLabel: 'Create order',
        onPrimaryAction: _openCreateOrder,
        showCheckboxes: false,
        showBulkBar: false,
        showKpis: false,
        exportModuleName: 'Order_Pending',
        exportSourceRows: p.filteredPending,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: _kColWidth * 10,
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
          TabConfig(
            label: 'Pending orders',
            count: p.pendingCount,
          ),
          TabConfig(
            label: 'Confirmed orders',
            count: p.confirmedCount,
          ),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: (i) => p.setTabByIndex(i),
        searchHint: 'Search quote no., enquiry, customer, site…',
        onSearch: p.setSearchQuery,
        columns: [
          TableColumn<QuotationRecord>(
            key: 'quoteNo',
            label: 'Quotation No.',
            width: _kColWidth,
            sortable: true,
            sortValue: (r) => r.quoteNo.toLowerCase(),
            cellBuilder: (r) => _cellText(r.quoteNo),
          ),
          TableColumn<QuotationRecord>(
            key: 'enquiryNo',
            label: 'Enquiry No.',
            width: _kColWidth,
            sortable: true,
            sortValue: (r) => r.enquiryNo.toLowerCase(),
            cellBuilder: (r) => _cellText(r.enquiryNo),
          ),
          TableColumn<QuotationRecord>(
            key: 'customer',
            label: 'Customer Name',
            width: _kColWidth,
            sortable: true,
            sortValue: (r) => r.customerName.toLowerCase(),
            cellBuilder: (r) => _cellText(r.customerName),
          ),
          TableColumn<QuotationRecord>(
            key: 'site',
            label: 'Site Name',
            width: _kColWidth,
            sortable: true,
            sortValue: (r) => r.siteName.toLowerCase(),
            cellBuilder: (r) => _cellText(r.siteName),
          ),
          TableColumn<QuotationRecord>(
            key: 'sample',
            label: 'Sample Type',
            width: _kColWidth,
            sortValue: (r) => r.typeOfSample.toLowerCase(),
            cellBuilder: (r) => _cellText(r.typeOfSample),
          ),
          TableColumn<QuotationRecord>(
            key: 'total',
            label: 'Total Amount',
            width: _kColWidthSm,
            sortValue: (r) => r.subtotal,
            cellBuilder: (r) => _cellText(_money(r.subtotal)),
          ),
          TableColumn<QuotationRecord>(
            key: 'discount',
            label: 'Discount',
            width: _kColWidthSm,
            sortValue: (r) => r.discountAmount,
            cellBuilder: (r) => _cellText(_money(r.discountAmount)),
          ),
          TableColumn<QuotationRecord>(
            key: 'final',
            label: 'Final Amount',
            width: _kColWidthSm,
            sortValue: (r) => r.grandTotal,
            cellBuilder: (r) => _cellText(_money(r.grandTotal)),
          ),
          TableColumn<QuotationRecord>(
            key: 'sales',
            label: 'Sales Person',
            width: _kColWidth,
            sortValue: (r) =>
                (r.salesPerson.isNotEmpty ? r.salesPerson : r.preparedBy)
                    .toLowerCase(),
            cellBuilder: (r) => _cellText(
              r.salesPerson.isNotEmpty ? r.salesPerson : r.preparedBy,
            ),
          ),
          TableColumn<QuotationRecord>(
            key: 'version',
            label: 'Version No.',
            width: 110,
            sortValue: (r) => r.versionNo,
            cellBuilder: (r) => _cellText('V${r.versionNo}'),
          ),
          TableColumn<QuotationRecord>(
            key: 'updated',
            label: 'Last Updated',
            width: 140,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => _cellText(_formatDate(r.updatedAt)),
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
              '${r.customerName} · ${_money(r.grandTotal)}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        totalCount: p.filteredPending.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No quotations awaiting order creation',
      ),
    );
  }

  Widget _buildConfirmedTab(BuildContext context, OrderProvider p) {
    final rows = p.pagedConfirmed;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<OrderRecord>(
        title: 'Order',
        subtitle:
            'Convert quotations in sales review into confirmed orders with version tracking.',
        primaryActionLabel: 'Create order',
        onPrimaryAction: _openCreateOrder,
        showCheckboxes: false,
        showKpis: false,
        exportModuleName: 'Order_Confirmed',
        exportSourceRows: p.filteredConfirmed,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: _kColWidth * 11,
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
          TabConfig(label: 'Pending orders', count: p.pendingCount),
          TabConfig(label: 'Confirmed orders', count: p.confirmedCount),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: (i) => p.setTabByIndex(i),
        searchHint: 'Search order no., customer, status…',
        onSearch: p.setSearchQuery,
        columns: [
          TableColumn<OrderRecord>(
            key: 'orderNo',
            label: 'Order No.',
            width: _kColWidth,
            sortable: true,
            sortValue: (r) => r.orderNo.toLowerCase(),
            cellBuilder: (r) => _cellText(r.orderNo),
          ),
          TableColumn<OrderRecord>(
            key: 'version',
            label: 'Version No.',
            width: 110,
            sortValue: (r) => r.versionNo,
            cellBuilder: (r) => _cellText('V${r.versionNo}'),
          ),
          TableColumn<OrderRecord>(
            key: 'customer',
            label: 'Customer',
            width: _kColWidth,
            sortable: true,
            sortValue: (r) => r.customerName.toLowerCase(),
            cellBuilder: (r) => _cellText(r.customerName),
          ),
          TableColumn<OrderRecord>(
            key: 'salesPerson',
            label: 'Sales Person',
            width: _kColWidth,
            sortValue: (r) => r.salesPerson.toLowerCase(),
            cellBuilder: (r) => _cellText(r.salesPerson),
          ),
          TableColumn<OrderRecord>(
            key: 'original',
            label: 'Original Amount',
            width: _kColWidthSm,
            sortValue: (r) => r.originalAmount,
            cellBuilder: (r) => _cellText(_money(r.originalAmount)),
          ),
          TableColumn<OrderRecord>(
            key: 'discountPct',
            label: 'Discount %',
            width: 110,
            sortValue: (r) => r.discountPercent,
            cellBuilder: (r) =>
                _cellText('${r.discountPercent.toStringAsFixed(1)}%'),
          ),
          TableColumn<OrderRecord>(
            key: 'revised',
            label: 'Revised Amount',
            width: _kColWidthSm,
            sortValue: (r) => r.revisedAmount,
            cellBuilder: (r) => _cellText(_money(r.revisedAmount)),
          ),
          TableColumn<OrderRecord>(
            key: 'status',
            label: 'Status',
            width: 150,
            sortable: false,
            sortValue: null,
            cellBuilder: (r) => _centeredStatus(r.status),
          ),
          TableColumn<OrderRecord>(
            key: 'email',
            label: 'Email Sent',
            width: 100,
            sortable: false,
            sortValue: null,
            cellBuilder: (r) => _cellText(r.emailSent ? 'Yes' : 'No'),
          ),
          TableColumn<OrderRecord>(
            key: 'customerApproval',
            label: 'Customer Approval',
            width: 150,
            sortValue: (r) => r.customerApproval.toLowerCase(),
            cellBuilder: (r) => _approvalChip(r.customerApproval),
          ),
          TableColumn<OrderRecord>(
            key: 'convertedAt',
            label: 'Converted Date',
            width: _kColWidthSm,
            sortValue: (r) =>
                r.convertedAt?.millisecondsSinceEpoch ?? 0,
            cellBuilder: (r) => _cellText(
              r.convertedAt != null ? _formatDate(r.convertedAt!) : '—',
            ),
          ),
          TableColumn<OrderRecord>(
            key: 'updatedBy',
            label: 'Updated By',
            width: _kColWidth,
            sortValue: (r) => r.updatedBy.toLowerCase(),
            cellBuilder: (r) => _cellText(r.updatedBy),
          ),
          TableColumn<OrderRecord>(
            key: 'updated',
            label: 'Last Updated',
            width: _kColWidthSm,
            sortValue: (r) => r.updatedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => _cellText(_formatDate(r.updatedAt)),
          ),
        ],
        rows: rows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.orderNo,
              style: GoogleFonts.poppins(
                fontWeight: AppTokens.weightSemibold,
              ),
            ),
            Text(
              '${r.customerName} · V${r.versionNo}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: _confirmedRowActions(context),
        totalCount: p.filteredConfirmed.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No confirmed orders yet',
      ),
    );
  }
}
