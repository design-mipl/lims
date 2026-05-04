import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/master_status.dart';
import '../data/plant_model.dart';
import '../state/plant_provider.dart';

/// Add / edit plant in [AppFormModal] (aligned with Bank Master popup).
class PlantMasterFormModal {
  static Future<void> show(
    BuildContext context, {
    PlantModel? existing,
  }) {
    final p = context.read<PlantProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => ChangeNotifierProvider<PlantProvider>.value(
        value: p,
        child: _PlantMasterFormDialog(existing: existing),
      ),
    );
  }
}

class _PlantMasterFormDialog extends StatefulWidget {
  const _PlantMasterFormDialog({this.existing});

  final PlantModel? existing;

  @override
  State<_PlantMasterFormDialog> createState() => _PlantMasterFormDialogState();
}

class _PlantMasterFormDialogState extends State<_PlantMasterFormDialog> {
  late final TextEditingController _code;
  late final TextEditingController _plant;
  MasterStatus _status = MasterStatus.active;
  String? _codeError;
  String? _plantError;

  bool get _isEdit => widget.existing != null;

  MasterStatus _statusFromString(String raw) {
    for (final v in MasterStatus.values) {
      if (v.name == raw) return v;
    }
    return MasterStatus.active;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _code = TextEditingController(text: e?.code ?? '');
    _plant = TextEditingController(text: e?.plant ?? '');
    _status = e != null ? _statusFromString(e.status) : MasterStatus.active;
  }

  @override
  void dispose() {
    _code.dispose();
    _plant.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _codeError = null;
      _plantError = null;
    });
    var ok = true;
    if (_code.text.trim().isEmpty) {
      _codeError = 'Required';
      ok = false;
    }
    if (_plant.text.trim().isEmpty) {
      _plantError = 'Required';
      ok = false;
    }
    if (!ok) setState(() {});
    return ok;
  }

  Future<void> _save(BuildContext dialogContext) async {
    if (!_validate()) return;
    final nav = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(dialogContext);
    final p = dialogContext.read<PlantProvider>();

    final payload = <String, dynamic>{
      'code': _code.text.trim(),
      'plant': _plant.text.trim(),
      'status': _status.name,
    };

    if (_isEdit) {
      await p.update(widget.existing!.id, payload);
    } else {
      await p.create(payload);
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
          _isEdit ? 'Plant updated' : 'Plant created',
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
    final p = context.watch<PlantProvider>();
    final title = _isEdit ? 'Edit Plant Master' : 'Add Plant Master';

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
              hint: 'e.g. PLT001',
              controller: _code,
              readOnly: _isEdit,
              enabled: !_isEdit,
              isRequired: true,
              errorText: _codeError,
              size: AppInputSize.sm,
            ),
            AppInput(
              label: 'Plant',
              hint: 'Plant name',
              controller: _plant,
              isRequired: true,
              errorText: _plantError,
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
                onChanged: (v) => setState(
                  () => _status = MasterStatus.values.byName(v),
                ),
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
