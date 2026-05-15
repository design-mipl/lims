import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../masters/courier_master/data/courier_model.dart';
import '../../../masters/courier_master/state/courier_provider.dart';
import '../../../masters/customer_master/data/customer_model.dart';
import '../../../masters/customer_master/state/customer_provider.dart';
import '../state/sample_intake_provider.dart';

/// Full-page Create Sample Receipt — Lab-style header, sectioned form, master dropdowns.
class CreateSampleReceiptPage extends StatefulWidget {
  const CreateSampleReceiptPage({
    super.key,
    this.prefillEnquiryId,
    this.prefillQuotationId,
  });

  final String? prefillEnquiryId;
  final String? prefillQuotationId;

  @override
  State<CreateSampleReceiptPage> createState() =>
      _CreateSampleReceiptPageState();
}

class _CreateSampleReceiptPageState extends State<CreateSampleReceiptPage> {
  final _lotCtrl = TextEditingController();
  final _courierCtrl = TextEditingController();
  final _podCtrl = TextEditingController();
  final _noSamplesCtrl = TextEditingController();
  final _custNameCtrl = TextEditingController();
  final _custCompanyCtrl = TextEditingController();
  final _custAddressCtrl = TextEditingController();
  final _custMobileCtrl = TextEditingController();
  final _custEmailCtrl = TextEditingController();
  final _siteContactCtrl = TextEditingController();
  final _siteCompanyCtrl = TextEditingController();
  final _siteAddressCtrl = TextEditingController();
  final _siteMobileCtrl = TextEditingController();
  final _siteEmailCtrl = TextEditingController();
  final _workOrderNoCtrl = TextEditingController();
  final _additionalCtrl = TextEditingController();
  final _freightCtrl = TextEditingController();

  DateTime? _receiptDate;
  DateTime? _reportExpectedDate;
  DateTime? _workOrderDate;
  DateTime? _trackDispatchedDate;
  DateTime? _trackCollectedDate;
  DateTime? _trackReceivedCcDate;
  DateTime? _trackReceivedLabDate;

  String? _selectedCustomerId;
  String? _selectedCourierId;
  String? _selectedSiteContactId;

  String? _lotError;
  String? _dateError;
  String? _samplesError;

  SampleIntakeProvider? _provider;

