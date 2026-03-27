import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores Principais (Velocity Noir)
  static const Color primary = Color(0xFFFFB3B1);
  static const Color primaryContainer = Color(0xFFFF535B);
  static const Color onPrimaryContainer = Color(0xFF5B000E);
  
  static const Color background = Color(0xFF11131C);
  static const Color surface = Color(0xFF11131C);
  
  // Tonal Layering
  static const Color surfaceContainerLowest = Color(0xFF0C0E17);
  static const Color surfaceContainerLow = Color(0xFF191B24);
  static const Color surfaceContainer = Color(0xFF1D1F29);
  static const Color surfaceContainerHigh = Color(0xFF282933);
  static const Color surfaceContainerHighest = Color(0xFF32343E);
  
  // Acentos
  static const Color tertiary = Color(0xFF6FD8C8); // Success
  static const Color secondary = Color(0xFFFFD795);
  static const Color secondaryContainer = Color(0xFFFBB400); // Alert
  static const Color onSecondaryContainer = Color(0xFF694900);

  // Utilitários
  static const Color surfaceVariant = Color(0xFF32343E);
  static const Color outlineVariant = Color(0xFF5B403F);
  static const Color onSurface = Color(0xFFE1E1EF);
  static const Color onSurfaceVariant = Color(0xFFE4BEBC);
  static const Color error = Color(0xFFFFB4AB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.black,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
            titleLarge: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
            bodyLarge: GoogleFonts.inter(fontSize: 16, color: onSurface),
            bodyMedium: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant),
            labelSmall: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimaryContainer,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999), // "full" radius from DESIGN.md
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerHigh, // Default card color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0, // ambient shadows handled manually, no hard 1px borders
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // md (0.75rem)
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.2)), // "Ghost Border" Fallback
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryContainer.withValues(alpha: 0.4)), // Active State
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent, // Handled implicitly by Glassmorphism containers
        elevation: 0,
      ),
    );
  }
}
