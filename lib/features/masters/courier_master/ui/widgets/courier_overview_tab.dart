import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/indian_states.dart';
import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../courier_validation.dart';
import '../../data/courier_model.dart';
import '../../state/courier_provider.dart';

/// Overview tab - validates/collects courier detail + communication fields.
class CourierOverviewTab extends StatefulWidget {
  const CourierOverviewTab({
    super.key,
    required this.courier,
    required this.isEditing,
  });

  final CourierModel? courier;
  final bool isEditing;

  @override
  State<CourierOverviewTab> createState() => CourierOverviewTabState();
}

class CourierOverviewTabState extends State<CourierOverviewTab> {
  final _codeCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _personCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String? _stateValue;

  final _email1Ctrl = TextEditingController();
  final _email2Ctrl = TextEditingController();
  final _mobile1Ctrl = TextEditingController();
  final _mobile2Ctrl = TextEditingController();

  int _emailSlotCount = 1;
  int _mobileSlotCount = 1;

  String? _codeError;
  String? _personError;
  String? _email1Error;
  String? _email2Error;
  String? _mobile1Error;
  String? _mobile2Error;

  bool get _existingRecord =>
      widget.courier != null && widget.courier!.id.isNotEmpty;

  bool get _codeLocked => _existingRecord && widget.isEditing;

  void _populateFrom(CourierModel c) {
    _codeCtrl.text = c.code;
    _companyCtrl.text = c.companyName;
    _personCtrl.text = c.personName;
    _addressCtrl.text = c.address;
    _cityCtrl.text = c.city;
    _stateValue = c.state.trim().isEmpty ? null : c.state;

    final em = List<String>.from(c.emails);
    _emailSlotCount = em.length >= 2 ? 2 : (em.isEmpty ? 1 : em.length);
    _email1Ctrl.text = em.isNotEmpty ? em[0] : '';
    _email2Ctrl.text = em.length > 1 ? em[1] : '';

    final mb = List<String>.from(c.mobiles);
    _mobileSlotCount = mb.length >= 2 ? 2 : (mb.isEmpty ? 1 : mb.length);
    _mobile1Ctrl.text = mb.isNotEmpty ? mb[0] : '';
    _mobile2Ctrl.text = mb.length > 1 ? mb[1] : '';

    _clearErrors();
  }

  void _clearForCreate() {
    _codeCtrl.clear();
    _companyCtrl.clear();
    _personCtrl.clear();
    _addressCtrl.clear();
    _cityCtrl.clear();
    _stateValue = null;
    _emailSlotCount = 1;
    _mobileSlotCount = 1;
    _email1Ctrl.clear();
    _email2Ctrl.clear();
    _mobile1Ctrl.clear();
    _mobile2Ctrl.clear();
    _clearErrors();
  }

  void _clearErrors() {
    _codeError = null;
    _personError = null;
    _email1Error = null;
    _email2Error = null;
    _mobile1Error = null;
    _mobile2Error = null;
  }

  @override
  void initState() {
    super.initState();
    final c = widget.courier;
    if (c != null && c.id.isNotEmpty) {
      _populateFrom(c);
    } else {
      _clearForCreate();
    }
  }

