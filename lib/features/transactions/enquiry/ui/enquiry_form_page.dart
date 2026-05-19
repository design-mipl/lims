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
import '../../sample_intake/ui/widgets/sample_attachment_cell.dart';
import '../../shared/activity_timeline_models.dart';
import '../data/enquiry_api.dart';
import '../data/enquiry_model.dart';
import '../state/enquiry_provider.dart';
import 'widgets/enquiry_sample_test_cards.dart';

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
  final _dateCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _siteContactCtrl = TextEditingController();
  final _siteCompanyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _sampleCountCtrl = TextEditingController(text: '1');
  final _internalCtrl = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedSiteId;
  String _source = 'Email';
  String _typeOfSampleKey = SampleMasterOptions.typeOfSample.first.value;
  List<EnquiryRequestedTestRow> _tests = [];
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

  static const List<AppSelectItem<String>> _catalogTests = [
    AppSelectItem(value: 'FTIR', label: 'FTIR Spectroscopy'),
    AppSelectItem(value: 'ICP', label: 'ICP Metals'),
    AppSelectItem(value: 'viscosity', label: 'Viscosity @ 40°C'),
    AppSelectItem(value: 'tnb', label: 'TBN / TAN'),
    AppSelectItem(value: 'particleCount', label: 'Particle Count ISO'),
    AppSelectItem(value: 'water', label: 'Water / Karl Fischer'),
    AppSelectItem(value: 'ferrography', label: 'Ferrography'),
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

  static String _normalizeTypeKey(String stored) {
    final t = stored.trim();
    if (t.isEmpty) return SampleMasterOptions.typeOfSample.first.value;
    for (final i in SampleMasterOptions.typeOfSample) {
      if (i.value == t || i.label == t) return i.value;
    }
    return t;
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
      final now = DateTime.now();
      _dateCtrl.text =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      _tests = [];
      _attachments = [];
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
    _dateCtrl.text =
        '${d.enquiryDate.year}-${d.enquiryDate.month.toString().padLeft(2, '0')}-${d.enquiryDate.day.toString().padLeft(2, '0')}';
    _companyCtrl.text = d.customerCompany;
    _siteContactCtrl.text = d.siteContactPerson;
    _siteCompanyCtrl.text = d.siteCompany;
    _contactCtrl.text = d.contactPerson;
    _emailCtrl.text = d.contactEmail;
    _phoneCtrl.text = d.contactPhone;
    _typeOfSampleKey = _normalizeTypeKey(d.typeOfSample);
    _sampleCountCtrl.text = '${d.sampleCount}';
    _source = d.enquirySource;
    _internalCtrl.text = d.internalNotes;
    _tests = List<EnquiryRequestedTestRow>.from(d.requestedTests);
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
    _dateCtrl.dispose();
    _companyCtrl.dispose();
    _siteContactCtrl.dispose();
    _siteCompanyCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _sampleCountCtrl.dispose();
    _internalCtrl.dispose();
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

  Future<void> _confirmRemoveSample(EnquiryRequestedTestRow row) async {
    if (_tests.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'At least one sample is required.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      return;
    }
    final ok = await AppConfirmDialog.show(
      context: context,
      title: 'Remove sample?',
      message: 'Are you sure you want to remove this sample?',
      confirmLabel: 'Remove',
      variant: AppConfirmDialogVariant.danger,
    );
    if (ok == true && mounted) {
      setState(() {
        _tests = _tests.where((t) => t.id != row.id).toList();
        _sampleCountCtrl.text = '${_tests.length}';
      });
    }
  }

  Future<void> _showAddSampleDialog() async {
    String? testKey = _catalogTests.first.value;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Add sample test',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textBase,
                  fontWeight: AppTokens.weightSemibold,
                ),
              ),
              content: SizedBox(
                width: 360,
                child: AnchoredSearchableDropdownField<String>(
                  label: 'Test',
                  hint: 'Select test',
                  value: testKey,
                  items: _catalogTests,
                  size: AppInputSize.md,
                  overlayMinimalShadow: true,
                  openOverlayWhenFocused: true,
                  onChanged: (v) => setDialogState(() => testKey = v),
                ),
              ),
              actions: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.tertiary,
                  size: AppButtonSize.sm,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                AppButton(
                  label: 'Add',
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.sm,
                  onPressed: () {
                    if (testKey == null || testKey!.isEmpty) return;
                    final item = _catalogTests.firstWhere(
                      (e) => e.value == testKey,
                      orElse: () => AppSelectItem(
                        value: testKey!,
                        label: testKey!,
                      ),
                    );
                    final id = 'rt-${DateTime.now().millisecondsSinceEpoch}';
                    setState(() {
                      _tests = [
                        ..._tests,
                        EnquiryRequestedTestRow(
                          id: id,
                          testCode: item.value,
                          testName: item.label,
                          selected: true,
                        ),
                      ];
                      final count = int.tryParse(_sampleCountCtrl.text.trim());
                      if (count == null || count < _tests.length) {
                        _sampleCountCtrl.text = '${_tests.length}';
                      }
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime? _parseDate() {
    final parts = _dateCtrl.text.trim().split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (y == null || m == null || day == null) return null;
    try {
      return DateTime(y, m, day);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate(TextEditingController c) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(c.text.trim());
    final current = parsed ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        c.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        if (c == _dateCtrl) {
          _dateError = null;
        }
      });
    }
  }

  Widget _datePickerField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? errorText,
  }) {
    return AppInput(
      label: label,
      hint: hint ?? 'YYYY-MM-DD',
      controller: controller,
      readOnly: true,
      errorText: errorText,
      size: AppInputSize.md,
      onTap: () => _pickDate(controller),
      suffixIcon: Icon(LucideIcons.calendar, size: AppTokens.iconButtonIconSm),
    );
  }

  bool _validate() {
    final dt = _parseDate();
    final count = int.tryParse(_sampleCountCtrl.text.trim());
    setState(() {
      _customerError =
          _selectedCustomerId == null ? 'Customer is required' : null;
      _sampleTypeError =
          _typeOfSampleKey.trim().isEmpty ? 'Sample type is required' : null;
      _countError =
          count == null || count < 1 ? 'Enter a valid sample count' : null;
      _dateError = dt == null ? 'Use YYYY-MM-DD' : null;
    });
    return _customerError == null &&
        _sampleTypeError == null &&
        _countError == null &&
        _dateError == null;
  }

  EnquiryRecord _buildRecord(
    String status,
    List<ActivityTimelineEntry> activity,
    List<CustomerModel> customers,
    List<SiteModel> sites,
  ) {
    final dt = _parseDate() ?? DateTime.now();
    final count = int.parse(_sampleCountCtrl.text.trim());
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
      typeOfSample: _typeOfSampleStoredLabel(),
      sampleCount: count,
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
      expectedTimeline: '',
      samplePriority: 'Normal',
      internalNotes: _internalCtrl.text.trim(),
      attachmentNames: List<String>.from(_attachments),
      requestedTests: List<EnquiryRequestedTestRow>.from(_tests),
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
        _datePickerField(
          label: 'Enquiry Date',
          controller: _dateCtrl,
          hint: 'YYYY-MM-DD',
          errorText: _dateError,
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
        label: '+ Add Samples',
        onPressed: _showAddSampleDialog,
      ),
      children: [
        AppSelect<String>(
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
        AppInput(
          label: 'Sample Count',
          hint: 'Count',
          controller: _sampleCountCtrl,
          keyboardType: TextInputType.number,
          isRequired: true,
          errorText: _countError,
          size: AppInputSize.md,
          onChanged: (_) => setState(() => _countError = null),
        ),
        if (_tests.isNotEmpty)
          AppFormFullWidth(
            child: EnquirySampleTestCards(
              tests: _tests,
              showDelete: true,
              onDelete: _confirmRemoveSample,
            ),
          ),
        AppFormFullWidth(
          child: AppTextarea(
            label: 'Additional Remarks',
            hint: 'Notes…',
            controller: _internalCtrl,
            minLines: 3,
            maxLines: 6,
          ),
        ),
      ],
    );

    final sectionAttachments = AppFormSection(
      title: 'Attachments',
      children: [
        SampleAttachmentCell(
          filename: _attachments.isEmpty ? null : _attachments.first,
          dense: false,
          prefix: 'enquiry',
          onPickMock: (name) => setState(() {
            if (name == null) {
              _attachments = [];
            } else {
              _attachments = [name];
            }
          }),
        ),
      ],
    );

    final overview = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          sectionEnquiryInformation,
          sectionSampleRequirement,
          sectionAttachments,
        ]),
        right: AppFormPageLayout.sectionsColumn([
          sectionCustomerDetails,
          sectionSiteDetails,
        ]),
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
