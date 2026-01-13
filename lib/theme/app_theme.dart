import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_messenger/config/theme_config.dart';

class AppTheme {
  final BuildContext context;

  // Constructor
  AppTheme(this.context);

  /// Get context using "of" syntax
  static AppTheme of(BuildContext context) => AppTheme(context);

  /// Get current theme mode => [dark or light]
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // <--- Build light theme --->
  ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightThemeBgColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: getSystemOverlayStyle(false),
        backgroundColor: lightThemeBgColor, // White app bar
        iconTheme: const IconThemeData(color: premiumBlack), // Black icons
        actionsIconTheme: const IconThemeData(
          color: premiumBlack,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700, // Bolder title
          color: premiumBlack,
          letterSpacing: -0.5,
        ),
      ),
      iconTheme: const IconThemeData(color: lightThemeTextColor, size: 24),
      textTheme: GoogleFonts.interTextTheme(customTextTheme).apply(
        bodyColor: lightThemeTextColor,
        displayColor: lightThemeTextColor,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLight,
        secondary: secondaryColor,
        surface: surfaceLight,
        error: errorColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight.withOpacity(0.9), // Slight transparency
        selectedItemColor: primaryColor,
        selectedIconTheme: const IconThemeData(color: primaryColor, size: 28), // Larger active icon
        unselectedItemColor: lightThemeSecondaryText,
        unselectedIconTheme: const IconThemeData(size: 26),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        showUnselectedLabels: true,
        elevation: 0, // Flat nav bar
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      dividerTheme: const DividerThemeData(
        color: lightDividerColor,
        thickness: 0.5,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0, // Flat cards
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          side: const BorderSide(color: lightDividerColor, width: 0.5), // Subtle border
        ),
      ),
    );
  }

  // <--- Build dark theme --->
  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkThemeBgColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: darkThemeBgColor, // Match scaffold for seamless look
        systemOverlayStyle: getSystemOverlayStyle(true),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      iconTheme: const IconThemeData(color: darkThemeTextColor, size: 24),
      // Asegurar contraste de íconos en modo oscuro
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),
      textTheme: GoogleFonts.interTextTheme(customTextTheme).apply(
        bodyColor: darkThemeTextColor,
        displayColor: darkThemeTextColor,
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryColor,
        primaryContainer: darkPrimaryContainer,
        secondary: secondaryColor,
        surface: surfaceDark,
        error: errorColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.black, // Negro puro
        selectedItemColor: primaryColor,
        unselectedItemColor: darkThemeSecondaryText,
        unselectedIconTheme: const IconThemeData(size: 26),
        selectedIconTheme: const IconThemeData(color: primaryColor, size: 28),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: inputDecorationTheme.copyWith(
        fillColor: darkSecondaryContainer,
        hintStyle: GoogleFonts.inter(color: darkThemeSecondaryText),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      dividerTheme: const DividerThemeData(
        color: darkDividerColor,
        thickness: 0.5,
      ),
      cardTheme: CardThemeData(
        color: darkPrimaryContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5), // Subtle glow border
        ),
      ),
    );
  }

  // Get text color
  Color? get textColor => isDarkMode ? darkThemeTextColor : lightThemeTextColor;

  // Build Custom TextTheme con Inter
  TextTheme get customTextTheme => TextTheme(
        displayLarge: GoogleFonts.inter(
            fontSize: 32.0, 
            fontWeight: FontWeight.w700, 
            color: textColor,
            letterSpacing: -0.5),
        displayMedium: GoogleFonts.inter(
            fontSize: 28.0, 
            fontWeight: FontWeight.w700, 
            color: textColor,
            letterSpacing: -0.5),
        displaySmall: GoogleFonts.inter(
            fontSize: 24.0, 
            fontWeight: FontWeight.w600, 
            color: textColor,
            letterSpacing: -0.5),
        headlineLarge: GoogleFonts.inter(
            fontSize: 22.0, 
            fontWeight: FontWeight.w600, 
            color: textColor,
            letterSpacing: -0.4),
        headlineMedium: GoogleFonts.inter(
            fontSize: 20.0, 
            fontWeight: FontWeight.w600, 
            color: textColor,
            letterSpacing: -0.3),
        headlineSmall: GoogleFonts.inter(
            fontSize: 17.0, // Standard iOS body size
            fontWeight: FontWeight.w600, 
            color: textColor,
            letterSpacing: -0.3),
        titleLarge: GoogleFonts.inter(
            fontSize: 17.0, 
            fontWeight: FontWeight.w600, 
            color: textColor,
            letterSpacing: -0.3),
        titleMedium: GoogleFonts.inter(
            fontSize: 16.0, 
            fontWeight: FontWeight.w500, 
            color: textColor,
            letterSpacing: -0.2),
        titleSmall: GoogleFonts.inter(
            fontSize: 14.0, 
            fontWeight: FontWeight.w500, 
            color: textColor,
            letterSpacing: -0.1),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16.0, 
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.4),
        bodyMedium: GoogleFonts.inter(
            fontSize: 15.0, // Slightly larger for better readability
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.4),
        bodySmall: GoogleFonts.inter(
            fontSize: 13.0, 
            fontWeight: FontWeight.w400,
            color: isDarkMode ? darkThemeSecondaryText : lightThemeSecondaryText,
            height: 1.3),
        labelLarge: GoogleFonts.inter(
            fontSize: 14.0, 
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(
            fontSize: 12.0, 
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: 0.1),
        labelSmall: GoogleFonts.inter(
            fontSize: 11.0, 
            fontWeight: FontWeight.w500,
            color: isDarkMode ? darkThemeSecondaryText : lightThemeSecondaryText,
            letterSpacing: 0.1),
      );

  final inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: greyLight,
    focusColor: primaryColor,
    hintStyle: GoogleFonts.inter(color: greyColor),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: defaultPadding,
      vertical: 12, // Slightly smaller vertical padding
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(defaultRadius),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(defaultRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: primaryColor, width: 1.5),
      borderRadius: BorderRadius.circular(defaultRadius),
    ),
  );

  final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0, // Flat button
      shadowColor: Colors.transparent,
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: 14,
      ),
    ),
  );

  final outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(width: 1.5, color: primaryColor),
      foregroundColor: primaryColor,
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: 14,
      ),
    ),
  );

  final dividerThemeData = const DividerThemeData(
    thickness: 0.5,
    color: greyLight,
  );
}



