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
    const surfaceTint = Color(0xFFEAF3EF);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primarySoft = Color(0xFFE7F5EF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outlineVariant,
    );
    final baseTheme =
        ThemeData.from(colorScheme: colorScheme, useMaterial3: true);
    final textTheme = _buildIMetroTextTheme(baseTheme.textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I-Metro',
      scaffoldMessengerKey: appMessengerKey,
      theme: baseTheme.copyWith(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,
        canvasColor: background,
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: onSurface,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: textTheme.headlineSmall,
          toolbarTextStyle: textTheme.bodyMedium,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: DividerThemeData(
          color: outlineVariant.withOpacity(0.45),
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          labelStyle: textTheme.labelMedium?.copyWith(
            color: onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: textTheme.labelMedium?.copyWith(
            color: primary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: textTheme.bodyLarge?.copyWith(
            color: outline.withOpacity(0.55),
            fontWeight: FontWeight.w500,
          ),
          helperStyle: textTheme.bodySmall,
          errorStyle: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: outlineVariant.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: outlineVariant.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide:
                BorderSide(color: primary.withOpacity(0.95), width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primary,
            elevation: 0,
            textStyle: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: textTheme.labelLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: onSurface,
            textStyle: textTheme.labelLarge?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(color: outlineVariant.withOpacity(0.4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceTint,
          labelStyle: textTheme.labelMedium!,
          side: BorderSide(color: outlineVariant.withOpacity(0.25)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: textTheme.titleMedium,
          subtitleTextStyle: textTheme.bodySmall?.copyWith(height: 1.45),
          iconColor: onSurfaceVariant,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1D2A24),
          contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          surfaceTintColor: surface,
          titleTextStyle: textTheme.headlineSmall,
          contentTextStyle: textTheme.bodyMedium?.copyWith(height: 1.55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: BorderSide(color: outlineVariant.withOpacity(0.8), width: 1.2),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface.withOpacity(0.96),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return textTheme.labelMedium?.copyWith(
              fontSize: selected ? 13 : 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? primary : onSurfaceVariant.withOpacity(0.82),
              letterSpacing: 0.15,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(
              size: 22,
              color: selected ? primary : onSurfaceVariant.withOpacity(0.78),
            );
          }),
          indicatorColor: primarySoft,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 78,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: onSurfaceVariant.withOpacity(0.74),
          selectedLabelStyle: textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surface,
          surfaceTintColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: primary,
          selectionColor: primary.withOpacity(0.18),
          selectionHandleColor: primary,
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

TextTheme _buildIMetroTextTheme(TextTheme base) {
  const onSurface = Color(0xFF191C1E);
  const onSurfaceVariant = Color(0xFF4D5A54);

  return GoogleFonts.interTextTheme(base).copyWith(
    displayLarge: GoogleFonts.manrope(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
      color: onSurface,
    ),
    displayMedium: GoogleFonts.manrope(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.35,
      color: onSurface,
    ),
    displaySmall: GoogleFonts.manrope(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.25,
      color: onSurface,
    ),
    headlineLarge: GoogleFonts.manrope(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.3,
      color: onSurface,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.18,
      letterSpacing: -0.2,
      color: onSurface,
    ),
    headlineSmall: GoogleFonts.manrope(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: onSurface,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.24,
      color: onSurface,
    ),
    titleMedium: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.24,
      color: onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: onSurfaceVariant,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.45,
      color: onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: onSurface,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.25,
      letterSpacing: 0.1,
      color: onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.08,
      color: onSurfaceVariant,
    ),
  );
}
