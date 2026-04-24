import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/breakpoints.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/department_model.dart';
import '../state/departments_provider.dart';

/// Right-edge drawer for creating or editing a department ([AppFormDrawer]).
abstract final class DepartmentFormDrawer {
  static Future<void> show(
    BuildContext context, {
    DepartmentModel? existing,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppTokens.neutral900.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        final theme = Theme.of(ctx);
        final panelW = _panelWidth(ctx);
        return Align(
          alignment: Alignment.centerRight,
          child: SafeArea(
            child: Material(
              elevation: AppTokens.space0,
              color: theme.colorScheme.surface,
              child: SizedBox(
                width: panelW,
                height: MediaQuery.sizeOf(ctx).height,
                child: _DepartmentFormDrawerHost(existing: existing),
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
      return w < AppTokens.formDrawerWidthDesktop ? w : AppTokens.formDrawerWidthDesktop;
    }
    return w;
  }
}

class _DepartmentFormDrawerHost extends StatefulWidget {
  const _DepartmentFormDrawerHost({this.existing});

  final DepartmentModel? existing;

  @override
  State<_DepartmentFormDrawerHost> createState() =>
      _DepartmentFormDrawerHostState();
}

class _DepartmentFormDrawerHostState extends State<_DepartmentFormDrawerHost> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late DepartmentStatus _status;

  String? _nameError;
  String? _codeError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _status = e?.status ?? DepartmentStatus.active;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    _nameError = null;
    _codeError = null;
    if (_nameCtrl.text.trim().isEmpty) {
      _nameError = 'Department name is required';
      ok = false;
    }
    if (_codeCtrl.text.trim().isEmpty) {
      _codeError = 'Department code is required';
      ok = false;
    }
    setState(() {});
    return ok;
  }

  Future<void> _onSave() async {
    if (!_validate()) {
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<DepartmentsProvider>();
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final description = desc.isEmpty ? null : desc;

    if (_isEdit) {
      await provider.updateDepartment(
        id: widget.existing!.id,
        name: name,
        code: code,
        description: description,
        status: _status,
      );
    } else {
      await provider.createDepartment(
        name: name,
        code: code,
        description: description,
        status: _status,
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (provider.hasError) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDrawer(
      title: _isEdit ? 'Edit Department' : 'Add Department',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Basic Details',
            child: AppFormFieldRow(
              children: [
                AppFormFieldSpan(
                  child: AppInput(
                    label: 'Department Name',
                    hint: 'e.g. Laboratory',
                    controller: _nameCtrl,
                    required: true,
                    size: AppInputSize.sm,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),
                ),
                AppFormFieldSpan(
                  child: AppInput(
                    label: 'Department Code',
                    hint: 'e.g. LAB',
                    controller: _codeCtrl,
                    required: true,
                    size: AppInputSize.sm,
                    errorText: _codeError,
                    onChanged: (_) {
                      if (_codeError != null) {
                        setState(() => _codeError = null);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Description',
            child: AppTextarea(
              label: 'Description',
              hint: 'Optional',
              controller: _descCtrl,
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Status',
            child: AppSegmentedControl<DepartmentStatus>(
              segments: const [
                AppSegment<DepartmentStatus>(
                  value: DepartmentStatus.active,
                  label: 'Active',
                  icon: LucideIcons.circleCheck,
                ),
                AppSegment<DepartmentStatus>(
                  value: DepartmentStatus.inactive,
                  label: 'Inactive',
                  icon: LucideIcons.circleOff,
                ),
              ],
              selected: _status,
              onChanged: (v) => setState(() => _status = v),
            ),
          ),
        ],
      ),
      onCancel: () => Navigator.of(context).maybePop(),
      onPrimary: _onSave,
      isPrimaryLoading: _saving,
      primaryEnabled: !_saving,
    );
  }
}
