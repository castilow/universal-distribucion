import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Klink Brand Colors - Modern Messenger (Telegram-inspired)
// Klink Brand Colors - Premium Turquoise
const primaryColor = Color(0xFF00E5FF); // Cyan brillante / Turquesa eléctrico
const secondaryColor = Color(0xFF00B8D4); // Turquesa más profundo
const primaryLight = Color(0xFFE0F7FA); // Cyan muy claro
const primaryDark = Color(0xFF006064); // Cyan muy oscuro

// System Colors
const Color greyLight = Color(0xFFF8FAFC); // Slate 50
const Color greyColor = Color(0xFF64748B); // Slate 500
const Color accentColor = Color(0xFF00E5FF); // Cyan accent
const Color premiumBlack = Color(0xFF0F172A); // Slate 900
const Color errorColor = Color(0xFFFF3B30); // iOS Red
const Color successColor = Color(0xFF34C759); // iOS Green
const Color warningColor = Color(0xFFFFCC00); // iOS Yellow

// Surface Colors
const Color surfaceLight = Color(0xFFFFFFFF);
const Color surfaceDark = Color(0xFF0F172A); // Slate 900 (Rich dark)
const Color cardLight = Color(0xFFFFFFFF);
const Color cardDark = Color(0xFF1E293B); // Slate 800 (Rich dark card)

// Light Theme Colors
const Color lightThemeBgColor = Color(0xFFF1F5F9); // Slate 100
const Color lightThemeTextColor = Color(0xFF0F172A); // Slate 900
const Color lightThemeSecondaryText = Color(0xFF64748B); // Slate 500
const Color lightDividerColor = Color(0xFFE2E8F0); // Slate 200

// Dark Theme Colors
const Color darkThemeBgColor = Color(0xFF020617); // Slate 950 (Deepest dark)
const Color darkThemeTextColor = Color(0xFFF8FAFC); // Slate 50
const Color darkThemeSecondaryText = Color(0xFF94A3B8); // Slate 400
const Color darkPrimaryContainer = Color(0xFF0F172A); // Slate 900
const Color darkSecondaryContainer = Color(0xFF1E293B); // Slate 800
const Color darkDividerColor = Color(0xFF1E293B); // Slate 800

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
    color: const Color(0xFF00E5FF).withOpacity(0.15), // Cyan glow
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
    Color(0xFF00E5FF), // Cyan brillante
    Color(0xFF2979FF), // Blue electrico
  ],
);

const LinearGradient darkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
);

const LinearGradient modernPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF00E5FF),
    Color(0xFF00B8D4),
  ],
);

const LinearGradient modernDarkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1E293B), Color(0xFF334155)],
);

// Gradiente negro premium para elementos especiales
const LinearGradient premiumGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF0F172A),
    Color(0xFF006064),
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
