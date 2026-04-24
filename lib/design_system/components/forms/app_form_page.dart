import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import '../primitives/app_button.dart';

/// Full-page form layout for complex workflows (use inside a parent with bounded height).
///
/// When hosted inside a scrollable shell, wrap this widget in a [SizedBox] with an
/// explicit height (e.g. viewport minus chrome) so the sticky footer can layout.
class AppFormPage extends StatelessWidget {
  const AppFormPage({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    required this.body,
    this.cancelLabel,
    this.onCancel,
    this.primaryLabel,
    this.onPrimary,
    this.saveAndContinueLabel,
    this.onSaveAndContinue,
    this.isPrimaryLoading = false,
    this.primaryEnabled = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget body;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? saveAndContinueLabel;
  final VoidCallback? onSaveAndContinue;
  final bool isPrimaryLoading;
  final bool primaryEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderTop = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;
    final borderBottom = borderTop;

    final showFooter = onCancel != null ||
        onPrimary != null ||
        onSaveAndContinue != null;

    final cancelText = cancelLabel ?? 'Cancel';
    final primaryText = primaryLabel ?? 'Save';
    final saveContinueText = saveAndContinueLabel ?? 'Save & continue';

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: borderBottom,
                  width: AppTokens.borderWidthSm,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space4,
                vertical: AppTokens.space3,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onBack != null)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        size: AppTokens.iconSizeMd,
                        color: theme.brightness == Brightness.dark
                            ? AppTokens.neutral300
                            : AppTokens.neutral600,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: theme.textTheme.headlineSmall?.fontFamily ??
                                AppTokens.fontFamily,
                            fontSize: AppTokens.pageTitleSize,
                            fontWeight: AppTokens.pageTitleWeight,
                            color: theme.brightness == Brightness.dark
                                ? theme.colorScheme.onSurface
                                : AppTokens.textPrimary,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          SizedBox(height: AppTokens.space1),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: theme.textTheme.bodyMedium?.fontFamily ??
                                  AppTokens.fontFamily,
                              fontSize: AppTokens.pageSubtitleSize,
                              fontWeight: AppTokens.pageSubtitleWeight,
                              color: AppTokens.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null && actions!.isNotEmpty)
                    Wrap(
                      spacing: AppTokens.space2,
                      runSpacing: AppTokens.space2,
                      alignment: WrapAlignment.end,
                      children: actions!,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppTokens.space5,
                AppTokens.space3,
                AppTokens.space5,
                AppTokens.space5,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppTokens.formPageContentMaxWidth,
                  ),
                  child: body,
                ),
              ),
            ),
          ),
          if (showFooter)
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
                    if (onCancel != null) ...[
                      AppButton(
                        label: cancelText,
                        onPressed:
                            isPrimaryLoading ? null : () => onCancel?.call(),
                        variant: AppButtonVariant.tertiary,
                        size: AppButtonSize.md,
                      ),
                      SizedBox(width: AppTokens.space3),
                    ],
                    if (onSaveAndContinue != null) ...[
                      AppButton(
                        label: saveContinueText,
                        onPressed: isPrimaryLoading
                            ? null
                            : () => onSaveAndContinue?.call(),
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.md,
                      ),
                      SizedBox(width: AppTokens.space3),
                    ],
                    if (onPrimary != null)
                      AppButton(
                        label: primaryText,
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
    );
  }
}
