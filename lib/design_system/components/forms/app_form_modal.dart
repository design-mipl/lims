import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import '../primitives/app_button.dart';

/// Centered modal shell: header, scrollable body, sticky footer (Stripe-like density).
class AppFormModal extends StatelessWidget {
  const AppFormModal({
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
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) {
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.9;
    final borderTop = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.border;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 480,
        maxHeight: maxH,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _FormHeader(
              title: title,
              subtitle: subtitle,
              headerActions: headerActions,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.space4,
                  AppTokens.space2,
                  AppTokens.space4,
                  AppTokens.space4,
                ),
                child: body,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: borderTop,
                    width: AppTokens.borderWidthHairline,
                  ),
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
                      onPressed:
                          isPrimaryLoading ? null : () => onCancel?.call(),
                      variant: AppButtonVariant.tertiary,
                      size: AppButtonSize.md,
                    ),
                    SizedBox(width: AppTokens.space2),
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
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.space2,
        AppTokens.space2,
        AppTokens.space2,
        AppTokens.space2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: AppTokens.space2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: AppTokens.weightSemibold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: AppTokens.space1),
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textSm,
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.neutral400
                            : AppTokens.neutral600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (headerActions != null && headerActions!.isNotEmpty) ...[
            ...headerActions!,
            SizedBox(width: AppTokens.space1),
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
    );
  }
}
