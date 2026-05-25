import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../credit_note/data/create_credit_note_prefill.dart';
import 'billing_document_row.dart';
import 'billing_invoice_audit_dialog.dart';
import 'billing_listing_provider.dart';
import 'billing_gst_verification_dialog.dart';
import 'billing_gst_verification_result.dart';
import 'billing_listing_row_cells.dart';
import 'billing_row_action_state.dart';

/// Shared listing UI for [CustomerInvoiceScreen] and [CreditNoteScreen].
class BillingListingScaffold extends StatefulWidget {
  const BillingListingScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.detailPathPrefix,
    required this.selectionSingular,
    required this.selectionPlural,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.showEditRowAction = true,
    this.enableGstEinvoiceWorkflow = false,
    this.showGenerateCreditNoteRowAction = false,
  });

  final String title;
  final String subtitle;
  final String searchHint;

  /// Optional listing header primary (e.g. Create Customer Invoice).
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  /// When false, the row action menu omits **Edit** (Customer Invoice policy).
  final bool showEditRowAction;

  /// Customer Invoice: GST / eInvoice toolbar + column icons + verification flow.
  final bool enableGstEinvoiceWorkflow;

  /// Customer Invoice only: row action to open Create Credit Note prefill.
  final bool showGenerateCreditNoteRowAction;

  /// e.g. `/transactions/customer-invoice` → detail at `…/:id/view`.
  final String detailPathPrefix;

  /// Used in bulk narration action label (e.g. “Update Invoice Narration”).
  final String selectionSingular;

  /// Used in bulk action snackbars (e.g. “N Invoices”).
  final String selectionPlural;

  @override
  State<BillingListingScaffold> createState() => _BillingListingScaffoldState();
}

class _BillingListingScaffoldState extends State<BillingListingScaffold> {
  // Tiered widths: small | medium | large — fixed so viewport scaling does not
  // stretch some columns more than others ([scaleDataColumnsToFillViewport]=false).
  /// eInvoice column — wider when GST workflow shows 3 action icons.
  static const double _wEinvGst = 132.0;
  static const double _wEinvLegacy = 84.0;
  double get _wEinv =>
      widget.enableGstEinvoiceWorkflow ? _wEinvGst : _wEinvLegacy;
  /// Digital signature icon column (GST workflow).
  static const double _wDigitalSignature = 56.0;
  /// Medium — Doc Date
  static const double _wDate = 128;
  /// Large — Invoice No.
  static const double _wDocNo = 170;
  /// Large — Customer (capped; no flex so it cannot dominate wide viewports)
  static const double _wCust = 188;
  /// Small — Due Days
  static const double _wDue = 98;
  /// Medium — Total / Amount Received / Outstanding (equal for finance rhythm)
  static const double _wAmt = 158;
  /// Small — Status
  static const double _wStat = 124;

  /// Small — Actions gutter; fits “ACTIONS” + ⋮ without truncation
  static const double _actionsColumnWidth = 96;

  /// Cached column defs — cell widgets use [context.select] for localized updates.
  List<TableColumn<BillingDocumentListingRow>>? _columnsCache;

  /// Stable bulk actions — avoids rebuilding [AppListingScreen] on checkbox toggles.
  late List<BulkAction<BillingDocumentListingRow>> _bulkActions;

  /// Prevents duplicate row-action navigation while a handler runs.
  bool _rowActionBusy = false;

