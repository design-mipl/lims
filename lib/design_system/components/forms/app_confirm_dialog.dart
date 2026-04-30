import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import '../primitives/app_button.dart';

enum AppConfirmDialogVariant { danger, warning, info }

/// Confirmation dialog with optional icon, title, message, and action buttons.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.variant = AppConfirmDialogVariant.danger,
    this.onCancel,
    this.onConfirm,
    this.isConfirmLoading = false,
  });

  final IconData? icon;
  final String title;
  final String? message;
  final String cancelLabel;
  final String confirmLabel;
  final AppConfirmDialogVariant variant;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isConfirmLoading;

  static Future<bool?> show({
    required BuildContext context,
    IconData? icon,
    required String title,
    String? message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    AppConfirmDialogVariant variant = AppConfirmDialogVariant.danger,
    bool isConfirmLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => AppConfirmDialog(
        icon: icon,
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        variant: variant,
        onCancel: () => Navigator.of(ctx).pop(false),
        onConfirm: () => Navigator.of(ctx).pop(true),
        isConfirmLoading: isConfirmLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppTokens.neutral700 : AppTokens.borderDefault;

    final (iconBg, iconColor) = switch (variant) {
      AppConfirmDialogVariant.danger => (AppTokens.error100, AppTokens.error500),
      AppConfirmDialogVariant.warning => (AppTokens.warning100, AppTokens.warning500),
      AppConfirmDialogVariant.info => (AppTokens.info100, AppTokens.info500),
    };

    final confirmVariant = switch (variant) {
      AppConfirmDialogVariant.danger => AppButtonVariant.danger,
      _ => AppButtonVariant.primary,
    };

    final resolvedIcon = icon ??
        switch (variant) {
          AppConfirmDialogVariant.danger => LucideIcons.triangleAlert,
          AppConfirmDialogVariant.warning => LucideIcons.alertCircle,
          AppConfirmDialogVariant.info => LucideIcons.info,
        };

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space5,
        vertical: AppTokens.space6,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Material(
          color: isDark ? theme.colorScheme.surface : AppTokens.cardBg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.space5,
                  AppTokens.space5,
                  AppTokens.space5,
                  AppTokens.space4,
                ),
                child: Column(
                  children: [
                    Container(
                      width: AppTokens.space10,
                      height: AppTokens.space10,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(AppTokens.space5),
                      ),
                      child: Icon(
                        resolvedIcon,
                        size: AppTokens.space5,
                        color: iconColor,
                      ),
                    ),
                    SizedBox(height: AppTokens.space2),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: AppTokens.weightSemibold,
                        color: isDark
                            ? theme.colorScheme.onSurface
                            : AppTokens.textPrimary,
                      ),
                    ),
                    if (message != null && message!.isNotEmpty) ...[
                      SizedBox(height: AppTokens.space2),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.textBase,
                          fontWeight: AppTokens.weightRegular,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: borderColor, width: AppTokens.borderWidthSm),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space5,
                    vertical: AppTokens.space4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        label: cancelLabel,
                        onPressed: isConfirmLoading ? null : () => onCancel?.call(),
                        variant: AppButtonVariant.tertiary,
                        size: AppButtonSize.md,
                      ),
                      SizedBox(width: AppTokens.space2),
                      AppButton(
                        label: confirmLabel,
                        onPressed: isConfirmLoading ? null : () => onConfirm?.call(),
                        variant: confirmVariant,
                        size: AppButtonSize.md,
                        isLoading: isConfirmLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
