import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/breakpoints.dart';
import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../state/sample_intake_provider.dart';

/// Receipt Tracking — compact create form in a right-edge [AppFormDrawer].
abstract final class ReceiptTrackingCreateDrawer {
  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppTokens.neutral900.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        final panelW = _panelWidth(ctx);
        return Align(
          alignment: Alignment.centerRight,
          child: SafeArea(
            child: Material(
              elevation: AppTokens.space0,
              color: AppTokens.cardBg,
              child: SizedBox(
                width: panelW,
                height: MediaQuery.sizeOf(ctx).height,
                child: const _ReceiptTrackingCreateDrawerHost(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  static double _panelWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isDesktopWidth(w)) {
      return w < AppTokens.formDrawerWidthDesktop
          ? w
          : AppTokens.formDrawerWidthDesktop;
    }
    return w;
  }
}

class _ReceiptTrackingCreateDrawerHost extends StatefulWidget {
  const _ReceiptTrackingCreateDrawerHost();

  @override
  State<_ReceiptTrackingCreateDrawerHost> createState() =>
      _ReceiptTrackingCreateDrawerHostState();
}

class _ReceiptTrackingCreateDrawerHostState
    extends State<_ReceiptTrackingCreateDrawerHost> {
  final _customerCtrl = TextEditingController();
  final _dockerNumberCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  DateTime? _receiptDate;
  TimeOfDay _receiptTime = TimeOfDay.now();

  String? _customerError;
  String? _dateError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _receiptDate = DateTime(now.year, now.month, now.day);
    _receiptTime = TimeOfDay.fromDateTime(now);
    _syncTimeField();
  }

  void _syncTimeField() {
    _timeCtrl.text =
        '${_receiptTime.hour.toString().padLeft(2, '0')}:${_receiptTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _dockerNumberCtrl.dispose();
    _remarkCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
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

  Widget _formTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Time',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.fieldLabelSize,
            fontWeight: AppTokens.fieldLabelWeight,
            color: AppTokens.labelColor,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: AppTokens.space1),
        AppInput(
          hint: 'HH:mm',
          controller: _timeCtrl,
          readOnly: true,
          size: AppInputSize.md,
          onTap: _pickTime,
          suffixIcon: Icon(
            LucideIcons.clock,
            size: AppTokens.iconButtonIconSm,
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _receiptTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTokens.primary600,
              onPrimary: AppTokens.white,
              surface: AppTokens.cardBg,
              onSurface: AppTokens.textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _receiptTime = picked;
        _syncTimeField();
      });
    }
  }

  bool _validate() {
    var ok = true;
    setState(() {
      _customerError =
          _customerCtrl.text.trim().isEmpty ? 'Customer name is required' : null;
      _dateError = _receiptDate == null ? 'Date is required' : null;
      if (_customerError != null || _dateError != null) {
        ok = false;
      }
    });
    return ok;
  }

  Map<String, dynamic> _payload() {
    final date = _receiptDate ?? DateTime.now();
    final time =
        '${_receiptTime.hour.toString().padLeft(2, '0')}:${_receiptTime.minute.toString().padLeft(2, '0')}';
    return {
      'receiptDate': date.toIso8601String(),
      'receiptTime': time,
      'customerName': _customerCtrl.text.trim(),
      'customerCompany': '',
      'customerAddress': '',
      'customerMobile': '',
      'customerEmail': '',
      'siteContactPerson': '',
      'siteCompany': '',
      'siteAddress': '',
      'siteMobile': '',
      'siteEmail': '',
      'reportExpectedBy': null,
      'workOrderNo': '',
      'workOrderDate': null,
      'additionalInformation': null,
      'courierName': '',
      'podNo': _dockerNumberCtrl.text.trim(),
      'noOfSamples': 1,
      'sampleDispatchedFromSite': false,
      'sampleCollectedFromCollectionCenter': false,
      'sampleReceivedAtCollectionCenter': false,
      'sampleReceivedAtLab': false,
      'freightCharges': null,
      'receivedBy': '',
      'quickRemarks': _remarkCtrl.text.trim(),
      'receiptMode': 'Courier',
    };
  }

  Future<void> _onSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    final p = context.read<SampleIntakeProvider>();
    await p.saveQuickReceipt(_payload());
    if (!mounted) return;
    setState(() => _submitting = false);
    if (p.hasError) return;
    Navigator.of(context).pop();
    await p.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDrawer(
      title: 'Create Receipt',
      subtitle: 'Receipt tracking',
      cancelLabel: 'Cancel',
      primaryLabel: 'Submit',
      onCancel: () => Navigator.of(context).maybePop(),
      onPrimary: _onSubmit,
      isPrimaryLoading: _submitting,
      body: AppFormSection(
        title: 'Receipt Details',
        children: [
          AppInput(
            label: 'Customer Name',
            hint: 'Enter customer name',
            controller: _customerCtrl,
            isRequired: true,
            errorText: _customerError,
            size: AppInputSize.md,
            onChanged: (_) {
              if (_customerError != null) {
                setState(() => _customerError = null);
              }
            },
          ),
          AppInput(
            label: 'Docker Number',
            hint: 'Enter docker number',
            controller: _dockerNumberCtrl,
            size: AppInputSize.md,
          ),
          _formLabDateField(
            label: 'Date',
            hint: 'Select date',
            value: _receiptDate,
            errorText: _dateError,
            onDateSelected: (d) => setState(() {
              _receiptDate = d;
              _dateError = null;
            }),
          ),
          _formTimeField(),
          AppFormFullWidth(
            child: AppTextarea(
              label: 'Remark',
              hint: 'Optional notes…',
              controller: _remarkCtrl,
              minLines: 2,
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }
}
