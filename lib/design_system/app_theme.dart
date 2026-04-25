import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tokens.dart';

// -----------------------------------------------------------------------------
// AppTheme — ThemeData factories (Material 3, Poppins, all values from AppTokens)
// No ColorScheme.fromSeed — every color is explicit to prevent M3 tonal bleed.
// -----------------------------------------------------------------------------

abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light({Color primary = AppTokens.primary800}) {
    final base = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppTokens.textPrimary,
      displayColor: AppTokens.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTokens.pageBg,
      colorScheme: ColorScheme.light(
        primary: AppTokens.primary800,
        onPrimary: AppTokens.white,
        primaryContainer: AppTokens.primary100,
        onPrimaryContainer: AppTokens.primary800,
        secondary: AppTokens.primary800,
        onSecondary: AppTokens.white,
        secondaryContainer: AppTokens.primary50,
        onSecondaryContainer: AppTokens.primary800,
        tertiary: AppTokens.accent500,
        onTertiary: AppTokens.white,
        error: AppTokens.error500,
        onError: AppTokens.white,
        surface: AppTokens.cardBg,
        onSurface: AppTokens.textPrimary,
        onSurfaceVariant: AppTokens.textSecondary,
        outline: AppTokens.borderDefault,
        outlineVariant: AppTokens.borderDefault,
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: AppTokens.primary800,
        onInverseSurface: AppTokens.white,
        surfaceContainerHighest: AppTokens.surfaceSubtle,
        surfaceContainerHigh: AppTokens.surfaceSubtle,
        surfaceContainer: AppTokens.surfaceSubtle,
        surfaceContainerLow: AppTokens.cardBg,
        surfaceContainerLowest: AppTokens.cardBg,
      ),
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(color: AppTokens.textPrimary),
        displayMedium: base.displayMedium?.copyWith(color: AppTokens.textPrimary),
        displaySmall: base.displaySmall?.copyWith(color: AppTokens.textPrimary),
        headlineLarge: base.headlineLarge?.copyWith(color: AppTokens.textPrimary),
        headlineMedium: base.headlineMedium?.copyWith(color: AppTokens.textPrimary),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: AppTokens.pageTitleSize,
          fontWeight: AppTokens.pageTitleWeight,
          color: AppTokens.textPrimary,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: AppTokens.pageTitleSize,
          fontWeight: AppTokens.pageTitleWeight,
          color: AppTokens.textPrimary,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: AppTokens.sectionTitleSize,
          fontWeight: AppTokens.sectionTitleWeight,
          color: AppTokens.textPrimary,
        ),
        titleSmall: base.titleSmall?.copyWith(
          fontSize: AppTokens.bodySize,
          fontWeight: FontWeight.w500,
          color: AppTokens.textPrimary,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: AppTokens.bodySize,
          fontWeight: AppTokens.bodyWeight,
          color: AppTokens.textPrimary,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: AppTokens.bodySmSize,
          fontWeight: AppTokens.bodyWeight,
          color: AppTokens.textPrimary,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: AppTokens.captionSize,
          fontWeight: AppTokens.captionWeight,
          color: AppTokens.textSecondary,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: AppTokens.bodySmSize,
          fontWeight: FontWeight.w500,
          color: AppTokens.textPrimary,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: AppTokens.captionSize,
          fontWeight: FontWeight.w500,
          color: AppTokens.textSecondary,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: AppTokens.captionSize,
          fontWeight: FontWeight.w400,
          color: AppTokens.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.cardBg,
        foregroundColor: AppTokens.textPrimary,
        elevation: AppTokens.space0,
        scrolledUnderElevation: AppTokens.space0,
        toolbarHeight: AppTokens.topbarHeight,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: AppTokens.pageTitleSize,
          fontWeight: AppTokens.pageTitleWeight,
          color: AppTokens.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppTokens.textSecondary,
          size: AppTokens.iconSizeMd,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary800,
          foregroundColor: AppTokens.white,
          minimumSize: Size(AppTokens.space0, AppTokens.buttonHeightMd),
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          elevation: AppTokens.space0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppTokens.bodySmSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.error500,
          minimumSize: Size(AppTokens.space0, AppTokens.buttonHeightMd),
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          side: const BorderSide(color: AppTokens.error500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppTokens.bodySmSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primary800,
          minimumSize: Size(AppTokens.space0, AppTokens.buttonHeightMd),
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppTokens.bodySmSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(AppTokens.filledSecondarySurface),
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
              borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.poppins(
              fontSize: AppTokens.bodySmSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.cardBg,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space0,
        ),
        constraints: BoxConstraints(minHeight: AppTokens.inputHeight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(color: AppTokens.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(color: AppTokens.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(
            color: AppTokens.borderFocus,
            width: AppTokens.focusRingWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(color: AppTokens.error500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(
            color: AppTokens.error500,
            width: AppTokens.focusRingWidth,
          ),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: AppTokens.bodySmSize,
          color: AppTokens.hintColor,
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: AppTokens.captionSize,
          color: AppTokens.error500,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppTokens.fieldLabelSize,
          fontWeight: AppTokens.fieldLabelWeight,
          color: AppTokens.labelColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.borderDefault,
        thickness: AppTokens.borderWidthSm,
        space: AppTokens.space0,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.cardBg,
        elevation: AppTokens.space0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          side: const BorderSide(color: AppTokens.borderDefault),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.surfaceSubtle,
        labelStyle: GoogleFonts.poppins(
          fontSize: AppTokens.chipSize,
          fontWeight: AppTokens.chipWeight,
          color: AppTokens.textSecondary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space2,
          vertical: AppTokens.space0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.chipRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        minLeadingWidth: AppTokens.space0,
        contentPadding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
        minVerticalPadding: AppTokens.space1,
        visualDensity: VisualDensity.compact,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppTokens.white,
        elevation: AppTokens.elevationPopupMenu,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: AppTokens.textBase,
          color: AppTokens.textPrimary,
        ),
      ),
    );
  }

  // Dark theme mirrors light for now — no tonal seed colors.
  static ThemeData dark({Color primary = AppTokens.primary800}) {
    final base = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppTokens.neutral100,
      displayColor: AppTokens.neutral100,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.neutral900,
      colorScheme: ColorScheme.dark(
        primary: AppTokens.primary800,
        onPrimary: AppTokens.white,
        primaryContainer: AppTokens.primary700,
        onPrimaryContainer: AppTokens.white,
        secondary: AppTokens.primary800,
        onSecondary: AppTokens.white,
        secondaryContainer: AppTokens.primary700,
        onSecondaryContainer: AppTokens.white,
        tertiary: AppTokens.accent500,
        onTertiary: AppTokens.white,
        error: AppTokens.error500,
        onError: AppTokens.white,
        surface: AppTokens.neutral800,
        onSurface: AppTokens.neutral100,
        onSurfaceVariant: AppTokens.neutral400,
        outline: AppTokens.neutral700,
        outlineVariant: AppTokens.neutral700,
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: AppTokens.neutral100,
        onInverseSurface: AppTokens.neutral900,
        surfaceContainerHighest: AppTokens.neutral700,
        surfaceContainerHigh: AppTokens.neutral700,
        surfaceContainer: AppTokens.neutral800,
        surfaceContainerLow: AppTokens.neutral800,
        surfaceContainerLowest: AppTokens.neutral900,
      ),
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(color: AppTokens.neutral100),
        displayMedium: base.displayMedium?.copyWith(color: AppTokens.neutral100),
        displaySmall: base.displaySmall?.copyWith(color: AppTokens.neutral100),
        headlineLarge: base.headlineLarge?.copyWith(color: AppTokens.neutral100),
        headlineMedium: base.headlineMedium?.copyWith(color: AppTokens.neutral100),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: AppTokens.pageTitleSize,
          fontWeight: AppTokens.pageTitleWeight,
          color: AppTokens.neutral100,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: AppTokens.pageTitleSize,
          fontWeight: AppTokens.pageTitleWeight,
          color: AppTokens.neutral100,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: AppTokens.sectionTitleSize,
          fontWeight: AppTokens.sectionTitleWeight,
          color: AppTokens.neutral100,
        ),
        titleSmall: base.titleSmall?.copyWith(
          fontSize: AppTokens.bodySize,
          fontWeight: FontWeight.w500,
          color: AppTokens.neutral100,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: AppTokens.bodySize,
          fontWeight: AppTokens.bodyWeight,
          color: AppTokens.neutral100,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: AppTokens.bodySmSize,
          fontWeight: AppTokens.bodyWeight,
          color: AppTokens.neutral100,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: AppTokens.captionSize,
          fontWeight: AppTokens.captionWeight,
          color: AppTokens.neutral400,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: AppTokens.bodySmSize,
          fontWeight: FontWeight.w500,
          color: AppTokens.neutral100,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: AppTokens.captionSize,
          fontWeight: FontWeight.w500,
          color: AppTokens.neutral400,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: AppTokens.captionSize,
          fontWeight: FontWeight.w400,
          color: AppTokens.neutral500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.neutral800,
        foregroundColor: AppTokens.neutral100,
        elevation: AppTokens.space0,
        scrolledUnderElevation: AppTokens.space0,
        toolbarHeight: AppTokens.topbarHeight,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: AppTokens.pageTitleSize,
          fontWeight: AppTokens.pageTitleWeight,
          color: AppTokens.neutral100,
        ),
        iconTheme: const IconThemeData(
          color: AppTokens.neutral100,
          size: AppTokens.iconSizeMd,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary800,
          foregroundColor: AppTokens.white,
          minimumSize: Size(AppTokens.space0, AppTokens.buttonHeightMd),
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          elevation: AppTokens.space0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppTokens.bodySmSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.accent500,
          minimumSize: Size(AppTokens.space0, AppTokens.buttonHeightMd),
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
          side: const BorderSide(color: AppTokens.accent500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppTokens.bodySmSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primary100,
          minimumSize: Size(AppTokens.space0, AppTokens.buttonHeightMd),
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppTokens.bodySmSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(AppTokens.primary700),
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
              borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.poppins(
              fontSize: AppTokens.bodySmSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.neutral800,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space0,
        ),
        constraints: BoxConstraints(minHeight: AppTokens.inputHeight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(color: AppTokens.neutral700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(color: AppTokens.neutral700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(
            color: AppTokens.borderFocus,
            width: AppTokens.focusRingWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(color: AppTokens.error500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.inputRadius),
          borderSide: const BorderSide(
            color: AppTokens.error500,
            width: AppTokens.focusRingWidth,
          ),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: AppTokens.bodySmSize,
          color: AppTokens.neutral500,
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: AppTokens.captionSize,
          color: AppTokens.error500,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppTokens.fieldLabelSize,
          fontWeight: AppTokens.fieldLabelWeight,
          color: AppTokens.neutral400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.neutral700,
        thickness: AppTokens.borderWidthSm,
        space: AppTokens.space0,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.neutral800,
        elevation: AppTokens.space0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          side: const BorderSide(color: AppTokens.neutral700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.neutral700,
        labelStyle: GoogleFonts.poppins(
          fontSize: AppTokens.chipSize,
          fontWeight: AppTokens.chipWeight,
          color: AppTokens.neutral300,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space2,
          vertical: AppTokens.space0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.chipRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        minLeadingWidth: AppTokens.space0,
        contentPadding: EdgeInsets.symmetric(horizontal: AppTokens.space3),
        minVerticalPadding: AppTokens.space1,
        visualDensity: VisualDensity.compact,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppTokens.neutral800,
        elevation: AppTokens.elevationPopupMenu,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: AppTokens.textBase,
          color: AppTokens.neutral100,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ThemeConfig — persisted user preferences
// -----------------------------------------------------------------------------

class ThemeConfig {
  static const String persistKey = 'interics:theme';

  final Color brandColor;
  final ThemeMode mode;

  const ThemeConfig({
    this.brandColor = AppTokens.primary800,
    this.mode = ThemeMode.light,
  });

  ThemeConfig copyWith({Color? brandColor, ThemeMode? mode}) {
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
    return ThemeConfig(brandColor: color, mode: ThemeMode.values[index]);
  }

  static Future<ThemeConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(persistKey);
    if (raw == null || raw.isEmpty) return const ThemeConfig();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return _fromJson(decoded);
      if (decoded is Map) return _fromJson(Map<String, dynamic>.from(decoded));
      return const ThemeConfig();
    } on Object {
      return const ThemeConfig();
    }
  }

  static Future<void> save(ThemeConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(persistKey, jsonEncode(config._toJson()));
  }
}

// -----------------------------------------------------------------------------
// ThemeNotifier — reactive theme + persistence
// -----------------------------------------------------------------------------

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier(ThemeConfig config) : _config = config;

  ThemeConfig _config;

  ThemeConfig get config => _config;

  ThemeData get currentTheme {
    final brightness = _resolveBrightness();
    final primary = _config.brandColor;
    return brightness == Brightness.dark
        ? AppTheme.dark(primary: primary)
        : AppTheme.light(primary: primary);
  }

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

  void setMode(ThemeMode mode) {
    _config = _config.copyWith(mode: mode);
    _persist();
    notifyListeners();
  }

  void setBrandColor(Color color) {
    _config = _config.copyWith(brandColor: color);
    _persist();
    notifyListeners();
  }

  void toggleMode() {
    final Brightness effective = _resolveBrightness();
    final ThemeMode next =
        effective == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }
}
