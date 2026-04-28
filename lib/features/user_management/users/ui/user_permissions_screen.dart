import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../modules/data/module_model.dart';
import '../state/user_permissions_provider.dart';

/// Permission matrix for a user. Hosted under [ShellRoute]: no [Scaffold] / [AppBar].
class UserPermissionsScreen extends StatelessWidget {
  const UserPermissionsScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userRole,
    required this.isAdmin,
  });

  /// Route identity; data shown from [UserPermissionsProvider] after [load].
  final String userId;
  final String userName;
  final String? userRole;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey<String>(
        'permissions_${userId}_${userName}_${userRole ?? ''}_$isAdmin',
      ),
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(onBack: () => context.pop()),
          Expanded(child: const _MatrixBody()),
          const _StickyFooter(),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserPermissionsProvider>();
    return Container(
      height: AppTokens.permissionPageHeaderHeight,
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(
          bottom: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space5),
      child: Row(
        children: [
          AppIconButton(
            variant: AppIconButtonVariant.ghost,
            size: AppIconButtonSize.sm,
            icon: Icon(
              LucideIcons.arrowLeft,
              size: AppTokens.iconButtonIconMd,
            ),
            tooltip: 'Back to Users',
            onPressed: onBack,
          ),
          SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User Permissions',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.pageTitleSize,
                    fontWeight: AppTokens.pageTitleWeight,
                    color: AppTokens.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '${provider.userName} · ${provider.userRole}',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.pageSubtitleSize,
                    color: AppTokens.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixBody extends StatelessWidget {
  const _MatrixBody();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<UserPermissionsProvider, bool>(
      (p) => p.isLoading,
    );
    final parents = context.select<UserPermissionsProvider, List<ModuleModel>>(
      (p) => p.parentModules,
    );

    if (isLoading && parents.isEmpty) {
      return Center(
        child: SizedBox(
          width: AppTokens.permissionEmptyStateIconSize,
          height: AppTokens.permissionEmptyStateIconSize,
          child: CircularProgressIndicator(
            color: AppTokens.primary800,
            strokeWidth: AppTokens.inlineProgressIndicatorStrokeWidth,
          ),
        ),
      );
    }

    if (!isLoading && parents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.shieldOff,
              size: AppTokens.permissionEmptyStateIconSize,
              color: AppTokens.textMuted,
            ),
            SizedBox(height: AppTokens.space2),
            Text(
              'No permission-enabled modules',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.bodySize,
                color: AppTokens.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final matrix = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final module in parents)
                _ModuleSection(module: module),
            ],
          );
          if (constraints.maxWidth < AppTokens.permissionMatrixMinScrollWidth) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: AppTokens.permissionMatrixMinScrollWidth,
                ),
                child: matrix,
              ),
            );
          }
          return matrix;
        },
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({required this.module});

  final ModuleModel module;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserPermissionsProvider>();
    final subs = provider.subModulesOf(module.id);

    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space3),
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        border: Border.all(color: AppTokens.borderDefault),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space4,
              vertical: AppTokens.space3,
            ),
            decoration: BoxDecoration(
              color: AppTokens.surfaceSubtle,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTokens.cardRadius),
                topRight: Radius.circular(AppTokens.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    module.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.tableHeaderSize,
                      fontWeight: AppTokens.tableHeaderWeight,
                      color: AppTokens.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                _PermissionHeaders(),
              ],
            ),
          ),
          ...subs.map(
            (sub) => _SubModuleRow(
              moduleId: module.id,
              sub: sub,
            ),
          ),
          if (subs.isEmpty)
            _SubModuleRow(
              moduleId: module.id,
              sub: null,
              moduleName: module.name,
            ),
        ],
      ),
    );
  }
}

class _PermissionHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labels = ['Select All', 'View', 'Create', 'Edit', 'Delete'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final label in labels)
          SizedBox(
            width: AppTokens.permissionMatrixColumnWidth,
            child: Center(
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.permissionMatrixHeaderFontSize,
                  fontWeight: AppTokens.permissionMatrixHeaderWeight,
                  color: AppTokens.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SubModuleRow extends StatelessWidget {
  const _SubModuleRow({
    required this.moduleId,
    this.sub,
    this.moduleName,
  });

  final String moduleId;
  final ModuleModel? sub;
  final String? moduleName;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserPermissionsProvider>();
    final perm = provider.permissionFor(
      moduleId,
      subModuleId: sub?.id,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space2,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              sub?.name ?? moduleName ?? '',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: FontWeight.w400,
                color: AppTokens.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: AppTokens.permissionMatrixColumnWidth,
            child: Center(
              child: _PermCheckbox(
                value: perm.hasAll,
                tristate: perm.hasAny && !perm.hasAll,
                onChanged: (v) => provider.selectAll(
                  moduleId,
                  sub?.id,
                  v ?? false,
                ),
              ),
            ),
          ),
          SizedBox(
            width: AppTokens.permissionMatrixColumnWidth,
            child: Center(
              child: _PermCheckbox(
                value: perm.canView,
                onChanged: (v) => provider.updatePermission(
                  moduleId,
                  sub?.id,
                  'view',
                  v ?? false,
                ),
              ),
            ),
          ),
          SizedBox(
            width: AppTokens.permissionMatrixColumnWidth,
            child: Center(
              child: _PermCheckbox(
                value: perm.canCreate,
                onChanged: (v) => provider.updatePermission(
                  moduleId,
                  sub?.id,
                  'create',
                  v ?? false,
                ),
              ),
            ),
          ),
          SizedBox(
            width: AppTokens.permissionMatrixColumnWidth,
            child: Center(
              child: _PermCheckbox(
                value: perm.canEdit,
                onChanged: (v) => provider.updatePermission(
                  moduleId,
                  sub?.id,
                  'edit',
                  v ?? false,
                ),
              ),
            ),
          ),
          SizedBox(
            width: AppTokens.permissionMatrixColumnWidth,
            child: Center(
              child: _PermCheckbox(
                value: perm.canDelete,
                onChanged: (v) => provider.updatePermission(
                  moduleId,
                  sub?.id,
                  'delete',
                  v ?? false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermCheckbox extends StatelessWidget {
  const _PermCheckbox({
    required this.value,
    required this.onChanged,
    this.tristate = false,
  });

  final bool value;
  final bool tristate;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppTokens.permissionCheckboxSize,
      height: AppTokens.permissionCheckboxSize,
      child: Checkbox(
        value: tristate ? null : value,
        tristate: tristate,
        onChanged: onChanged,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primary800;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppTokens.neutral200;
          }
          return AppTokens.white;
        }),
        checkColor: AppTokens.white,
        side: WidgetStateBorderSide.resolveWith(
          (_) => BorderSide(
            color: AppTokens.borderStrong,
            width: AppTokens.borderWidthMd,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTokens.permissionCheckboxRadius,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserPermissionsProvider>();
    return Container(
      height: AppTokens.permissionFooterHeight,
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space5),
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(
          top: BorderSide(color: AppTokens.borderDefault),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            variant: AppButtonVariant.tertiary,
            size: AppButtonSize.md,
            label: 'Cancel',
            onPressed: () => context.pop(),
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.md,
            label: 'Save Permissions',
            isLoading: provider.isLoading,
            onPressed: () async {
              await provider.save();
              if (!context.mounted) {
                return;
              }
              if (provider.hasError) {
                final msg = provider.error ?? 'Save failed';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      msg,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.bodySize,
                        color: AppTokens.white,
                      ),
                    ),
                    backgroundColor: AppTokens.error500,
                  ),
                );
                provider.clearError();
                return;
              }
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
