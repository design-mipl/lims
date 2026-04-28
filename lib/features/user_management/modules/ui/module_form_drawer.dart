import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/breakpoints.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/module_model.dart';
import '../state/modules_provider.dart';

abstract final class ModuleFormDrawer {
  static Future<void> show(
    BuildContext context, {
    ModuleModel? existing,
  }) {
    final provider = context.read<ModulesProvider>();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppTokens.neutral900.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        final theme = Theme.of(ctx);
        final panelW = _panelWidth(ctx);
        return ChangeNotifierProvider<ModulesProvider>.value(
          value: provider,
          child: Align(
            alignment: Alignment.centerRight,
            child: SafeArea(
              child: Material(
                elevation: AppTokens.space0,
                color: theme.colorScheme.surface,
                child: SizedBox(
                  width: panelW,
                  height: MediaQuery.sizeOf(ctx).height,
                  child: _ModuleFormDrawerHost(existing: existing),
                ),
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

class _ModuleFormDrawerHost extends StatefulWidget {
  const _ModuleFormDrawerHost({this.existing});

  final ModuleModel? existing;

  @override
  State<_ModuleFormDrawerHost> createState() => _ModuleFormDrawerHostState();
}

class _ModuleFormDrawerHostState extends State<_ModuleFormDrawerHost> {
  late final TextEditingController _nameCtrl;
  late String _parentId;
  late ModuleStatus _status;

  String? _nameError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  List<ModuleModel> _parentOptions(ModulesProvider p) {
    final all = p.items;
    if (!_isEdit) {
      return all;
    }
    final selfId = widget.existing!.id;
    final blocked = <String>{selfId};

    void addDescendants(String id) {
      for (final m in all) {
        if (m.parentId == id && blocked.add(m.id)) {
          addDescendants(m.id);
        }
      }
    }

    addDescendants(selfId);
    return all.where((m) => !blocked.contains(m.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _parentId = e?.parentId ?? '';
    _status = e?.status ?? ModuleStatus.active;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    _nameError = null;
    if (_nameCtrl.text.trim().isEmpty) {
      _nameError = 'Module name is required';
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
    final provider = context.read<ModulesProvider>();
    final name = _nameCtrl.text.trim();
    final parentId = _parentId.isEmpty ? null : _parentId;

    if (_isEdit) {
      await provider.updateModule(
        id: widget.existing!.id,
        name: name,
        parentId: parentId,
        status: _status,
      );
    } else {
      await provider.createModule(
        name: name,
        parentId: parentId,
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
    final p = context.watch<ModulesProvider>();
    final parents = _parentOptions(p);

    return AppFormDrawer(
      title: _isEdit ? 'Edit Module' : 'Add Module',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Module Details',
            children: [
              AppFormFullWidth(
                child: AppInput(
                  label: 'Module Name',
                  hint: 'e.g. Sample Receipt',
                  isRequired: true,
                  controller: _nameCtrl,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
              ),
              AppFormFullWidth(
                child: AppSelect<String>(
                  label: 'Parent Module',
                  hint: 'None (root)',
                  value: _parentId.isEmpty ? null : _parentId,
                  items: [
                    const AppSelectItem<String>(
                      value: '',
                      label: 'None (root)',
                    ),
                    ...parents.map(
                      (m) => AppSelectItem<String>(
                        value: m.id,
                        label: m.name,
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _parentId = v ?? ''),
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
                  onChanged: (v) => setState(
                    () => _status =
                        ModuleStatus.values.firstWhere((s) => s.name == v),
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
