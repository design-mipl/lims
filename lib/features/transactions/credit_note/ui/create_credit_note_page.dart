import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/breakpoints.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/credit_note_invoice_line_model.dart';
import '../state/create_credit_note_provider.dart';

/// **Create Credit Note** — body for route `/transactions/credit-note/create`
/// ([lib/core/router/app_router.dart]). Form is declarative here (no field-config
/// map); dates, selection, and totals use [CreateCreditNoteProvider].
///
/// Same shell and section rhythm as **Create Customer Invoice**;
/// line grid uses **AppListingScreen** (Supervisor Comments listing stack).
class CreateCreditNotePage extends StatefulWidget {
  const CreateCreditNotePage({super.key});

  @override
  State<CreateCreditNotePage> createState() => _CreateCreditNotePageState();
}

class _CreateCreditNotePageState extends State<CreateCreditNotePage> {
  CreateCreditNoteProvider? _provider;

  final _cnNoCtrl = TextEditingController();
  final _billToCtrl = TextEditingController();
  final _gstNoCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _shipToCtrl = TextEditingController();

  final _deliveryNoteCtrl = TextEditingController();
  final _buyerOrderCtrl = TextEditingController();
  final _supplierRefCtrl = TextEditingController();
  final _dispatchDocNoCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  final _otherReferencesCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _referenceInvoiceNoCtrl = TextEditingController();

  final Map<String, TextEditingController> _rateCtrls = {};

  String? _typeOfService;
  String? _paymentTerms;
  String? _notificationChannel;
  String? _regularInvoiceType = 'regular';
  String? _dispatchThrough;
  String? _modeOfDelivery;
  String? _hsnCode;

  /// Avoid rewriting customer [TextEditingController]s on every provider tick (rates/totals).
  String _customerFieldsSyncKey = '';

  bool _prefillFormSynced = false;

  /// Same column width as [CreateCustomerInvoicePage] line grid.
  static const double _itemCol = 120;

