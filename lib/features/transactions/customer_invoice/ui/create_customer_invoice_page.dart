import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../masters/customer_master/data/customer_model.dart';
import '../../../masters/customer_master/state/customer_provider.dart';
import '../../credit_note/data/create_credit_note_prefill.dart';
import '../../shared/billing_invoice_audit_dialog.dart';
import '../../shared/billing_invoice_audit_history.dart';
import '../data/create_customer_invoice_form_model.dart';
import '../data/customer_invoice_view_loader.dart';
import '../data/invoice_item_row_model.dart';
import '../data/pending_invoice_lab_row_model.dart';
import 'customer_invoice_bill_to_drawer.dart';
import 'customer_invoice_pending_lab_picker_dialog.dart';

/// Snapshot of editable form state (used to cancel inline edit on View Invoice).
class _InvoiceFormEditSnapshot {
  const _InvoiceFormEditSnapshot({
    required this.customerId,
    required this.invoiceNo,
    required this.billTo,
    required this.address,
    required this.shipTo,
    required this.gstNo,
    required this.state,
    required this.country,
    required this.buyerOrder,
    required this.deliveryNote,
    required this.supplierRef,
    required this.dispatchDocNo,
    required this.remarks,
    required this.invoiceType,
    required this.gstType,
    required this.typeOfService,
    required this.paymentTerms,
    required this.hsnCode,
    required this.dispatchThrough,
    required this.modeOfDelivery,
    required this.invoiceDate,
    required this.buyerOrderDate,
    required this.dispatchDate,
    required this.lines,
  });

  final String? customerId;
  final String invoiceNo;
  final String billTo;
  final String address;
  final String shipTo;
  final String gstNo;
  final String state;
  final String country;
  final String buyerOrder;
  final String deliveryNote;
  final String supplierRef;
  final String dispatchDocNo;
  final String remarks;
  final String? invoiceType;
  final String? gstType;
  final String? typeOfService;
  final String? paymentTerms;
  final String? hsnCode;
  final String? dispatchThrough;
  final String? modeOfDelivery;
  final DateTime? invoiceDate;
  final DateTime? buyerOrderDate;
  final DateTime? dispatchDate;
  final List<InvoiceItemRowModel> lines;
}

/// Create Customer Invoice — same shell/sections as [CreateSampleReceiptPage],
/// with Bill To picker, pending-lab (+) workspace, editable rates, and GST summary.
///
/// Pass [viewInvoiceId] to open **View Customer Invoice** (read-only; Edit toggles inline edit).
/// When [startInEditMode] is true with [viewInvoiceId], opens already in edit mode (row action **Edit**).
class CreateCustomerInvoicePage extends StatefulWidget {
  const CreateCustomerInvoicePage({
    super.key,
    this.viewInvoiceId,
    this.startInEditMode = false,
  });

  /// When non-null, page is view mode for this listing id.
  final String? viewInvoiceId;

  /// With [viewInvoiceId], starts with fields editable (same as tapping **Edit Invoice**).
  final bool startInEditMode;

  @override
  State<CreateCustomerInvoicePage> createState() =>
      _CreateCustomerInvoicePageState();
}

class _CreateCustomerInvoicePageState extends State<CreateCustomerInvoicePage> {
  final _invoiceNoCtrl = TextEditingController();
  final _billToCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _shipToCtrl = TextEditingController();
  final _gstNoCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _buyerOrderCtrl = TextEditingController();
  final _deliveryNoteCtrl = TextEditingController();
  final _supplierRefCtrl = TextEditingController();
  final _dispatchDocNoCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  final Map<String, TextEditingController> _rateByLineId = {};

  String? _invoiceType;
  String? _gstType;
  String? _customerId;
  String? _typeOfService;
  String? _paymentTerms;
  String? _hsnCode;
  String? _dispatchThrough;
  String? _modeOfDelivery;

  DateTime? _invoiceDate;
  DateTime? _buyerOrderDate;
  DateTime? _dispatchDate;

  late CreateCustomerInvoiceDraft _draft;
  List<InvoiceItemRowModel> _lines = [];
  final Set<String> _pendingIdsOnInvoice = {};
  List<PendingInvoiceLabRow> _pendingPool = [];
  int _itemSelectionCount = 0;

  bool _isEditing = false;
  _InvoiceFormEditSnapshot? _editSnapshot;

  bool _lineItemActionBusy = false;

  static const double _itemCol = 120;
  static const double _mockOtherCharges = 0.0;
  static const double _mockDiscount = 0.0;

  bool get _isView => widget.viewInvoiceId != null;
  bool get _readOnly => _isView && !_isEditing;
  bool get _fieldsEnabled => !_isView || _isEditing;

