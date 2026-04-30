import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/indian_states.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../state/customer_provider.dart';

/// Create-customer flow only — editing is inline on [CustomerDetailScreen].
class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
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

  bool _validate() {
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

  Future<void> _onSave() async {
    if (!_validate()) return;
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
      'status': 'active',
    };
    await p.create(data);
    if (!mounted || p.hasError) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerProvider>();
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          _FormHeader(
            title: 'Create Customer',
            onCancel: () => Navigator.of(context).maybePop(),
            onSave: _onSave,
            isLoading: p.isLoading || p.saving,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTokens.space5),
              child: AppFormPageLayout(
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
                        isRequired: true,
                        controller: _companyCtrl,
                        errorText: _companyError,
                      ),
                      AppInput(
                        label: 'Display Name',
                        hint: 'Enter display name',
                        controller: _displayCtrl,
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
                      AppFormFullWidth(
                        child: AppToggleSwitch(
                          label: 'GST Registered',
                          value: _gstRegistered,
                          onChanged: (v) => setState(() => _gstRegistered = v),
                        ),
                      ),
                      AppInput(
                        label: 'GST No.',
                        hint: 'Enter GST number',
                        controller: _gstNoCtrl,
                        enabled: _gstRegistered,
                        errorText: _gstError,
                      ),
                      AppFormFullWidth(
                        child: AppToggleSwitch(
                          label: 'Composite Dealer',
                          value: _compositDealer,
                          onChanged: (v) => setState(() => _compositDealer = v),
                        ),
                      ),
                      AppSelect<String>(
                        label: 'Billing Cycle',
                        hint: 'Select billing cycle',
                        value: _billingCycle,
                        items: const [
                          AppSelectItem<String>(
                            value: 'monthly',
                            label: 'Monthly',
                          ),
                          AppSelectItem<String>(
                            value: 'weekly',
                            label: 'Weekly',
                          ),
                          AppSelectItem<String>(
                            value: 'fortnight',
                            label: 'Fortnight',
                          ),
                          AppSelectItem<String>(
                            value: 'immediately',
                            label: 'Immediately',
                          ),
                        ],
                        onChanged: (v) => setState(() => _billingCycle = v),
                      ),
                      AppInput(
                        label: 'Payment Terms',
                        hint: 'e.g. Net 30',
                        controller: _paymentTermsCtrl,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({
    required this.title,
    required this.onCancel,
    required this.onSave,
    required this.isLoading,
  });

  final String title;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.topbarHeight + AppTokens.space4,
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space2,
      ),
      decoration: const BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(bottom: BorderSide(color: AppTokens.borderDefault)),
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            tooltip: 'Back',
            variant: AppIconButtonVariant.ghost,
            onPressed: onCancel,
          ),
          SizedBox(width: AppTokens.space3),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.pageTitleSize,
                fontWeight: AppTokens.pageTitleWeight,
                color: AppTokens.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.tertiary,
            onPressed: onCancel,
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Save',
            variant: AppButtonVariant.primary,
            onPressed: isLoading ? null : onSave,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
