import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../sample_intake/data/sample_master_options.dart';
import '../../sample_intake/ui/widgets/sample_attachment_cell.dart';
import '../../shared/activity_timeline_models.dart';
import '../data/enquiry_api.dart';
import '../data/enquiry_model.dart';
import '../state/enquiry_provider.dart';

/// Create or edit enquiry — [DetailTemplate] + section layout aligned with Sample Intake create receipt.
class EnquiryFormPage extends StatefulWidget {
  const EnquiryFormPage({super.key, this.enquiryId});

  final String? enquiryId;

  @override
  State<EnquiryFormPage> createState() => _EnquiryFormPageState();
}

class _EnquiryFormPageState extends State<EnquiryFormPage> {
  final _dateCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _siteContactCtrl = TextEditingController();
  final _siteCompanyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _sampleCountCtrl = TextEditingController(text: '1');
  final _equipCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _internalCtrl = TextEditingController();

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
        _applyRecord(d);
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

  void _applyRecord(EnquiryRecord d) {
    _recordId = d.id;
    _enquiryNo = d.enquiryNo;
    _createdBy = d.createdBy;
    _dateCtrl.text =
        '${d.enquiryDate.year}-${d.enquiryDate.month.toString().padLeft(2, '0')}-${d.enquiryDate.day.toString().padLeft(2, '0')}';
    _customerCtrl.text = d.customerName;
    _siteCtrl.text = d.siteName;
    _companyCtrl.text = d.customerCompany;
    _siteContactCtrl.text = d.siteContactPerson;
    _siteCompanyCtrl.text = d.siteCompany;
    _contactCtrl.text = d.contactPerson;
    _emailCtrl.text = d.contactEmail;
    _phoneCtrl.text = d.contactPhone;
    _typeOfSampleKey = _normalizeTypeKey(d.typeOfSample);
    _sampleCountCtrl.text = '${d.sampleCount}';
    _source = d.enquirySource;
    _equipCtrl.text = d.equipmentMakeModel;
    _conditionsCtrl.text = d.operatingConditions;
    _internalCtrl.text = d.internalNotes;
    _tests = List<EnquiryRequestedTestRow>.from(d.requestedTests);
    _attachments = List<String>.from(d.attachmentNames);
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderError);
    _dateCtrl.dispose();
    _customerCtrl.dispose();
    _siteCtrl.dispose();
    _companyCtrl.dispose();
    _siteContactCtrl.dispose();
    _siteCompanyCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _sampleCountCtrl.dispose();
    _equipCtrl.dispose();
    _conditionsCtrl.dispose();
    _internalCtrl.dispose();
    super.dispose();
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
          _customerCtrl.text.trim().isEmpty ? 'Customer is required' : null;
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

  EnquiryRecord _buildRecord(String status, List<ActivityTimelineEntry> activity) {
    final dt = _parseDate() ?? DateTime.now();
    final count = int.parse(_sampleCountCtrl.text.trim());
    return EnquiryRecord(
      id: _recordId!,
      enquiryNo: _enquiryNo ?? sl<EnquiryApi>().allocateEnquiryNo(),
      enquiryDate: dt,
      customerName: _customerCtrl.text.trim(),
      siteName: _siteCtrl.text.trim(),
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
      equipmentMakeModel: _equipCtrl.text.trim(),
      operatingConditions: _conditionsCtrl.text.trim(),
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
    final record = _buildRecord(status, activity);
    await pr.saveEnquiry(record);
    if (!mounted) return;
    context.go('/transactions/enquiry');
  }

  void _onCancel() {
    context.go('/transactions/enquiry');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnquiryProvider>();

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
      children: [
        AppInput(
          label: 'Customer Name',
          hint: 'Customer',
          controller: _customerCtrl,
          isRequired: true,
          errorText: _customerError,
          size: AppInputSize.md,
          onChanged: (_) => setState(() => _customerError = null),
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
        AppInput(
          label: 'Site Name',
          hint: 'Site',
          controller: _siteCtrl,
          size: AppInputSize.md,
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
        AppInput(
          label: 'Equipment Make / Model',
          hint: 'Equipment',
          controller: _equipCtrl,
          size: AppInputSize.md,
        ),
      ],
    );

    final sectionSampleRequirement = AppFormSection(
      title: 'Sample Requirement Information',
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
        AppFormFullWidth(
          child: AppInput(
            label: 'Operating Conditions',
            hint: 'Conditions',
            controller: _conditionsCtrl,
            size: AppInputSize.md,
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
        AppFormFullWidth(
          child: SampleAttachmentCell(
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
        ),
      ],
    );

    final overview = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormPageLayout(
            left: AppFormPageLayout.sectionsColumn([
              sectionEnquiryInformation,
              sectionSampleRequirement,
            ]),
            right: AppFormPageLayout.sectionsColumn([
              sectionCustomerDetails,
              sectionSiteDetails,
            ]),
          ),
          SizedBox(height: AppTokens.space3),
          sectionAttachments,
        ],
      ),
    );

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
