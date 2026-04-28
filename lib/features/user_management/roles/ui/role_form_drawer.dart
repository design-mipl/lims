import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/breakpoints.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/role_model.dart';
import '../state/roles_provider.dart';

abstract final class RoleFormDrawer {
  static Future<void> show(
    BuildContext context, {
    RoleModel? existing,
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
                child: _RoleFormDrawerHost(existing: existing),
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
      return w < AppTokens.formDrawerWidthDesktop
          ? w
          : AppTokens.formDrawerWidthDesktop;
    }
    return w;
  }
}

class _RoleFormDrawerHost extends StatefulWidget {
  const _RoleFormDrawerHost({this.existing});

  final RoleModel? existing;

  @override
  State<_RoleFormDrawerHost> createState() => _RoleFormDrawerHostState();
}

class _RoleFormDrawerHostState extends State<_RoleFormDrawerHost> {
  /// Below this width, Role Name and Level stack; drawer content is typically wider.
  static const double _nameLevelSideBySideMinWidth = 480;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late int _level;
  late RoleType _type;
  late RoleStatus _status;

  String? _nameError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _level = e?.level ?? 0;
    _type = e?.type ?? RoleType.custom;
    _status = e?.status ?? RoleStatus.active;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    _nameError = null;
    if (_nameCtrl.text.trim().isEmpty) {
      _nameError = 'Role name is required';
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
    final provider = context.read<RolesProvider>();
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final description = desc.isEmpty ? null : desc;

    if (_isEdit) {
      await provider.updateRole(
        id: widget.existing!.id,
        name: name,
        level: _level,
        description: description,
        type: _type,
        status: _status,
      );
    } else {
      await provider.createRole(
        name: name,
        level: _level,
        description: description,
        type: _type,
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
      title: _isEdit ? 'Edit Role' : 'Add Role',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Role Details',
            children: [
              AppFormFullWidth(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sideBySide =
                        constraints.maxWidth >= _nameLevelSideBySideMinWidth;
                    final nameField = AppInput(
                      label: 'Role Name',
                      hint: 'e.g. Lab Supervisor',
                      controller: _nameCtrl,
                      isRequired: true,
                      errorText: _nameError,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    );
                    final levelField = AppSelect<int>(
                      label: 'Level',
                      hint: 'Select level',
                      isRequired: true,
                      value: _level,
                      items: const [
                        AppSelectItem(value: 0, label: 'Admin'),
                        AppSelectItem(value: 1, label: 'Power User'),
                        AppSelectItem(value: 2, label: 'Project User'),
                        AppSelectItem(value: 3, label: 'Viewer'),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _level = v);
                        }
                      },
                    );
                    if (!sideBySide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          nameField,
                          SizedBox(height: AppTokens.space4),
                          levelField,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: nameField),
                        SizedBox(width: AppTokens.space3),
                        Expanded(child: levelField),
                      ],
                    );
                  },
                ),
              ),
              AppFormFullWidth(
                child: AppTextarea(
                  label: 'Description',
                  hint: 'Optional description',
                  controller: _descCtrl,
                  minLines: 2,
                  maxLines: 4,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Type & Status',
            children: [
              AppFormFullWidth(
                child: AppSegmentedControl(
                  label: 'Type',
                  options: const [
                    AppSegmentOption(
                      value: 'system',
                      label: 'System',
                      icon: LucideIcons.lock,
                    ),
                    AppSegmentOption(
                      value: 'custom',
                      label: 'Custom',
                      icon: LucideIcons.settings2,
                    ),
                  ],
                  value: _type.name,
                  onChanged: (v) => setState(
                    () => _type =
                        RoleType.values.firstWhere((t) => t.name == v),
                  ),
                ),
              ),
              AppFormFullWidth(
                child: AppSegmentedControl(
                  label: 'Status',
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
                  value: _status.name,
                  onChanged: (v) => setState(
                    () => _status =
                        RoleStatus.values.firstWhere((s) => s.name == v),
                  ),
                ),
              ),
            ],
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
