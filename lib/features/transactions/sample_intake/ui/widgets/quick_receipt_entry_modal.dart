import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../state/sample_intake_provider.dart';

/// Lightweight quick receipt capture (dialog).
class QuickReceiptEntryModal extends StatefulWidget {
  const QuickReceiptEntryModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTokens.modalBarrierScrim,
      builder: (ctx) => const QuickReceiptEntryModal(),
    );
  }

  @override
  State<QuickReceiptEntryModal> createState() =>
      _QuickReceiptEntryModalState();
}

class _QuickReceiptEntryModalState extends State<QuickReceiptEntryModal> {
  final _dateCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();
  final _courierCtrl = TextEditingController();
  final _trackingCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');
  final _receivedByCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  String _mode = 'Courier';

  static List<AppSelectItem<String>> get _modeItems => const [
        AppSelectItem(value: 'Courier', label: 'Courier'),
        AppSelectItem(value: 'Hand delivery', label: 'Hand delivery'),
      ];

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _dateCtrl.text =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _customerCtrl.dispose();
    _siteCtrl.dispose();
    _courierCtrl.dispose();
    _trackingCtrl.dispose();
    _countCtrl.dispose();
    _receivedByCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _payload() {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(_dateCtrl.text.trim()) ?? now;
    final n = int.tryParse(_countCtrl.text.trim()) ?? 1;
    return {
      'receiptDate': parsed.toIso8601String(),
      'receiptTime':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'customerName': _customerCtrl.text.trim(),
      'customerCompany': '',
      'customerAddress': '',
      'customerMobile': '',
      'customerEmail': '',
      'siteContactPerson': '',
      'siteCompany': _siteCtrl.text.trim(),
      'siteAddress': '',
      'siteMobile': '',
      'siteEmail': '',
      'reportExpectedBy': null,
      'workOrderNo': '',
      'workOrderDate': null,
      'additionalInformation': null,
      'courierName': _courierCtrl.text.trim(),
      'podNo': _trackingCtrl.text.trim(),
      'noOfSamples': n < 1 ? 1 : n,
      'sampleDispatchedFromSite': false,
      'sampleCollectedFromCollectionCenter': false,
      'sampleReceivedAtCollectionCenter': false,
      'sampleReceivedAtLab': false,
      'freightCharges': null,
      'receivedBy': _receivedByCtrl.text.trim(),
      'quickRemarks': _remarksCtrl.text.trim(),
      'receiptMode': _mode,
    };
  }

  Future<void> _saveDraft(BuildContext context,
      {required bool navigateContinue}) async {
    final p = context.read<SampleIntakeProvider>();
    final id = await p.saveQuickReceipt(_payload());
    if (!context.mounted || id == null) return;
    Navigator.of(context).pop();
    if (navigateContinue) {
      context.push('/transactions/sample-intake/$id/complete');
    }
    await p.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: AppTokens.formModalMaxWidth,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quick receipt entry',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.textLg,
                    fontWeight: AppTokens.weightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                SizedBox(
                  height: (MediaQuery.sizeOf(context).height * 0.45)
                      .clamp(240.0, 520.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppInput(
                          label: 'Receipt date',
                          controller: _dateCtrl,
                          hint: 'YYYY-MM-DD',
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Customer',
                          controller: _customerCtrl,
                          isRequired: true,
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Site',
                          controller: _siteCtrl,
                        ),
                        SizedBox(height: AppTokens.space3),
                        AnchoredSearchableDropdownField<String>(
                          label: 'Receipt mode',
                          value: _mode,
                          items: _modeItems,
                          isSearchable: false,
                          overlayMinimalShadow: true,
                          onChanged: (v) =>
                              setState(() => _mode = v ?? _mode),
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Courier name',
                          controller: _courierCtrl,
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Tracking number',
                          controller: _trackingCtrl,
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Sample count',
                          controller: _countCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Received by',
                          controller: _receivedByCtrl,
                        ),
                        SizedBox(height: AppTokens.space3),
                        AppInput(
                          label: 'Remarks',
                          controller: _remarksCtrl,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Wrap(
                  spacing: AppTokens.space2,
                  runSpacing: AppTokens.space2,
                  alignment: WrapAlignment.end,
                  children: [
                    AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.tertiary,
                      onPressed:
                          p.isLoading ? null : () => Navigator.of(context).pop(),
                    ),
                    AppButton(
                      label: 'Save draft',
                      variant: AppButtonVariant.secondary,
                      onPressed: p.isLoading
                          ? null
                          : () => _saveDraft(context, navigateContinue: false),
                      isLoading: p.isLoading,
                    ),
                    AppButton(
                      label: 'Continue full intake',
                      variant: AppButtonVariant.primary,
                      onPressed: p.isLoading
                          ? null
                          : () => _saveDraft(context, navigateContinue: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
