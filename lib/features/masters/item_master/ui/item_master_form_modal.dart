import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/master_status.dart';
import '../models/item_master_model.dart';
import '../state/item_master_provider.dart';

class ItemMasterFormModal {
  static Future<void> show(
    BuildContext context, {
    ItemMasterModel? existing,
  }) {
    final p = context.read<ItemMasterProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => ChangeNotifierProvider<ItemMasterProvider>.value(
        value: p,
        child: _ItemMasterFormDialog(existing: existing),
      ),
    );
  }
}

class _ItemMasterFormDialog extends StatefulWidget {
  const _ItemMasterFormDialog({this.existing});

  final ItemMasterModel? existing;

  @override
  State<_ItemMasterFormDialog> createState() => _ItemMasterFormDialogState();
}

class _ItemMasterFormDialogState extends State<_ItemMasterFormDialog> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
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
    _description = TextEditingController(text: e?.description ?? '');
    _status = e?.status ?? MasterStatus.active;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
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
    final p = dialogContext.read<ItemMasterProvider>();

    if (_isEdit) {
      await p.update(
        id: widget.existing!.id,
        code: _code.text.trim(),
        name: _name.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        status: _status,
      );
    } else {
      await p.create(
        code: _code.text.trim(),
        name: _name.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
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
          _isEdit ? 'Item updated' : 'Item created',
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
    final p = context.watch<ItemMasterProvider>();
    final title = _isEdit ? 'Edit Item Master' : 'Add Item Master';

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
              hint: 'e.g. EO',
              controller: _code,
              readOnly: _isEdit,
              enabled: !_isEdit,
              isRequired: true,
              errorText: _codeError,
              size: AppInputSize.sm,
            ),
            AppInput(
              label: 'Name',
              hint: 'Item name',
              controller: _name,
              isRequired: true,
              errorText: _nameError,
              size: AppInputSize.sm,
            ),
            AppFormFullWidth(
              child: AppTextarea(
                label: 'Description',
                hint: 'Optional',
                controller: _description,
                minLines: 2,
                maxLines: 4,
              ),
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
