import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../design_system/components/components.dart';
import '../../../design_system/tokens.dart';
import 'master_status.dart';
import 'simple_master_config.dart';
import 'simple_master_model.dart';
import 'simple_master_provider.dart';

class SimpleMasterFormModal {
  static Future<void> show(
    BuildContext context, {
    required SimpleMasterConfig config,
    SimpleMasterModel? existing,
  }) {
    final p = context.read<SimpleMasterProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTokens.modalBarrierScrim,
      builder: (ctx) => ChangeNotifierProvider<SimpleMasterProvider>.value(
        value: p,
        child: _SimpleMasterFormDialog(config: config, existing: existing),
      ),
    );
  }
}

class _SimpleMasterFormDialog extends StatefulWidget {
  const _SimpleMasterFormDialog({
    required this.config,
    this.existing,
  });

  final SimpleMasterConfig config;
  final SimpleMasterModel? existing;

  @override
  State<_SimpleMasterFormDialog> createState() =>
      _SimpleMasterFormDialogState();
}

class _SimpleMasterFormDialogState extends State<_SimpleMasterFormDialog> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  MasterStatus _status = MasterStatus.active;
  String? _codeError;
  String? _nameError;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _code = TextEditingController(text: e?.code ?? '');
    _name = TextEditingController(text: e?.name ?? '');
    _status = e?.status ?? MasterStatus.active;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _codeError = null;
      _nameError = null;
    });
    var ok = true;
    if (_code.text.trim().isEmpty) {
      _codeError = 'Required';
      ok = false;
    }
    if (_name.text.trim().isEmpty) {
      _nameError = 'Required';
      ok = false;
    }
    if (!ok) setState(() {});
    return ok;
  }

  Future<void> _save(BuildContext dialogContext) async {
    if (!_validate()) return;
    final nav = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(dialogContext);
    final p = dialogContext.read<SimpleMasterProvider>();
    final config = widget.config;

    if (_isEdit) {
      await p.update(
        id: widget.existing!.id,
        code: _code.text.trim(),
        name: _name.text.trim(),
        status: _status,
      );
    } else {
      await p.create(
        code: _code.text.trim(),
        name: _name.text.trim(),
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
          _isEdit ? config.updatedSuccessMessage : config.createdSuccessMessage,
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
    final p = context.watch<SimpleMasterProvider>();
    final config = widget.config;
    final title = _isEdit ? config.editFormTitle : config.addFormTitle;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 16,
      child: AppFormModal(
        title: title,
        body: AppFormSection(
          title: 'Details',
          children: [
            AppInput(
              label: 'Code',
              hint: config.codeHint,
              controller: _code,
              readOnly: _isEdit,
              enabled: !_isEdit,
              isRequired: true,
              errorText: _codeError,
              size: AppInputSize.sm,
            ),
            AppInput(
              label: 'Name',
              hint: config.nameHint,
              controller: _name,
              isRequired: true,
              errorText: _nameError,
              size: AppInputSize.sm,
            ),
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
        onCancel: () => Navigator.of(context).maybePop(),
        onPrimary: () => _save(context),
        isPrimaryLoading: p.isLoading,
        primaryEnabled: !p.isLoading,
      ),
    );
  }
}
