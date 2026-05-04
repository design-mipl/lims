import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/indian_states.dart';
import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../../customer_master/state/customer_provider.dart';
import '../../data/site_model.dart';
import '../../state/site_provider.dart';

class SiteOverviewTab extends StatefulWidget {
  const SiteOverviewTab({
    super.key,
    required this.site,
    required this.isEditing,
    required this.onSaveSucceeded,
  });

  final SiteModel? site;
  final bool isEditing;
  final VoidCallback onSaveSucceeded;

  @override
  State<SiteOverviewTab> createState() => SiteOverviewTabState();
}

class SiteOverviewTabState extends State<SiteOverviewTab> {
  final _codeCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _displayCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _mergedCtrl = TextEditingController();
  final _gstNoCtrl = TextEditingController();

  String? _state;
  String? _companyId;
  bool _gstRegistered = false;
  bool _compositDealer = false;

  String? _codeError;
  String? _gstError;

  void _populateFrom(SiteModel s) {
    _codeCtrl.text = s.code;
    _typeCtrl.text = s.typeOfContact ?? '';
    _displayCtrl.text = s.displayName ?? '';
    _companyNameCtrl.text = s.companyName ?? '';
    _addressCtrl.text = s.addressLine1 ?? '';
    _cityCtrl.text = s.city ?? '';
    _state = s.state;
    _countryCtrl.text = s.country?.trim().isNotEmpty == true
        ? s.country!
        : 'India';
    _mergedCtrl.text = s.mergedItems ?? '';
    _gstRegistered = s.gstRegistered;
    _gstNoCtrl.text = s.gstNo ?? '';
    _compositDealer = s.compositDealer;
    _companyId = s.companyId;
    _codeError = null;
    _gstError = null;
  }

