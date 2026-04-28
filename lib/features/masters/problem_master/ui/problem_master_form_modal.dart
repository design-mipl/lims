import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/master_status.dart';
import '../models/problem_master_model.dart';
import '../state/problem_master_provider.dart';

class ProblemMasterFormModal {
  static Future<void> show(
    BuildContext context, {
    ProblemMasterModel? existing,
  }) {
    final p = context.read<ProblemMasterProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => ChangeNotifierProvider<ProblemMasterProvider>.value(
        value: p,
        child: _ProblemMasterFormDialog(existing: existing),
      ),
    );
  }
}

class _ProblemMasterFormDialog extends StatefulWidget {
  const _ProblemMasterFormDialog({this.existing});

  final ProblemMasterModel? existing;

  @override
  State<_ProblemMasterFormDialog> createState() =>
      _ProblemMasterFormDialogState();
}

class _ProblemMasterFormDialogState extends State<_ProblemMasterFormDialog> {
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
    final p = dialogContext.read<ProblemMasterProvider>();

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
          _isEdit ? 'Problem updated' : 'Problem created',
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
    final p = context.watch<ProblemMasterProvider>();
    final title = _isEdit ? 'Edit Problem Master' : 'Add Problem Master';

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
              hint: 'e.g. P-01',
              controller: _code,
              readOnly: _isEdit,
              enabled: !_isEdit,
              isRequired: true,
              errorText: _codeError,
              size: AppInputSize.sm,
            ),
            AppInput(
              label: 'Name',
              hint: 'Problem description / category',
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