  @override
  void didUpdateWidget(covariant CourierOverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditing &&
        widget.isEditing &&
        widget.courier != null &&
        widget.courier!.id.isNotEmpty) {
      _populateFrom(widget.courier!);
    }
    if (oldWidget.isEditing &&
        !widget.isEditing &&
        widget.courier != null &&
        widget.courier!.id.isNotEmpty) {
      _populateFrom(widget.courier!);
    }
    if (oldWidget.courier?.id != widget.courier?.id) {
      final c = widget.courier;
      if (c != null && c.id.isNotEmpty) {
        _populateFrom(c);
      } else {
        _clearForCreate();
      }
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _companyCtrl.dispose();
    _personCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _email1Ctrl.dispose();
    _email2Ctrl.dispose();
    _mobile1Ctrl.dispose();
    _mobile2Ctrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? validateAndCollectPayload(
    CourierProvider provider,
    String? excludeCourierId,
  ) {
    final code = _codeCtrl.text.trim();
    final person = _personCtrl.text.trim();

    _clearErrors();

    if (code.isEmpty) {
      _codeError = 'Required';
    } else if (!provider.isCodeUnique(code,
        excludeCourierId: excludeCourierId)) {
      _codeError = 'Code must be unique';
    }

    if (person.isEmpty) {
      _personError = 'Required';
    }

    final e1 = _email1Ctrl.text.trim();
    final e2 = _emailSlotCount > 1 ? _email2Ctrl.text.trim() : '';

    if (!CourierValidators.emailOptionalValid(e1)) {
      _email1Error = 'Invalid email';
    }
    if (_emailSlotCount > 1 && !CourierValidators.emailOptionalValid(e2)) {
      _email2Error = 'Invalid email';
    }

    final m1 = _mobile1Ctrl.text.trim();
    final m2 = _mobileSlotCount > 1 ? _mobile2Ctrl.text.trim() : '';

    if (m1.isNotEmpty && !CourierValidators.mobileOptionalValid(m1)) {
      _mobile1Error = 'Enter a valid 10-digit mobile';
    }
    if (_mobileSlotCount > 1 &&
        m2.isNotEmpty &&
        !CourierValidators.mobileOptionalValid(m2)) {
      _mobile2Error = 'Enter a valid 10-digit mobile';
    }

    final emails = <String>[
      if (e1.isNotEmpty) e1,
      if (_emailSlotCount > 1 && e2.isNotEmpty) e2,
    ];

    final mobiles = <String>[
      if (m1.isNotEmpty) m1.replaceAll(RegExp(r'\D'), ''),
      if (_mobileSlotCount > 1 && m2.isNotEmpty)
        m2.replaceAll(RegExp(r'\D'), ''),
    ];

    if (_codeError != null ||
        _personError != null ||
        _email1Error != null ||
        _email2Error != null ||
        _mobile1Error != null ||
        _mobile2Error != null) {
      setState(() {});
      return null;
    }

    return {
      'code': code,
      'companyName': _companyCtrl.text.trim(),
      'personName': person,
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateValue ?? '',
      'emails': emails,
      'mobiles': mobiles,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.courier;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: c == null || (widget.isEditing && c.id.isEmpty)
          ? _buildEdit(providerWatch: context.watch<CourierProvider>())
          : widget.isEditing && c.id.isNotEmpty
              ? _buildEdit(providerWatch: context.watch<CourierProvider>())
              : _buildRead(c),
    );
  }

  Widget _buildEdit({required CourierProvider providerWatch}) {
    providerWatch;
    return AppFormPageLayout(
      left: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Courier Details',
          children: [
            AppInput(
              label: 'Code',
              hint: 'Courier code',
              controller: _codeCtrl,
              readOnly: _codeLocked,
              enabled: !_codeLocked,
              isRequired: true,
              errorText: _codeError,
              size: AppInputSize.sm,
            ),
            AppInput(
              label: 'Company Name',
              hint: 'Optional',
              controller: _companyCtrl,
              size: AppInputSize.sm,
            ),
            AppInput(
              label: 'Name of the Person',
              hint: 'Primary contact person',
              controller: _personCtrl,
              isRequired: true,
              errorText: _personError,
              size: AppInputSize.sm,
            ),
            AppFormFullWidth(
              child: AppTextarea(
                label: 'Address',
                hint: 'Street, landmark',
                controller: _addressCtrl,
                minLines: 3,
                maxLines: 6,
              ),
            ),
            AppInput(
              label: 'City',
              controller: _cityCtrl,
              size: AppInputSize.sm,
            ),
            AppSelect<String>(
              label: 'State',
              hint: 'Select state',
              value: _stateValue,
              items: IndianStates.list,
              onChanged: (v) => setState(() => _stateValue = v),
              size: AppInputSize.sm,
            ),
          ],
        ),
      ]),
      right: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Communication Details',
          children: [
            Text(
              'Maximum 2 email addresses allowed',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            AppInput(
              label: 'Email 1',
              controller: _email1Ctrl,
              errorText: _email1Error,
              size: AppInputSize.sm,
            ),
            if (_emailSlotCount > 1) ...[
              SizedBox(height: AppTokens.space2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Email 2',
                      controller: _email2Ctrl,
                      errorText: _email2Error,
                      size: AppInputSize.sm,
                    ),
                  ),
                  SizedBox(width: AppTokens.space2),
                  Padding(
                    padding: EdgeInsets.only(top: AppTokens.space6),
                    child: AppIconButton(
                      tooltip: 'Remove Email 2',
                      icon: Icon(LucideIcons.trash2),
                      variant: AppIconButtonVariant.outlined,
                      onPressed: () => setState(() {
                        _email2Ctrl.clear();
                        _emailSlotCount = 1;
                      }),
                    ),
                  ),
                ],
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: '+ Add Email',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
                onPressed: _emailSlotCount >= 2
                    ? null
                    : () => setState(() => _emailSlotCount = 2),
              ),
            ),
            SizedBox(height: AppTokens.space3),
            Text(
              'Maximum 2 mobile numbers allowed',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            AppInput(
              label: 'Mobile 1',
              hint: '10-digit mobile',
              controller: _mobile1Ctrl,
              errorText: _mobile1Error,
              size: AppInputSize.sm,
            ),
            if (_mobileSlotCount > 1) ...[
              SizedBox(height: AppTokens.space2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Mobile 2',
                      hint: '10-digit mobile',
                      controller: _mobile2Ctrl,
                      errorText: _mobile2Error,
                      size: AppInputSize.sm,
                    ),
                  ),
                  SizedBox(width: AppTokens.space2),
                  Padding(
                    padding: EdgeInsets.only(top: AppTokens.space6),
                    child: AppIconButton(
                      tooltip: 'Remove Mobile 2',
                      icon: Icon(LucideIcons.trash2),
                      variant: AppIconButtonVariant.outlined,
                      onPressed: () => setState(() {
                        _mobile2Ctrl.clear();
                        _mobileSlotCount = 1;
                      }),
                    ),
                  ),
                ],
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: '+ Add Mobile',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
                onPressed: _mobileSlotCount >= 2
                    ? null
                    : () => setState(() => _mobileSlotCount = 2),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildRead(CourierModel c) {
    final emails = c.emails.isEmpty ? '—' : c.emails.join(', ');
    final mobiles = c.mobiles.isEmpty ? '—' : c.mobiles.join(', ');
    return AppFormPageLayout(
      left: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Courier Details',
          children: [
            _ReadOnlyField(label: 'Code', value: c.code),
            _ReadOnlyField(label: 'Company Name', value: c.companyName),
            _ReadOnlyField(label: 'Name of the Person', value: c.personName),
            AppFormFullWidth(
              child: _ReadOnlyField(label: 'Address', value: c.address),
            ),
            _ReadOnlyField(label: 'City', value: c.city),
            _ReadOnlyField(label: 'State', value: c.state),
          ],
        ),
      ]),
      right: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Communication Details',
          children: [
            _ReadOnlyField(label: 'Emails', value: emails),
            _ReadOnlyField(label: 'Mobiles', value: mobiles),
          ],
        ),
      ]),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final v = value?.trim();
    final display = v == null || v.isEmpty ? '—' : v;
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.fieldLabelSize,
              fontWeight: AppTokens.fieldLabelWeight,
              color: AppTokens.labelColor,
            ),
          ),
          SizedBox(height: AppTokens.space1),
          Text(
            display,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.textPrimary,
              fontWeight: AppTokens.weightRegular,
            ),
          ),
        ],
      ),
    );
  }
}
