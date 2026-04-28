import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/master_status.dart';
import '../models/hsn_master_model.dart';
import '../state/hsn_master_provider.dart';

class HsnFormDrawer {
  static Future<void> show(
    BuildContext context, {
    HsnMasterModel? existing,
  }) {
    final p = context.read<HsnMasterProvider>();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'HSN Form Drawer',
      barrierColor: AppTokens.neutral900.withValues(alpha: 0.38),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) => ChangeNotifierProvider<HsnMasterProvider>.value(
        value: p,
        child: Align(
          alignment: Alignment.centerRight,
          child: _HsnFormDrawer(existing: existing),
        ),
      ),
      transitionBuilder: (ctx, animation, _, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offset, child: child);
      },
    );
  }
}

class _HsnFormDrawer extends StatefulWidget {
  const _HsnFormDrawer({this.existing});

  final HsnMasterModel? existing;

  @override
  State<_HsnFormDrawer> createState() => _HsnFormDrawerState();
}

class _HsnFormDrawerState extends State<_HsnFormDrawer> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _igst;
  late final TextEditingController _cgst;
  late final TextEditingController _sgst;
  MasterStatus _status = MasterStatus.active;
  String? _codeError;
  String? _nameError;
  String? _igstError;
  String? _cgstError;
  String? _sgstError;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _code = TextEditingController(text: e?.code ?? '');
    _name = TextEditingController(text: e?.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _igst = TextEditingController(text: e != null ? _fmt(e.igst) : '');
    _cgst = TextEditingController(text: e != null ? _fmt(e.cgst) : '');
    _sgst = TextEditingController(text: e != null ? _fmt(e.sgst) : '');
    _status = e?.status ?? MasterStatus.active;
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    _igst.dispose();
    _cgst.dispose();
    _sgst.dispose();
    super.dispose();
  }

  String? _taxFieldError(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final v = double.tryParse(t);
    if (v == null) return 'Enter a valid number';
    if (v < 0) return 'Cannot be negative';
    return null;
  }

  bool _validate() {
    _codeError = null;
    _nameError = null;
    _igstError = null;
    _cgstError = null;
    _sgstError = null;

    if (_code.text.trim().isEmpty) _codeError = 'Required';
    if (_name.text.trim().isEmpty) _nameError = 'Required';
    _igstError = _taxFieldError(_igst.text);
    _cgstError = _taxFieldError(_cgst.text);
    _sgstError = _taxFieldError(_sgst.text);

    final ok = _codeError == null &&
        _nameError == null &&
        _igstError == null &&
        _cgstError == null &&
        _sgstError == null;
    setState(() {});
    return ok;
  }

  double _taxValue(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 0;
    return double.parse(t);
  }

  Future<void> _save(BuildContext dialogContext) async {
    if (!_validate()) return;
    final ig = _taxValue(_igst.text);
    final cg = _taxValue(_cgst.text);
    final sg = _taxValue(_sgst.text);

    final nav = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(dialogContext);
    final p = dialogContext.read<HsnMasterProvider>();

    if (_isEdit) {
      await p.update(
        id: widget.existing!.id,
        code: _code.text.trim(),
        name: _name.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        igst: ig,
        cgst: cg,
        sgst: sg,
        status: _status,
      );
    } else {
      await p.create(
        code: _code.text.trim(),
        name: _name.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        igst: ig,
        cgst: cg,
        sgst: sg,
        status: _status,
      );
    }

    if (!dialogContext.mounted) return;
    if (p.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            p.error ?? 'Error',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      p.clearError();
      return;
    }

    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isEdit ? 'HSN updated' : 'HSN created',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HsnMasterProvider>();
    final title = _isEdit ? 'Edit HSN Master' : 'Add HSN Master';

    return AppFormDrawer(
      title: title,
      body: Column(
        children: [
          AppFormSection(
            title: 'Basic Details',
            children: [
              AppInput(
                label: 'Code',
                hint: 'e.g. 27101980',
                controller: _code,
                readOnly: _isEdit,
                enabled: !_isEdit,
                isRequired: true,
                errorText: _codeError,
                size: AppInputSize.sm,
              ),
              AppInput(
                label: 'Name',
                hint: 'e.g. Lubricating oils',
                controller: _name,
                isRequired: true,
                errorText: _nameError,
                size: AppInputSize.sm,
              ),
              AppFormFullWidth(
                child: AppTextarea(
                  label: 'Description',
                  hint: 'Optional description',
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space4),
          AppFormSection(
            title: 'Tax Rates',
            children: [
              AppInput(
                label: 'IGST %',
                hint: 'e.g. 18',
                controller: _igst,
                keyboardType: TextInputType.number,
                errorText: _igstError,
                size: AppInputSize.sm,
              ),
              AppInput(
                label: 'CGST %',
                hint: 'e.g. 9',
                controller: _cgst,
                keyboardType: TextInputType.number,
                errorText: _cgstError,
                size: AppInputSize.sm,
              ),
              AppInput(
                label: 'SGST %',
                hint: 'e.g. 9',
                controller: _sgst,
                keyboardType: TextInputType.number,
                errorText: _sgstError,
                size: AppInputSize.sm,
              ),
            ],
          ),
          SizedBox(height: AppTokens.space4),
          AppFormSection(
            title: 'Status',
            children: [
              AppFormFullWidth(
                child: AppSegmentedControl(
                  label: 'Status',
                  value: _status.name,
                  options: const [
                    AppSegmentOption(
                      value: 'active',
                      label: 'Active',
                      icon: LucideIcons.check,
                    ),
                    AppSegmentOption(
                      value: 'inactive',
                      label: 'Inactive',
                      icon: LucideIcons.ban,
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _status = MasterStatus.values.byName(v)),
                ),
              ),
            ],
          ),
        ],
      ),
      onCancel: () => Navigator.of(context).maybePop(),
      onPrimary: () => _save(context),
      isPrimaryLoading: p.isLoading,
      primaryEnabled: !p.isLoading,
    );
  }
}
