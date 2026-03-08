import 'package:flutter/material.dart';

/// CropID app theme.
/// Earth tones + high-contrast for outdoor / bright sunlight use.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color backgroundBase = Color(0xFF111411);
  static const Color backgroundRaised = Color(0xFF171B18);
  static const Color panel = Color(0xFF1A1F1A);
  static const Color panelRaised = Color(0xFF212721);
  static const Color panelStroke = Color(0xFF343B33);
  static const Color primaryGreen = Color(0xFF99B24C);
  static const Color primaryGreenLight = Color(0xFFB7C96E);
  static const Color accentAmber = Color(0xFFD9AE5A);
  static const Color dangerRed = Color(0xFFD77A52);
  static const Color soilBrown = Color(0xFF725844);
  static const Color skyBlue = Color(0xFF6E899A);
  static const Color textPrimary = Color(0xFFF4ECDD);
  static const Color textMuted = Color(0xFFACB29F);
  static const Color textSoft = Color(0xFF7B8378);
  static const Color backgroundLight = Color(0xFFE7DEC8);

  static LinearGradient get appGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF171C17),
          backgroundBase,
          Color(0xFF0C0F0C),
        ],
      );

  static BoxDecoration panelDecoration({
    Color? borderColor,
    bool emphasized = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          emphasized ? const Color(0xFF242B24) : panelRaised,
          panel,
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: borderColor ?? panelStroke),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 24,
          offset: Offset(0, 14),
        ),
      ],
    );
  }

  static ThemeData get lightTheme => _buildTheme();
  static ThemeData get darkTheme => _buildTheme();

  static ThemeData _buildTheme() {
    const colorScheme = ColorScheme.dark(
      primary: primaryGreen,
      onPrimary: Color(0xFF14180F),
      secondary: accentAmber,
      onSecondary: Color(0xFF221A0E),
      error: dangerRed,
      onError: Colors.white,
      surface: panel,
      onSurface: textPrimary,
    );

    final textTheme = const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundBase,
      canvasColor: backgroundBase,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      dividerColor: panelStroke,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: panelStroke),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: panelStroke,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentAmber,
          foregroundColor: colorScheme.onSecondary,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: const BorderSide(color: panelStroke),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Color(0xFF131711),
        elevation: 0,
        extendedTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundRaised,
        hintStyle: const TextStyle(color: textSoft),
        labelStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: panelStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: panelStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundRaised,
        selectedColor: primaryGreen.withValues(alpha: 0.18),
        disabledColor: backgroundRaised,
        side: const BorderSide(color: panelStroke),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panelRaised,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: panelStroke),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 78,
        backgroundColor: panelRaised,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryGreen.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? primaryGreenLight
                : textSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color:
                states.contains(WidgetState.selected) ? textPrimary : textSoft,
          ),
        ),
      ),
    );
  }
}
