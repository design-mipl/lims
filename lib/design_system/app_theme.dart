import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tokens.dart';

// -----------------------------------------------------------------------------
// AppTheme — ThemeData factories (Material 3, Inter, all values from AppTokens)
// -----------------------------------------------------------------------------

/// Centralized [ThemeData] for the app. All sizing and colors come from [AppTokens].
abstract final class AppTheme {
  const AppTheme._();

  // --- Light theme ---

  /// Enterprise light theme: navy primary, dense controls, Inter typography.
  static ThemeData light({Color primary = AppTokens.primary800}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: AppTokens.white,
      secondary: AppTokens.primary100,
      onSecondary: AppTokens.primary800,
      error: AppTokens.error500,
      onError: AppTokens.white,
      surface: AppTokens.surfaceCard,
      onSurface: AppTokens.neutral900,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.background,
      appBarTheme: _lightAppBarTheme(),
      cardTheme: _lightCardTheme(),
      elevatedButtonTheme: _lightElevatedButtonTheme(),
      filledButtonTheme: _lightFilledButtonTheme(),
      textButtonTheme: _lightTextButtonTheme(),
      outlinedButtonTheme: _lightOutlinedButtonTheme(),
      inputDecorationTheme: _lightInputDecorationTheme(),
      dividerTheme: _lightDividerTheme(),
      listTileTheme: _listTileTheme(),
      popupMenuTheme: _lightPopupMenuTheme(),
      textTheme: _textTheme(AppTokens.neutral900),
    );
  }

  // --- Dark theme ---

  /// Dark counterpart: neutral surfaces, light text, same primary and accent.
  static ThemeData dark({Color primary = AppTokens.primary800}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: AppTokens.white,
      secondary: AppTokens.primary100,
      onSecondary: AppTokens.primary800,
      error: AppTokens.error500,
      onError: AppTokens.white,
      surface: AppTokens.neutral800,
      onSurface: AppTokens.neutral100,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.neutral900,
      appBarTheme: _darkAppBarTheme(),
      cardTheme: _darkCardTheme(),
      elevatedButtonTheme: _darkElevatedButtonTheme(),
      filledButtonTheme: _darkFilledButtonTheme(),
      textButtonTheme: _darkTextButtonTheme(),
      outlinedButtonTheme: _darkOutlinedButtonTheme(),
      inputDecorationTheme: _darkInputDecorationTheme(),
      dividerTheme: _darkDividerTheme(),
      listTileTheme: _listTileTheme(),
      popupMenuTheme: _darkPopupMenuTheme(),
      textTheme: _textTheme(AppTokens.neutral100),
    );
  }

  // --- Light component themes ---

  static AppBarTheme _lightAppBarTheme() {
    return AppBarTheme(
      backgroundColor: AppTokens.white,
      foregroundColor: AppTokens.neutral900,
      elevation: AppTokens.space0,
      scrolledUnderElevation: AppTokens.space0,
      toolbarHeight: AppTokens.topbarHeight,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textMd,
        fontWeight: AppTokens.weightSemibold,
        color: AppTokens.neutral900,
      ),
      iconTheme: IconThemeData(
        color: AppTokens.neutral600,
        size: AppTokens.iconSizeMd,
      ),
    );
  }

  static CardThemeData _lightCardTheme() {
    return CardThemeData(
      color: AppTokens.surfaceCard,
      elevation: AppTokens.space0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: BorderSide(
          color: AppTokens.border,
          width: AppTokens.borderWidthHairline,
        ),
      ),
    );
  }

  static ElevatedButtonThemeData _lightElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppTokens.primary800),
        foregroundColor: const WidgetStatePropertyAll(AppTokens.white),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space4),
        ),
        elevation: const WidgetStatePropertyAll(AppTokens.space0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return AppTokens.primary700
                .withValues(alpha: AppTokens.overlayPrimaryAlpha);
          }
          return null;
        }),
      ),
    );
  }

  static FilledButtonThemeData _lightFilledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll(AppTokens.filledSecondarySurface),
        foregroundColor: const WidgetStatePropertyAll(AppTokens.primary800),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space4),
        ),
        elevation: const WidgetStatePropertyAll(AppTokens.space0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
      ),
    );
  }

  static TextButtonThemeData _lightTextButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppTokens.primary800),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space3),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _lightOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppTokens.accent500),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space4),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(
            color: AppTokens.accent500,
            width: AppTokens.borderWidthSm,
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme _lightInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.neutral200,
          width: AppTokens.borderWidthHairline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.neutral200,
          width: AppTokens.borderWidthHairline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.primary800,
          width: AppTokens.borderWidthMd,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.error500,
          width: AppTokens.borderWidthSm,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.error500,
          width: AppTokens.borderWidthMd,
        ),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        color: AppTokens.neutral500,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        color: AppTokens.neutral400,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textXs,
        color: AppTokens.error500,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        color: AppTokens.primary800,
      ),
    );
  }

  static DividerThemeData _lightDividerTheme() {
    return DividerThemeData(
      color: AppTokens.borderLight,
      thickness: AppTokens.borderWidthHairline,
      space: AppTokens.space0,
    );
  }

  // --- Dark component themes ---

  static AppBarTheme _darkAppBarTheme() {
    return AppBarTheme(
      backgroundColor: AppTokens.neutral800,
      foregroundColor: AppTokens.neutral100,
      elevation: AppTokens.space0,
      scrolledUnderElevation: AppTokens.space0,
      toolbarHeight: AppTokens.topbarHeight,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textMd,
        fontWeight: AppTokens.weightSemibold,
        color: AppTokens.neutral100,
      ),
      iconTheme: IconThemeData(
        color: AppTokens.neutral100,
        size: AppTokens.iconSizeMd,
      ),
    );
  }

  static CardThemeData _darkCardTheme() {
    return CardThemeData(
      color: AppTokens.neutral800,
      elevation: AppTokens.space0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: BorderSide(
          color: AppTokens.neutral700,
          width: AppTokens.borderWidthHairline,
        ),
      ),
    );
  }

  static ElevatedButtonThemeData _darkElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppTokens.primary800),
        foregroundColor: const WidgetStatePropertyAll(AppTokens.white),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space4),
        ),
        elevation: const WidgetStatePropertyAll(AppTokens.space0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return AppTokens.primary700
                .withValues(alpha: AppTokens.overlayPrimaryAlpha);
          }
          return null;
        }),
      ),
    );
  }

  static FilledButtonThemeData _darkFilledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll(AppTokens.filledSecondarySurface),
        foregroundColor: const WidgetStatePropertyAll(AppTokens.primary800),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space4),
        ),
        elevation: const WidgetStatePropertyAll(AppTokens.space0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
      ),
    );
  }

  static TextButtonThemeData _darkTextButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppTokens.primary800),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space3),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _darkOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppTokens.accent500),
        minimumSize: WidgetStateProperty.all(
          Size(AppTokens.space0, AppTokens.buttonHeightMd),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppTokens.space4),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(
            color: AppTokens.accent500,
            width: AppTokens.borderWidthSm,
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTokens.textBase,
            fontWeight: AppTokens.weightMedium,
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme _darkInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.neutral800,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.neutral700,
          width: AppTokens.borderWidthHairline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.neutral700,
          width: AppTokens.borderWidthHairline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.primary800,
          width: AppTokens.borderWidthMd,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.error500,
          width: AppTokens.borderWidthSm,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(
          color: AppTokens.error500,
          width: AppTokens.borderWidthMd,
        ),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        color: AppTokens.neutral400,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        color: AppTokens.neutral500,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textXs,
        color: AppTokens.error500,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        color: AppTokens.neutral100,
      ),
    );
  }

  static DividerThemeData _darkDividerTheme() {
    return DividerThemeData(
      color: AppTokens.neutral700,
      thickness: AppTokens.borderWidthHairline,
      space: AppTokens.space0,
    );
  }

  // --- Shared component themes ---

  static ListTileThemeData _listTileTheme() {
    return ListTileThemeData(
      dense: true,
      minLeadingWidth: AppTokens.space0,
      contentPadding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
      minVerticalPadding: AppTokens.space1,
      visualDensity: VisualDensity.compact,
    );
  }

  static PopupMenuThemeData _lightPopupMenuTheme() {
    return PopupMenuThemeData(
      color: AppTokens.white,
      elevation: AppTokens.elevationPopupMenu,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textBase,
        color: AppTokens.neutral700,
      ),
    );
  }

  static PopupMenuThemeData _darkPopupMenuTheme() {
    return PopupMenuThemeData(
      color: AppTokens.neutral800,
      elevation: AppTokens.elevationPopupMenu,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textBase,
        color: AppTokens.neutral100,
      ),
    );
  }

  /// Text roles for enterprise UI; [color] is body/heading ink on the surface.
  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.text3xl,
        fontWeight: AppTokens.weightSemibold,
        color: color,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.text2xl,
        fontWeight: AppTokens.weightSemibold,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textXl,
        fontWeight: AppTokens.weightSemibold,
        color: color,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textMd,
        fontWeight: AppTokens.weightMedium,
        color: color,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textBase,
        fontWeight: AppTokens.weightMedium,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textMd,
        fontWeight: AppTokens.weightRegular,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textBase,
        fontWeight: AppTokens.weightRegular,
        color: color,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        fontWeight: AppTokens.weightRegular,
        color: color,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textBase,
        fontWeight: AppTokens.weightMedium,
        color: color,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textSm,
        fontWeight: AppTokens.weightMedium,
        color: color,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppTokens.textXs,
        fontWeight: AppTokens.weightMedium,
        color: color,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ThemeConfig — persisted user preferences
