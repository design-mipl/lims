import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/indian_states.dart';
import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/customer_model.dart';
import '../../state/customer_provider.dart';

const List<AppSelectItem<String>> _billingCycleOptions = [
  AppSelectItem<String>(value: 'monthly', label: 'Monthly'),
  AppSelectItem<String>(value: 'weekly', label: 'Weekly'),
  AppSelectItem<String>(value: 'fortnight', label: 'Fortnight'),
  AppSelectItem<String>(value: 'immediately', label: 'Immediately'),
];

class OverviewTab extends StatefulWidget {
  const OverviewTab({
    super.key,
    required this.customer,
    required this.isEditing,
    required this.onSaveSucceeded,
  });

  final CustomerModel customer;
  final bool isEditing;

  /// Parent should set `_isEditing = false` after this returns (success path).
  final VoidCallback onSaveSucceeded;

  @override
  State<OverviewTab> createState() => OverviewTabState();
}

class OverviewTabState extends State<OverviewTab> {
  final _groupCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _displayCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _pincodeCtrl = TextEditingController();
  final _gstNoCtrl = TextEditingController();
  final _paymentTermsCtrl = TextEditingController();
  final _salesPersonCtrl = TextEditingController();
  final _creditCtrl = TextEditingController();
  final _oemCtrl = TextEditingController();
  final _kamCtrl = TextEditingController();

  String? _state;
  String? _billingCycle;
  bool _gstRegistered = false;
  bool _compositDealer = false;

  String? _companyError;
  String? _gstError;

  void _populateFrom(CustomerModel c) {
    _groupCtrl.text = c.groupName ?? '';
    _companyCtrl.text = c.companyName;
    _displayCtrl.text = c.displayName ?? '';
    _addressCtrl.text = c.addressLine1 ?? '';
    _cityCtrl.text = c.city ?? '';
    _state = c.state;
    _countryCtrl.text = c.country?.trim().isNotEmpty == true
        ? c.country!
        : 'India';
    _pincodeCtrl.text = c.pincode ?? '';
    _gstRegistered = c.gstRegistered;
    _gstNoCtrl.text = c.gstNo ?? '';
    _compositDealer = c.compositDealer;
    _billingCycle = c.billingCycle;
    _paymentTermsCtrl.text = c.paymentTerms ?? '';
    _salesPersonCtrl.text = c.salesPerson ?? '';
    _creditCtrl.text = c.creditControl ?? '';
    _oemCtrl.text = c.oem ?? '';
    _kamCtrl.text = c.kam ?? '';
    _companyError = null;
    _gstError = null;
  }

  @override
  void initState() {
    super.initState();
    _populateFrom(widget.customer);
  }

