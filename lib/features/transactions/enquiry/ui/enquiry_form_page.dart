import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../masters/customer_master/data/customer_model.dart';
import '../../../masters/customer_master/state/customer_provider.dart';
import '../../../masters/site_master/data/site_model.dart';
import '../../../masters/site_master/state/site_provider.dart';
import '../../sample_intake/data/sample_master_options.dart';
import '../../shared/activity_timeline_models.dart';
import '../data/enquiry_api.dart';
import '../data/enquiry_model.dart';
import '../state/enquiry_provider.dart';
import 'widgets/enquiry_sample_requirements_table.dart';

/// Create or edit enquiry — [DetailTemplate] + section layout aligned with Sample Intake create receipt.
class EnquiryFormPage extends StatefulWidget {
  const EnquiryFormPage({
    super.key,
    this.enquiryId,
    this.inlineEdit = false,
    this.onInlineCancel,
    this.onInlineSaved,
  });

  final String? enquiryId;

  /// When true, renders only the form body (used by [EnquiryDetailScreen] inline edit).
  final bool inlineEdit;
  final VoidCallback? onInlineCancel;
  final VoidCallback? onInlineSaved;

  @override
  State<EnquiryFormPage> createState() => _EnquiryFormPageState();
}

class _EnquiryFormPageState extends State<EnquiryFormPage> {
  DateTime? _enquiryDate;
  DateTime? _expectedTimelineDraft;
  final _companyCtrl = TextEditingController();
  final _siteContactCtrl = TextEditingController();
  final _siteCompanyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _sampleCountCtrl = TextEditingController(text: '1');
  final _sampleRemarksCtrl = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedSiteId;
  String _source = 'Email';
  String _typeOfSampleKey = SampleMasterOptions.typeOfSample.first.value;
  String _samplePriority = 'Normal';
  List<EnquirySampleRequirementRow> _sampleRequirements = [];
  List<String> _attachments = [];

  String? _recordId;
  String? _enquiryNo;
  String _createdBy = 'Current user';

  String? _customerError;
  String? _sampleTypeError;
  String? _countError;
  String? _dateError;

  bool _hydrated = false;
  EnquiryProvider? _provider;

  static const List<String> _sources = ['Email', 'Portal', 'Phone', 'Walk-in'];

  static const List<AppSelectItem<String>> _priorityItems = [
    AppSelectItem(value: 'Normal', label: 'Normal'),
    AppSelectItem(value: 'Critical', label: 'Critical'),
    AppSelectItem(value: 'Urgent', label: 'Urgent'),
  ];

  static List<AppSelectItem<String>> _itemsFrom(List<String> values) =>
      values
          .map((s) => AppSelectItem<String>(value: s, label: s))
          .toList(growable: false);

  List<AppSelectItem<String>> get _typeOfSampleItems {
    final base =
        List<AppSelectItem<String>>.from(SampleMasterOptions.typeOfSample);
    final hasKey =
        base.any((e) => e.value == _typeOfSampleKey || e.label == _typeOfSampleKey);
    if (_typeOfSampleKey.isNotEmpty && !hasKey) {
      base.insert(
        0,
        AppSelectItem<String>(value: _typeOfSampleKey, label: _typeOfSampleKey),
      );
    }
    return base;
  }

  String _typeOfSampleStoredLabel() {
    for (final i in SampleMasterOptions.typeOfSample) {
      if (i.value == _typeOfSampleKey) return i.label;
    }
    return _typeOfSampleKey;
  }

  static String _formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _resetSampleDraftFields() {
    _typeOfSampleKey = SampleMasterOptions.typeOfSample.first.value;
    _sampleCountCtrl.text = '1';
    _expectedTimelineDraft = null;
    _samplePriority = 'Normal';
    _sampleRemarksCtrl.clear();
    _sampleTypeError = null;
    _countError = null;
    _dateError = null;
  }

  bool _validateSampleDraft() {
    final count = int.tryParse(_sampleCountCtrl.text.trim());
    setState(() {
      _sampleTypeError =
          _typeOfSampleKey.trim().isEmpty ? 'Sample type is required' : null;
      _countError =
          count == null || count < 1 ? 'Enter a valid sample count' : null;
    });
    return _sampleTypeError == null && _countError == null;
  }

