import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../primitives/app_button.dart';

/// Right-edge form panel with sticky footer (desktop width from [AppTokens.formDrawerWidthDesktop]).
class AppFormDrawer extends StatelessWidget {
  const AppFormDrawer({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.headerActions,
    this.cancelLabel = 'Cancel',
    this.primaryLabel = 'Save',
    this.onCancel,
    this.onPrimary,
    this.isPrimaryLoading = false,
    this.primaryEnabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? headerActions;
  final String cancelLabel;
  final String primaryLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onPrimary;
  final bool isPrimaryLoading;
  final bool primaryEnabled;

  static double _panelWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isDesktopWidth(w)) {
      return w < AppTokens.formDrawerWidthDesktop ? w : AppTokens.formDrawerWidthDesktop;
    }
    return w;
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget body,
    List<Widget>? headerActions,
    String cancelLabel = 'Cancel',
    String primaryLabel = 'Save',
    VoidCallback? onCancel,
    VoidCallback? onPrimary,
    bool isPrimaryLoading = false,
    bool primaryEnabled = true,
  }) {
    final theme = Theme.of(context);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppTokens.neutral900.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) {
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
                child: AppFormDrawer(
                  title: title,
                  subtitle: subtitle,
                  headerActions: headerActions,
                  body: body,
                  cancelLabel: cancelLabel,
                  primaryLabel: primaryLabel,
                  onCancel: onCancel ?? () => Navigator.of(ctx).maybePop(),
                  onPrimary: onPrimary,
                  isPrimaryLoading: isPrimaryLoading,
                  primaryEnabled: primaryEnabled,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderTop = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DrawerHeader(
          title: title,
          subtitle: subtitle,
          headerActions: headerActions,
          onClose: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppTokens.space5),
            child: body,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : AppTokens.white,
            border: Border(
              top: BorderSide(
                color: borderTop,
                width: AppTokens.borderWidthSm,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppTokens.space5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: cancelLabel,
                  onPressed: isPrimaryLoading ? null : () => onCancel?.call(),
                  variant: AppButtonVariant.tertiary,
                  size: AppButtonSize.md,
                ),
                SizedBox(width: AppTokens.space3),
                AppButton(
                  label: primaryLabel,
                  onPressed: primaryEnabled && !isPrimaryLoading
                      ? () => onPrimary?.call()
                      : null,
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.md,
                  isLoading: isPrimaryLoading,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.title,
    this.subtitle,
    this.headerActions,
    required this.onClose,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? headerActions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderBottom = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderBottom,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppTokens.space5,
          AppTokens.space4,
          AppTokens.space5,
          AppTokens.space4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: theme.textTheme.titleLarge?.fontFamily ??
                          AppTokens.fontFamily,
                      fontSize: AppTokens.textLg,
                      fontWeight: AppTokens.weightSemibold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: AppTokens.space1),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppTokens.pageSubtitleSize,
                        fontWeight: AppTokens.pageSubtitleWeight,
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.textMuted
                            : AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (headerActions != null && headerActions!.isNotEmpty) ...[
              ...headerActions!,
            ],
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: onClose,
              icon: Icon(
                LucideIcons.x,
                size: AppTokens.iconSizeMd,
                color: theme.brightness == Brightness.dark
                    ? AppTokens.neutral300
                    : AppTokens.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