  @override
  void initState() {
    super.initState();
    _bulkActions = _createBulkActions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BillingListingProvider>().load();
    });
  }

  double get _scrollMinWidth =>
      (widget.enableGstEinvoiceWorkflow ? _wDigitalSignature : 0) +
      _wEinv +
      _wDate +
      _wDocNo +
      _wCust +
      _wDue +
      _wAmt +
      _wAmt +
      _wAmt +
      _wStat +
      AppTokens.space5;

  String _formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatAmt(double v) => v.toStringAsFixed(2);

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? LucideIcons.circleX : LucideIcons.info,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.white,
            ),
            SizedBox(width: AppTokens.space2),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: error ? AppTokens.error500 : AppTokens.primary800,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDetail(BillingDocumentListingRow row) {
    context.push('${widget.detailPathPrefix}/${row.id}/view');
  }

  void _openEdit(BillingDocumentListingRow row) {
    context.push('${widget.detailPathPrefix}/${row.id}/view?edit=1');
  }

  Future<void> _onAuditHistory(BillingDocumentListingRow row) async {
    if (_rowActionBusy) return;
    setState(() => _rowActionBusy = true);
    try {
      await showBillingInvoiceAuditDialog(context, row: row);
    } finally {
      if (mounted) setState(() => _rowActionBusy = false);
    }
  }

  Future<void> _onGenerateCreditNote(BillingDocumentListingRow row) async {
    if (!widget.showGenerateCreditNoteRowAction) return;
    if (_rowActionBusy) return;
    setState(() => _rowActionBusy = true);
    try {
      final prefill = CreateCreditNotePrefill.fromBillingListingRow(row);
      if (!mounted) return;
      await context.push(
        '/transactions/credit-note/create',
        extra: prefill,
      );
    } catch (_) {
      if (mounted) {
        _snack('Could not open Create Credit Note.', error: true);
      }
    } finally {
      if (mounted) setState(() => _rowActionBusy = false);
    }
  }

  Widget _cell(
    String text, {
    FontWeight weight = AppTokens.weightRegular,
    Color? color,
  }) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: weight,
        color: color ?? AppTokens.textPrimary,
      ),
    );
  }

  List<TableColumn<BillingDocumentListingRow>> _columns() {
    return _columnsCache ??= [
      if (widget.enableGstEinvoiceWorkflow)
        TableColumn<BillingDocumentListingRow>(
          key: 'digitalSignature',
          label: '',
          width: _wDigitalSignature,
          sortable: false,
          cellBuilder: (r) => BillingDigitalSignatureCell(
            rowId: r.id,
            enabled: widget.enableGstEinvoiceWorkflow,
          ),
        ),
      TableColumn<BillingDocumentListingRow>(
        key: 'eInvoice',
        label: 'eInvoice',
        width: _wEinv,
        sortable: true,
        sortValue: (r) => widget.enableGstEinvoiceWorkflow
            ? (r.gstVerified ? 2 : (r.eInvoiceActive ? 1 : 0))
            : (r.eInvoiceActive ? 1 : 0),
        cellBuilder: (r) => BillingEInvoiceCell(
          rowId: r.id,
          enableGstWorkflow: widget.enableGstEinvoiceWorkflow,
          selectionSingular: widget.selectionSingular,
          onSnack: _snack,
          onShowQr: _showGstQrIrnDialog,
        ),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'docDate',
        label: 'Doc Date',
        width: _wDate,
        sortable: true,
        sortValue: (r) => r.docDate.millisecondsSinceEpoch,
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => _formatYmd(r.docDate),
        cellBuilder: (r) => _cell(_formatYmd(r.docDate)),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'invoiceNo',
        label: 'Invoice No.',
        width: _wDocNo,
        sortable: true,
        sortValue: (r) => r.documentNo.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.documentNo,
        cellBuilder: (r) => InkWell(
          onTap: () => _openDetail(r),
          child: Text(
            r.documentNo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: AppTokens.weightSemibold,
              color: AppTokens.primary800,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'customer',
        label: 'Customer',
        width: _wCust,
        sortable: true,
        sortValue: (r) => r.customer.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.customer,
        cellBuilder: (r) => _cell(r.customer),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'dueDays',
        label: 'Due Days',
        width: _wDue,
        sortable: true,
        sortValue: (r) => r.dueDays,
        cellBuilder: _dueDaysCell,
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'total',
        label: 'Total',
        width: _wAmt,
        sortable: true,
        sortValue: (r) => r.total,
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => _formatAmt(r.total),
        cellBuilder: (r) => _cell(_formatAmt(r.total)),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'received',
        label: 'Amount Received',
        width: _wAmt,
        sortable: true,
        sortValue: (r) => r.amountReceived,
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => _formatAmt(r.amountReceived),
        cellBuilder: (r) => _cell(_formatAmt(r.amountReceived)),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'outstanding',
        label: 'Outstanding',
        width: _wAmt,
        sortable: true,
        sortValue: (r) => r.outstanding,
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => _formatAmt(r.outstanding),
        cellBuilder: (r) => _cell(_formatAmt(r.outstanding)),
      ),
      TableColumn<BillingDocumentListingRow>(
        key: 'docStatus',
        label: 'Status',
        width: _wStat,
        sortable: true,
        sortValue: (r) => r.statusLabel.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.statusLabel,
        cellBuilder: (r) => BillingStatusCell(rowId: r.id),
      ),
    ];
  }

  void _showGstQrIrnDialog(BillingDocumentListingRow r) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'IRN & QR',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textMd,
            fontWeight: AppTokens.weightSemibold,
            color: AppTokens.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'IRN Number',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: AppTokens.weightMedium,
                  color: AppTokens.textSecondary,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              SelectableText(
                r.irnNumber ?? '—',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              Text(
                'GST verification response',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: AppTokens.weightMedium,
                  color: AppTokens.textSecondary,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              SelectableText(
                r.gstVerificationResponse ?? '—',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 112,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              Text(
                'QR preview (mock — embeds in UltraLabs template after verification)',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  color: AppTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDirectToGst(List<BillingDocumentListingRow> rows) async {
    if (!widget.enableGstEinvoiceWorkflow) return;
    if (rows.isEmpty) {
      _snack(
        'Select at least one ${widget.selectionSingular.toLowerCase()} using checkboxes.',
        error: true,
      );
      return;
    }

    final provider = context.read<BillingListingProvider>();
    if (provider.gstVerificationInProgress) return;

    final result = await provider.verifyGstForRows(rows);
    if (!mounted) return;

    await _presentGstVerificationOutcome(rows, result);
  }

  Future<void> _presentGstVerificationOutcome(
    List<BillingDocumentListingRow> rows,
    BillingGstVerificationResult result,
  ) async {
    if (!mounted) return;

    final isCreditNote = widget.selectionSingular == 'Credit Note';
    final successMessage = isCreditNote
        ? 'Credit Note successfully verified with GST portal.'
        : 'Invoice successfully verified with GST portal.';

    if (result.success) {
      final items = result.verifiedItems;
      await BillingGstVerificationDialog.showSuccess(
        context,
        title: 'GST Verification Successful',
        subtitle: 'GST verification completed successfully.',
        successMessage: successMessage,
        onViewStatus: () {
          if (items.isEmpty) return;
          final provider = context.read<BillingListingProvider>();
          final row = provider.rowById(items.first.documentId);
          if (row != null && row.gstVerified) {
            _showGstQrIrnDialog(row);
          }
        },
      );
      return;
    }

    await BillingGstVerificationDialog.showFailure(
      context,
      title: 'GST Verification Failed',
      subtitle: 'Unable to complete GST verification.',
      errorMessage: result.errorMessage ??
          'The GST portal did not accept the request. Please try again.',
      onRetry: () => _onDirectToGst(rows),
    );
  }

  Widget _dueDaysCell(BillingDocumentListingRow r) {
    final overdue = r.dueDays < 0;
    final label = overdue ? 'Overdue ${r.dueDays.abs()}d' : '${r.dueDays}d';
    return _cell(
      label,
      weight: overdue ? AppTokens.weightSemibold : AppTokens.weightRegular,
      color: overdue ? AppTokens.accent500 : null,
    );
  }

  Widget _toolbarIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return AppIconButton(
      tooltip: tooltip,
      variant: AppIconButtonVariant.outlined,
      size: AppIconButtonSize.sm,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  @override
  void didUpdateWidget(covariant BillingListingScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionSingular != widget.selectionSingular ||
        oldWidget.enableGstEinvoiceWorkflow != widget.enableGstEinvoiceWorkflow) {
      _bulkActions = _createBulkActions();
    }
  }

  List<BulkAction<BillingDocumentListingRow>> _createBulkActions() {
    final docWord = widget.selectionSingular;
    const iconSize = AppTokens.bulkActionIconSize;
    return [
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_print',
        label: 'Print',
        icon: Icon(LucideIcons.printer, size: iconSize),
        onTap: (rows) => _snack(
          'Print — ${rows.length} ${widget.selectionPlural} (coming soon)',
        ),
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_gst',
        label: 'Direct to GST',
        icon: Icon(LucideIcons.landmark, size: iconSize),
        onTap: (rows) {
          if (!mounted) return;
          if (context.read<BillingRowActionState>().gstVerificationInProgress) {
            return;
          }
          if (widget.enableGstEinvoiceWorkflow) {
            _onDirectToGst(rows);
          } else {
            _snack('Direct to GST — ${rows.length} row(s) (coming soon)');
          }
        },
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_email',
        label: 'Email Customer',
        icon: Icon(LucideIcons.mail, size: iconSize),
        onTap: (rows) =>
            _snack('Email Customer — ${rows.length} row(s) (coming soon)'),
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_export',
        label: 'Export',
        icon: Icon(LucideIcons.download, size: iconSize),
        onTap: (rows) =>
            _snack('Export — ${rows.length} row(s) (coming soon)'),
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_narration',
        label: 'Update $docWord Narration',
        icon: Icon(LucideIcons.filePenLine, size: iconSize),
        onTap: (rows) => _snack(
          rows.length == 1
              ? 'Update narration — ${rows.first.documentNo} (coming soon)'
              : 'Update narration — ${rows.length} row(s) (coming soon)',
        ),
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_irn',
        label: 'Import from IRNGenByMe',
        icon: Icon(LucideIcons.fileInput, size: iconSize),
        onTap: (rows) => _snack(
          'Import from IRNGenByMe — ${rows.length} row(s) (coming soon)',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Selector<BillingListingProvider, _BillingTableSnapshot>(
        selector: (_, p) => _BillingTableSnapshot.from(p),
        builder: (context, snapshot, _) {
          final p = context.read<BillingListingProvider>();

          return AppListingScreen<BillingDocumentListingRow>(
            key: ValueKey('billing-listing-${widget.title}'),
            title: widget.title,
            subtitle: widget.subtitle,
            primaryActionLabel: widget.primaryActionLabel,
            onPrimaryAction: widget.onPrimaryAction,
            showKpis: false,
            exportModuleName: widget.title.replaceAll(' ', '_'),
            exportSourceRows: snapshot.filteredItems,
            showImport: false,
            showPrint: false,
            showColumnToggle: false,
            showBulkBar: true,
            // Sample Intake: bar always visible; buttons greyed until selection.
            bulkBarVisibleOnlyWhenSelection: false,
            actionsColumnWidth: _actionsColumnWidth,
            scaleDataColumnsToFillViewport: false,
            showCheckboxes: true,
            bulkRowId: (r) => r.id,
            bulkActions: _bulkActions,
            tableScrollableMinWidth: _scrollMinWidth,
            showTableHorizontalScrollbar: true,
            tableBodyFillsViewport: true,
            showActionsColumnLeadingBorder: false,
            searchHint: widget.searchHint,
            onSearch: p.setSearchQuery,
            toolbarAfterSearch: [
              SizedBox(width: AppTokens.space2),
              _toolbarIcon(
                icon: LucideIcons.refreshCw,
                tooltip: 'Reload latest records',
                onPressed: snapshot.isLoading ? null : () => p.load(),
              ),
              SizedBox(width: AppTokens.space2),
              LabCodeLabIdDateField(
                hint: 'From Date',
                selectedDate: snapshot.fromDate,
                onDateSelected: p.setFromDate,
              ),
              SizedBox(width: AppTokens.space2),
              LabCodeLabIdDateField(
                hint: 'To Date',
                selectedDate: snapshot.toDate,
                onDateSelected: p.setToDate,
              ),
            ],
            columns: _columns(),
            rows: snapshot.pagedRows,
            rowActions: [
              RowAction<BillingDocumentListingRow>(
                key: 'view',
                label: 'View',
                icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
                onTap: _openDetail,
                isEnabled: (row) =>
                    !context.read<BillingRowActionState>().isGstVerifying(row.id) &&
                    !context.read<BillingRowActionState>().isSignatureBusy(row.id),
              ),
              if (widget.showEditRowAction)
                RowAction<BillingDocumentListingRow>(
                  key: 'edit',
                  label: 'Edit',
                  icon: Icon(
                    LucideIcons.pencilLine,
                    size: AppTokens.iconButtonIconMd,
                  ),
                  onTap: _openEdit,
                  isEnabled: (row) =>
                      !context.read<BillingRowActionState>().isGstVerifying(row.id) &&
                      !context.read<BillingRowActionState>().isSignatureBusy(row.id),
                ),
              RowAction<BillingDocumentListingRow>(
                key: 'pdf',
                label: 'Download PDF',
                icon: Icon(LucideIcons.fileDown, size: AppTokens.iconButtonIconMd),
                onTap: (row) =>
                    _snack('Download PDF — ${row.documentNo} (coming soon)'),
              ),
              RowAction<BillingDocumentListingRow>(
                key: 'audit',
                label: 'Audit History',
                icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
                isEnabled: (row) =>
                    !_rowActionBusy &&
                    !context.read<BillingRowActionState>().isGstVerifying(row.id) &&
                    !context.read<BillingRowActionState>().isSignatureBusy(row.id),
                onTap: _onAuditHistory,
              ),
              if (widget.showGenerateCreditNoteRowAction)
                RowAction<BillingDocumentListingRow>(
                  key: 'gen_cn',
                  label: 'Generate Credit Note',
                  icon: Icon(
                    LucideIcons.banknote,
                    size: AppTokens.iconButtonIconMd,
                  ),
                  isEnabled: (row) =>
                      !_rowActionBusy &&
                      !context.read<BillingRowActionState>().isGstVerifying(row.id) &&
                      !context.read<BillingRowActionState>().isSignatureBusy(row.id),
                  onTap: _onGenerateCreditNote,
                ),
            ],
            mobileCardBuilder: (r) => Padding(
              padding: EdgeInsets.all(AppTokens.space2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _openDetail(r),
                    child: Text(
                      r.documentNo,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.tableCellSize,
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.primary800,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Text(
                    r.customer,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      color: AppTokens.textMuted,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Text(
                    'Outstanding ${_formatAmt(r.outstanding)} · ${r.statusLabel}',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            isLoading: snapshot.isLoading,
            totalCount: snapshot.totalCount,
            currentPage: snapshot.currentPage,
            pageSize: snapshot.pageSize,
            onPageChanged: p.setPage,
            onPageSizeChanged: p.setPageSize,
            emptyMessage: 'No records match the current filters',
          );
        },
      ),
    );
  }
}

/// Listing data slice for [Selector] — avoids rebuilds during row-only loading.
class _BillingTableSnapshot {
  const _BillingTableSnapshot({
    required this.pagedRows,
    required this.filteredItems,
    required this.isLoading,
    required this.fromDate,
    required this.toDate,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.rowSignature,
  });

  factory _BillingTableSnapshot.from(BillingListingProvider p) {
    final rows = p.pagedRows;
    return _BillingTableSnapshot(
      pagedRows: rows,
      filteredItems: p.filteredItems,
      isLoading: p.isLoading,
      fromDate: p.fromDate,
      toDate: p.toDate,
      currentPage: p.effectiveCurrentPage,
      pageSize: p.pageSize,
      totalCount: p.totalFilteredCount,
      rowSignature: _rowSignature(rows),
    );
  }

  final List<BillingDocumentListingRow> pagedRows;
  final List<BillingDocumentListingRow> filteredItems;
  final bool isLoading;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final String rowSignature;

  /// Excludes icon-column flags so GST/signature updates rebuild only row cells.
  static String _rowSignature(List<BillingDocumentListingRow> rows) {
    return rows
        .map(
          (r) =>
              '${r.id}|${r.documentNo}|${r.statusLabel}|${r.total}|${r.amountReceived}|${r.outstanding}',
        )
        .join(';');
  }

  @override
  bool operator ==(Object other) {
    return other is _BillingTableSnapshot &&
        rowSignature == other.rowSignature &&
        isLoading == other.isLoading &&
        fromDate == other.fromDate &&
        toDate == other.toDate &&
        currentPage == other.currentPage &&
        pageSize == other.pageSize &&
        totalCount == other.totalCount;
  }

  @override
  int get hashCode => Object.hash(
        rowSignature,
        isLoading,
        fromDate,
        toDate,
        currentPage,
        pageSize,
        totalCount,
      );
}
