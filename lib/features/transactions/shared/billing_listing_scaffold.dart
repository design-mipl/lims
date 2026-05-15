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

  /// e.g. `/transactions/customer-invoice` → detail at `…/:id/view`.
  final String detailPathPrefix;

  /// Bulk-bar label: “1 Invoice Selected” / “1 Credit Note Selected”.
  final String selectionSingular;

  /// Bulk-bar label plural: “N Invoices Selected”.
  final String selectionPlural;

  @override
  State<BillingListingScaffold> createState() => _BillingListingScaffoldState();
}

class _BillingListingScaffoldState extends State<BillingListingScaffold> {
  // Tiered widths: small | medium | large — fixed so viewport scaling does not
  // stretch some columns more than others ([scaleDataColumnsToFillViewport]=false).
  /// eInvoice column — wider when GST workflow shows 3 action icons.
  double get _wEinv =>
      widget.enableGstEinvoiceWorkflow ? 132.0 : 84.0;
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

  List<BillingDocumentListingRow> _selectedRows = [];

  /// Prevents duplicate row-action navigation while a handler runs.
  bool _rowActionBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BillingListingProvider>().load();
    });
  }

  double get _scrollMinWidth =>
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
        content: Text(
          msg,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: error ? AppTokens.error500 : AppTokens.primary800,
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
    if (!widget.enableGstEinvoiceWorkflow) return;
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

  Widget _eInvoiceCellLegacy(BillingDocumentListingRow r) {
    return Tooltip(
      message: r.eInvoiceActive ? 'eInvoice active' : 'eInvoice off',
      child: Icon(
        r.eInvoiceActive ? LucideIcons.badgeCheck : LucideIcons.circleDashed,
        size: AppTokens.iconButtonIconSm,
        color: r.eInvoiceActive ? AppTokens.primary800 : AppTokens.textMuted,
      ),
    );
  }

  Widget _eInvoiceCellGst(BillingDocumentListingRow r) {
    if (!r.gstVerified) {
      return Center(
        child: Tooltip(
          message: 'Invoice — GST verification pending',
          child: Icon(
            LucideIcons.fileText,
            size: AppTokens.iconButtonIconSm,
            color: AppTokens.textMuted,
          ),
        ),
      );
    }
    const gap = 12.0;
    Widget iconBtn({
      required IconData icon,
      required String tooltip,
      required VoidCallback onTap,
      Color? color,
    }) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              size: AppTokens.iconButtonIconSm,
              color: color ?? AppTokens.textPrimary,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBtn(
            icon: LucideIcons.fileText,
            tooltip: 'GST-approved invoice PDF',
            color: AppTokens.success500,
            onTap: () => _snack(
              'GST-approved invoice PDF — ${r.documentNo} (coming soon)',
            ),
          ),
          const SizedBox(width: gap),
          iconBtn(
            icon: Icons.qr_code_2_rounded,
            tooltip: 'IRN & QR code',
            onTap: () => _showGstQrIrnDialog(r),
          ),
          const SizedBox(width: gap),
          iconBtn(
            icon: LucideIcons.fileDown,
            tooltip: 'Download GST invoice PDF',
            onTap: () => _snack(
              'Download GST invoice PDF — ${r.documentNo} (coming soon)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _eInvoiceCell(BillingDocumentListingRow r) {
    if (widget.enableGstEinvoiceWorkflow) {
      return _eInvoiceCellGst(r);
    }
    return _eInvoiceCellLegacy(r);
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
      _snack('Select at least one invoice using checkboxes.', error: true);
      return;
    }

    final provider = context.read<BillingListingProvider>();

    BuildContext? progressDialogContext;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) {
        progressDialogContext = dialogContext;
        return AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: Text(
                  'GST / eInvoice verification in progress…',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySize,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future<void>.delayed(Duration.zero);

    void dismissProgressDialog() {
      final ctx = progressDialogContext;
      if (ctx != null && ctx.mounted) {
        Navigator.of(ctx).pop();
      } else if (mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      }
    }

    var ok = false;
    var hadException = false;
    try {
      ok = await provider.verifyGstForRows(rows);
    } catch (_) {
      ok = false;
      hadException = true;
    } finally {
      dismissProgressDialog();
    }

    if (!mounted) return;

    if (hadException) {
      _snack('GST verification failed.', error: true);
      return;
    }

    if (!ok) {
      _snack('GST verification could not complete.', error: true);
      return;
    }

    final pr = provider;
    final ids = rows.map((e) => e.id).toSet();
    setState(() {
      _selectedRows = pr.items.where((e) => ids.contains(e.id)).toList();
    });

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'GST verification',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textMd,
            fontWeight: AppTokens.weightSemibold,
            color: AppTokens.textPrimary,
          ),
        ),
        content: Text(
          rows.length == 1
              ? 'Invoice successfully verified by GST'
              : '${rows.length} invoices successfully verified by GST',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
            ),
          ),
        ],
      ),
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

  List<BulkAction<BillingDocumentListingRow>> _bulkWorkflowActions(int count) {
    final docWord = widget.selectionSingular;
    return [
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_print',
        label: 'Print',
        icon: Icon(LucideIcons.printer, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) => _snack(
          'Print — ${rows.length} ${widget.selectionPlural} (coming soon)',
        ),
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_irn',
        label: 'Import from IRNGenByMe',
        icon: Icon(LucideIcons.fileInput, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) => _snack(
          'Import from IRNGenByMe — ${rows.length} row(s) (coming soon)',
        ),
      ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_gst',
        label: 'Direct to GST',
        icon: Icon(
          widget.enableGstEinvoiceWorkflow
              ? LucideIcons.wifi
              : LucideIcons.landmark,
          size: AppTokens.iconButtonIconSm,
        ),
        showOnlyWhenSelected: widget.enableGstEinvoiceWorkflow,
        onTap: (rows) {
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
        icon: Icon(LucideIcons.mail, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) =>
            _snack('Email Customer — ${rows.length} row(s) (coming soon)'),
      ),
      if (count == 1)
        BulkAction<BillingDocumentListingRow>(
          key: 'bulk_narration_single',
          label: 'Update $docWord Narration',
          icon: Icon(LucideIcons.filePenLine, size: AppTokens.iconButtonIconSm),
          showOnlyWhenSelected: false,
          onTap: (rows) => _snack(
            'Update narration — ${rows.first.documentNo} (coming soon)',
          ),
        ),
      BulkAction<BillingDocumentListingRow>(
        key: 'bulk_excel',
        label: 'Export to Excel',
        icon: Icon(
          LucideIcons.fileSpreadsheet,
          size: AppTokens.iconButtonIconSm,
        ),
        showOnlyWhenSelected: false,
        onTap: (rows) =>
            _snack('Export to Excel — ${rows.length} row(s) (coming soon)'),
      ),
      if (count > 1)
        BulkAction<BillingDocumentListingRow>(
          key: 'bulk_narration_multi',
          label: 'Bulk Update Narration',
          icon: Icon(LucideIcons.alignLeft, size: AppTokens.iconButtonIconSm),
          showOnlyWhenSelected: false,
          onTap: (rows) => _snack(
            'Bulk update narration — ${rows.length} row(s) (coming soon)',
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BillingListingProvider>();
    final n = _selectedRows.length;

    final columns = <TableColumn<BillingDocumentListingRow>>[
      TableColumn<BillingDocumentListingRow>(
        key: 'eInvoice',
        label: 'eInvoice',
        width: _wEinv,
        sortable: true,
        sortValue: (r) => widget.enableGstEinvoiceWorkflow
            ? (r.gstVerified ? 2 : (r.eInvoiceActive ? 1 : 0))
            : (r.eInvoiceActive ? 1 : 0),
        cellBuilder: _eInvoiceCell,
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
        cellBuilder: (r) =>
            _cell(r.statusLabel, weight: AppTokens.weightMedium),
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<BillingDocumentListingRow>(
        title: widget.title,
        subtitle: widget.subtitle,
        primaryActionLabel: widget.primaryActionLabel,
        onPrimaryAction: widget.onPrimaryAction,
        showKpis: false,
        showExport: false,
        showImport: false,
        showPrint: false,
        showColumnToggle: false,
        showBulkBar: true,
        bulkBarVisibleOnlyWhenSelection: true,
        bulkSelectionSummary: (c) => c == 1
            ? '1 ${widget.selectionSingular} Selected'
            : '$c ${widget.selectionPlural} Selected',
        actionsColumnWidth: _actionsColumnWidth,
        scaleDataColumnsToFillViewport: false,
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        bulkActions: n == 0 ? [] : _bulkWorkflowActions(n),
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
            onPressed: p.isLoading ? null : () => p.load(),
          ),
          SizedBox(width: AppTokens.space2),
          LabCodeLabIdDateField(
            hint: 'From Date',
            selectedDate: p.fromDate,
            onDateSelected: p.setFromDate,
          ),
          SizedBox(width: AppTokens.space2),
          LabCodeLabIdDateField(
            hint: 'To Date',
            selectedDate: p.toDate,
            onDateSelected: p.setToDate,
          ),
          if (widget.enableGstEinvoiceWorkflow) ...[
            SizedBox(width: AppTokens.space2),
            _toolbarIcon(
              icon: LucideIcons.wifi,
              tooltip: 'Direct to GST',
              onPressed: p.isLoading || p.gstVerificationInProgress
                  ? null
                  : () => _onDirectToGst(_selectedRows),
            ),
          ],
        ],
        columns: columns,
        rows: p.pagedRows,
        onRowSelectionChanged: (indices) {
          final rows = p.pagedRows;
          setState(() {
            _selectedRows = indices
                .map((i) => i < rows.length ? rows[i] : null)
                .whereType<BillingDocumentListingRow>()
                .toList();
          });
        },
        rowActions: [
          RowAction<BillingDocumentListingRow>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: _openDetail,
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
            isEnabled: (_) => !_rowActionBusy,
            onTap: _onAuditHistory,
          ),
          if (widget.enableGstEinvoiceWorkflow)
            RowAction<BillingDocumentListingRow>(
              key: 'gen_cn',
              label: 'Generate Credit Note',
              icon: Icon(
                LucideIcons.banknote,
                size: AppTokens.iconButtonIconMd,
              ),
              isEnabled: (_) => !_rowActionBusy,
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
        isLoading: p.isLoading,
        totalCount: p.totalFilteredCount,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No records match the current filters',
      ),
    );
  }
}
