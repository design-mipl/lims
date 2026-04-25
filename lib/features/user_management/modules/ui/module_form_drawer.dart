import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // `showGeneralDialog` builds a new route: not a descendant of the
    // route-scoped [ChangeNotifierProvider<ModulesProvider>]. Bridge the
    // same instance into the dialog subtree.
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
  late final TextEditingController _codeCtrl;
  late final TextEditingController _routeCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _sortCtrl;
  String? _parentId;
  late bool _showInNav;
  late bool _permEnabled;
  late ModuleStatus _status;

  String? _nameError;
  String? _codeError;
  String? _sortError;
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
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _routeCtrl = TextEditingController(text: e?.route ?? '');
    _iconCtrl = TextEditingController(text: e?.icon ?? '');
    _sortCtrl = TextEditingController(text: '${e?.sortOrder ?? 0}');
    _parentId = e?.parentId;
    _showInNav = e?.showInNavigation ?? true;
    _permEnabled = e?.permissionEnabled ?? true;
    _status = e?.status ?? ModuleStatus.active;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _routeCtrl.dispose();
    _iconCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    _nameError = null;
    _codeError = null;
    _sortError = null;
    if (_nameCtrl.text.trim().isEmpty) {
      _nameError = 'Module name is required';
      ok = false;
    }
    if (_codeCtrl.text.trim().isEmpty) {
      _codeError = 'Module code is required';
      ok = false;
    }
    final sortParsed = int.tryParse(_sortCtrl.text.trim());
    if (sortParsed == null) {
      _sortError = 'Enter a valid number';
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
    final code = _codeCtrl.text.trim();
    final route = _routeCtrl.text.trim();
    final icon = _iconCtrl.text.trim();
    final sortOrder = int.parse(_sortCtrl.text.trim());

    if (_isEdit) {
      await provider.updateModule(
        id: widget.existing!.id,
        name: name,
        code: code,
        parentId: _parentId,
        route: route,
        icon: icon,
        sortOrder: sortOrder,
        showInNavigation: _showInNav,
        permissionEnabled: _permEnabled,
        status: _status,
      );
    } else {
      await provider.createModule(
        name: name,
        code: code,
        parentId: _parentId,
        route: route,
        icon: icon,
        sortOrder: sortOrder,
        showInNavigation: _showInNav,
        permissionEnabled: _permEnabled,
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

  Widget _switchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: AppTokens.textSm,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.watch<ModulesProvider>();
    final parents = _parentOptions(p);

    return AppFormDrawer(
      title: _isEdit ? 'Edit Module' : 'Add Module',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Basic',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormFieldRow(
                  children: [
                    AppFormFieldSpan(
                      child: AppInput(
                        label: 'Module Name',
                        hint: 'e.g. Sample Receipt',
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
                        label: 'Module Code',
                        hint: 'e.g. TXN_SR',
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
                SizedBox(height: AppTokens.space4),
                AppSelect<String?>(
                  key: ValueKey<String?>(_parentId),
                  label: 'Parent Module',
                  hint: 'None (root)',
                  value: _parentId,
                  items: [
                    const AppSelectItem<String?>(
                      value: null,
                      label: 'None (root)',
                    ),
                    ...parents.map(
                      (m) => AppSelectItem<String?>(
                        value: m.id,
                        label: m.name,
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _parentId = v),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Configuration',
            child: AppFormFieldRow(
              children: [
                AppFormFieldSpan(
                  child: AppInput(
                    label: 'Route',
                    hint: 'e.g. /transactions/sample-receipt',
                    controller: _routeCtrl,
                    size: AppInputSize.sm,
                  ),
                ),
                AppFormFieldSpan(
                  child: AppInput(
                    label: 'Icon',
                    hint: 'Lucide icon key, e.g. clipboardList',
                    controller: _iconCtrl,
                    size: AppInputSize.sm,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'Sort Order',
            hint: '0',
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            size: AppInputSize.sm,
            errorText: _sortError,
            onChanged: (_) {
              if (_sortError != null) {
                setState(() => _sortError = null);
              }
            },
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Flags',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _switchRow(
                  label: 'Show in Navigation',
                  value: _showInNav,
                  onChanged: (v) => setState(() => _showInNav = v),
                  theme: theme,
                ),
                _switchRow(
                  label: 'Permission Enabled',
                  value: _permEnabled,
                  onChanged: (v) => setState(() => _permEnabled = v),
                  theme: theme,
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.fieldLabelSize,
                    fontWeight: AppTokens.fieldLabelWeight,
                    color: AppTokens.labelColor,
                  ),
                ),
                SizedBox(height: AppTokens.space1),
                AppSegmentedControl(
                  options: const [
                    AppSegmentOption(value: 'active', label: 'Active', icon: LucideIcons.circleCheck),
                    AppSegmentOption(value: 'inactive', label: 'Inactive', icon: LucideIcons.circleOff),
                  ],
                  value: _status.name,
                  onChanged: (v) => setState(() =>
                      _status = ModuleStatus.values.firstWhere((s) => s.name == v)),
                ),
              ],
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
