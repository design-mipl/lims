import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../state/sample_intake_provider.dart';

/// Create Sample Receipt — [AppFormPage] root (header actions only, no sticky footer),
/// [AppFormPageLayout] + [AppFormSection] cards (same structure as [CustomerFormPage] body).
class CreateSampleReceiptPage extends StatefulWidget {
  const CreateSampleReceiptPage({super.key});

  @override
  State<CreateSampleReceiptPage> createState() =>
      _CreateSampleReceiptPageState();
}

class _CreateSampleReceiptPageState extends State<CreateSampleReceiptPage> {
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _receiptDateCtrl.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _receiptTimeCtrl.text =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onProviderChanged);
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

  Future<void> _onSave() async {
    if (!_validate()) return;
    final p = context.read<SampleIntakeProvider>();
    await p.createReceipt(_buildPayload());
    if (!mounted || p.hasError) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/sample-intake');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();

    return AppFormPage(
      title: 'Create Sample Receipt',
      onBack: _onCancel,
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.tertiary,
          onPressed: _onCancel,
        ),
        AppButton(
          label: 'Save',
          variant: AppButtonVariant.primary,
          onPressed: p.isLoading ? null : () => _onSave(),
          isLoading: p.isLoading,
        ),
      ],
      body: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
                  AppFormSection(
                    title: 'Basic Receipt Details',
                    children: [
                      AppInput(
                        label: 'Lot No.',
                        hint: 'Enter lot number',
                        controller: _lotCtrl,
                        isRequired: true,
                        errorText: _lotError,
                        onChanged: (_) {
                          if (_lotError != null) setState(() => _lotError = null);
                        },
                      ),
                      AppInput(
                        label: 'Receipt Date',
                        hint: 'YYYY-MM-DD',
                        controller: _receiptDateCtrl,
                        isRequired: true,
                        errorText: _dateError,
                        onChanged: (_) {
                          if (_dateError != null) {
                            setState(() => _dateError = null);
                          }
                        },
                      ),
                      AppInput(
                        label: 'Receipt Time',
                        hint: 'HH:mm',
                        controller: _receiptTimeCtrl,
                      ),
                      AppInput(
                        label: 'Courier Name',
                        hint: 'Enter courier',
                        controller: _courierCtrl,
                      ),
                      AppInput(
                        label: 'POD No.',
                        hint: 'Enter POD number',
                        controller: _podCtrl,
                      ),
                      AppInput(
                        label: 'No. of Samples',
                        hint: 'Enter number of samples',
                        controller: _noSamplesCtrl,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        errorText: _samplesError,
                        onChanged: (_) {
                          if (_samplesError != null) {
                            setState(() => _samplesError = null);
                          }
                        },
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: 'Customer Details',
                    children: [
                      AppInput(
                        label: 'Customer',
                        hint: 'Enter customer name',
                        controller: _custNameCtrl,
                      ),
                      AppInput(
                        label: 'Company',
                        hint: 'Enter company name',
                        controller: _custCompanyCtrl,
                      ),
                      AppFormFullWidth(
                        child: AppInput(
                          label: 'Address',
                          hint: 'Enter address',
                          controller: _custAddressCtrl,
                        ),
                      ),
                      AppInput(
                        label: 'Mobile',
                        hint: 'Enter mobile',
                        controller: _custMobileCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      AppInput(
                        label: 'Email',
                        hint: 'Enter email',
                        controller: _custEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: 'Sample Movement Tracking',
                    children: [
                      AppFormFullWidth(
                        child: AppToggleSwitch(
                          label: 'Sample Dispatched from Site',
                          value: _dispatchedFromSite,
                          onChanged: (v) => setState(() => _dispatchedFromSite = v),
                        ),
                      ),
                      AppFormFullWidth(
                        child: AppToggleSwitch(
                          label: 'Sample Collected from Collection Center',
                          value: _collectedFromCc,
                          onChanged: (v) => setState(() => _collectedFromCc = v),
                        ),
                      ),
                      AppFormFullWidth(
                        child: AppToggleSwitch(
                          label: 'Sample Received at Collection Center',
                          value: _receivedAtCc,
                          onChanged: (v) => setState(() => _receivedAtCc = v),
                        ),
                      ),
                      AppFormFullWidth(
                        child: AppToggleSwitch(
                          label: 'Sample Received at Lab',
                          value: _receivedAtLab,
                          onChanged: (v) => setState(() => _receivedAtLab = v),
                        ),
                      ),
                    ],
                  ),
                ]),
                right: AppFormPageLayout.sectionsColumn([
                  AppFormSection(
                    title: 'Site Details',
                    children: [
                      AppInput(
                        label: 'Site Contact Person',
                        hint: 'Enter contact name',
                        controller: _siteContactCtrl,
                      ),
                      AppInput(
                        label: 'Company',
                        hint: 'Enter site company',
                        controller: _siteCompanyCtrl,
                      ),
                      AppFormFullWidth(
                        child: AppInput(
                          label: 'Address',
                          hint: 'Enter site address',
                          controller: _siteAddressCtrl,
                        ),
                      ),
                      AppInput(
                        label: 'Mobile',
                        hint: 'Enter mobile',
                        controller: _siteMobileCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      AppInput(
                        label: 'Email',
                        hint: 'Enter email',
                        controller: _siteEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: 'Work & Report Details',
                    children: [
                      AppInput(
                        label: 'Report Expected By',
                        hint: 'YYYY-MM-DD',
                        controller: _reportExpectedCtrl,
                      ),
                      AppInput(
                        label: 'Work Order No.',
                        hint: 'Enter work order number',
                        controller: _workOrderNoCtrl,
                      ),
                      AppInput(
                        label: 'Work Order Date',
                        hint: 'YYYY-MM-DD',
                        controller: _workOrderDateCtrl,
                      ),
                      AppFormFullWidth(
                        child: AppTextarea(
                          label: 'Additional Information',
                          hint: 'Notes for the lab',
                          controller: _additionalCtrl,
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: 'Financial Details',
                    children: [
                      AppInput(
                        label: 'Freight Charges',
                        hint: '0.00',
                        controller: _freightCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ]),
              ),
    );
  }
}
