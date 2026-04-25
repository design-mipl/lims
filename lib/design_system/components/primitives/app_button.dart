import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tokens.dart';

enum AppButtonVariant { primary, secondary, tertiary, danger, outlined }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final bool isLoading;
  final bool isDisabled;

  /// When non-null and the button is enabled, overrides label/icon color.
  final Color? foregroundColor;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  bool get _disabled =>
      widget.isDisabled || widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final height = switch (widget.size) {
      AppButtonSize.sm => AppTokens.buttonHeightSm,
      AppButtonSize.md => AppTokens.buttonHeightMd,
      AppButtonSize.lg => AppTokens.buttonHeightLg,
    };
    final hPad = switch (widget.size) {
      AppButtonSize.sm => AppTokens.space3,
      AppButtonSize.md => AppTokens.space4,
      AppButtonSize.lg => AppTokens.space5,
    };
    final fontSize = switch (widget.size) {
      AppButtonSize.sm => 11.0,
      AppButtonSize.md => 12.0,
      AppButtonSize.lg => 13.0,
    };
    final iconSize = widget.size == AppButtonSize.lg ? 16.0 : 14.0;

    final style = _resolveStyle(widget.variant, _hovered, _disabled);
    final fg = (!_disabled && widget.foregroundColor != null)
        ? widget.foregroundColor!
        : style.fg;
    final radius = BorderRadius.circular(AppTokens.buttonRadius);

    Widget btn = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: height,
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: radius,
        border: style.borderColor != null
            ? Border.all(color: style.borderColor!, width: AppTokens.borderWidthSm)
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        widthFactor: widget.fullWidth ? null : 1.0,
        child: _buildContent(fg, iconSize, fontSize),
      ),
    );

    btn = ClipRRect(
      borderRadius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _disabled ? null : widget.onPressed,
          onHover: _disabled ? null : (v) => setState(() => _hovered = v),
          borderRadius: radius,
          child: btn,
        ),
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return IntrinsicWidth(child: btn);
  }

  Widget _buildContent(Color fg, double iconSize, double fontSize) {
    if (widget.isLoading) {
      return SizedBox(
        width: AppTokens.inlineProgressIndicatorSize,
        height: AppTokens.inlineProgressIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: fg,
        ),
      );
    }

    final label = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: fg,
        height: 1.0,
      ),
    );

    final leading = widget.icon != null
        ? Icon(widget.icon, size: iconSize, color: fg)
        : widget.leadingIcon;
    final trailing = widget.trailingIcon;

    if (leading == null && trailing == null) return label;

    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(width: AppTokens.space1),
        ],
        if (widget.fullWidth) Expanded(child: label) else label,
        if (trailing != null) ...[
          SizedBox(width: AppTokens.space1),
          trailing,
        ],
      ],
    );
  }

  _BtnStyle _resolveStyle(
    AppButtonVariant variant,
    bool hovered,
    bool disabled,
  ) {
    if (disabled) {
      return switch (variant) {
        AppButtonVariant.primary => const _BtnStyle(
            bg: AppTokens.borderDefault,
            fg: AppTokens.textMuted,
            borderColor: null,
          ),
        AppButtonVariant.secondary => const _BtnStyle(
            bg: AppTokens.surfaceSubtle,
            fg: AppTokens.textMuted,
            borderColor: AppTokens.borderDefault,
          ),
        AppButtonVariant.tertiary => const _BtnStyle(
            bg: Colors.transparent,
            fg: AppTokens.textMuted,
            borderColor: null,
          ),
        AppButtonVariant.danger => const _BtnStyle(
            bg: AppTokens.surfaceSubtle,
            fg: AppTokens.textMuted,
            borderColor: null,
          ),
        AppButtonVariant.outlined => const _BtnStyle(
            bg: AppTokens.surfaceSubtle,
            fg: AppTokens.textMuted,
            borderColor: AppTokens.borderDefault,
          ),
      };
    }

    return switch (variant) {
      AppButtonVariant.primary => _BtnStyle(
          bg: hovered ? AppTokens.primary700 : AppTokens.primary800,
          fg: AppTokens.white,
          borderColor: null,
        ),
      AppButtonVariant.secondary => _BtnStyle(
          bg: hovered ? AppTokens.borderDefault : AppTokens.surfaceSubtle,
          fg: AppTokens.textPrimary,
          borderColor: AppTokens.borderDefault,
        ),
      AppButtonVariant.tertiary => _BtnStyle(
          bg: hovered ? AppTokens.surfaceSubtle : Colors.transparent,
          fg: AppTokens.primary800,
          borderColor: null,
        ),
      AppButtonVariant.danger => _BtnStyle(
          bg: hovered ? AppTokens.error500 : AppTokens.error100,
          fg: hovered ? AppTokens.white : AppTokens.error500,
          borderColor: AppTokens.error500,
        ),
      // outlined maps to secondary style for backward compatibility
      AppButtonVariant.outlined => _BtnStyle(
          bg: hovered ? AppTokens.borderDefault : AppTokens.surfaceSubtle,
          fg: AppTokens.textPrimary,
          borderColor: AppTokens.borderDefault,
        ),
    };
  }
}

class _BtnStyle {
  const _BtnStyle({
    required this.bg,
    required this.fg,
    required this.borderColor,
  });
  final Color bg;
  final Color fg;
  final Color? borderColor;
}

