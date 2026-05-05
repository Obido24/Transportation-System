import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_messenger.dart';
import 'routes.dart';
import 'widgets/global_connectivity_overlay.dart';

class IMetroApp extends StatelessWidget {
  const IMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0E3B2E);
    const background = Color(0xFFF7F9FB);
    const surface = Color(0xFFFFFFFF);
    const surfaceVariant = Color(0xFFF2F4F6);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    final baseTheme = ThemeData.from(colorScheme: colorScheme);
    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.manrope(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.7,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.6,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onSurfaceVariant,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: surface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
        color: onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.15,
        color: onSurfaceVariant,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I-Metro',
      scaffoldMessengerKey: appMessengerKey,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: background,
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: onSurface,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: textTheme.titleLarge,
          toolbarTextStyle: textTheme.bodyMedium,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceVariant,
          labelStyle: textTheme.labelMedium?.copyWith(color: onSurfaceVariant),
          hintStyle: textTheme.bodyMedium?.copyWith(color: outline.withOpacity(0.55)),
          helperStyle: textTheme.bodySmall,
          errorStyle: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            side: BorderSide(color: outlineVariant.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariant,
          labelStyle: textTheme.labelMedium!,
          side: BorderSide(color: outlineVariant.withOpacity(0.25)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      ),
      builder: (context, child) => GlobalConnectivityOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
