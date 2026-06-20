import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/values/app_constants.dart';

class AppTheme {
  // Professional Dark Palette (Slate inspired)
  static const Color darkBackground = Color(0xFF0F172A); 
  static const Color cardBackground = Color(0xFF1E293B); 

  static ThemeData getTheme(bool isDarkMode, Color primaryColor) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme);
    
    final scaffoldBg = isDarkMode ? darkBackground : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? cardBackground : Colors.white;
    
    // Improved contrast for input fields
    final inputFill = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black38;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardBg,
      hintColor: hintColor,
      colorScheme: isDarkMode 
        ? ColorScheme.dark(
            primary: primaryColor,
            secondary: primaryColor.withOpacity(0.8),
            surface: cardBackground,
            onSurface: Colors.white,
          )
        : ColorScheme.light(
            primary: primaryColor,
            secondary: primaryColor.withOpacity(0.8),
            surface: Colors.white,
            onSurface: const Color(0xFF0F172A),
          ),
      textTheme: textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
        decoration: TextDecoration.none,
      ).copyWith(
        titleMedium: textTheme.titleMedium?.copyWith(color: textColor, decoration: TextDecoration.none),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: textColor, decoration: TextDecoration.none),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: textColor, decoration: TextDecoration.none),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.3),
        selectionHandleColor: primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        prefixIconColor: isDarkMode ? Colors.white : Colors.black54,
        suffixIconColor: isDarkMode ? Colors.white : Colors.black54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white30 : const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white38 : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
        labelStyle: TextStyle(color: textColor, decoration: TextDecoration.none),
        prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        suffixStyle: TextStyle(color: textColor, decoration: TextDecoration.none),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? darkBackground : Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  // Fallback themes for initialization
  static final ThemeData darkTheme = ThemeData.dark();
  static final ThemeData lightTheme = ThemeData.light();
}
