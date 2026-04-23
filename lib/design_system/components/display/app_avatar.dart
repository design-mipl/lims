import 'package:flutter/material.dart';

import '../../tokens.dart';

/// Diameter preset for [AppAvatar].
enum AppAvatarSize { xs, sm, md, lg, xl }

/// Circular avatar with optional network image or initials fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.customInitials,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final Color? backgroundColor;
  final String? customInitials;

  static const List<Color> _palette = <Color>[
    AppTokens.primary600,
    AppTokens.info500,
    AppTokens.warning500,
    AppTokens.success500,
    AppTokens.primary500,
    AppTokens.accent500,
    AppTokens.accent600,
    AppTokens.neutral600,
  ];

  double get _diameter => switch (size) {
        AppAvatarSize.xs => AppTokens.avatarSizeXs,
        AppAvatarSize.sm => AppTokens.avatarSizeSm,
        AppAvatarSize.md => AppTokens.buttonHeightMd,
        AppAvatarSize.lg => AppTokens.tableRowHeight,
        AppAvatarSize.xl => AppTokens.topbarHeight,
      };

  double get _fontSize => switch (size) {
        AppAvatarSize.xs => AppTokens.textXs,
        AppAvatarSize.sm => AppTokens.textXs,
        AppAvatarSize.md => AppTokens.textSm,
        AppAvatarSize.lg => AppTokens.textBase,
        AppAvatarSize.xl => AppTokens.textMd,
      };

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter;
    final initials = _initialsFrom(name);
    final bg = backgroundColor ?? _backgroundForName(name);
    final textColor = _contrastingInk(bg);

    final fontFamily =
        Theme.of(context).textTheme.titleMedium?.fontFamily ?? 'Inter';

    final Widget child = imageUrl != null && imageUrl!.isNotEmpty
        ? ClipOval(
            child: Image.network(
              imageUrl!,
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: diameter,
                height: diameter,
                child: _initialsLayer(
                  initials,
                  bg,
                  textColor,
                  fontFamily,
                ),
              ),
            ),
          )
        : _initialsLayer(initials, bg, textColor, fontFamily);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: child,
    );
  }

  Widget _initialsLayer(
    String initials,
    Color bg,
    Color textColor,
    String fontFamily,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: _fontSize,
            fontWeight: AppTokens.weightSemibold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Color _backgroundForName(String? raw) {
    final key = raw?.trim() ?? '';
    if (key.isEmpty) {
      return AppTokens.neutral200;
    }
    final index = key.hashCode.abs() % _palette.length;
    return _palette[index];
  }

  String _initialsFrom(String? raw) {
    final o = customInitials?.trim();
    if (o != null && o.isNotEmpty) {
      if (o.length >= 2) {
        return o.substring(0, 2).toUpperCase();
      }
      return o.toUpperCase();
    }
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '?';
    }
    final parts =
        trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      final first = _firstGrapheme(parts.first);
      final last = _firstGrapheme(parts.last);
      return (first + last).toUpperCase();
    }
    final single = parts.first;
    if (single.length >= 2) {
      return single.substring(0, 2).toUpperCase();
    }
    return single.toUpperCase();
  }

  Color _contrastingInk(Color background) {
    final luminance = background.computeLuminance();
    return luminance > AppTokens.luminanceInkThreshold
        ? AppTokens.neutral900
        : AppTokens.white;
  }

  static String _firstGrapheme(String value) {
    if (value.isEmpty) {
      return '';
    }
    return value.substring(0, 1);
  }
}