  void _addSampleRequirement() {
    if (!_validateSampleDraft()) return;
    final count = int.parse(_sampleCountCtrl.text.trim());
    final id = 'sr-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _sampleRequirements = [
        ..._sampleRequirements,
        EnquirySampleRequirementRow(
          id: id,
          typeOfSample: _typeOfSampleStoredLabel(),
          sampleCount: count,
          expectedTimeline: _expectedTimelineDraft == null
              ? ''
              : _formatYmd(_expectedTimelineDraft!),
          priority: _samplePriority,
          remarks: _sampleRemarksCtrl.text.trim(),
        ),
      ];
      _resetSampleDraftFields();
    });
  }

  void _removeSampleRequirement(int index) {
    setState(() {
      final next = List<EnquirySampleRequirementRow>.from(_sampleRequirements)
        ..removeAt(index);
      _sampleRequirements = next;
    });
  }

  static String _normalizeSamplePriority(String stored) {
    const allowed = {'Normal', 'Critical', 'Urgent'};
    final t = stored.trim();
    if (allowed.contains(t)) return t;
    return 'Normal';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final pr = context.read<EnquiryProvider>();
    _provider = pr;
    pr.addListener(_onProviderError);
    if (widget.enquiryId != null) {
      await pr.loadDetail(widget.enquiryId!);
      final d = pr.detail;
      if (!mounted) return;
      if (d != null) {
        final customers = context.read<CustomerProvider>().customers;
        final sites = context.read<SiteProvider>().sites;
        _applyRecord(d, customers: customers, sites: sites);
      }
    } else {
      _enquiryDate = DateTime.now();
      _sampleRequirements = [];
      _attachments = [];
      _resetSampleDraftFields();
      _recordId = 'enq-${DateTime.now().millisecondsSinceEpoch}';
      _enquiryNo = sl<EnquiryApi>().allocateEnquiryNo();
    }
    setState(() => _hydrated = true);
  }

  void _onProviderError() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final message = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTokens.error500,
        ),
      );
      pr.clearError();
    });
  }

  void _applyRecord(
    EnquiryRecord d, {
    List<CustomerModel>? customers,
    List<SiteModel>? sites,
  }) {
    _recordId = d.id;
    _enquiryNo = d.enquiryNo;
    _createdBy = d.createdBy;
    _enquiryDate = d.enquiryDate;
    _companyCtrl.text = d.customerCompany;
    _siteContactCtrl.text = d.siteContactPerson;
    _siteCompanyCtrl.text = d.siteCompany;
    _contactCtrl.text = d.contactPerson;
    _emailCtrl.text = d.contactEmail;
    _phoneCtrl.text = d.contactPhone;
    _source = d.enquirySource;
    _sampleRequirements = List<EnquirySampleRequirementRow>.from(
      d.sampleRequirements,
    );
    if (_sampleRequirements.isEmpty && d.typeOfSample.trim().isNotEmpty) {
      _sampleRequirements = [
        EnquirySampleRequirementRow(
          id: 'sr-legacy-${d.id}',
          typeOfSample: d.typeOfSample,
          sampleCount: d.sampleCount,
          expectedTimeline: d.expectedTimeline,
          priority: _normalizeSamplePriority(d.samplePriority),
        ),
      ];
    }
    _resetSampleDraftFields();
    _attachments = List<String>.from(d.attachmentNames);

    if (customers != null) {
      _selectedCustomerId = _matchCustomerId(customers, d.customerName);
      _applyCustomer(_customerById(customers, _selectedCustomerId));
    }
    if (sites != null) {
      _selectedSiteId = _matchSiteId(sites, d.siteName, _selectedCustomerId);
      _applySite(_siteById(sites, _selectedSiteId));
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderError);
    _companyCtrl.dispose();
    _siteContactCtrl.dispose();
    _siteCompanyCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _sampleCountCtrl.dispose();
    _sampleRemarksCtrl.dispose();
    super.dispose();
  }

  CustomerModel? _customerById(List<CustomerModel> list, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  SiteModel? _siteById(List<SiteModel> list, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String? _matchCustomerId(List<CustomerModel> customers, String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    for (final c in customers) {
      if (c.companyName.toLowerCase() == n) return c.id;
      final d = c.displayName?.trim();
      if (d != null && d.toLowerCase() == n) return c.id;
    }
    return null;
  }

  String? _matchSiteId(
    List<SiteModel> sites,
    String name,
    String? customerId,
  ) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    for (final s in sites) {
      final label = (s.displayName ?? s.code).toLowerCase();
      if (label == n) return s.id;
      if ((s.companyName ?? '').toLowerCase() == n) return s.id;
    }
    if (customerId != null) {
      for (final s in sites) {
        if (s.companyId == customerId) return s.id;
      }
    }
    return null;
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
      _companyCtrl.clear();
      _contactCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      return;
    }
    _companyCtrl.text = c.companyName;
    final contact = _primaryContact(c);
    _contactCtrl.text = contact?.name ?? '';
    _emailCtrl.text = contact?.email ?? '';
    _phoneCtrl.text = contact?.mobile ?? '';
  }

  void _applySite(SiteModel? s) {
    if (s == null) {
      _siteCompanyCtrl.clear();
      _siteContactCtrl.clear();
      return;
    }
    _siteCompanyCtrl.text = s.companyName ?? '';
    _siteContactCtrl.text = s.typeOfContact ?? '';
  }

  String _customerDisplayName(CustomerModel c) {
    final d = c.displayName?.trim();
    if (d != null && d.isNotEmpty) return d;
    return c.companyName;
  }

  String _siteDisplayName(SiteModel s) {
    final d = s.displayName?.trim();
    if (d != null && d.isNotEmpty) return d;
    return s.code;
  }

  List<AppSelectItem<String>> _siteItemsFor(
    List<SiteModel> sites,
    String? customerId,
    CustomerModel? customer,
  ) {
    final active = sites.where((s) => s.status == 'active').toList();
    final filtered = customerId == null
        ? active
        : active.where((s) {
            if (s.companyId == customerId) return true;
            if (customer == null) return false;
            final siteCo = (s.companyName ?? '').trim().toLowerCase();
            return siteCo == customer.companyName.trim().toLowerCase();
          }).toList();

    return [
      for (final s in filtered)
        AppSelectItem<String>(value: s.id, label: _siteDisplayName(s)),
    ];
  }

  Widget _sectionHeaderAction({
    required String label,
    required VoidCallback onPressed,
  }) {
    return AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      size: AppButtonSize.sm,
      onPressed: onPressed,
    );
  }

  Widget _formLabDateField({
    required String label,
    required String hint,
    required DateTime? value,
    required ValueChanged<DateTime> onDateSelected,
    String? errorText,
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

  bool _validate() {
    setState(() {
      _customerError =
          _selectedCustomerId == null ? 'Customer is required' : null;
      _dateError = _enquiryDate == null ? 'Enquiry date is required' : null;
    });
    return _customerError == null && _dateError == null;
  }

  EnquiryRecord _buildRecord(
    String status,
    List<ActivityTimelineEntry> activity,
    List<CustomerModel> customers,
    List<SiteModel> sites,
  ) {
    final dt = _enquiryDate ?? DateTime.now();
    final totalSamples = _sampleRequirements.fold<int>(
      0,
      (sum, r) => sum + r.sampleCount,
    );
    final primary = _sampleRequirements.isNotEmpty
        ? _sampleRequirements.first
        : null;
    final customer = _customerById(customers, _selectedCustomerId);
    final site = _siteById(sites, _selectedSiteId);
    final customerName = customer != null
        ? _customerDisplayName(customer)
        : '';
    final siteName = site != null ? _siteDisplayName(site) : '';

    return EnquiryRecord(
      id: _recordId!,
      enquiryNo: _enquiryNo ?? sl<EnquiryApi>().allocateEnquiryNo(),
      enquiryDate: dt,
      customerName: customerName,
      siteName: siteName,
      enquirySource: _source,
      typeOfSample: primary?.typeOfSample ?? '',
      sampleCount: totalSamples > 0 ? totalSamples : 1,
      status: status,
      createdBy: _createdBy,
      customerCompany: _companyCtrl.text.trim(),
      siteContactPerson: _siteContactCtrl.text.trim(),
      siteCompany: _siteCompanyCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      equipmentMakeModel: '',
      operatingConditions: '',
      urgency: 'Normal',
      expectedTimeline: primary?.expectedTimeline ?? '',
      samplePriority: primary?.priority ?? 'Normal',
      internalNotes: '',
      attachmentNames: List<String>.from(_attachments),
      sampleRequirements: List<EnquirySampleRequirementRow>.from(
        _sampleRequirements,
      ),
      requestedTests: const [],
      activity: activity,
      quotationId: context.read<EnquiryProvider>().detail?.quotationId,
    );
  }

  Future<void> _save(String status) async {
    if (!_validate()) return;
    final pr = context.read<EnquiryProvider>();
    final customers = context.read<CustomerProvider>().customers;
    final sites = context.read<SiteProvider>().sites;
    final existing = pr.detail;
    List<ActivityTimelineEntry> activity;
    if (existing == null) {
      activity = [
        ActivityTimelineEntry(
          id: 'evt-new',
          at: DateTime.now(),
          actorLabel: _createdBy,
          message: 'Draft enquiry created',
        ),
      ];
    } else {
      activity = [
        ...existing.activity,
        ActivityTimelineEntry(
          id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
          at: DateTime.now(),
          actorLabel: _createdBy,
          message: status == EnquiryStatus.submitted
              ? 'Enquiry submitted'
              : 'Draft saved',
        ),
      ];
    }
    final record = _buildRecord(status, activity, customers, sites);
    await pr.saveEnquiry(record);
    if (!mounted) return;
    if (widget.inlineEdit) {
      widget.onInlineSaved?.call();
    } else {
      context.go('/transactions/enquiry');
    }
  }

  void _onCancel() {
    if (widget.inlineEdit) {
      widget.onInlineCancel?.call();
    } else {
      context.go('/transactions/enquiry');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnquiryProvider>();
    final customers = context.watch<CustomerProvider>().customers;
    final sites = context.watch<SiteProvider>().sites;

    if (!_hydrated) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pageTitle =
        widget.enquiryId == null ? 'Create enquiry' : 'Edit enquiry';
    final refLabel = _enquiryNo ?? '';
    final enquiryRefLabel = refLabel.isEmpty ? '—' : refLabel;

    final activeCustomers =
        customers.where((e) => e.status == 'active').toList();
    final customerItems = <AppSelectItem<String>>[
      for (final c in activeCustomers)
        AppSelectItem<String>(
          value: c.id,
          label: _customerDisplayName(c),
        ),
    ];
    final selectedCustomer =
        _customerById(activeCustomers, _selectedCustomerId);
    final siteItems = _siteItemsFor(sites, _selectedCustomerId, selectedCustomer);

    final sectionEnquiryInformation = AppFormSection(
      title: 'Enquiry Information',
      children: [
        _formLabDateField(
          label: 'Enquiry Date',
          hint: 'Select date',
          value: _enquiryDate,
          errorText: _dateError,
          onDateSelected: (d) => setState(() {
            _enquiryDate = d;
            _dateError = null;
          }),
        ),
        AppSelect<String>(
          label: 'Enquiry Source',
          hint: 'Select source',
          value: _source,
          items: _itemsFrom(_sources),
          size: AppInputSize.md,
          overlayMinimalShadow: true,
          overlayWidthMatchesTrigger: true,
          onChanged: (v) => setState(() => _source = v ?? _source),
        ),
      ],
    );

    final sectionCustomerDetails = AppFormSection(
      title: 'Customer Details',
      trailing: _sectionHeaderAction(
        label: '+ Add Customer',
        onPressed: () => context.push('/customers/create'),
      ),
      children: [
        AnchoredSearchableDropdownField<String>(
          label: 'Customer Name',
          hint: 'Select customer',
          value: _selectedCustomerId,
          items: customerItems,
          isRequired: true,
          errorText: _customerError,
          size: AppInputSize.md,
          overlayMinimalShadow: true,
          overlayWidthMatchesTrigger: true,
          openOverlayWhenFocused: true,
          onChanged: (id) {
            setState(() {
              _selectedCustomerId = id;
              _customerError = null;
              _selectedSiteId = null;
              _applyCustomer(_customerById(activeCustomers, id));
              _applySite(null);
            });
          },
        ),
        AppInput(
          label: 'Customer Company',
          hint: 'Company',
          controller: _companyCtrl,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'Contact Person',
          hint: 'Name',
          controller: _contactCtrl,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'Contact Email',
          hint: 'Email',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'Contact Phone',
          hint: 'Phone',
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          size: AppInputSize.md,
        ),
      ],
    );

    final sectionSiteDetails = AppFormSection(
      title: 'Site Details',
      children: [
        AnchoredSearchableDropdownField<String>(
          label: 'Site Name',
          hint: _selectedCustomerId == null
              ? 'Select customer first'
              : 'Select site',
          value: _selectedSiteId,
          items: siteItems,
          enabled: _selectedCustomerId != null,
          size: AppInputSize.md,
          overlayMinimalShadow: true,
          overlayWidthMatchesTrigger: true,
          openOverlayWhenFocused: true,
          onChanged: (id) {
            setState(() {
              _selectedSiteId = id;
              _applySite(_siteById(sites, id));
            });
          },
        ),
        AppInput(
          label: 'Site Company',
          hint: 'Company',
          controller: _siteCompanyCtrl,
          size: AppInputSize.md,
        ),
        AppInput(
          label: 'Site Contact',
          hint: 'Contact',
          controller: _siteContactCtrl,
          size: AppInputSize.md,
        ),
      ],
    );

    final sectionSampleRequirement = AppFormSection(
      title: 'Sample Requirement Information',
      trailing: _sectionHeaderAction(
        label: '+ Add Test',
        onPressed: _addSampleRequirement,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppSelect<String>(
                  label: 'Type of Sample',
                  hint: 'Select type',
                  isRequired: true,
                  errorText: _sampleTypeError,
                  value: _typeOfSampleKey,
                  items: _typeOfSampleItems,
                  size: AppInputSize.md,
                  overlayMinimalShadow: true,
                  overlayWidthMatchesTrigger: true,
                  onChanged: (v) => setState(() {
                    _typeOfSampleKey = v ?? _typeOfSampleKey;
                    _sampleTypeError = null;
                  }),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AppInput(
                  label: 'Sample Count',
                  hint: 'Count',
                  controller: _sampleCountCtrl,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  errorText: _countError,
                  size: AppInputSize.md,
                  onChanged: (_) => setState(() => _countError = null),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: _formLabDateField(
                  label: 'Expected Timeline',
                  hint: 'Select date',
                  value: _expectedTimelineDraft,
                  onDateSelected: (d) =>
                      setState(() => _expectedTimelineDraft = d),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Priority',
                  hint: 'Select priority',
                  value: _samplePriority,
                  items: _priorityItems,
                  size: AppInputSize.md,
                  overlayMinimalShadow: true,
                  openOverlayWhenFocused: true,
                  onChanged: (v) =>
                      setState(() => _samplePriority = v ?? _samplePriority),
                ),
              ),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: AppInput(
                  label: 'Remarks',
                  hint: 'Remarks for this sample type',
                  controller: _sampleRemarksCtrl,
                  size: AppInputSize.md,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          EnquirySampleRequirementsTable(
            rows: _sampleRequirements,
            showDelete: true,
            onDelete: _removeSampleRequirement,
          ),
        ],
      ),
    );

    final attachFileControl = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: 'Attach File',
          variant: AppButtonVariant.primary,
          size: AppButtonSize.md,
          icon: LucideIcons.paperclip,
          onPressed: () => setState(() {
            _attachments = [
              'enquiry-${DateTime.now().millisecondsSinceEpoch}.bin',
            ];
          }),
        ),
        if (_attachments.isNotEmpty) ...[
          SizedBox(height: AppTokens.space2),
          Text(
            _attachments.first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
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

    final overview = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppFormPageLayout.sectionsColumn([
                  sectionEnquiryInformation,
                  sectionSiteDetails,
                ]),
              ),
              SizedBox(width: AppTokens.space4),
              Expanded(child: sectionCustomerDetails),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          sectionSampleRequirement,
          SizedBox(height: AppTokens.space3),
          attachFileControl,
        ],
      ),
    );

    if (widget.inlineEdit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: overview),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.cardBg,
              border: Border(
                top: BorderSide(color: AppTokens.borderDefault),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.tertiary,
                    onPressed: p.isLoading ? null : _onCancel,
                  ),
                  SizedBox(width: AppTokens.space2),
                  AppButton(
                    label: 'Save draft',
                    variant: AppButtonVariant.secondary,
                    onPressed: p.isLoading
                        ? null
                        : () => _save(EnquiryStatus.pending),
                    isLoading: p.isLoading,
                  ),
                  SizedBox(width: AppTokens.space2),
                  AppButton(
                    label: 'Submit',
                    variant: AppButtonVariant.primary,
                    onPressed: p.isLoading
                        ? null
                        : () => _save(EnquiryStatus.submitted),
                    isLoading: p.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DetailTemplate(
              parentLabel: 'Enquiry',
              parentRoute: '/transactions/enquiry',
              currentLabel: pageTitle,
              tabController: null,
              headerCard: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    name: 'EN',
                    size: AppAvatarSize.lg,
                  ),
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
                          'Enquiry No. · $enquiryRefLabel',
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
                        onPressed: p.isLoading ? null : _onCancel,
                      ),
                      SizedBox(width: AppTokens.space2),
                      AppButton(
                        label: 'Save draft',
                        variant: AppButtonVariant.secondary,
                        onPressed: p.isLoading
                            ? null
                            : () => _save(EnquiryStatus.pending),
                        isLoading: p.isLoading,
                      ),
                      SizedBox(width: AppTokens.space2),
                      AppButton(
                        label: 'Submit',
                        variant: AppButtonVariant.primary,
                        onPressed: p.isLoading
                            ? null
                            : () => _save(EnquiryStatus.submitted),
                        isLoading: p.isLoading,
                      ),
                    ],
                  ),
                ],
              ),
              tabLabels: const ['Overview'],
              tabViews: [overview],
            ),
          ),
        ],
      ),
    );
  }
}
