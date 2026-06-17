import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/order_form_model.dart';
import '../state/create_order_provider.dart';
import 'widgets/order_sample_lines_table.dart';

/// Operational order confirmation form — data sourced from quotation.
class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({
    super.key,
    this.formId,
    this.initialQuotationId,
  });

  final String? formId;
  final String? initialQuotationId;

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _customerPoNoCtrl = TextEditingController();
  final _supplierRefCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  DateTime? _orderDate;
  DateTime? _customerPoDate;
  String? _quotationId;
  String? _dispatchMode;
  bool _hydrated = false;

  static const _dispatchItems = <AppSelectItem<String>>[
    AppSelectItem(value: 'road', label: 'Road'),
    AppSelectItem(value: 'rail', label: 'Rail'),
    AppSelectItem(value: 'air', label: 'Air'),
    AppSelectItem(value: 'courier', label: 'Courier'),
  ];

  static const _statusItems = <AppSelectItem<String>>[
    AppSelectItem(value: OrderFormStatus.draft, label: 'Draft'),
    AppSelectItem(value: OrderFormStatus.confirmed, label: 'Confirmed'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final p = context.read<CreateOrderProvider>();
    if (widget.formId != null && widget.formId!.isNotEmpty) {
      await p.initFromFormId(widget.formId!);
    } else {
      await p.initNew();
    }
    if (!mounted) return;
    _syncFromProvider(p);
  }

  void _syncFromProvider(CreateOrderProvider p) {
    final f = p.form;
    if (f == null) return;
    _orderDate = f.orderDate;
    _customerPoDate = f.customerPoDate;
    _quotationId = f.quotationId.isEmpty ? null : f.quotationId;
    _dispatchMode = f.dispatchMode.isEmpty ? null : f.dispatchMode;
    _customerPoNoCtrl.text = f.customerPoNo;
    _supplierRefCtrl.text = f.supplierRef;
    _remarksCtrl.text = f.remarks;
    setState(() => _hydrated = true);

    final initialQuote = widget.initialQuotationId;
    if (initialQuote != null &&
        initialQuote.isNotEmpty &&
        (_quotationId == null || _quotationId!.isEmpty)) {
      _onQuotationSelected(initialQuote);
    }
  }

  @override
  void dispose() {
    _customerPoNoCtrl.dispose();
    _supplierRefCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  OrderFormRecord? _currentForm(CreateOrderProvider p) => p.form;

  bool _isReadOnly(OrderFormRecord f) => f.status == OrderFormStatus.confirmed;

  void _patchForm(CreateOrderProvider p, OrderFormRecord next) {
    p.patchForm(next);
  }

  OrderFormRecord _formWithLocalFields(OrderFormRecord base) {
    return base.copyWith(
      orderDate: _orderDate ?? base.orderDate,
      customerPoNo: _customerPoNoCtrl.text.trim(),
      customerPoDate: _customerPoDate,
      supplierRef: _supplierRefCtrl.text.trim(),
      dispatchMode: _dispatchMode ?? '',
      remarks: _remarksCtrl.text.trim(),
    );
  }

  Future<void> _onQuotationSelected(String? id) async {
    if (id == null || id.isEmpty) return;
    setState(() => _quotationId = id);
    final p = context.read<CreateOrderProvider>();
    final base = _currentForm(p);
    if (base != null) {
      _patchForm(p, _formWithLocalFields(base));
    }
    await p.applyQuotation(id);
    if (!mounted) return;
    _syncFromProvider(p);
  }

  Future<void> _saveDraft() async {
    final p = context.read<CreateOrderProvider>();
    final base = _currentForm(p);
    if (base == null) return;
    _patchForm(
      p,
      _formWithLocalFields(base).copyWith(status: OrderFormStatus.draft),
    );
    final ok = await p.saveDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Order draft saved.' : (p.error ?? 'Could not save draft.'),
          style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
        ),
        backgroundColor: ok ? null : AppTokens.error500,
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final p = context.read<CreateOrderProvider>();
    final base = _currentForm(p);
    if (base == null) return;
    if (base.quotationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Select a quotation before confirming the order.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      return;
    }
    _patchForm(
      p,
      _formWithLocalFields(base).copyWith(status: OrderFormStatus.confirmed),
    );
    final ok = await p.confirmOrder();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order confirmed — ${p.form?.orderNo ?? ''}.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
        ),
      );
      context.go('/transactions/order');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            p.error ?? 'Could not confirm order.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
    }
  }

  void _convertToSampleIntake() {
    final f = _currentForm(context.read<CreateOrderProvider>());
    if (f == null || f.enquiryNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Confirm the order and link a quotation before sample intake.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
        ),
      );
      return;
    }
      final q = f.quotationId;
    final uri = Uri(
      path: '/transactions/sample-intake/create',
      queryParameters: {
        if (f.enquiryNo.isNotEmpty) 'enquiryId': _enquiryIdFromForm(f),
        if (q.isNotEmpty) 'quotationId': q,
      },
    );
    context.push(uri.toString());
  }

  String _enquiryIdFromForm(OrderFormRecord f) {
    final p = context.read<CreateOrderProvider>();
    final match = p.quotationOptions
        .where((q) => q.id == f.quotationId)
        .map((q) => q.enquiryId)
        .firstOrNull;
    return match ?? '';
  }

  void _onCancel() => context.go('/transactions/order');

  Widget _formLabDateField({
    required String label,
    required String hint,
    required DateTime? value,
    required ValueChanged<DateTime> onDateSelected,
    bool enabled = true,
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
              fontSize: emphasize ? AppTokens.bodySize : AppTokens.textSm,
              fontWeight: emphasize
                  ? AppTokens.weightSemibold
                  : AppTokens.weightRegular,
              color: emphasize ? AppTokens.textPrimary : AppTokens.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: emphasize ? AppTokens.bodySize : AppTokens.textSm,
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

  Widget _readOnlyInput(String label, String value) {
    return AppInput(
      label: label,
      hint: value.isEmpty ? '—' : value,
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: true,
      size: AppInputSize.md,
    );
  }

  /// Three equal columns — Order Details (6 fields → 2 rows × 3).
  Widget _threeColumnFieldGrid(List<Widget> fields) {
    const cols = 3;
    final gap = AppTokens.space3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columnCount = w < 640 ? 1 : (w < 960 ? 2 : cols);

        final rows = <Widget>[];
        for (var i = 0; i < fields.length; i += columnCount) {
          if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
          if (columnCount == 1) {
            rows.add(fields[i]);
            continue;
          }
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < columnCount; c++) ...[
                  if (c > 0) SizedBox(width: gap),
                  Expanded(
                    child: i + c < fields.length
                        ? fields[i + c]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        );
      },
    );
  }

  Widget _commercialSummaryCard(OrderFormRecord f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summaryRow('Total', f.total.toStringAsFixed(2)),
        _summaryRow('Discount', f.discount.toStringAsFixed(2)),
        _summaryRow('GST', f.gstAmount.toStringAsFixed(2)),
        _summaryRow(
          'Freight / Other Charges',
          f.freight.toStringAsFixed(2),
        ),
        Divider(height: AppTokens.space3, color: AppTokens.borderLight),
        _summaryRow(
          'Grand Total',
          f.grandTotal.toStringAsFixed(2),
          emphasize: true,
        ),
      ],
    );
  }

  Widget _stickyAttachmentBar({
    required CreateOrderProvider p,
    required OrderFormRecord f,
    required bool readOnly,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        border: const Border(
          top: BorderSide(color: AppTokens.borderDefault),
        ),
        boxShadow: AppTokens.shadowSm,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space4,
            vertical: AppTokens.space3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _attachButton(
                label: 'Attach Customer PO',
                readOnly: readOnly,
                alignEnd: true,
                fileName: f.customerPoFileName,
                onPressed: () {
                  final name =
                      'customer-po-${DateTime.now().millisecondsSinceEpoch}.pdf';
                  _patchForm(p, f.copyWith(customerPoFileName: name));
                },
              ),
              SizedBox(width: AppTokens.space2),
              _attachButton(
                label: 'Supporting Documents',
                readOnly: readOnly,
                alignEnd: true,
                fileName: f.supportingFileNames.isNotEmpty
                    ? f.supportingFileNames.join(', ')
                    : null,
                onPressed: () {
                  final name =
                      'support-${DateTime.now().millisecondsSinceEpoch}.pdf';
                  _patchForm(
                    p,
                    f.copyWith(
                      supportingFileNames: [
                        ...f.supportingFileNames,
                        name,
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachButton({
    required String label,
    required VoidCallback onPressed,
    required bool readOnly,
    bool alignEnd = false,
    String? fileName,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: label,
          variant: AppButtonVariant.primary,
          size: AppButtonSize.md,
          icon: LucideIcons.paperclip,
          onPressed: readOnly ? null : onPressed,
        ),
        if (fileName != null && fileName.isNotEmpty) ...[
          SizedBox(height: AppTokens.space2),
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              color: AppTokens.primary600,
              decoration: TextDecoration.underline,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CreateOrderProvider>();

    if (!_hydrated || p.isLoading && p.form == null) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final f = p.form;
    final readOnly = f != null && _isReadOnly(f);
    if (f == null) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: Text('Unable to load order form.')),
      );
    }

    final quoteItems = <AppSelectItem<String>>[
      for (final q in p.quotationOptions)
        AppSelectItem<String>(value: q.id, label: q.quoteNo),
    ];

    final orderNoField = AppInput(
      label: 'Order No.',
      controller: TextEditingController(text: f.orderNo),
      readOnly: true,
      enabled: true,
      size: AppInputSize.md,
    );
    final orderDate = _formLabDateField(
      label: 'Order Date',
      hint: 'Select date',
      value: _orderDate,
      enabled: !readOnly,
      onDateSelected: (d) => setState(() => _orderDate = d),
    );
    final quotationField = AnchoredSearchableDropdownField<String>(
      label: 'Quotation No.',
      hint: 'Search quotation',
      value: _quotationId,
      items: quoteItems,
      size: AppInputSize.md,
      enabled: !readOnly,
      overlayMinimalShadow: true,
      overlayWidthMatchesTrigger: true,
      onChanged: _onQuotationSelected,
    );
    final statusField = AnchoredSearchableDropdownField<String>(
      label: 'Status',
      hint: 'Status',
      value: f.status,
      items: _statusItems,
      size: AppInputSize.md,
      enabled: false,
      overlayMinimalShadow: true,
      overlayWidthMatchesTrigger: true,
      onChanged: (_) {},
    );
    final customerPoNo = AppInput(
      label: 'Customer PO No.',
      controller: _customerPoNoCtrl,
      size: AppInputSize.md,
      enabled: !readOnly,
    );
    final customerPoDate = _formLabDateField(
      label: 'Customer PO Date',
      hint: 'Select date',
      value: _customerPoDate,
      enabled: !readOnly,
      onDateSelected: (d) => setState(() => _customerPoDate = d),
    );

    final sectionHeader = AppFormSection(
      title: 'Order Details',
      child: _threeColumnFieldGrid([
        orderNoField,
        orderDate,
        quotationField,
        statusField,
        customerPoNo,
        customerPoDate,
      ]),
    );

    final sectionCustomer = AppFormSection(
      title: 'Customer Details',
      children: [
        _readOnlyInput('Customer Name', f.customerName),
        _readOnlyInput('Site Name', f.siteName),
        _readOnlyInput('Contact Person', f.contactPerson),
        _readOnlyInput('Mobile Number', f.mobile),
        AppFormFullWidth(child: _readOnlyInput('Email', f.email)),
      ],
    );

    final sectionSamples = AppFormSection(
      title: 'Sample / Test Information',
      child: OrderSampleLinesTable(lines: f.sampleLines),
    );

    final sectionCommercial = AppFormSection(
      title: 'Commercial Summary',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
        child: _commercialSummaryCard(f),
      ),
    );

    final sectionReference = AppFormSection(
      title: 'Reference Details',
      children: [
        AppInput(
          label: 'Supplier Ref',
          controller: _supplierRefCtrl,
          size: AppInputSize.md,
          enabled: !readOnly,
        ),
        AnchoredSearchableDropdownField<String>(
          label: 'Dispatch Mode',
          hint: 'Select mode',
          value: _dispatchMode,
          items: _dispatchItems,
          size: AppInputSize.md,
          enabled: !readOnly,
          overlayMinimalShadow: true,
          overlayWidthMatchesTrigger: true,
          onChanged: (v) => setState(() => _dispatchMode = v),
        ),
        AppFormFullWidth(
          child: AppTextarea(
            label: 'Remarks / Narration',
            hint: 'Notes',
            controller: _remarksCtrl,
            enabled: !readOnly,
            minLines: 3,
            maxLines: 6,
          ),
        ),
      ],
    );

    final scrollableForm = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionHeader,
          SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sectionCustomer),
              SizedBox(width: AppTokens.space4),
              Expanded(child: sectionReference),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          sectionSamples,
          SizedBox(height: AppTokens.space3),
          sectionCommercial,
        ],
      ),
    );

    final formBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: scrollableForm),
        _stickyAttachmentBar(p: p, f: f, readOnly: readOnly),
      ],
    );

    final headerActions = <Widget>[
      AppButton(
        label: 'Cancel',
        variant: AppButtonVariant.tertiary,
        onPressed: p.isLoading ? null : _onCancel,
      ),
      SizedBox(width: AppTokens.space2),
      AppButton(
        label: 'Save Draft',
        variant: AppButtonVariant.secondary,
        isLoading: p.isLoading,
        onPressed: readOnly || p.isLoading ? null : _saveDraft,
      ),
      SizedBox(width: AppTokens.space2),
      AppButton(
        label: 'Confirm Order',
        variant: AppButtonVariant.primary,
        isLoading: p.isLoading,
        onPressed: readOnly || p.isLoading ? null : _confirmOrder,
      ),
      SizedBox(width: AppTokens.space2),
      AppButton(
        label: 'Convert to Sample Intake',
        variant: AppButtonVariant.secondary,
        onPressed: _convertToSampleIntake,
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DetailTemplate(
              plainTabPanel: true,
              rootBreadcrumbLabel: 'Transactions',
              rootBreadcrumbRoute: '/transactions',
              parentLabel: 'Order',
              parentRoute: '/transactions/order',
              currentLabel: 'Create order',
              tabController: null,
              onBreadcrumbBack: _onCancel,
              headerCard: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppAvatar(name: 'Order', size: AppAvatarSize.lg),
                  SizedBox(width: AppTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order form',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textXl,
                            fontWeight: AppTokens.weightBold,
                            color: AppTokens.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: AppTokens.space1),
                        Text(
                          f.orderNo,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textSm,
                            color: AppTokens.textMuted,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: headerActions),
                ],
              ),
              tabLabels: const ['Overview'],
              tabViews: [formBody],
            ),
          ),
        ],
      ),
    );
  }
}