// -----------------------------------------------------------------------------

/// Serializable theme preferences (brand color + light/dark/system mode).
class ThemeConfig {
  /// SharedPreferences key for JSON payload.
  static const String persistKey = 'interics:theme';

  /// Brand seed applied to [ColorScheme.primary] in both themes.
  final Color brandColor;

  /// Active [ThemeMode] (light, dark, or follow system).
  final ThemeMode mode;

  const ThemeConfig({
    this.brandColor = AppTokens.primary800,
    this.mode = ThemeMode.light,
  });

  /// Returns a copy with selective overrides.
  ThemeConfig copyWith({
    Color? brandColor,
    ThemeMode? mode,
  }) {
    return ThemeConfig(
      brandColor: brandColor ?? this.brandColor,
      mode: mode ?? this.mode,
    );
  }

  Map<String, Object?> _toJson() => <String, Object?>{
        'brand': brandColor.toARGB32(),
        'mode': mode.index,
      };

  static ThemeConfig _fromJson(Map<String, dynamic> json) {
    final brand = json['brand'];
    final modeRaw = json['mode'];
    final color = brand is int ? Color(brand) : AppTokens.primary800;
    var index = modeRaw is int ? modeRaw : ThemeMode.light.index;
    if (index < 0 || index >= ThemeMode.values.length) {
      index = ThemeMode.light.index;
    }
    return ThemeConfig(
      brandColor: color,
      mode: ThemeMode.values[index],
    );
  }

