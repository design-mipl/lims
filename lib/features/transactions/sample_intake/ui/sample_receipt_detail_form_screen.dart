import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/form_read_only_field.dart';
import '../../quotation/ui/widgets/quotation_activity_timeline.dart';
import '../data/sample_intake_model.dart';
import '../sample_intake_synthetic_activity.dart';
import '../state/sample_intake_provider.dart';
import 'widgets/sample_receipt_form_tabs.dart';
import 'widgets/sample_receipt_header_card.dart';

/// Sample Receipt View (`readOnly: true`) or Edit (`readOnly: false`) — Overview + Entry Data.
class SampleReceiptDetailFormScreen extends StatefulWidget {
  const SampleReceiptDetailFormScreen({
    super.key,
    required this.receiptId,
    required this.readOnly,
    this.startInEditMode = false,
  });

  final String receiptId;
  final bool readOnly;

  /// When [readOnly] is true, opens directly in inline edit (same as row **Edit**).
  final bool startInEditMode;

  @override
  State<SampleReceiptDetailFormScreen> createState() =>
      _SampleReceiptDetailFormScreenState();
}

class _SampleReceiptDetailFormScreenState
    extends State<SampleReceiptDetailFormScreen> {
  final _lotCtrl = TextEditingController();
  final _receiptDateCtrl = TextEditingController();
  final _receiptTimeCtrl = TextEditingController();
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
  final _reportExpectedCtrl = TextEditingController();
  final _workOrderNoCtrl = TextEditingController();
  final _workOrderDateCtrl = TextEditingController();
  final _additionalCtrl = TextEditingController();
  final _freightCtrl = TextEditingController();

  bool _dispatchedFromSite = false;
  bool _collectedFromCc = false;
  bool _receivedAtCc = false;
  bool _receivedAtLab = false;

  String? _lotError;
  String? _dateError;
  String? _samplesError;

  SampleIntakeProvider? _provider;
  String _appliedForId = '';

  /// Inline edit session while [widget.readOnly] view route is active.
  bool _editingFromView = false;

  bool get _effectiveReadOnly => widget.readOnly && !_editingFromView;

  static bool _isReceiptWorkflowLocked(SampleIntakeModel r) =>
      r.status == SampleIntakeStatus.completed ||
      r.status == SampleIntakeStatus.forwardedToLab;

  static String _formatDateYmd(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _applyReceipt(SampleIntakeModel r) {
    _lotCtrl.text = r.lotNo;
    _receiptDateCtrl.text = _formatDateYmd(r.receiptDate);
    _receiptTimeCtrl.text = r.receiptTime;
    _courierCtrl.text = r.courierName;
    _podCtrl.text = r.podNo;
    _noSamplesCtrl.text = '${r.noOfSamples}';
    _custNameCtrl.text = r.customerName;
    _custCompanyCtrl.text = r.customerCompany;
    _custAddressCtrl.text = r.customerAddress;
    _custMobileCtrl.text = r.customerMobile;
    _custEmailCtrl.text = r.customerEmail;
    _siteContactCtrl.text = r.siteContactPerson;
    _siteCompanyCtrl.text = r.siteCompany;
    _siteAddressCtrl.text = r.siteAddress;
    _siteMobileCtrl.text = r.siteMobile;
    _siteEmailCtrl.text = r.siteEmail;
    _reportExpectedCtrl.text = _formatDateYmd(r.reportExpectedBy);
    _workOrderNoCtrl.text = r.workOrderNo;
    _workOrderDateCtrl.text = _formatDateYmd(r.workOrderDate);
    _additionalCtrl.text = r.additionalInformation ?? '';
    _freightCtrl.text =
        r.freightCharges == null ? '' : r.freightCharges!.toString();
    _dispatchedFromSite = r.sampleDispatchedFromSite;
    _collectedFromCc = r.sampleCollectedFromCollectionCenter;
    _receivedAtCc = r.sampleReceivedAtCollectionCenter;
    _receivedAtLab = r.sampleReceivedAtLab;
  }

  @override
  void initState() {
    super.initState();
    if (widget.readOnly && widget.startInEditMode) {
      _editingFromView = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onProviderChanged);
      await _provider!.fetchById(widget.receiptId);
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
    _provider?.removeListener(_onProviderChanged);
    _lotCtrl.dispose();
    _receiptDateCtrl.dispose();
    _receiptTimeCtrl.dispose();
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
    _reportExpectedCtrl.dispose();
    _workOrderNoCtrl.dispose();
    _workOrderDateCtrl.dispose();
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

  Future<void> _onSaveDraft() async {
    if (!_validate()) return;
    final p = context.read<SampleIntakeProvider>();
    await p.saveReceiptDraftFromCompleteForm(widget.receiptId, _buildPayload());
    if (!mounted || p.hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Draft saved.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.neutral700,
      ),
    );
  }

  Future<void> _onSaveAndContinue() async {
    if (!_validate()) return;
    final p = context.read<SampleIntakeProvider>();
    await p.saveReceiptAndContinueToQueue(widget.receiptId, _buildPayload());
    if (!mounted || p.hasError) return;
    context.go('/transactions/sample-intake');
  }

  DateTime? _tryParseDate(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return DateTime.tryParse(t);
  }

  Map<String, dynamic> _buildPayload() {
    final report = _tryParseDate(_reportExpectedCtrl.text);
    final woDate = _tryParseDate(_workOrderDateCtrl.text);
    final rcDate = _tryParseDate(_receiptDateCtrl.text) ?? DateTime.now();
    final n = int.tryParse(_noSamplesCtrl.text.trim());
    return {
      'lotNo': _lotCtrl.text.trim(),
      'receiptDate': rcDate.toIso8601String(),
      'receiptTime': _receiptTimeCtrl.text.trim(),
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
      'sampleDispatchedFromSite': _dispatchedFromSite,
      'sampleCollectedFromCollectionCenter': _collectedFromCc,
      'sampleReceivedAtCollectionCenter': _receivedAtCc,
      'sampleReceivedAtLab': _receivedAtLab,
      'freightCharges': _freightCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_freightCtrl.text.trim()),
    };
  }

  bool _validate() {
    setState(() {
      _lotError = _lotCtrl.text.trim().isEmpty ? 'Required' : null;
      _dateError = _tryParseDate(_receiptDateCtrl.text) == null
          ? 'Use YYYY-MM-DD'
          : null;
      final n = int.tryParse(_noSamplesCtrl.text.trim());
      _samplesError = n == null || n < 1 ? 'Enter a positive number' : null;
    });
    return _lotError == null && _dateError == null && _samplesError == null;
  }

  String _yesNo(bool v) => v ? 'Yes' : 'No';

  String _dashIfEmpty(String? s) {
    final t = s?.trim() ?? '';
    return t.isEmpty ? '—' : t;
  }

  Future<void> _cancelInlineViewEdit() async {
    final p = context.read<SampleIntakeProvider>();
    await p.fetchById(widget.receiptId);
    if (!mounted) return;
    setState(() {
      _editingFromView = false;
      _appliedForId = '';
    });
  }

  Future<void> _onSaveInlineViewEdit() async {
    if (!_validate()) return;
    final p = context.read<SampleIntakeProvider>();
    await p.saveReceiptDraftFromCompleteForm(widget.receiptId, _buildPayload());
    if (!mounted || p.hasError) return;
    setState(() {
      _editingFromView = false;
      _appliedForId = '';
    });
    await p.fetchById(widget.receiptId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Changes saved.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.neutral700,
      ),
    );
  }

  Widget _buildReadOnlyView(
    BuildContext context,
    SampleIntakeModel r,
    SampleIntakeProvider p,
  ) {
    final overviewBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Receipt details',
            children: [
              FormReadOnlyField(label: 'Receipt no. (Lot)', value: r.lotNo),
              FormReadOnlyField(
                label: 'Receipt date',
                value: _formatDateYmd(r.receiptDate),
              ),
              FormReadOnlyField(label: 'Receipt time', value: r.receiptTime),
              FormReadOnlyField(
                label: 'Courier / delivery',
                value: r.courierName,
              ),
              FormReadOnlyField(label: 'POD no.', value: r.podNo),
              FormReadOnlyField(
                label: 'Receipt mode',
                value: _dashIfEmpty(r.receiptMode),
              ),
              FormReadOnlyField(
                label: 'Received by',
                value: _dashIfEmpty(r.receivedBy),
              ),
              FormReadOnlyField(
                label: 'Freight charges',
                value: r.freightCharges?.toString(),
              ),
              FormReadOnlyField(
                label: 'Report expected by',
                value: _formatDateYmd(r.reportExpectedBy),
              ),
              FormReadOnlyField(
                label: 'Work order no.',
                value: _dashIfEmpty(r.workOrderNo),
              ),
              FormReadOnlyField(
                label: 'Work order date',
                value: _formatDateYmd(r.workOrderDate),
              ),
              FormReadOnlyField(
                label: 'Additional information',
                value: r.additionalInformation,
              ),
              FormReadOnlyField(
                label: 'Quick remarks',
                value: _dashIfEmpty(r.quickRemarks),
              ),
              FormReadOnlyField(
                label: 'Internal notes',
                value: _dashIfEmpty(r.internalNotes),
              ),
              FormReadOnlyField(
                label: 'Previous lab reference',
                value: _dashIfEmpty(r.previousLabReference),
              ),
              FormReadOnlyField(
                label: 'Dispatched from site',
                value: _yesNo(r.sampleDispatchedFromSite),
              ),
              FormReadOnlyField(
                label: 'Collected from collection center',
                value: _yesNo(r.sampleCollectedFromCollectionCenter),
              ),
              FormReadOnlyField(
                label: 'Received at collection center',
                value: _yesNo(r.sampleReceivedAtCollectionCenter),
              ),
              FormReadOnlyField(
                label: 'Received at lab',
                value: _yesNo(r.sampleReceivedAtLab),
              ),
            ],
          ),
          AppFormSection(
            title: 'Customer details',
            children: [
              FormReadOnlyField(label: 'Customer name', value: r.customerName),
              FormReadOnlyField(
                label: 'Company',
                value: r.customerCompany,
              ),
              FormReadOnlyField(
                label: 'Address',
                value: r.customerAddress,
              ),
              FormReadOnlyField(label: 'Mobile', value: r.customerMobile),
              FormReadOnlyField(label: 'Email', value: r.customerEmail),
            ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Site details',
            children: [
              FormReadOnlyField(
                label: 'Site contact',
                value: r.siteContactPerson,
              ),
              FormReadOnlyField(
                label: 'Site company',
                value: r.siteCompany,
              ),
              FormReadOnlyField(label: 'Site address', value: r.siteAddress),
              FormReadOnlyField(label: 'Site mobile', value: r.siteMobile),
              FormReadOnlyField(label: 'Site email', value: r.siteEmail),
            ],
          ),
          AppFormSection(
            title: 'Sample details',
            children: [
              FormReadOnlyField(
                label: 'No. of samples',
                value: '${r.noOfSamples}',
              ),
              FormReadOnlyField(
                label: 'Type of sample',
                value: _dashIfEmpty(r.typeOfSample),
              ),
              FormReadOnlyField(
                label: 'Primary sample ID',
                value:
                    r.primarySampleId.trim().isEmpty ? null : r.primarySampleId,
              ),
              FormReadOnlyField(
                label: 'Equipment make',
                value: _dashIfEmpty(r.equipmentMake),
              ),
              FormReadOnlyField(
                label: 'Equipment model',
                value: _dashIfEmpty(r.equipmentModel),
              ),
              FormReadOnlyField(
                label: 'Operating conditions',
                value: _dashIfEmpty(r.operatingConditions),
              ),
              FormReadOnlyField(
                label: 'Running hours',
                value: r.receiptRunningHours?.toString(),
              ),
              FormReadOnlyField(
                label: 'Top-up volume',
                value: r.receiptTopUpVolume?.toString(),
              ),
            ],
          ),
          AppFormSection(
            title: 'Datasheet status',
            children: [
              FormReadOnlyField(
                label: 'Data entry progress',
                value:
                    '${r.dataEntryCompletedCount} of ${r.noOfSamples} sample rows completed',
              ),
              FormReadOnlyField(
                label: 'Intake status',
                value: r.status,
              ),
            ],
          ),
          AppFormSection(
            title: 'Lab code status',
            children: [
              FormReadOnlyField(
                label: 'Workflow status',
                value: r.status,
              ),
              FormReadOnlyField(
                label: 'Primary sample ID',
                value:
                    r.primarySampleId.trim().isEmpty ? null : r.primarySampleId,
              ),
              FormReadOnlyField(
                label: 'Intake completed',
                value: _formatDateYmd(r.intakeCompletedAt),
              ),
              FormReadOnlyField(
                label: 'Generated by',
                value: _dashIfEmpty(r.generatedBy),
              ),
            ],
          ),
          AppFormSection(
            title: 'Activity',
            children: [
              QuotationActivityTimeline(
                entries: syntheticSampleIntakeActivity(r),
              ),
            ],
          ),
        ]),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Sample Intake',
        parentRoute: '/transactions/sample-intake',
        currentLabel: r.lotNo,
        tabController: null,
        headerCard: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              name: r.lotNo,
              size: AppAvatarSize.lg,
            ),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.lotNo,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXl,
                      fontWeight: AppTokens.weightBold,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusChip(status: r.status),
                    ],
                  ),
                  SizedBox(height: AppTokens.space2),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space1,
                    children: [
                      _SampleIntakeViewInfoItem(
                        icon: LucideIcons.user,
                        label:
                            '${r.customerName} · ${r.customerCompany}',
                      ),
                      _SampleIntakeViewInfoItem(
                        icon: LucideIcons.mapPin,
                        label: r.siteCompany.isEmpty ? '—' : r.siteCompany,
                      ),
                      _SampleIntakeViewInfoItem(
                        icon: LucideIcons.calendar,
                        label: _formatDateYmd(r.receiptDate),
                      ),
                      _SampleIntakeViewInfoItem(
                        icon: LucideIcons.package,
                        label: '${r.noOfSamples} samples',
                      ),
                      _SampleIntakeViewInfoItem(
                        icon: LucideIcons.listChecks,
                        label:
                            '${r.dataEntryCompletedCount} / ${r.noOfSamples} data entry',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.primary,
                  onPressed: _onCancel,
                ),
                SizedBox(width: AppTokens.space2),
                if (!_isReceiptWorkflowLocked(r))
                  AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => setState(() => _editingFromView = true),
                  ),
              ],
            ),
          ],
        ),
        tabLabels: const ['Overview'],
        tabViews: [
          overviewBody,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();
    final r = p.selected;

    if (r != null &&
        r.id == widget.receiptId &&
        !_effectiveReadOnly &&
        _appliedForId != r.id) {
      _appliedForId = r.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _applyReceipt(r));
      });
    }

    if (p.isLoading && r == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            height: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            child: CircularProgressIndicator(
              strokeWidth: AppTokens.inlineProgressIndicatorStrokeWidth,
              color: AppTokens.primary800,
            ),
          ),
        ),
      );
    }

    if (r == null || r.id != widget.receiptId) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Receipt not found',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              AppButton(
                label: 'Back',
                variant: AppButtonVariant.tertiary,
                onPressed: _onCancel,
              ),
            ],
          ),
        ),
      );
    }

    if (_effectiveReadOnly) {
      return _buildReadOnlyView(context, r, p);
    }

    final overviewTab = SampleReceiptFormTabs.buildMergedOverviewTab(
      readOnly: _effectiveReadOnly,
      lotCtrl: _lotCtrl,
      receiptDateCtrl: _receiptDateCtrl,
      receiptTimeCtrl: _receiptTimeCtrl,
      courierCtrl: _courierCtrl,
      podCtrl: _podCtrl,
      noSamplesCtrl: _noSamplesCtrl,
      custNameCtrl: _custNameCtrl,
      custCompanyCtrl: _custCompanyCtrl,
      custAddressCtrl: _custAddressCtrl,
      custMobileCtrl: _custMobileCtrl,
      custEmailCtrl: _custEmailCtrl,
      siteContactCtrl: _siteContactCtrl,
      siteCompanyCtrl: _siteCompanyCtrl,
      siteAddressCtrl: _siteAddressCtrl,
      siteMobileCtrl: _siteMobileCtrl,
      siteEmailCtrl: _siteEmailCtrl,
      reportExpectedCtrl: _reportExpectedCtrl,
      workOrderNoCtrl: _workOrderNoCtrl,
      workOrderDateCtrl: _workOrderDateCtrl,
      additionalCtrl: _additionalCtrl,
      freightCtrl: _freightCtrl,
      dispatchedFromSite: _dispatchedFromSite,
      collectedFromCc: _collectedFromCc,
      receivedAtCc: _receivedAtCc,
      receivedAtLab: _receivedAtLab,
      onDispatchedFromSite: _effectiveReadOnly
          ? (_) {}
          : (v) => setState(() => _dispatchedFromSite = v),
      onCollectedFromCc: _effectiveReadOnly
          ? (_) {}
          : (v) => setState(() => _collectedFromCc = v),
      onReceivedAtCc: _effectiveReadOnly
          ? (_) {}
          : (v) => setState(() => _receivedAtCc = v),
      onReceivedAtLab: _effectiveReadOnly
          ? (_) {}
          : (v) => setState(() => _receivedAtLab = v),
      lotError: _lotError,
      dateError: _dateError,
      samplesError: _samplesError,
      onLotErrorCleared: _effectiveReadOnly
          ? null
          : (_) => setState(() => _lotError = null),
      onDateErrorCleared: _effectiveReadOnly
          ? null
          : (_) => setState(() => _dateError = null),
      onSamplesErrorCleared: _effectiveReadOnly
          ? null
          : (_) => setState(() => _samplesError = null),
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Sample Intake',
        parentRoute: '/transactions/sample-intake',
        currentLabel: r.lotNo,
        headerCard: SampleReceiptHeaderCard(
          receipt: r,
          readOnly: false,
          viewInlineEditActions: widget.readOnly && _editingFromView,
          isLoading: p.isLoading,
          onCancel:
              widget.readOnly && _editingFromView ? _cancelInlineViewEdit : _onCancel,
          onSaveDraft: widget.readOnly && _editingFromView
              ? _onSaveInlineViewEdit
              : _onSaveDraft,
          onSaveAndContinue:
              widget.readOnly && _editingFromView ? null : _onSaveAndContinue,
        ),
        tabLabels: const ['Overview'],
        tabViews: [
          overviewTab,
        ],
      ),
    );
  }
}

class _SampleIntakeViewInfoItem extends StatelessWidget {
  const _SampleIntakeViewInfoItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppTokens.textSm,
          color: AppTokens.textMuted,
        ),
        SizedBox(width: AppTokens.space1),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            color: AppTokens.textMuted,
            fontWeight: AppTokens.weightRegular,
          ),
        ),
      ],
    );
  }
}