  double _embeddedListingHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    final base = AppBreakpoints.isMobileWidth(w) ? 0.52 : 0.40;
    return math.min(580, math.max(300, h * base));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<CreateCreditNoteProvider>();
      _provider = p;
      _cnNoCtrl.text = p.provisionalCreditNoteNo;
      p.addListener(_onProviderError);
      p.addListener(_syncCustomerFields);
      _syncCustomerFields();
      _syncFormFromPrefill(p);
    });
  }

  void _syncFormFromPrefill(CreateCreditNoteProvider p) {
    final pre = p.appliedPrefill;
    if (pre == null || _prefillFormSynced) return;
    _prefillFormSynced = true;
    _billToCtrl.text = pre.customerName;
    _gstNoCtrl.text = pre.gstNo;
    _stateCtrl.text = pre.state;
    _countryCtrl.text = pre.country;
    _pinCodeCtrl.text = pre.pinCode;
    _addressCtrl.text = pre.billToAddress ?? '';
    _shipToCtrl.text = pre.shipToSite ?? '';
    _referenceInvoiceNoCtrl.text = pre.invoiceNo;
    _buyerOrderCtrl.text = pre.buyerOrder;
    _supplierRefCtrl.text = pre.supplierRef;
    _deliveryNoteCtrl.text = pre.deliveryNote;
    _dispatchDocNoCtrl.text = pre.dispatchDocNo;
    _remarksCtrl.text = pre.remarks;
    _otherReferencesCtrl.text = pre.otherReferences;
    _destinationCtrl.text = pre.destination;
    if (pre.gstType != null) {
      p.setGstType(pre.gstType);
    }
    if (pre.creditNoteType != null) {
      p.setCreditNoteType(pre.creditNoteType);
    }
    if (pre.referenceInvoiceDate != null) {
      p.setReferenceInvoiceDate(pre.referenceInvoiceDate);
    }
    if (pre.buyerOrderDate != null) {
      p.setBuyerOrderDate(pre.buyerOrderDate);
    }
    if (pre.dispatchDate != null) {
      p.setDispatchDate(pre.dispatchDate);
    }
  }

  void _onProviderError() {
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

  void _syncCustomerFields() {
    final pr = _provider;
    if (pr == null || !mounted) return;
    _syncFormFromPrefill(pr);
    final row = pr.firstSelectedRow();
    final key = row == null
        ? ''
        : '${row.id}|${row.customer}|${row.site}|${row.invoiceNo}|${row.referenceInvoiceNo}';
    if (key == _customerFieldsSyncKey) return;
    _customerFieldsSyncKey = key;

    if (row == null) {
      _billToCtrl.clear();
      _gstNoCtrl.clear();
      _stateCtrl.clear();
      _countryCtrl.clear();
      _pinCodeCtrl.clear();
      _addressCtrl.clear();
      _shipToCtrl.clear();
      _referenceInvoiceNoCtrl.clear();
      return;
    }
    _billToCtrl.text = row.customer;
    _gstNoCtrl.text = '—';
    _stateCtrl.text = '—';
    _countryCtrl.text = 'India';
    _pinCodeCtrl.text = '400001';
    _addressCtrl.text = '${row.site} — billing address (mock)';
    _shipToCtrl.text = row.site;
    _referenceInvoiceNoCtrl.text = row.referenceInvoiceNo;
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderError);
    _provider?.removeListener(_syncCustomerFields);
    _cnNoCtrl.dispose();
    _billToCtrl.dispose();
    _gstNoCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _addressCtrl.dispose();
    _shipToCtrl.dispose();
    _deliveryNoteCtrl.dispose();
    _buyerOrderCtrl.dispose();
    _supplierRefCtrl.dispose();
    _dispatchDocNoCtrl.dispose();
    _remarksCtrl.dispose();
    _pinCodeCtrl.dispose();
    _otherReferencesCtrl.dispose();
    _destinationCtrl.dispose();
    _referenceInvoiceNoCtrl.dispose();
    for (final c in _rateCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncRateControllers(Set<String> selectedIds) {
    _rateCtrls.removeWhere((id, c) {
      if (!selectedIds.contains(id)) {
        c.dispose();
        return true;
      }
      return false;
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/credit-note');
    }
  }

  String _fmtYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _textCell(String t, {TextAlign align = TextAlign.start}) {
    return Text(
      t,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textPrimary,
      ),
    );
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

  Widget _rateCell(CreditNoteInvoiceLineRow r, CreateCreditNoteProvider p) {
    if (!p.selectedIds.contains(r.id)) {
      return Align(
        alignment: Alignment.centerRight,
        child: _textCell(
          p.resolvedRateForId(r.id).toStringAsFixed(2),
          align: TextAlign.end,
        ),
      );
    }
    final c = _rateCtrls.putIfAbsent(
      r.id,
      () => TextEditingController(text: p.rateFieldText(r.id)),
    );
    return SizedBox(
      height: AppTokens.tableRowHeight,
      child: Align(
        alignment: Alignment.center,
        child: AppInput(
          hint: 'Rate',
          controller: c,
          size: AppInputSize.sm,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => p.setRateText(r.id, v),
        ),
      ),
    );
  }

  Widget _creditNoteDetailsFields(CreateCreditNoteProvider p) {
    SizedBox hGap() => SizedBox(width: AppTokens.space3);

    final cnNo = AppInput(
      label: 'Credit Note No.',
      controller: _cnNoCtrl,
      size: AppInputSize.md,
      enabled: true,
      onChanged: (t) => p.setProvisionalCreditNoteNo(t),
    );
    final cnDate = _formLabDateField(
      label: 'Credit Note Date',
      hint: 'Select date',
      value: p.creditNoteDate,
      enabled: true,
      onDateSelected: p.setCreditNoteDate,
    );
    final cnTypeItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'credit', label: 'Credit Note'),
      AppSelectItem(value: 'debit', label: 'Debit Note'),
      AppSelectItem(value: 'service', label: 'Service Credit'),
    ];
    final cnType = AnchoredSearchableDropdownField<String>(
      label: 'Credit Note Type',
      hint: 'Select type',
      value: p.creditNoteType,
      items: cnTypeItems,
      size: AppInputSize.md,
      enabled: true,
      overlayMinimalShadow: true,
      onChanged: p.setCreditNoteType,
    );
    final gstTypeItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'intra', label: 'Registered (Intra-state)'),
      AppSelectItem(value: 'inter', label: 'Registered (Inter-state / IGST)'),
      AppSelectItem(value: 'unreg', label: 'Unregistered'),
    ];
    final gstType = AnchoredSearchableDropdownField<String>(
      label: 'GST Type',
      hint: 'Select GST type',
      value: p.gstType,
      items: gstTypeItems,
      size: AppInputSize.md,
      enabled: true,
      overlayMinimalShadow: true,
      onChanged: p.setGstType,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final useTwoRows = w < 720;
        if (useTwoRows) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cnNo),
                  hGap(),
                  Expanded(child: cnDate),
                ],
              ),
              SizedBox(height: AppTokens.space2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cnType),
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
            Expanded(child: cnNo),
            hGap(),
            Expanded(child: cnDate),
            hGap(),
            Expanded(child: cnType),
            hGap(),
            Expanded(child: gstType),
          ],
        );
      },
    );
  }

  List<TableColumn<CreditNoteInvoiceLineRow>> _tableColumns(
    CreateCreditNoteProvider p,
  ) {
    return [
      TableColumn<CreditNoteInvoiceLineRow>(
        key: 'labDate',
        label: 'Lab Date',
        width: _itemCol,
        sortable: true,
        sortValue: (r) => r.labDate.millisecondsSinceEpoch,
        cellBuilder: (r) => _textCell(_fmtYmd(r.labDate)),
      ),
      TableColumn<CreditNoteInvoiceLineRow>(
        key: 'labNo',
        label: 'Lab No.',
        width: _itemCol,
        sortable: true,
        sortValue: (r) => r.labNo.toLowerCase(),
        cellBuilder: (r) => _textCell(r.labNo),
      ),
      TableColumn<CreditNoteInvoiceLineRow>(
        key: 'reportId',
        label: 'Report Id',
        width: _itemCol,
        sortable: true,
        sortValue: (r) => r.reportId.toLowerCase(),
        cellBuilder: (r) => _textCell(r.reportId),
      ),
      TableColumn<CreditNoteInvoiceLineRow>(
        key: 'type',
        label: 'Type Of Sample',
        width: _itemCol,
        sortable: true,
        sortValue: (r) => r.typeOfSample.toLowerCase(),
        cellBuilder: (r) => _textCell(r.typeOfSample),
      ),
      TableColumn<CreditNoteInvoiceLineRow>(
        key: 'rate',
        label: 'Rate',
        width: _itemCol,
        numeric: true,
        sortable: true,
        sortValue: (r) => p.resolvedRateForId(r.id),
        cellBuilder: (r) => _rateCell(r, p),
      ),
      TableColumn<CreditNoteInvoiceLineRow>(
        key: 'inv',
        label: 'Invoice No.',
        width: _itemCol,
        sortable: true,
        sortValue: (r) => r.invoiceNo.toLowerCase(),
        cellBuilder: (r) => _textCell(r.invoiceNo),
      ),
    ];
  }

  Widget _buildHeaderCard(BuildContext context, CreateCreditNoteProvider p) {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Credit Note',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textXl,
            fontWeight: AppTokens.weightBold,
            color: AppTokens.textPrimary,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: AppTokens.space1),
        ListenableBuilder(
          listenable: _cnNoCtrl,
          builder: (context, _) {
            final no = _cnNoCtrl.text.trim();
            return Text(
              'Credit Note No.: ${no.isEmpty ? p.provisionalCreditNoteNo : no}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.textSm,
                fontWeight: AppTokens.weightRegular,
                color: AppTokens.textMuted,
                decoration: TextDecoration.none,
              ),
            );
          },
        ),
        SizedBox(height: AppTokens.spaceHalf),
        Text(
          'Linked Invoice No.: ${p.linkedInvoiceNo}',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            fontWeight: AppTokens.weightRegular,
            color: AppTokens.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: AppTokens.space2,
      runSpacing: AppTokens.space2,
      alignment: WrapAlignment.end,
      children: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.tertiary,
          size: AppButtonSize.md,
          onPressed: _back,
        ),
        AppButton(
          label: 'Save Draft',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: () async {
            await p.saveDraft();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Draft saved (mock)',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySize,
                    color: AppTokens.white,
                  ),
                ),
                backgroundColor: AppTokens.neutral700,
              ),
            );
          },
        ),
        AppButton(
          label: 'Generate Credit Note',
          variant: AppButtonVariant.primary,
          size: AppButtonSize.md,
          onPressed: () async {
            p.setProvisionalCreditNoteNo(_cnNoCtrl.text);
            final id = await p.generateCreditNote();
            if (!context.mounted || id == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Credit note $id created (mock).',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySize,
                    color: AppTokens.white,
                  ),
                ),
                backgroundColor: AppTokens.primary800,
              ),
            );
            context.go('/transactions/credit-note/$id/view');
          },
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 720;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(name: 'CN', size: AppAvatarSize.lg),
                  SizedBox(width: AppTokens.space3),
                  Expanded(child: titleColumn),
                ],
              ),
              SizedBox(height: AppTokens.space3),
              Align(
                alignment: Alignment.centerRight,
                child: actions,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(name: 'CN', size: AppAvatarSize.lg),
            SizedBox(width: AppTokens.space3),
            Expanded(child: titleColumn),
            actions,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CreateCreditNoteProvider>();
    final columns = _tableColumns(p);

    final serviceItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'lab', label: 'Laboratory Testing'),
      AppSelectItem(value: 'field', label: 'Field Service'),
      AppSelectItem(value: 'consult', label: 'Consulting'),
    ];
    final paymentItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'net30', label: 'Net 30'),
      AppSelectItem(value: 'net15', label: 'Net 15'),
      AppSelectItem(value: 'advance', label: 'Advance'),
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
    final hsnItems = const <AppSelectItem<String>>[
      AppSelectItem(value: '998346', label: '998346 — Testing services'),
      AppSelectItem(value: '902710', label: '902710 — Instruments'),
    ];
    final notificationItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'email', label: 'Email'),
      AppSelectItem(value: 'sms', label: 'SMS'),
      AppSelectItem(value: 'whatsapp', label: 'WhatsApp'),
      AppSelectItem(value: 'none', label: 'None'),
    ];
    final invoiceTypeItems = const <AppSelectItem<String>>[
      AppSelectItem(value: 'regular', label: 'Regular Invoice'),
      AppSelectItem(value: 'export', label: 'Export Invoice'),
      AppSelectItem(value: 'sez', label: 'SEZ Invoice'),
    ];

    final sectionCreditNoteDetails = AppFormSection(
      title: 'Credit Note Details',
      child: _creditNoteDetailsFields(p),
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
            enabled: true,
            size: AppInputSize.md,
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'GST No.',
            controller: _gstNoCtrl,
            readOnly: true,
            enabled: true,
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
                  enabled: true,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AppInput(
                  label: 'Country',
                  controller: _countryCtrl,
                  readOnly: true,
                  enabled: true,
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
                child: AppInput(
                  label: 'PinCode',
                  controller: _pinCodeCtrl,
                  readOnly: true,
                  enabled: true,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Notification',
                  hint: 'Select channel',
                  value: _notificationChannel,
                  items: notificationItems,
                  size: AppInputSize.md,
                  enabled: true,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _notificationChannel = v),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Invoice Type',
                  hint: 'Select type',
                  value: _regularInvoiceType,
                  items: invoiceTypeItems,
                  size: AppInputSize.md,
                  enabled: true,
                  overlayMinimalShadow: true,
                  onChanged: (v) => setState(() => _regularInvoiceType = v),
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
                  enabled: true,
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
                  enabled: true,
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
            readOnly: true,
            enabled: true,
            minLines: 4,
            maxLines: 8,
          ),
          SizedBox(height: AppTokens.space3),
          AppTextarea(
            label: 'Ship To',
            hint: 'Shipping address',
            controller: _shipToCtrl,
            readOnly: true,
            enabled: true,
            minLines: 4,
            maxLines: 8,
          ),
        ],
      ),
    );

    final sectionReference = AppFormSection(
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
                  enabled: true,
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
                  enabled: true,
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
                  enabled: true,
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
                  enabled: true,
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
                  value: p.buyerOrderDate,
                  enabled: true,
                  onDateSelected: p.setBuyerOrderDate,
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
                  enabled: true,
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
            enabled: true,
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
                  enabled: true,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: _formLabDateField(
                  label: 'Dispatch Date',
                  hint: 'Select date',
                  value: p.dispatchDate,
                  enabled: true,
                  onDateSelected: p.setDispatchDate,
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
                  label: 'Other Reference(s)',
                  controller: _otherReferencesCtrl,
                  enabled: true,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AppInput(
                  label: 'Destination',
                  controller: _destinationCtrl,
                  enabled: true,
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
                child: AppInput(
                  label: 'Reference Invoice No.',
                  controller: _referenceInvoiceNoCtrl,
                  enabled: true,
                  size: AppInputSize.md,
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: _formLabDateField(
                  label: 'Reference Invoice Date',
                  hint: 'Select date',
                  value: p.referenceInvoiceDate,
                  enabled: true,
                  onDateSelected: p.setReferenceInvoiceDate,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppTextarea(
            label: 'Remarks / Narration',
            hint: 'Notes for customer / compliance…',
            controller: _remarksCtrl,
            enabled: true,
            minLines: 6,
            maxLines: 14,
          ),
        ],
      ),
    );

    final sectionFinancial = AppFormSection(
      title: 'Financial Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summaryRow('Line Value', p.lineValueSelected.toStringAsFixed(2)),
          _summaryRow('Other Charges', p.otherCharges.toStringAsFixed(2)),
          _summaryRow('Discount', p.discount.toStringAsFixed(2)),
          _summaryRow('CGST', p.cgst.toStringAsFixed(2)),
          _summaryRow('SGST', p.sgst.toStringAsFixed(2)),
          _summaryRow('IGST', p.igst.toStringAsFixed(2)),
          Divider(height: AppTokens.space3, color: AppTokens.borderLight),
          _summaryRow(
            'Grand Total',
            p.grandTotal.toStringAsFixed(2),
            emphasize: true,
          ),
        ],
      ),
    );

    final w = MediaQuery.sizeOf(context).width;
    final useBoundedTablePane = !AppBreakpoints.isMobileWidth(w);

    final listingChild = AppListingScreen<CreditNoteInvoiceLineRow>(
      showPageHeader: false,
      title: '',
      subtitle: '',
      showKpis: false,
      showExport: false,
      showImport: false,
      showPrint: false,
      showColumnToggle: false,
      showBulkBar: true,
      bulkBarVisibleOnlyWhenSelection: true,
      bulkSelectionSummary: (c) =>
          c == 1 ? '1 Line Selected' : '$c Lines Selected',
      showTableHorizontalScrollbar: true,
      tableBodyFillsViewport: useBoundedTablePane,
      disableOuterVerticalScroll: true,
      listingShellPadding: EdgeInsets.zero,
      scaleDataColumnsToFillViewport: true,
      showActionsColumnLeadingBorder: false,
      tableScrollableMinWidth: _itemCol * 6 + 88 + AppTokens.space2,
      searchHint: 'Lab no., invoice, report id…',
      onSearch: p.setSearchQuery,
      toolbarAfterSearch: [
        SizedBox(width: AppTokens.space2),
        Tooltip(
          message: 'Refresh',
          child: IconButton(
            onPressed: p.refreshListing,
            icon: Icon(
              LucideIcons.refreshCw,
              size: AppTokens.iconButtonIconMd,
            ),
          ),
        ),
      ],
      showCheckboxes: true,
      bulkRowId: (r) => r.id,
      onRowSelectionChanged: (idx) {
        p.onRowSelectionChanged(idx, p.pagedRows);
        _syncRateControllers(p.selectedIds);
      },
      bulkActions: [
        BulkAction<CreditNoteInvoiceLineRow>(
          key: 'remove',
          label: 'Remove from billing',
          icon: Icon(
            LucideIcons.circleMinus,
            size: AppTokens.iconButtonIconSm,
          ),
          onTap: (_) {
            final n = p.removeSelectedFromBilling();
            _syncRateControllers(p.selectedIds);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  n == 0
                      ? 'No rows removed'
                      : '$n row(s) returned to uninvoiced pool (mock)',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySize,
                    color: AppTokens.white,
                  ),
                ),
                backgroundColor: AppTokens.primary800,
              ),
            );
          },
        ),
      ],
      columns: columns,
      rows: p.pagedRows,
      mobileCardBuilder: (r) => Text(r.labNo),
      isLoading: false,
      totalCount: p.totalFilteredCount,
      currentPage: p.effectivePage,
      pageSize: CreateCreditNoteProvider.kPageSize,
      onPageChanged: p.setPage,
      onPageSizeChanged: p.setPageSize,
      emptyMessage: 'No lines loaded yet',
    );

    final itemTable = RepaintBoundary(
      child: useBoundedTablePane
          ? SizedBox(
              height: _embeddedListingHeight(context),
              child: listingChild,
            )
          : listingChild,
    );

    final sectionItems = AppFormSection(
      title: 'Credit Note Items',
      description:
          'Lines appear here when loaded from billing. Select rows to credit; adjust rates when selected.',
      child: itemTable,
    );

    final formBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionCreditNoteDetails,
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppFormPageLayout.sectionsColumn([
                  sectionCustomer,
                ]),
              ),
              SizedBox(width: AppTokens.space4),
              Expanded(child: sectionReference),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          sectionFinancial,
          SizedBox(height: AppTokens.space3),
          sectionItems,
        ],
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        plainTabPanel: true,
        rootBreadcrumbLabel: 'Transactions',
        rootBreadcrumbRoute: '/transactions',
        parentLabel: 'Credit Note',
        parentRoute: '/transactions/credit-note',
        currentLabel: 'Create Credit Note',
        tabController: null,
        onBreadcrumbBack: _back,
        headerCard: _buildHeaderCard(context, p),
        tabLabels: const ['Overview'],
        tabViews: [formBody],
      ),
    );
  }
}
