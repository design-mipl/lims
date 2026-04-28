import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppTokens.neutral700 : AppTokens.borderDefault;
    final surfaceColor = isDark ? theme.colorScheme.surface : AppTokens.cardBg;
    final contentBg = isDark ? theme.scaffoldBackgroundColor : AppTokens.pageBg;

    final showFooter = onCancel != null ||
        onPrimary != null ||
        onSaveAndContinue != null;

    final cancelText = cancelLabel ?? 'Cancel';
    final primaryText = primaryLabel ?? 'Save';
    final saveContinueText = saveAndContinueLabel ?? 'Save & continue';

    return Material(
      color: contentBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                bottom: BorderSide(color: borderColor, width: AppTokens.borderWidthSm),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space4,
                vertical: AppTokens.space3,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (onBack != null) ...[
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        size: AppTokens.iconSizeMd,
                        color: isDark ? AppTokens.neutral300 : AppTokens.neutral600,
                      ),
                    ),
                    SizedBox(width: AppTokens.space2),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.pageTitleSize,
                            fontWeight: AppTokens.pageTitleWeight,
                            color: isDark
                                ? theme.colorScheme.onSurface
                                : AppTokens.textPrimary,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          SizedBox(height: AppTokens.space1),
                          Text(
                            subtitle!,
                            style: GoogleFonts.poppins(
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
              padding: EdgeInsets.all(AppTokens.space5),
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
                color: surfaceColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: AppTokens.borderWidthSm),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space5,
                  vertical: AppTokens.space3,
                ),
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
                      SizedBox(width: AppTokens.space2),
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
                      SizedBox(width: AppTokens.space2),
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

/// Two-panel side-by-side layout for full-page forms.
/// Stacks below [kTwoPanelBreakpointWidth] (single column on narrow viewports).
class AppFormPageLayout extends StatelessWidget {
  const AppFormPageLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
  });

  /// Minimum width (px) to show left/right panels side by side.
  static const double kTwoPanelBreakpointWidth = 800;

  final List<Widget> leftPanel;
  final List<Widget> rightPanel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return _stackPanels();
        }
        final w = constraints.maxWidth;
        if (!w.isFinite) {
          return _stackPanels();
        }
        if (w >= kTwoPanelBreakpointWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 55,
                child: _panel(leftPanel),
              ),
              SizedBox(width: AppTokens.space4),
              Expanded(
                flex: 45,
                child: _panel(rightPanel),
              ),
            ],
          );
        }
        return _stackPanels();
      },
    );
  }

  /// Single column when width is unbounded or below the two-panel breakpoint.
  Widget _stackPanels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(leftPanel),
        SizedBox(height: AppTokens.space3),
        _panel(rightPanel),
      ],
    );
  }

  Widget _panel(List<Widget> sections) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final children = <Widget>[sections.first];
    for (var i = 1; i < sections.length; i++) {
      children
        ..add(SizedBox(height: AppTokens.space3))
        ..add(sections[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