  /// Loads [ThemeConfig] from disk, or defaults when missing / invalid.
  static Future<ThemeConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(persistKey);
    if (raw == null || raw.isEmpty) {
      return const ThemeConfig();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _fromJson(decoded);
      }
      if (decoded is Map) {
        return _fromJson(Map<String, dynamic>.from(decoded));
      }
      return const ThemeConfig();
    } on Object {
      return const ThemeConfig();
    }
  }

  /// Persists this configuration under [persistKey].
  static Future<void> save(ThemeConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(persistKey, jsonEncode(config._toJson()));
  }
}

// -----------------------------------------------------------------------------
// ThemeNotifier — reactive theme + persistence
// -----------------------------------------------------------------------------

/// Holds [ThemeConfig], exposes resolved [ThemeData], and persists changes.
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier(ThemeConfig config) : _config = config;

  ThemeConfig _config;

  /// Latest user configuration (brand + mode).
  ThemeConfig get config => _config;

  /// Resolved theme for the current [config] and platform brightness.
  ThemeData get currentTheme {
    final brightness = _resolveBrightness();
    final primary = _config.brandColor;
    return brightness == Brightness.dark
        ? AppTheme.dark(primary: primary)
        : AppTheme.light(primary: primary);
  }

  /// Whether the effective scheme is dark.
  bool get isDark => _resolveBrightness() == Brightness.dark;

  Brightness _resolveBrightness() {
    switch (_config.mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  void _persist() {
    unawaited(ThemeConfig.save(_config));
  }

  /// Sets the active [ThemeMode] and saves.
  void setMode(ThemeMode mode) {
    _config = _config.copyWith(mode: mode);
    _persist();
    notifyListeners();
  }

  /// Updates the brand primary color and saves.
  void setBrandColor(Color color) {
    _config = _config.copyWith(brandColor: color);
    _persist();
    notifyListeners();
  }

  /// Toggles between light and dark based on the effective brightness.
  void toggleMode() {
    final Brightness effective = _resolveBrightness();
    final ThemeMode next =
        effective == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }
}