  void _clearForCreate() {
    _codeCtrl.clear();
    _typeCtrl.clear();
    _displayCtrl.clear();
    _companyNameCtrl.clear();
    _addressCtrl.clear();
    _cityCtrl.clear();
    _countryCtrl.text = 'India';
    _mergedCtrl.clear();
    _gstNoCtrl.clear();
    _state = null;
    _companyId = null;
    _gstRegistered = false;
    _compositDealer = false;
    _codeError = null;
    _gstError = null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.site != null) {
      _populateFrom(widget.site!);
    } else {
      _clearForCreate();
    }
  }

  @override
  void didUpdateWidget(covariant SiteOverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditing && widget.isEditing && widget.site != null) {
      _populateFrom(widget.site!);
    }
    if (oldWidget.site?.id != widget.site?.id) {
      if (widget.site != null) {
        _populateFrom(widget.site!);
      } else {
        _clearForCreate();
      }
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _typeCtrl.dispose();
    _displayCtrl.dispose();
    _companyNameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _mergedCtrl.dispose();
    _gstNoCtrl.dispose();
    super.dispose();
  }

  String? _resolveCompanyLabel(CustomerProvider cp) {
    if (_companyId == null) return null;
    for (final c in cp.customers) {
      if (c.id == _companyId) return c.companyName;
    }
    return null;
  }

  List<AppSelectItem<String>> _customerItems(CustomerProvider cp) {
    return cp.customers
        .map((c) => AppSelectItem<String>(value: c.id, label: c.companyName))
        .toList();
  }

  bool validate() {
    setState(() {
      _codeError = _codeCtrl.text.trim().isEmpty ? 'Code is required' : null;
      _gstError = _gstRegistered && _gstNoCtrl.text.trim().isEmpty
          ? 'GST No. is required'
          : null;
    });
    return _codeError == null && _gstError == null;
  }

  Future<void> saveInline() async {
    if (!validate()) return;
    final siteProv = context.read<SiteProvider>();
    final cp = context.read<CustomerProvider>();
    final companyLabel = _resolveCompanyLabel(cp);

    final data = <String, dynamic>{
      'code': _codeCtrl.text.trim(),
      'typeOfContact': _typeCtrl.text.trim().isEmpty
          ? null
          : _typeCtrl.text.trim(),
      'displayName': _displayCtrl.text.trim().isEmpty
          ? null
          : _displayCtrl.text.trim(),
      'companyName': _companyNameCtrl.text.trim().isEmpty
          ? null
          : _companyNameCtrl.text.trim(),
      'addressLine1': _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      'state': _state,
      'country': _countryCtrl.text.trim().isEmpty
          ? null
          : _countryCtrl.text.trim(),
      'gstRegistered': _gstRegistered,
      'gstNo': _gstNoCtrl.text.trim().isEmpty ? null : _gstNoCtrl.text.trim(),
      'compositDealer': _compositDealer,
      'companyId': _companyId,
      'companyLabel': companyLabel,
      'mergedItems': _mergedCtrl.text.trim().isEmpty
          ? null
          : _mergedCtrl.text.trim(),
    };

    if (widget.site == null) {
      data['status'] = 'active';
      final created = await siteProv.create(data);
      if (!mounted || created == null || siteProv.hasError) return;
      context.go('/sites/${created.id}');
      return;
    }

    await siteProv.update(widget.site!.id, data);
    if (!mounted || siteProv.hasError) return;
    widget.onSaveSucceeded();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.site;
    final cp = context.watch<CustomerProvider>();
    final customerItems = _customerItems(cp);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: s == null
          ? _buildEditBody(customerItems)
          : widget.isEditing
          ? _buildEditBody(customerItems)
          : _buildReadBody(s),
    );
  }

  Widget _buildReadBody(SiteModel s) {
    return AppFormPageLayout(
      left: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Basic Details',
          children: [
            _ReadOnlyField(label: 'Code', value: s.code),
            _ReadOnlyField(label: 'Type of Contact', value: s.typeOfContact),
            _ReadOnlyField(label: 'Display Name', value: s.displayName),
            _ReadOnlyField(label: 'Company Name', value: s.companyName),
            AppFormFullWidth(
              child: _ReadOnlyField(label: 'Address', value: s.addressLine1),
            ),
          ],
        ),
        AppFormSection(
          title: 'Location',
          children: [
            _ReadOnlyField(label: 'City', value: s.city),
            _ReadOnlyField(label: 'State', value: s.state),
            AppFormFullWidth(
              child: _ReadOnlyField(label: 'Country', value: s.country),
            ),
          ],
        ),
      ]),
      right: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Company Link',
          children: [
            AppFormFullWidth(
              child: _ReadOnlyField(
                label: 'Company',
                value: s.companyLabel ?? s.companyId,
              ),
            ),
            AppFormFullWidth(
              child: _ReadOnlyField(
                label: 'Merged Items',
                value: s.mergedItems,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'GST Details',
          children: [
            _ReadOnlyField(
              label: 'GST Registered',
              value: s.gstRegistered ? 'Yes' : 'No',
            ),
            _ReadOnlyField(label: 'GST No.', value: s.gstNo),
            AppFormFullWidth(
              child: _ReadOnlyField(
                label: 'Composite Dealer',
                value: s.compositDealer ? 'Yes' : 'No',
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildEditBody(List<AppSelectItem<String>> customerItems) {
    return AppFormPageLayout(
      left: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Basic Details',
          children: [
            AppInput(
              label: 'Code',
              hint: 'Enter site code',
              controller: _codeCtrl,
              isRequired: true,
              errorText: _codeError,
            ),
            AppInput(
              label: 'Type of Contact',
              hint: 'e.g. Plant, Office',
              controller: _typeCtrl,
            ),
            AppInput(
              label: 'Display Name',
              hint: 'Enter display name',
              controller: _displayCtrl,
            ),
            AppInput(
              label: 'Company Name',
              hint: 'Enter company name',
              controller: _companyNameCtrl,
            ),
            AppFormFullWidth(
              child: AppInput(
                label: 'Address',
                hint: 'Enter address',
                controller: _addressCtrl,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'Location',
          children: [
            AppInput(label: 'City', hint: 'Enter city', controller: _cityCtrl),
            AppSelect<String>(
              label: 'State',
              hint: 'Select state',
              value: _state,
              items: IndianStates.list,
              onChanged: (v) => setState(() => _state = v),
              countLabel: 'states',
            ),
            AppFormFullWidth(
              child: AppInput(
                label: 'Country',
                hint: 'Enter country',
                controller: _countryCtrl,
              ),
            ),
          ],
        ),
      ]),
      right: AppFormPageLayout.sectionsColumn([
        AppFormSection(
          title: 'Company Link',
          children: [
            AppFormFullWidth(
              child: AppSelect<String>(
                label: 'Company',
                hint: 'Search customer...',
                value: _companyId,
                items: customerItems,
                isSearchable: true,
                countLabel: 'customers',
                onChanged: (v) => setState(() => _companyId = v),
              ),
            ),
            AppFormFullWidth(
              child: AppInput(
                label: 'Merged Items',
                hint: 'Enter merged items',
                controller: _mergedCtrl,
              ),
            ),
          ],
        ),
        AppFormSection(
          title: 'GST Details',
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
            decoration: TextDecoration.none,
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
              color: hasContent ? AppTokens.textPrimary : AppTokens.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