  @override
  void initState() {
    super.initState();
    if (_isView) {
      final t = DateTime.now();
      _draft = CreateCustomerInvoiceDraft(provisionalInvoiceNo: '—');
      _invoiceDate = DateTime(t.year, t.month, t.day);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await context.read<CustomerProvider>().fetchAll();
        if (!mounted) return;
        await _loadViewInvoice();
      });
      return;
    }
    final now = DateTime.now();
    _draft = CreateCustomerInvoiceDraft(
      provisionalInvoiceNo:
          'INV-${now.year}-${now.month.toString().padLeft(2, '0')}${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
    );
    _invoiceNoCtrl.text = _draft.provisionalInvoiceNo;
    _invoiceDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<CustomerProvider>().fetchAll();
      if (!mounted) return;
      final active = context
          .read<CustomerProvider>()
          .customers
          .where((e) => e.status == 'active')
          .toList();
      setState(() {
        _pendingPool = pendingLabsTemplateForCustomers(active);
      });
    });
  }

  @override
  void dispose() {
    _invoiceNoCtrl.dispose();
    _billToCtrl.dispose();
    _addressCtrl.dispose();
    _shipToCtrl.dispose();
    _gstNoCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _buyerOrderCtrl.dispose();
    _deliveryNoteCtrl.dispose();
    _supplierRefCtrl.dispose();
    _dispatchDocNoCtrl.dispose();
    _remarksCtrl.dispose();
    for (final c in _rateByLineId.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _disposeAllRateControllers() {
    for (final c in _rateByLineId.values) {
      c.dispose();
    }
    _rateByLineId.clear();
  }

  void _resetInvoiceLines() {
    _disposeAllRateControllers();
    _lines = [];
    _pendingIdsOnInvoice.clear();
    _itemSelectionCount = 0;
  }

  static String _formatYmd(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/customer-invoice');
    }
  }

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

  String get _workspaceInvoiceId =>
      widget.viewInvoiceId ?? 'draft-${_draft.provisionalInvoiceNo}';

  String get _workspaceInvoiceNo {
    final t = _invoiceNoCtrl.text.trim();
    return t.isEmpty ? _draft.provisionalInvoiceNo : t;
  }

  Future<void> _onLineAuditHistory(InvoiceItemRowModel line) async {
    if (_lineItemActionBusy) return;
    setState(() => _lineItemActionBusy = true);
    try {
      final entries = buildInvoiceLineAuditHistory(_workspaceInvoiceNo, line);
      await showInvoiceLineAuditDialog(
        context,
        invoiceNo: _workspaceInvoiceNo,
        labNo: line.labNo,
        entries: entries,
      );
    } finally {
      if (mounted) setState(() => _lineItemActionBusy = false);
    }
  }

  Future<void> _onLineGenerateCreditNote(InvoiceItemRowModel line) async {
    if (_lineItemActionBusy) return;
    setState(() => _lineItemActionBusy = true);
    try {
      final summary = CreateCustomerInvoiceDraft.computeSummary(
        lines: _lines,
        otherCharges: _mockOtherCharges,
        discount: _mockDiscount,
        useIgst: _useIgst,
      );
      final prefill = CreateCreditNotePrefill.fromInvoiceLine(
        invoiceId: _workspaceInvoiceId,
        invoiceNo: _workspaceInvoiceNo,
        customerName: _billToCtrl.text.trim().isEmpty
            ? 'Customer'
            : _billToCtrl.text.trim(),
        invoiceDate: _invoiceDate ?? DateTime.now(),
        invoiceTotal: summary.grandTotal,
        line: line,
      );
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
      if (mounted) setState(() => _lineItemActionBusy = false);
    }
  }

  String _formatAddress(CustomerModel c) {
    final parts = <String>[
      c.addressLine1 ?? '',
      c.city ?? '',
      c.state ?? '',
      c.pincode ?? '',
    ].where((e) => e.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  CustomerModel? _customerById(List<CustomerModel> list, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  _InvoiceFormEditSnapshot _captureEditSnapshot() {
    return _InvoiceFormEditSnapshot(
      customerId: _customerId,
      invoiceNo: _invoiceNoCtrl.text,
      billTo: _billToCtrl.text,
      address: _addressCtrl.text,
      shipTo: _shipToCtrl.text,
      gstNo: _gstNoCtrl.text,
      state: _stateCtrl.text,
      country: _countryCtrl.text,
      buyerOrder: _buyerOrderCtrl.text,
      deliveryNote: _deliveryNoteCtrl.text,
      supplierRef: _supplierRefCtrl.text,
      dispatchDocNo: _dispatchDocNoCtrl.text,
      remarks: _remarksCtrl.text,
      invoiceType: _invoiceType,
      gstType: _gstType,
      typeOfService: _typeOfService,
      paymentTerms: _paymentTerms,
      hsnCode: _hsnCode,
      dispatchThrough: _dispatchThrough,
      modeOfDelivery: _modeOfDelivery,
      invoiceDate: _invoiceDate,
      buyerOrderDate: _buyerOrderDate,
      dispatchDate: _dispatchDate,
      lines: [for (final l in _lines) l],
    );
  }

  void _restoreEditSnapshot(_InvoiceFormEditSnapshot s) {
    _customerId = s.customerId;
    _invoiceNoCtrl.text = s.invoiceNo;
    _billToCtrl.text = s.billTo;
    _addressCtrl.text = s.address;
    _shipToCtrl.text = s.shipTo;
    _gstNoCtrl.text = s.gstNo;
    _stateCtrl.text = s.state;
    _countryCtrl.text = s.country;
    _buyerOrderCtrl.text = s.buyerOrder;
    _deliveryNoteCtrl.text = s.deliveryNote;
    _supplierRefCtrl.text = s.supplierRef;
    _dispatchDocNoCtrl.text = s.dispatchDocNo;
    _remarksCtrl.text = s.remarks;
    _invoiceType = s.invoiceType;
    _gstType = s.gstType;
    _typeOfService = s.typeOfService;
    _paymentTerms = s.paymentTerms;
    _hsnCode = s.hsnCode;
    _dispatchThrough = s.dispatchThrough;
    _modeOfDelivery = s.modeOfDelivery;
    _invoiceDate = s.invoiceDate;
    _buyerOrderDate = s.buyerOrderDate;
    _dispatchDate = s.dispatchDate;
    _disposeAllRateControllers();
    _lines = [for (final l in s.lines) l];
    _pendingIdsOnInvoice
      ..clear()
      ..addAll(s.lines.map((e) => e.id));
    for (final line in _lines) {
      _rateByLineId[line.id] = TextEditingController(
        text: line.rate.toStringAsFixed(2),
      );
    }
  }

  Future<void> _loadViewInvoice() async {
    final id = widget.viewInvoiceId;
    if (id == null) return;
    final customers = context.read<CustomerProvider>().customers;
    final payload = await loadCustomerInvoiceViewPayload(id, customers);
    if (!mounted) return;
    if (payload == null) {
      _snack('Invoice not found');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onCancel();
      });
      return;
    }
    setState(() {
      _applyViewPayload(payload);
      if (widget.startInEditMode) {
        _editSnapshot = _captureEditSnapshot();
        _isEditing = true;
      }
    });
  }

  void _applyViewPayload(CustomerInvoiceViewPayload p) {
    final row = p.listingRow;
    _draft = CreateCustomerInvoiceDraft(provisionalInvoiceNo: row.documentNo);
    _invoiceNoCtrl.text = row.documentNo;
    _invoiceDate = DateTime(row.docDate.year, row.docDate.month, row.docDate.day);
    _invoiceType = p.invoiceType;
    _gstType = p.gstType;
    _billToCtrl.text = row.customer;
    _buyerOrderCtrl.text = 'PO-${row.id}-VIEW';
    _buyerOrderDate = p.buyerOrderDate;
    _dispatchDate = p.dispatchDate;
    _deliveryNoteCtrl.text = p.deliveryNote;
    _supplierRefCtrl.text = p.supplierRef;
    _dispatchDocNoCtrl.text = p.dispatchDocNo;
    _dispatchThrough = p.dispatchThrough;
    _modeOfDelivery = p.modeOfDelivery;
    _hsnCode = p.hsnCode;
    _remarksCtrl.text = p.remarks;
    _typeOfService = p.typeOfService;
    _paymentTerms = p.paymentTerms;

    final c = p.customer;
    if (c != null) {
      _customerId = c.id;
      _gstNoCtrl.text = (c.gstNo ?? '').trim();
      _stateCtrl.text = (c.state ?? '').trim();
      _countryCtrl.text = (c.country ?? '').trim();
      _addressCtrl.text = _formatAddress(c);
      _shipToCtrl.text = _formatAddress(c);
    } else {
      _customerId = null;
      _gstNoCtrl.clear();
      _stateCtrl.clear();
      _countryCtrl.clear();
      _addressCtrl.text = '${row.customer} — billing address (mock)';
      _shipToCtrl.text = _addressCtrl.text;
    }

    _resetInvoiceLines();
    for (final line in p.lines) {
      _lines.add(line);
      _pendingIdsOnInvoice.add(line.id);
      _rateByLineId[line.id] = TextEditingController(
        text: line.rate.toStringAsFixed(2),
      );
    }
    _renumberInvoiceSr();

    final active = context
        .read<CustomerProvider>()
        .customers
        .where((e) => e.status == 'active')
        .toList();
    _pendingPool = pendingLabsTemplateForCustomers(active);
  }

  void _onBeginEdit() {
    setState(() {
      _editSnapshot = _captureEditSnapshot();
      _isEditing = true;
    });
  }

  void _onCancelEdit() {
    final snap = _editSnapshot;
    if (snap == null) return;
    setState(() {
      _restoreEditSnapshot(snap);
      _isEditing = false;
      _editSnapshot = null;
    });
  }

  void _onSaveChanges() {
    setState(() {
      _isEditing = false;
      _editSnapshot = null;
    });
    _snack('Changes saved (UI only)');
  }

  void _onDownloadPdf() {
    _snack('Download PDF (coming soon)');
  }

  bool get _useIgst =>
      (_gstType ?? '').toLowerCase().contains('inter') ||
      (_gstType ?? '').toLowerCase().contains('igst');

  void _openBillToDrawer(List<CustomerModel> active) {
    if (_readOnly) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final picked = await showCustomerInvoiceBillToDrawer(
        context,
        customers: active,
        pendingLabs: _pendingPool,
        excludedPendingIds: _pendingIdsOnInvoice,
      );
      if (!mounted || picked == null) return;
      setState(() {
        _customerId = picked.id;
        _resetInvoiceLines();
        _applyCustomerSelection(picked);
      });
    });
  }

  void _applyCustomerSelection(CustomerModel c) {
    _billToCtrl.text = c.companyName;
    _addressCtrl.text = _formatAddress(c);
    _shipToCtrl.text = _formatAddress(c);
    _gstNoCtrl.text = (c.gstNo ?? '').trim();
    _stateCtrl.text = (c.state ?? '').trim();
    _countryCtrl.text = (c.country ?? '').trim();

    if (c.sampleTypes.isNotEmpty) {
      final n = c.sampleTypes.first.sampleTypeName.toLowerCase();
      if (n.contains('field')) {
        _typeOfService = 'field';
      } else if (n.contains('consult')) {
        _typeOfService = 'consult';
      } else {
        _typeOfService = 'lab';
      }
    } else {
      _typeOfService = 'lab';
    }

    if ((c.paymentTerms ?? '').trim().isNotEmpty) {
      _paymentTerms = 'cust';
    } else {
      _paymentTerms = 'net30';
    }

    final short = c.id.length >= 6 ? c.id.substring(0, 6) : c.id;
    _buyerOrderCtrl.text = 'PO-$short-025';
    _buyerOrderDate = DateTime.now();
    _hsnCode = '998346';
    _deliveryNoteCtrl.text = 'DN-${DateTime.now().year}-${short.toUpperCase()}';
  }

  void _openPendingLabPicker() {
    if (_readOnly) return;
    if (_customerId == null) {
      _snack('Select Bill To customer first');
      return;
    }
    final available = _pendingPool
        .where(
          (p) =>
              p.customerId == _customerId &&
              !_pendingIdsOnInvoice.contains(p.id),
        )
        .toList();
    if (available.isEmpty) {
      _snack('No pending uninvoiced labs for this customer');
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      final picked = await showPendingInvoiceLabSelectionDialog(
        context,
        availableRows: available,
      );
      if (!mounted || picked == null || picked.isEmpty) return;
      setState(() {
        for (final p in picked) {
          if (_pendingIdsOnInvoice.contains(p.id)) continue;
          final line = InvoiceItemRowModel(
            srNo: _lines.length + 1,
            id: p.id,
            labDate: p.labDate,
            labNo: p.labNo,
            reportId: p.reportId,
            typeOfSample: p.typeOfSample,
            lineItem: p.lineItem,
            rate: p.suggestedRate,
            quantity: 1,
            site: p.site,
            status: 'Pending invoice',
            references: p.referenceNo,
            contactPerson: p.contactPerson,
          );
          _lines.add(line);
          _pendingIdsOnInvoice.add(p.id);
          _rateByLineId[line.id] = TextEditingController(
            text: line.rate.toStringAsFixed(2),
          );
        }
        _renumberInvoiceSr();
      });
    });
  }

  void _updateRate(String lineId, String raw) {
    final v = double.tryParse(raw.trim());
    if (v == null || v < 0) return;
    final i = _lines.indexWhere((e) => e.id == lineId);
    if (i < 0) return;
    setState(() => _lines[i] = _lines[i].copyWith(rate: v));
  }

  void _renumberInvoiceSr() {
    _lines = [
      for (var i = 0; i < _lines.length; i++) _lines[i].copyWith(srNo: i + 1),
    ];
  }

  List<BulkAction<InvoiceItemRowModel>> _itemBulkActions() {
    return [
      BulkAction<InvoiceItemRowModel>(
        key: 'print',
        label: 'Print',
        icon: Icon(LucideIcons.printer, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) => _snack('Print — ${rows.length} line(s) (coming soon)'),
      ),
      BulkAction<InvoiceItemRowModel>(
        key: 'irn',
        label: 'Import from IRNGenByMe',
        icon: Icon(LucideIcons.fileInput, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) =>
            _snack('Import from IRNGenByMe — ${rows.length} (coming soon)'),
      ),
      BulkAction<InvoiceItemRowModel>(
        key: 'gst',
        label: 'Direct to GST',
        icon: Icon(LucideIcons.wifi, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) => _snack(
          'Use Customer Invoice listing: select invoices, then toolbar Direct to GST — ${rows.length} line(s) selected here.',
        ),
      ),
      BulkAction<InvoiceItemRowModel>(
        key: 'email',
        label: 'Email Customer',
        icon: Icon(LucideIcons.mail, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) =>
            _snack('Email Customer — ${rows.length} (coming soon)'),
      ),
      BulkAction<InvoiceItemRowModel>(
        key: 'narration',
        label: 'Update Invoice Narration',
        icon: Icon(LucideIcons.filePenLine, size: AppTokens.iconButtonIconSm),
        showOnlyWhenSelected: false,
        onTap: (rows) =>
            _snack('Update narration — ${rows.length} (coming soon)'),
      ),
      BulkAction<InvoiceItemRowModel>(
        key: 'excel',
        label: 'Export Excel',
        icon: Icon(
          LucideIcons.fileSpreadsheet,
          size: AppTokens.iconButtonIconSm,
        ),
        showOnlyWhenSelected: false,
        onTap: (rows) => _snack('Export Excel — ${rows.length} (coming soon)'),
      ),
    ];
  }

  Widget _formLabDateField({
    required String label,
    required String hint,
    required DateTime? value,
    required ValueChanged<DateTime> onDateSelected,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.fieldLabelSize,
            fontWeight: AppTokens.fieldLabelWeight,
            color: AppTokens.labelColor,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: AppTokens.space1),
        LabCodeLabIdDateField(
          layout: LabCodeLabIdDateFieldLayout.formRow,
          hint: hint,
          selectedDate: value,
          onDateSelected: onDateSelected,
          enabled: enabled,
        ),
      ],
    );
  }

  /// Compact ERP-style header row: Invoice No., Date, Type, GST (one row desktop).
  Widget _invoiceDetailsFields({
    required List<AppSelectItem<String>> invoiceTypeItems,
    required List<AppSelectItem<String>> gstTypeItems,
  }) {
    SizedBox hGap() => SizedBox(width: AppTokens.space3);
    final invoiceNo = AppInput(
      label: 'Invoice No.',
      controller: _invoiceNoCtrl,
      size: AppInputSize.md,
      enabled: _fieldsEnabled,
      onChanged: (_) => setState(() {}),
    );
    final invoiceDate = _formLabDateField(
      label: 'Invoice Date',
      hint: 'Select date',
      value: _invoiceDate,
      enabled: _fieldsEnabled,
      onDateSelected: (d) => setState(() => _invoiceDate = d),
    );
    final invoiceType = AnchoredSearchableDropdownField<String>(
      label: 'Invoice Type',
      hint: 'Select type',
      value: _invoiceType,
      items: invoiceTypeItems,
      size: AppInputSize.md,
      enabled: _fieldsEnabled,
      overlayMinimalShadow: true,
      onChanged: (v) => setState(() => _invoiceType = v),
    );
    final gstType = AnchoredSearchableDropdownField<String>(
      label: 'GST Type',
      hint: 'Select GST type',
      value: _gstType,
      items: gstTypeItems,
      size: AppInputSize.md,
      enabled: _fieldsEnabled,
      overlayMinimalShadow: true,
      onChanged: (v) => setState(() => _gstType = v),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Below ~720px, four equal fields in one row risks overflow; use 2×2.
        final useTwoRows = w < 720;
        if (useTwoRows) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: invoiceNo),
                  hGap(),
                  Expanded(child: invoiceDate),
                ],
              ),
              SizedBox(height: AppTokens.space2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: invoiceType),
                  hGap(),
                  Expanded(child: gstType),
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: invoiceNo),
            hGap(),
            Expanded(child: invoiceDate),
            hGap(),
            Expanded(child: invoiceType),
            hGap(),
            Expanded(child: gstType),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: emphasize ? AppTokens.textSm : AppTokens.tableCellSize,
              fontWeight: emphasize
                  ? AppTokens.weightSemibold
                  : AppTokens.weightRegular,
              color: AppTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: emphasize ? AppTokens.textMd : AppTokens.tableCellSize,
              fontWeight: emphasize
                  ? AppTokens.weightBold
                  : AppTokens.weightMedium,
              color: AppTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGenerateInvoice() async {
    if (_customerId == null) {
      _snack('Select Bill To customer');
      return;
    }
    if (_lines.isEmpty) {
      _snack('Add at least one invoice line');
      return;
    }
    _snack(
      'Invoice generated — saved to UltraLabs invoice template (mock). '
      'CEO signature & eInvoice QR/IRN embed after GST verification on listing.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    context.go('/transactions/customer-invoice');
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final active = customers.where((e) => e.status == 'active').toList();
    final selectedCustomer = _customerById(active, _customerId);

    final invoiceTypeItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'tax', label: 'Tax Invoice'),
      AppSelectItem(value: 'proforma', label: 'Proforma'),
      AppSelectItem(value: 'export', label: 'Export'),
    ];
    final gstTypeItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'intra', label: 'Registered (Intra-state)'),
      AppSelectItem(value: 'inter', label: 'Registered (Inter-state / IGST)'),
      AppSelectItem(value: 'unreg', label: 'Unregistered'),
    ];
    final serviceItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'lab', label: 'Laboratory Testing'),
      AppSelectItem(value: 'field', label: 'Field Service'),
      AppSelectItem(value: 'consult', label: 'Consulting'),
    ];
    final paymentItems = <AppSelectItem<String>>[
      const AppSelectItem(value: 'net30', label: 'Net 30'),
      const AppSelectItem(value: 'net15', label: 'Net 15'),
      const AppSelectItem(value: 'advance', label: 'Advance'),
      if (selectedCustomer != null &&
          (selectedCustomer.paymentTerms ?? '').trim().isNotEmpty)
        AppSelectItem(
          value: 'cust',
          label: selectedCustomer.paymentTerms!.trim(),
        ),
    ];
    final hsnItems = const <AppSelectItem<String>>[
      AppSelectItem(value: '998346', label: '998346 — Testing services'),
      AppSelectItem(value: '902710', label: '902710 — Instruments'),
    ];
    final dispatchThroughItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'road', label: 'Road'),
      AppSelectItem(value: 'rail', label: 'Rail'),
      AppSelectItem(value: 'air', label: 'Air'),
      AppSelectItem(value: 'courier', label: 'Courier'),
    ];
    final deliveryModeItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'road', label: 'Road'),
      AppSelectItem(value: 'courier', label: 'Courier'),
      AppSelectItem(value: 'hand', label: 'Hand delivery'),
    ];

    final summary = CreateCustomerInvoiceDraft.computeSummary(
      lines: _lines,
      otherCharges: _mockOtherCharges,
      discount: _mockDiscount,
      useIgst: _useIgst,
    );

    final itemLinesInteractive = _fieldsEnabled;

    final sectionInvoice = AppFormSection(
      title: 'Invoice Details',
      child: _invoiceDetailsFields(
        invoiceTypeItems: invoiceTypeItems,
        gstTypeItems: gstTypeItems,
      ),
    );

    final sectionCustomer = AppFormSection(
      title: 'Customer Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: 'Bill To',
            hint: 'Tap to select customer',
            controller: _billToCtrl,
            readOnly: true,
            enabled: !_readOnly,
            size: AppInputSize.md,
            onTap: _readOnly ? null : () => _openBillToDrawer(active),
            suffixIcon: _readOnly
                ? null
                : Icon(
                    LucideIcons.panelRightOpen,
                    size: AppTokens.iconButtonIconSm,
                  ),
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'GST No.',
            controller: _gstNoCtrl,
            readOnly: true,
            size: AppInputSize.md,
          ),
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInput(
                  label: 'State',
                  controller: _stateCtrl,
                  readOnly: true,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AppInput(
                  label: 'Country',
                  controller: _countryCtrl,
                  readOnly: true,
                  size: AppInputSize.md,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Type Of Service',
                  hint: 'Select service',
                  value: _typeOfService,
                  items: serviceItems,
                  size: AppInputSize.md,
                  enabled: _fieldsEnabled,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _typeOfService = v),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Payment Terms',
                  hint: 'Select terms',
                  value: _paymentTerms,
                  items: paymentItems,
                  size: AppInputSize.md,
                  enabled: _fieldsEnabled,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _paymentTerms = v),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppTextarea(
            label: 'Address',
            hint: 'Billing address',
            controller: _addressCtrl,
            enabled: _fieldsEnabled,
            minLines: 4,
            maxLines: 8,
          ),
          SizedBox(height: AppTokens.space3),
          AppTextarea(
            label: 'Ship To',
            hint: 'Shipping address',
            controller: _shipToCtrl,
            enabled: _fieldsEnabled,
            minLines: 4,
            maxLines: 8,
          ),
        ],
      ),
    );

    final sectionFinancial = AppFormSection(
      title: 'Financial Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summaryRow('Line Value', summary.lineValue.toStringAsFixed(2)),
          _summaryRow(
            'Other Charges',
            summary.otherCharges.toStringAsFixed(2),
          ),
          _summaryRow('Discount', summary.discount.toStringAsFixed(2)),
          _summaryRow('CGST', summary.cgst.toStringAsFixed(2)),
          _summaryRow('SGST', summary.sgst.toStringAsFixed(2)),
          _summaryRow('IGST', summary.igst.toStringAsFixed(2)),
          Divider(height: AppTokens.space3, color: AppTokens.borderLight),
          _summaryRow(
            'Grand Total',
            summary.grandTotal.toStringAsFixed(2),
            emphasize: true,
          ),
        ],
      ),
    );

    final sectionRef = AppFormSection(
      title: 'Reference Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInput(
                  label: 'Delivery Note',
                  controller: _deliveryNoteCtrl,
                  enabled: _fieldsEnabled,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Dispatch Through',
                  hint: 'Select mode',
                  value: _dispatchThrough,
                  items: dispatchThroughItems,
                  size: AppInputSize.md,
                  enabled: _fieldsEnabled,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _dispatchThrough = v),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInput(
                  label: 'Buyer Order No.',
                  controller: _buyerOrderCtrl,
                  enabled: _fieldsEnabled,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'HSN/SAC Code',
                  hint: 'Select HSN/SAC',
                  value: _hsnCode,
                  items: hsnItems,
                  size: AppInputSize.md,
                  enabled: _fieldsEnabled,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _hsnCode = v),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _formLabDateField(
                  label: 'Buyer Order Date',
                  hint: 'Select date',
                  value: _buyerOrderDate,
                  enabled: _fieldsEnabled,
                  onDateSelected: (d) => setState(() => _buyerOrderDate = d),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Mode Of Delivery',
                  hint: 'Select mode',
                  value: _modeOfDelivery,
                  items: deliveryModeItems,
                  size: AppInputSize.md,
                  enabled: _fieldsEnabled,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _modeOfDelivery = v),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'Supplier Ref',
            controller: _supplierRefCtrl,
            enabled: _fieldsEnabled,
            size: AppInputSize.md,
          ),
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInput(
                  label: 'Dispatch Document No.',
                  controller: _dispatchDocNoCtrl,
                  enabled: _fieldsEnabled,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: _formLabDateField(
                  label: 'Dispatch Date',
                  hint: 'Select date',
                  value: _dispatchDate,
                  enabled: _fieldsEnabled,
                  onDateSelected: (d) => setState(() => _dispatchDate = d),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppTextarea(
            label: 'Remarks / Narration',
            hint: 'Notes for customer / compliance…',
            controller: _remarksCtrl,
            enabled: _fieldsEnabled,
            minLines: 6,
            maxLines: 14,
          ),
        ],
      ),
    );

    final itemTable = RepaintBoundary(
      child: AppListingScreen<InvoiceItemRowModel>(
        showPageHeader: false,
        title: '',
        subtitle: '',
        showKpis: false,
        showExport: false,
        showImport: false,
        showPrint: false,
        showColumnToggle: false,
        showToolbar: itemLinesInteractive,
        showBulkBar: itemLinesInteractive,
        bulkBarVisibleOnlyWhenSelection: true,
        bulkSelectionSummary: (c) =>
            c == 1 ? '1 Line Selected' : '$c Lines Selected',
        showCheckboxes: itemLinesInteractive,
        bulkRowId: (r) => r.id,
        bulkActions: !itemLinesInteractive || _itemSelectionCount == 0
            ? []
            : _itemBulkActions(),
        onRowSelectionChanged: (indices) {
          setState(() => _itemSelectionCount = indices.length);
        },
        tableScrollableMinWidth: _itemCol * 9 + 88 + AppTokens.space2,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: false,
        disableOuterVerticalScroll: true,
        listingShellPadding: EdgeInsets.zero,
        scaleDataColumnsToFillViewport: true,
        showActionsColumnLeadingBorder: false,
        actionsColumnWidth: 88,
        columns: [
          TableColumn<InvoiceItemRowModel>(
            key: 'labDate',
            label: 'Lab Date',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.labDate.millisecondsSinceEpoch,
            cellBuilder: (r) => Text(
              _formatYmd(r.labDate),
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'labNo',
            label: 'Lab No.',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.labNo.toLowerCase(),
            cellBuilder: (r) => Text(
              r.labNo,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'reportId',
            label: 'Report Id',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.reportId.toLowerCase(),
            cellBuilder: (r) => Text(
              r.reportId,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'sample',
            label: 'Type Of Sample',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.typeOfSample.toLowerCase(),
            cellBuilder: (r) => Text(
              r.typeOfSample,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'rate',
            label: 'Rate',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.rate,
            cellBuilder: (r) {
              final ctrl = _rateByLineId[r.id];
              if (ctrl == null) {
                return const SizedBox.shrink();
              }
              return AppInput(
                key: ValueKey<String>('rate-${r.id}'),
                controller: ctrl,
                size: AppInputSize.sm,
                enabled: _fieldsEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (t) => _updateRate(r.id, t),
              );
            },
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'srNo',
            label: 'Sr No.',
            width: _itemCol - 16,
            sortable: true,
            sortValue: (r) => r.srNo,
            cellBuilder: (r) => Text(
              '${r.srNo}',
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'references',
            label: 'References',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.references.toLowerCase(),
            cellBuilder: (r) => Text(
              r.references,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
          TableColumn<InvoiceItemRowModel>(
            key: 'contact',
            label: 'Contact Person',
            width: _itemCol,
            sortable: true,
            sortValue: (r) => r.contactPerson.toLowerCase(),
            cellBuilder: (r) => Text(
              r.contactPerson,
              style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
            ),
          ),
        ],
        rows: _lines,
        rowActions: [
          RowAction<InvoiceItemRowModel>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) => _snack('View ${row.labNo} (coming soon)'),
          ),
          if (!_isView)
            RowAction<InvoiceItemRowModel>(
              key: 'edit',
              label: 'Edit',
              icon: Icon(
                LucideIcons.pencilLine,
                size: AppTokens.iconButtonIconMd,
              ),
              onTap: (row) => _snack('Edit ${row.labNo} (coming soon)'),
            ),
          RowAction<InvoiceItemRowModel>(
            key: 'pdf',
            label: 'Download PDF',
            icon: Icon(LucideIcons.fileDown, size: AppTokens.iconButtonIconMd),
            onTap: (row) => _snack('PDF ${row.labNo} (coming soon)'),
          ),
          RowAction<InvoiceItemRowModel>(
            key: 'audit',
            label: 'Audit History',
            icon: Icon(LucideIcons.history, size: AppTokens.iconButtonIconMd),
            isEnabled: (_) => !_lineItemActionBusy,
            onTap: _onLineAuditHistory,
          ),
          RowAction<InvoiceItemRowModel>(
            key: 'cn',
            label: 'Generate Credit Note',
            icon: Icon(LucideIcons.banknote, size: AppTokens.iconButtonIconMd),
            isEnabled: (_) => !_lineItemActionBusy,
            onTap: _onLineGenerateCreditNote,
          ),
        ],
        mobileCardBuilder: (r) => ListTile(
          title: Text(r.labNo),
          subtitle: Text(
            '${r.typeOfSample} · ${r.rate.toStringAsFixed(2)} · ${r.references}',
          ),
        ),
        totalCount: _lines.length,
        currentPage: 1,
        pageSize: _lines.isEmpty ? 1 : _lines.length.clamp(1, 100),
        onPageChanged: (_) {},
        onPageSizeChanged: (_) {},
      ),
    );

    final sectionInvoiceItems = AppFormSection(
      title: 'Invoice Items',
      description: _readOnly
          ? 'Invoice line items (read-only).'
          : 'Add pending lab lines with (+). Edit rates — totals update automatically.',
      trailing: itemLinesInteractive
          ? AppIconButton(
              tooltip: 'Add pending lab lines',
              variant: AppIconButtonVariant.outlined,
              icon: Icon(LucideIcons.plus, size: AppTokens.iconButtonIconMd),
              onPressed: _openPendingLabPicker,
            )
          : null,
      child: itemTable,
    );

    final formBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionInvoice,
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppFormPageLayout.sectionsColumn([
                  sectionCustomer,
                  sectionFinancial,
                ]),
              ),
              SizedBox(width: AppTokens.space4),
              Expanded(child: sectionRef),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          sectionInvoiceItems,
        ],
      ),
    );

    final pageTitle =
        _isView ? 'View Customer Invoice' : 'Create Customer Invoice';
    final breadcrumbCurrent = pageTitle;

    final List<Widget> headerActions;
    if (_isView) {
      if (_isEditing) {
        headerActions = [
          AppButton(
            label: 'Cancel Edit',
            variant: AppButtonVariant.tertiary,
            onPressed: _onCancelEdit,
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Save Changes',
            variant: AppButtonVariant.primary,
            onPressed: _onSaveChanges,
          ),
        ];
      } else {
        headerActions = [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.tertiary,
            onPressed: _onCancel,
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Edit Invoice',
            variant: AppButtonVariant.secondary,
            onPressed: _onBeginEdit,
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Download PDF',
            variant: AppButtonVariant.secondary,
            onPressed: _onDownloadPdf,
          ),
        ];
      }
    } else {
      headerActions = [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.tertiary,
          onPressed: _onCancel,
        ),
        SizedBox(width: AppTokens.space2),
        AppButton(
          label: 'Save Draft',
          variant: AppButtonVariant.secondary,
          onPressed: () => _snack('Save draft (UI only)'),
        ),
        SizedBox(width: AppTokens.space2),
        AppButton(
          label: 'Generate Invoice',
          variant: AppButtonVariant.primary,
          onPressed: _onGenerateInvoice,
        ),
      ];
    }

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        plainTabPanel: true,
        rootBreadcrumbLabel: 'Transactions',
        rootBreadcrumbRoute: '/transactions',
        parentLabel: 'Customer Invoice',
        parentRoute: '/transactions/customer-invoice',
        currentLabel: breadcrumbCurrent,
        tabController: null,
        onBreadcrumbBack: _onCancel,
        headerCard: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(name: 'Invoice', size: AppAvatarSize.lg),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pageTitle,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXl,
                      fontWeight: AppTokens.weightBold,
                      color: AppTokens.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Text(
                    _invoiceNoCtrl.text.trim().isEmpty
                        ? _draft.provisionalInvoiceNo
                        : _invoiceNoCtrl.text.trim(),
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textSm,
                      fontWeight: AppTokens.weightRegular,
                      color: AppTokens.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: headerActions,
            ),
          ],
        ),
        tabLabels: const ['Overview'],
        tabViews: [formBody],
      ),
    );
  }
}
