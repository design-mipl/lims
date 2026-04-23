import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Visual style for [AppButton].
enum AppButtonVariant { primary, secondary, tertiary, danger }

/// Compact, default, or prominent hit target for [AppButton].
enum AppButtonSize { sm, md, lg }

/// Design-system button built on Material 3 buttons and [AppTheme] button themes.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed =
        isLoading || onPressed == null ? null : onPressed;
    final visuallyDisabled = onPressed == null && !isLoading;

    final height = switch (size) {
      AppButtonSize.sm => AppTokens.buttonHeightSm,
      AppButtonSize.md => AppTokens.buttonHeightMd,
      AppButtonSize.lg => AppTokens.buttonHeightLg,
    };
    final horizontalPadding = switch (size) {
      AppButtonSize.sm => AppTokens.space3,
      AppButtonSize.md => AppTokens.space4,
      AppButtonSize.lg => AppTokens.space4,
    };
    final fontSize = switch (size) {
      AppButtonSize.sm => AppTokens.textSm,
      AppButtonSize.md => AppTokens.textBase,
      AppButtonSize.lg => AppTokens.textMd,
    };

    final textStyle = TextStyle(
      fontFamily: theme.textTheme.labelLarge?.fontFamily ?? 'Inter',
      fontSize: fontSize,
      fontWeight: AppTokens.weightMedium,
    );

    final minimumSize = WidgetStateProperty.all<Size?>(
      Size(AppTokens.space0, height),
    );
    final padding = WidgetStateProperty.all<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: horizontalPadding),
    );
    final mergedTextStyle = WidgetStateProperty.all<TextStyle?>(textStyle);

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: (theme.elevatedButtonTheme.style ?? const ButtonStyle()).merge(
            ButtonStyle(
              minimumSize: minimumSize,
              padding: padding,
              textStyle: mergedTextStyle,
            ),
          ),
          child: _buildChild(
            context,
            foregroundColor: AppTokens.white,
          ),
        ),
      AppButtonVariant.secondary => FilledButton(
          onPressed: effectiveOnPressed,
          style: (theme.filledButtonTheme.style ?? const ButtonStyle()).merge(
            ButtonStyle(
              minimumSize: minimumSize,
              padding: padding,
              textStyle: mergedTextStyle,
            ),
          ),
          child: _buildChild(
            context,
            foregroundColor: AppTokens.primary800,
          ),
        ),
      AppButtonVariant.tertiary => TextButton(
          onPressed: effectiveOnPressed,
          style: (theme.textButtonTheme.style ?? const ButtonStyle()).merge(
            ButtonStyle(
              minimumSize: minimumSize,
              padding: padding,
              textStyle: mergedTextStyle,
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                final brightness = theme.brightness;
                if (brightness == Brightness.dark) {
                  return theme.colorScheme.primary;
                }
                return AppTokens.primary800;
              }),
            ),
          ),
          child: _buildChild(
            context,
            foregroundColor: theme.brightness == Brightness.dark
                ? theme.colorScheme.primary
                : AppTokens.primary800,
          ),
        ),
      AppButtonVariant.danger => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: (theme.outlinedButtonTheme.style ?? const ButtonStyle()).merge(
            ButtonStyle(
              minimumSize: minimumSize,
              padding: padding,
              textStyle: mergedTextStyle,
              foregroundColor:
                  const WidgetStatePropertyAll(AppTokens.error500),
              side: const WidgetStatePropertyAll(
                BorderSide(
                  color: AppTokens.error500,
                  width: AppTokens.borderWidthSm,
                ),
              ),
            ),
          ),
          child: _buildChild(
            context,
            foregroundColor: AppTokens.error500,
          ),
        ),
    };

    final opacityWidget = Opacity(
      opacity: visuallyDisabled
          ? AppTokens.disabledOpacity
          : AppTokens.opacityFull,
      child: button,
    );

    if (!fullWidth) {
      return opacityWidget;
    }
    return SizedBox(
      width: double.infinity,
      child: opacityWidget,
    );
  }

  Widget _buildChild(BuildContext context, {required Color foregroundColor}) {
    if (isLoading) {
      return SizedBox(
        width: AppTokens.inlineProgressIndicatorSize,
        height: AppTokens.inlineProgressIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: AppTokens.inlineProgressIndicatorStrokeWidth,
          color: foregroundColor,
        ),
      );
    }

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          SizedBox(width: AppTokens.space2),
        ],
        if (fullWidth) Expanded(child: text) else text,
        if (trailingIcon != null) ...[
          SizedBox(width: AppTokens.space2),
          trailingIcon!,
        ],
      ],
    );
  }
}
