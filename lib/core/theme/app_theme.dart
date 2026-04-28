import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFE11976);
  static const Color secondary = Color(0xFF5B5FF8);
  static const Color income = Color(0xFF17B26A);
  static const Color expense = Color(0xFFF04438);
  static const Color transfer = Color(0xFF2E90FA);
  static const Color surfaceTint = Color(0xFFF6F3FB);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.light,
      surface: Colors.white,
      surfaceContainer: const Color(0xFFF8F7FC),
      surfaceContainerHighest: const Color(0xFFF1EFF8),
      error: expense,
    );

    final textTheme = Typography.material2021().black.copyWith(
          displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
          headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          bodyMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFF5F6FB),
      canvasColor: const Color(0xFFF5F6FB),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF14161C),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: const Color(0xFF14161C)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.black.withValues(alpha: 0.04),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        labelStyle: textTheme.bodyMedium?.copyWith(color: const Color(0xFF23262F)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyLarge?.copyWith(color: const Color(0xFF98A2B3)),
        labelStyle: textTheme.bodyLarge?.copyWith(color: const Color(0xFF667085)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF344054),
          backgroundColor: Colors.white,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        height: 74,
        indicatorColor: const Color(0xFFFCE4F1),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primary
                : const Color(0xFF98A2B3),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.bodySmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? primary
                : const Color(0xFF98A2B3),
          ),
        ),
      ),
      dividerColor: const Color(0xFFEAECF0),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF101828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.dark,
      surface: const Color(0xFF10131F),
      surfaceContainer: const Color(0xFF171B2D),
      surfaceContainerHighest: const Color(0xFF1E2336),
      error: expense,
    );

    final textTheme = Typography.material2021().white.copyWith(
          displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
          headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          bodyMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF0E1220),
      canvasColor: const Color(0xFF0E1220),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.black.withValues(alpha: 0.22),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: scheme.surfaceContainer,
        selectedColor: primary.withValues(alpha: 0.24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyLarge?.copyWith(color: const Color(0xFF98A2B3)),
        labelStyle: textTheme.bodyLarge?.copyWith(color: const Color(0xFFB7C0D0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: scheme.surface,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFF9A8D4),
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF131827),
        surfaceTintColor: const Color(0xFF131827),
        height: 74,
        indicatorColor: primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFFFF7DB5)
                : const Color(0xFF98A2B3),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.bodySmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? const Color(0xFFFF7DB5)
                : const Color(0xFF98A2B3),
          ),
        ),
      ),
      dividerColor: const Color(0xFF2B3248),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE5E7EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: const Color(0xFF111827)),
      ),
    );
  }
}