  @override
  void didUpdateWidget(covariant OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditing && widget.isEditing) {
      _populateFrom(widget.customer);
    }
    if (oldWidget.customer.id != widget.customer.id) {
      _populateFrom(widget.customer);
    }
  }

  @override
  void dispose() {
    _groupCtrl.dispose();
    _companyCtrl.dispose();
    _displayCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _pincodeCtrl.dispose();
    _gstNoCtrl.dispose();
    _paymentTermsCtrl.dispose();
    _salesPersonCtrl.dispose();
    _creditCtrl.dispose();
    _oemCtrl.dispose();
    _kamCtrl.dispose();
    super.dispose();
  }

  bool validate() {
    setState(() {
      _companyError = _companyCtrl.text.trim().isEmpty
          ? 'Company Name is required'
          : null;
      _gstError = _gstRegistered && _gstNoCtrl.text.trim().isEmpty
          ? 'GST No. is required'
          : null;
    });
    return _companyError == null && _gstError == null;
  }

  Future<void> saveInline() async {
    if (!validate()) return;
    final p = context.read<CustomerProvider>();
    final data = <String, dynamic>{
      'groupName': _groupCtrl.text.trim().isEmpty
          ? null
          : _groupCtrl.text.trim(),
      'companyName': _companyCtrl.text.trim(),
      'displayName': _displayCtrl.text.trim().isEmpty
          ? null
          : _displayCtrl.text.trim(),
      'addressLine1': _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      'state': _state,
      'country': _countryCtrl.text.trim().isEmpty
          ? null
          : _countryCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim().isEmpty
          ? null
          : _pincodeCtrl.text.trim(),
      'gstRegistered': _gstRegistered,
      'gstNo': _gstNoCtrl.text.trim().isEmpty ? null : _gstNoCtrl.text.trim(),
      'compositDealer': _compositDealer,
      'billingCycle': _billingCycle,
      'paymentTerms': _paymentTermsCtrl.text.trim().isEmpty
          ? null
          : _paymentTermsCtrl.text.trim(),
      'salesPerson': _salesPersonCtrl.text.trim().isEmpty
          ? null
          : _salesPersonCtrl.text.trim(),
      'creditControl': _creditCtrl.text.trim().isEmpty
          ? null
          : _creditCtrl.text.trim(),
      'oem': _oemCtrl.text.trim().isEmpty ? null : _oemCtrl.text.trim(),
      'kam': _kamCtrl.text.trim().isEmpty ? null : _kamCtrl.text.trim(),
    };
    await p.update(widget.customer.id, data);
    if (!mounted || p.hasError) return;
    widget.onSaveSucceeded();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: widget.isEditing ? _buildEditBody() : _buildReadBody(c),
    );
  }

  Widget _buildReadBody(CustomerModel c) {
    return AppFormPageLayout(
      left: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Basic Details',
          children: [
            _ReadOnlyField(label: 'Group Name', value: c.groupName),
            _ReadOnlyField(label: 'Company Name', value: c.companyName),
            AppFormFullWidth(
              child: _ReadOnlyField(
                label: 'Display Name',
                value: c.displayName,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'Address',
          children: [
            AppFormFullWidth(
              child: _ReadOnlyField(
                label: 'Address',
                value: c.addressLine1,
              ),
            ),
            _ReadOnlyField(label: 'City', value: c.city),
            _ReadOnlyField(label: 'State', value: c.state),
            _ReadOnlyField(label: 'Country', value: c.country),
            _ReadOnlyField(label: 'Pincode', value: c.pincode),
          ],
        ),
      ]),
      right: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'GST & Billing',
          children: [
            _ReadOnlyField(
              label: 'GST Registered',
              value: c.gstRegistered ? 'Yes' : 'No',
            ),
            _ReadOnlyField(label: 'GST No.', value: c.gstNo),
            _ReadOnlyField(
              label: 'Composite Dealer',
              value: c.compositDealer ? 'Yes' : 'No',
            ),
            _ReadOnlyField(label: 'Billing Cycle', value: c.billingCycle),
            AppFormFullWidth(
              child: _ReadOnlyField(
                label: 'Payment Terms',
                value: c.paymentTerms,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'Sales Info',
          children: [
            _ReadOnlyField(label: 'Sales Person', value: c.salesPerson),
            _ReadOnlyField(label: 'Credit Control', value: c.creditControl),
            _ReadOnlyField(label: 'OEM', value: c.oem),
            _ReadOnlyField(label: 'KAM', value: c.kam),
          ],
        ),
      ]),
    );
  }

  Widget _buildEditBody() {
    return AppFormPageLayout(
      left: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Basic Details',
          children: [
            AppInput(
              label: 'Group Name',
              hint: 'Enter group name',
              controller: _groupCtrl,
            ),
            AppInput(
              label: 'Company Name',
              hint: 'Enter company name',
              controller: _companyCtrl,
              isRequired: true,
              errorText: _companyError,
            ),
            AppFormFullWidth(
              child: AppInput(
                label: 'Display Name',
                hint: 'Enter display name',
                controller: _displayCtrl,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'Address',
          children: [
            AppFormFullWidth(
              child: AppInput(
                label: 'Address',
                hint: 'Enter address',
                controller: _addressCtrl,
              ),
            ),
            AppInput(
              label: 'City',
              hint: 'Enter city',
              controller: _cityCtrl,
            ),
            AppSelect<String>(
              label: 'State',
              hint: 'Select state',
              value: _state,
              items: IndianStates.list,
              onChanged: (v) => setState(() => _state = v),
              isRequired: true,
              countLabel: 'states',
            ),
            AppInput(
              label: 'Country',
              hint: 'Enter country',
              controller: _countryCtrl,
            ),
            AppInput(
              label: 'Pincode',
              hint: 'Enter pincode',
              controller: _pincodeCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ]),
      right: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'GST & Billing',
          children: [
            AppToggleSwitch(
              label: 'GST Registered',
              value: _gstRegistered,
              onChanged: (v) => setState(() {
                _gstRegistered = v;
                if (!_gstRegistered) _gstError = null;
              }),
            ),
            AppInput(
              label: 'GST No.',
              hint: 'Enter GST number',
              controller: _gstNoCtrl,
              enabled: _gstRegistered,
              errorText: _gstError,
            ),
            AppToggleSwitch(
              label: 'Composite Dealer',
              value: _compositDealer,
              onChanged: (v) => setState(() => _compositDealer = v),
            ),
            AppSelect<String>(
              label: 'Billing Cycle',
              hint: 'Select billing cycle',
              value: _billingCycle,
              items: _billingCycleOptions,
              onChanged: (v) => setState(() => _billingCycle = v),
            ),
            AppFormFullWidth(
              child: AppInput(
                label: 'Payment Terms',
                hint: 'e.g. Net 30',
                controller: _paymentTermsCtrl,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'Sales Info',
          children: [
            AppInput(
              label: 'Sales Person',
              hint: 'Enter sales person',
              controller: _salesPersonCtrl,
            ),
            AppInput(
              label: 'Credit Control',
              hint: 'Enter credit control',
              controller: _creditCtrl,
            ),
            AppInput(
              label: 'OEM',
              hint: 'Enter OEM',
              controller: _oemCtrl,
            ),
            AppInput(
              label: 'KAM',
              hint: 'Enter KAM',
              controller: _kamCtrl,
            ),
          ],
        ),
      ]),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final hasContent = value != null && value!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textXs,
            fontWeight: AppTokens.weightMedium,
            color: AppTokens.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: AppTokens.space1),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space3,
            vertical: AppTokens.space2,
          ),
          decoration: BoxDecoration(
            color: AppTokens.pageBg,
            border: Border.all(color: AppTokens.border),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          child: Text(
            hasContent ? value!.trim() : '—',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              color:
                  hasContent ? AppTokens.textPrimary : AppTokens.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
