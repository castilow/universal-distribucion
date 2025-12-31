import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Klink Brand Colors - Sun Black & Gold (Elegant)
const primaryColor = Color(0xFFD4AF37); // Metallic Gold
const secondaryColor = Color(0xFFB8860B); // Dark Golden Rod
const primaryLight = Color(0xFFFFF8E1); // Very light gold/cream
const primaryDark = Color(0xFF8B6508); // Dark Gold

// System Colors
const Color greyLight = Color(0xFFF8FAFC); // Slate 50
const Color greyColor = Color(0xFF64748B); // Slate 500
const Color accentColor = Color(0xFFD4AF37); // Gold accent
const Color premiumBlack = Color(0xFF000000); // Pure Black
const Color errorColor = Color(0xFFFF3B30); // iOS Red
const Color successColor = Color(0xFF34C759); // iOS Green
const Color warningColor = Color(0xFFFFCC00); // iOS Yellow

// Surface Colors
const Color surfaceLight = Color(0xFFFFFFFF);
const Color surfaceDark = Color(0xFF000000); // Pure Black
const Color cardLight = Color(0xFFFFFFFF);
const Color cardDark = Color(0xFF0A0A0A); // Nearly black for cards

// Light Theme Colors
const Color lightThemeBgColor = Color(0xFFF8F9FA); // Very light grey
const Color lightThemeTextColor = Color(0xFF000000); // Black
const Color lightThemeSecondaryText = Color(0xFF64748B); // Slate 500
const Color lightDividerColor = Color(0xFFE2E8F0); // Slate 200

// Dark Theme Colors
const Color darkThemeBgColor = Color(0xFF000000); // Pure Black
const Color darkThemeTextColor = Color(0xFFFFFFFF); // White
const Color darkThemeSecondaryText = Color(0xFF94A3B8); // Slate 400
const Color darkPrimaryContainer = Color(0xFF0A0A0A); // Nearly black
const Color darkSecondaryContainer = Color(0xFF161616); // Dark grey
const Color darkDividerColor = Color(0xFF1F1F1F); // Dark grey divider

//
// Be careful when changing others below unless you have a specific need.
//

// Other defaults - updated for modern design
const double defaultPadding = 16.0; // Standard mobile padding
const double defaultMargin = 16.0;
const double defaultRadius = 16.0; // More rounded for premium feel
const double smallRadius = 8.0;
const double largeRadius = 24.0;

/// Default Border Radius
final BorderRadius borderRadius = BorderRadius.circular(defaultRadius);
final BorderRadius smallBorderRadius = BorderRadius.circular(smallRadius);
final BorderRadius largeBorderRadius = BorderRadius.circular(largeRadius);

/// Default Bottom Sheet Radius
const BorderRadius bottomSheetRadius = BorderRadius.only(
  topLeft: Radius.circular(24),
  topRight: Radius.circular(24),
);

/// Default Top Sheet Radius
const BorderRadius topSheetRadius = BorderRadius.only(
  bottomLeft: Radius.circular(24),
  bottomRight: Radius.circular(24),
);

/// Modern Box Shadow - Soft & Diffused
final List<BoxShadow> boxShadow = [
  BoxShadow(
    blurRadius: 20,
    spreadRadius: 0,
    offset: const Offset(0, 4),
    color: const Color(0xFFD4AF37).withOpacity(0.15), // Gold glow
  ),
];

/// Subtle Box Shadow
final List<BoxShadow> subtleShadow = [
  BoxShadow(
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 2),
    color: Colors.black.withOpacity(0.04),
  ),
];

/// Card Shadow
final List<BoxShadow> cardShadow = [
  BoxShadow(
    blurRadius: 12,
    spreadRadius: 0,
    offset: const Offset(0, 4),
    color: Colors.black.withOpacity(0.06),
  ),
];

const Duration duration = Duration(milliseconds: 300); // Smoother animations

// Modern gradient definitions
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFD4AF37), // Metallic Gold
    Color(0xFFFDC830), // Bright Gold
  ],
);

const LinearGradient darkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF000000), Color(0xFF111111)],
);

const LinearGradient modernPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFD4AF37),
    Color(0xFFB8860B),
  ],
);

const LinearGradient modernDarkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0A0A0A), Color(0xFF1C1C1C)],
);

// Gradiente premium negro y dorado
const LinearGradient premiumGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF000000), // Pure Black
    Color(0xFF1C1C1C), // Deep charcoal
  ],
);

const LinearGradient glassGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
);

// <-- Get system overlay theme style -->
SystemUiOverlayStyle getSystemOverlayStyle(bool isDarkMode) {
  final Brightness brightness = isDarkMode ? Brightness.dark : Brightness.light;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // iOS only
    statusBarBrightness: brightness,
    // Android only
    statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    // Android only
    systemNavigationBarColor: isDarkMode ? darkThemeBgColor : lightThemeBgColor,
    // Android only
    systemNavigationBarIconBrightness: isDarkMode
        ? Brightness.light
        : Brightness.dark,
  );
}