  void _onLotChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _lotCtrl.addListener(_onLotChanged);
    final now = DateTime.now();
    _receiptDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<CustomerProvider>().fetchAll();
      context.read<CourierProvider>().fetchAll();
      final peek = context.read<SampleIntakeProvider>().peekNextLotNo();
      if (_lotCtrl.text.trim().isEmpty) {
        _lotCtrl.text = peek;
      }
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
    _lotCtrl.removeListener(_onLotChanged);
    _provider?.removeListener(_onProviderChanged);
    _lotCtrl.dispose();
    _courierCtrl.dispose();
    _podCtrl.dispose();
    _noSamplesCtrl.dispose();
    _custNameCtrl.dispose();
    _custCompanyCtrl.dispose();
    _custAddressCtrl.dispose();
    _custMobileCtrl.dispose();
    _custEmailCtrl.dispose();
    _siteContactCtrl.dispose();
    _siteCompanyCtrl.dispose();
    _siteAddressCtrl.dispose();
    _siteMobileCtrl.dispose();
    _siteEmailCtrl.dispose();
    _workOrderNoCtrl.dispose();
    _additionalCtrl.dispose();
    _freightCtrl.dispose();
    super.dispose();
  }

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/sample-intake');
    }
  }

  Widget _formLabDateField({
    required String label,
    required String hint,
    required DateTime? value,
    required ValueChanged<DateTime> onDateSelected,
    String? errorText,
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
        ),
        if (errorText != null && errorText.isNotEmpty) ...[
          SizedBox(height: AppTokens.space1),
          Text(
            errorText,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.captionSize,
              fontWeight: AppTokens.captionWeight,
              color: AppTokens.error500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _trackingDateCell({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
          hint: 'Select date',
          selectedDate: value,
          onDateSelected: onSelected,
        ),
      ],
    );
  }

  String _formatCustomerAddress(CustomerModel c) {
    final parts = <String>[
      c.addressLine1 ?? '',
      c.city ?? '',
      c.state ?? '',
      c.pincode ?? '',
    ].where((e) => e.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  ContactPersonModel? _primaryContact(CustomerModel c) {
    if (c.contacts.isEmpty) return null;
    for (final p in c.contacts) {
      if ((p.mobile ?? '').trim().isNotEmpty) return p;
    }
    return c.contacts.first;
  }

  void _applyCustomer(CustomerModel? c) {
    if (c == null) {
      _custNameCtrl.clear();
      _custCompanyCtrl.clear();
      _custAddressCtrl.clear();
      _custMobileCtrl.clear();
      _custEmailCtrl.clear();
      _siteCompanyCtrl.clear();
      _siteAddressCtrl.clear();
      _siteContactCtrl.clear();
      _siteMobileCtrl.clear();
      _siteEmailCtrl.clear();
      _selectedSiteContactId = null;
      return;
    }
    _custNameCtrl.text =
        (c.displayName?.trim().isNotEmpty == true) ? c.displayName! : c.companyName;
    _custCompanyCtrl.text = c.companyName;
    _custAddressCtrl.text = _formatCustomerAddress(c);
    final contact = _primaryContact(c);
    _custMobileCtrl.text = contact?.mobile ?? '';
    _custEmailCtrl.text = contact?.email ?? '';
    _siteCompanyCtrl.text = c.companyName;
    _siteAddressCtrl.text = _formatCustomerAddress(c);
    _selectedSiteContactId = null;
    _siteContactCtrl.clear();
    _siteMobileCtrl.clear();
    _siteEmailCtrl.clear();
  }

  void _onSiteContactSelected(CustomerModel? customer, String? contactId) {
    if (customer == null || contactId == null || contactId.isEmpty) {
      _siteContactCtrl.clear();
      _siteMobileCtrl.clear();
      _siteEmailCtrl.clear();
      return;
    }
    try {
      final p = customer.contacts.firstWhere((e) => e.id == contactId);
      _siteContactCtrl.text = p.name;
      _siteMobileCtrl.text = p.mobile ?? '';
      _siteEmailCtrl.text = p.email ?? '';
    } catch (_) {}
  }

  CustomerModel? _customerById(List<CustomerModel> list, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  CourierModel? _courierById(List<CourierModel> list, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildPayload() {
    final report = _reportExpectedDate;
    final woDate = _workOrderDate;
    final rcDate = _receiptDate ?? DateTime.now();
    final n = int.tryParse(_noSamplesCtrl.text.trim());
    final now = DateTime.now();
    final receiptTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dDisp = _trackDispatchedDate;
    final dCol = _trackCollectedDate;
    final dCc = _trackReceivedCcDate;
    final dLab = _trackReceivedLabDate;
    return {
      'lotNo': _lotCtrl.text.trim(),
      'receiptDate': rcDate.toIso8601String(),
      'receiptTime': receiptTime,
      'courierName': _courierCtrl.text.trim(),
      'podNo': _podCtrl.text.trim(),
      'noOfSamples': n ?? 0,
      'customerName': _custNameCtrl.text.trim(),
      'customerCompany': _custCompanyCtrl.text.trim(),
      'customerAddress': _custAddressCtrl.text.trim(),
      'customerMobile': _custMobileCtrl.text.trim(),
      'customerEmail': _custEmailCtrl.text.trim(),
      'siteContactPerson': _siteContactCtrl.text.trim(),
      'siteCompany': _siteCompanyCtrl.text.trim(),
      'siteAddress': _siteAddressCtrl.text.trim(),
      'siteMobile': _siteMobileCtrl.text.trim(),
      'siteEmail': _siteEmailCtrl.text.trim(),
      'reportExpectedBy': report?.toIso8601String(),
      'workOrderNo': _workOrderNoCtrl.text.trim(),
      'workOrderDate': woDate?.toIso8601String(),
      'additionalInformation': _additionalCtrl.text.trim().isEmpty
          ? null
          : _additionalCtrl.text.trim(),
      'sampleDispatchedFromSite': dDisp != null,
      'sampleCollectedFromCollectionCenter': dCol != null,
      'sampleReceivedAtCollectionCenter': dCc != null,
      'sampleReceivedAtLab': dLab != null,
      if (dDisp != null) 'sampleDispatchedFromSiteAt': dDisp.toIso8601String(),
      if (dCol != null)
        'sampleCollectedFromCollectionCenterAt': dCol.toIso8601String(),
      if (dCc != null)
        'sampleReceivedAtCollectionCenterAt': dCc.toIso8601String(),
      if (dLab != null) 'sampleReceivedAtLabAt': dLab.toIso8601String(),
      'freightCharges': _freightCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_freightCtrl.text.trim()),
    };
  }

  bool _validate() {
    setState(() {
      _lotError = _lotCtrl.text.trim().isEmpty ? 'Required' : null;
      _dateError = _receiptDate == null ? 'Select date' : null;
      final n = int.tryParse(_noSamplesCtrl.text.trim());
      _samplesError = n == null || n < 1 ? 'Enter a positive number' : null;
    });
    return _lotError == null && _dateError == null && _samplesError == null;
  }

  Future<void> _onSave() async {
    if (!_validate()) return;
    final p = context.read<SampleIntakeProvider>();
    final id = await p.saveQuickReceipt(_buildPayload());
    if (!mounted || p.hasError || id == null) return;
    context.go('/transactions/sample-intake/$id/complete');
  }

  Future<void> _onSaveAndContinue() async {
    if (!_validate()) return;
    final p = context.read<SampleIntakeProvider>();
    final id = await p.createReceipt(_buildPayload());
    if (!mounted || p.hasError || id == null) return;
    context.go('/transactions/sample-intake/$id/datasheet');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();
    final customers = context.watch<CustomerProvider>().customers;
    final couriers = context.watch<CourierProvider>().couriers;

    final activeCustomers =
        customers.where((e) => e.status == 'active').toList();
    final customerItems = <AppSelectItem<String>>[
      for (final c in activeCustomers)
        AppSelectItem<String>(value: c.id, label: c.companyName),
    ];

    final activeCouriers =
        couriers.where((e) => e.status == 'active').toList();
    final courierItems = <AppSelectItem<String>>[
      for (final c in activeCouriers)
        AppSelectItem<String>(
          value: c.id,
          label: c.companyName,
          code: c.code,
        ),
    ];

    final selectedCustomer = _customerById(activeCustomers, _selectedCustomerId);
    final siteContactItems = <AppSelectItem<String>>[
      for (final contact in selectedCustomer?.contacts ?? const <ContactPersonModel>[])
        AppSelectItem<String>(value: contact.id, label: contact.name),
    ];
    final showSiteContactSelect =
        selectedCustomer != null && siteContactItems.isNotEmpty;

    final sectionA = AppFormSection(
      title: 'Create Sample Receipt',
      children: [
        AppInput(
          label: 'Lot No.',
          hint: 'Lot number',
          controller: _lotCtrl,
          isRequired: true,
          errorText: _lotError,
          size: AppInputSize.md,
          onChanged: (_) => setState(() => _lotError = null),
        ),
        _formLabDateField(
          label: 'Date',
          hint: 'Select date',
          value: _receiptDate,
          onDateSelected: (d) => setState(() {
            _receiptDate = d;
            _dateError = null;
          }),
          errorText: _dateError,
        ),
        AppSelect<String>(
          label: 'Courier Name',
          hint: 'Select courier',
          value: _selectedCourierId,
          items: courierItems,
          size: AppInputSize.md,
          overlayMinimalShadow: true,
          overlayWidthMatchesTrigger: true,
          onChanged: (id) {
            setState(() {
              _selectedCourierId = id;
              final c = _courierById(activeCouriers, id);
              _courierCtrl.text = c?.companyName ?? '';
            });
          },
        ),
        AppInput(
          label: 'POD No.',
          hint: 'POD number',
          controller: _podCtrl,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'No. of Samples',
          hint: 'Count',
          controller: _noSamplesCtrl,
          keyboardType: TextInputType.number,
          isRequired: true,
          errorText: _samplesError,
          size: AppInputSize.md,
          onChanged: (_) => setState(() => _samplesError = null),
        ),
      ],
    );

    final sectionB = AppFormSection(
      title: 'Customer Details',
      children: [
        AppSelect<String>(
          label: 'Customer',
          hint: 'Select from Customer Master',
          isRequired: false,
          value: _selectedCustomerId,
          items: customerItems,
          size: AppInputSize.md,
          overlayMinimalShadow: true,
          overlayWidthMatchesTrigger: true,
          onChanged: (id) {
            setState(() {
              _selectedCustomerId = id;
              _selectedSiteContactId = null;
              _applyCustomer(_customerById(activeCustomers, id));
            });
          },
        ),
        AppInput(
          label: 'Company',
          hint: 'Company',
          controller: _custCompanyCtrl,
          readOnly: true,
          size: AppInputSize.md,
        ),
        AppFormFullWidth(
          child: AppInput(
            label: 'Address',
            hint: 'Address',
            controller: _custAddressCtrl,
            readOnly: true,
            size: AppInputSize.md,
          ),
        ),
        AppInput(
          label: 'Mobile',
          hint: 'Mobile',
          controller: _custMobileCtrl,
          readOnly: true,
          keyboardType: TextInputType.phone,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'Email Id',
          hint: 'Email',
          controller: _custEmailCtrl,
          readOnly: true,
          keyboardType: TextInputType.emailAddress,
          size: AppInputSize.md,
        ),
      ],
    );

    final sectionC = AppFormSection(
      title: 'Site Details',
      children: [
        if (showSiteContactSelect)
          AppSelect<String>(
            label: 'Site Contact Person',
            hint: 'Select contact',
            value: _selectedSiteContactId,
            items: siteContactItems,
            size: AppInputSize.md,
            overlayMinimalShadow: true,
            overlayWidthMatchesTrigger: true,
            onChanged: (id) {
              setState(() {
                _selectedSiteContactId = id;
                _onSiteContactSelected(selectedCustomer, id);
              });
            },
          )
        else
          AppInput(
            label: 'Site Contact Person',
            hint: selectedCustomer == null
                ? 'Select a customer first'
                : 'Enter contact name',
            controller: _siteContactCtrl,
            enabled: selectedCustomer != null,
            size: AppInputSize.md,
          ),
        AppInput(
          label: 'Company',
          hint: 'Site company',
          controller: _siteCompanyCtrl,
          size: AppInputSize.md,
        ),
        AppFormFullWidth(
          child: AppInput(
            label: 'Address',
            hint: 'Site address',
            controller: _siteAddressCtrl,
            size: AppInputSize.md,
          ),
        ),
        AppInput(
          label: 'Mobile',
          hint: 'Mobile',
          controller: _siteMobileCtrl,
          keyboardType: TextInputType.phone,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'Email Id',
          hint: 'Email',
          controller: _siteEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          size: AppInputSize.md,
        ),
      ],
    );

    final sectionD = AppFormSection(
      title: 'Additional Details',
      children: [
        _formLabDateField(
          label: 'Report Expected By',
          hint: 'Select date',
          value: _reportExpectedDate,
          onDateSelected: (d) => setState(() => _reportExpectedDate = d),
        ),
        _formLabDateField(
          label: 'Work Order Date',
          hint: 'Select date',
          value: _workOrderDate,
          onDateSelected: (d) => setState(() => _workOrderDate = d),
        ),
        AppFormFullWidth(
          child: AppInput(
            label: 'Work Order',
            hint: 'Work order no.',
            controller: _workOrderNoCtrl,
            size: AppInputSize.md,
          ),
        ),
        AppFormFullWidth(
          child: AppTextarea(
            label: 'Additional Information',
            hint: 'Notes…',
            controller: _additionalCtrl,
            minLines: 3,
            maxLines: 6,
          ),
        ),
      ],
    );

    final sectionE = AppFormSection(
      title: 'Sample Tracking Dates',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final oneRow = constraints.maxWidth >= 960;
          Widget cell(
            String label,
            DateTime? value,
            void Function(DateTime) onSel,
          ) {
            return _trackingDateCell(
              label: label,
              value: value,
              onSelected: (d) => setState(() => onSel(d)),
            );
          }

          final c1 = cell(
            'Sample Dispatched from Site',
            _trackDispatchedDate,
            (d) => _trackDispatchedDate = d,
          );
          final c2 = cell(
            'Sample Collected from Collection Center',
            _trackCollectedDate,
            (d) => _trackCollectedDate = d,
          );
          final c3 = cell(
            'Sample Received at Collection Center',
            _trackReceivedCcDate,
            (d) => _trackReceivedCcDate = d,
          );
          final c4 = cell(
            'Sample Received at Lab',
            _trackReceivedLabDate,
            (d) => _trackReceivedLabDate = d,
          );

          if (oneRow) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: c1),
                SizedBox(width: AppTokens.space3),
                Expanded(child: c2),
                SizedBox(width: AppTokens.space3),
                Expanded(child: c3),
                SizedBox(width: AppTokens.space3),
                Expanded(child: c4),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: c1),
                  SizedBox(width: AppTokens.space3),
                  Expanded(child: c2),
                ],
              ),
              SizedBox(height: AppTokens.space3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: c3),
                  SizedBox(width: AppTokens.space3),
                  Expanded(child: c4),
                ],
              ),
            ],
          );
        },
      ),
    );

    final sectionF = AppFormSection(
      title: 'Other Fields',
      children: [
        AppFormFullWidth(
          child: AppInput(
            label: 'Freight Charges',
            hint: 'Amount',
            controller: _freightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            size: AppInputSize.md,
          ),
        ),
      ],
    );

    final formBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormPageLayout(
            left: AppFormPageLayout.sectionsColumn([sectionA]),
            right: AppFormPageLayout.sectionsColumn([sectionB]),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormPageLayout(
            left: AppFormPageLayout.sectionsColumn([sectionC]),
            right: AppFormPageLayout.sectionsColumn([sectionD]),
          ),
          SizedBox(height: AppTokens.space3),
          sectionE,
          SizedBox(height: AppTokens.space3),
          sectionF,
        ],
      ),
    );

    final subtitleLot = _lotCtrl.text.trim().isEmpty
        ? p.peekNextLotNo()
        : _lotCtrl.text.trim();

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.prefillEnquiryId != null ||
              widget.prefillQuotationId != null)
            Material(
              color: AppTokens.info100,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space4,
                  vertical: AppTokens.space3,
                ),
                child: Text(
                  [
                    if (widget.prefillEnquiryId != null)
                      'Linked enquiry: ${widget.prefillEnquiryId}',
                    if (widget.prefillQuotationId != null)
                      'Linked quotation: ${widget.prefillQuotationId}',
                  ].join(' · '),
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySize,
                    color: AppTokens.primary900,
                  ),
                ),
              ),
            ),
          Expanded(
            child: DetailTemplate(
              parentLabel: 'Sample Intake',
              parentRoute: '/transactions/sample-intake',
              currentLabel: 'Create Sample Receipt',
              tabController: null,
              headerCard: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    name: 'Receipt',
                    size: AppAvatarSize.lg,
                  ),
                  SizedBox(width: AppTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Sample Receipt',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textXl,
                            fontWeight: AppTokens.weightBold,
                            color: AppTokens.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: AppTokens.space1),
                        Text(
                          'Lot No. · $subtitleLot',
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
                    children: [
                      AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.tertiary,
                        onPressed: _onCancel,
                      ),
                      SizedBox(width: AppTokens.space2),
                      AppButton(
                        label: 'Save',
                        variant: AppButtonVariant.secondary,
                        onPressed: p.isLoading ? null : _onSave,
                        isLoading: p.isLoading,
                      ),
                      SizedBox(width: AppTokens.space2),
                      AppButton(
                        label: 'Save & Continue',
                        variant: AppButtonVariant.primary,
                        onPressed: p.isLoading ? null : _onSaveAndContinue,
                        isLoading: p.isLoading,
                      ),
                    ],
                  ),
                ],
              ),
              tabLabels: const ['Overview'],
              tabViews: [
                formBody,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
