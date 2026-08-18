import 'package:flutter/material.dart';

abstract final class AppColors {
  static const orange = Color(0xFFFF7C11);
  static const orangeDark = Color(0xFFE86200);
  static const peach = Color(0xFFFFBE89);
  static const coral = Color(0xFFFF6C56);
  static const blush = Color(0xFFFA9788);
  static const cream = Color(0xFFFFF3E8);
  static const surface = Color(0xFFF8F8F6);
  static const surfaceMuted = Color(0xFFF1F1EE);
  static const ink = Color(0xFF20201E);
  static const inkSoft = Color(0xFF696965);
  static const line = Color(0xFFE7E7E2);
  static const lavender = Color(0xFFC78AF7);
  static const blue = Color(0xFF568AF7);
  static const yellow = Color(0xFFFFE75C);
  static const success = Color(0xFF1A7F37);
  static const successSoft = Color(0xFFEAF6ED);
  static const warning = Color(0xFF8A5A00);
  static const warningSoft = Color(0xFFFFF4D6);
  static const error = Color(0xFFB42318);
  static const errorSoft = Color(0xFFFDECEA);
  static const info = Color(0xFF275DAD);
  static const infoSoft = Color(0xFFEAF2FF);
}

abstract final class AppRadii {
  static const small = 8.0;
  static const control = 12.0;
  static const card = 16.0;
  static const large = 24.0;
  static const pill = 999.0;
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const page = 20.0;
  static const lg = 24.0;
  static const section = 32.0;
  static const xl = 40.0;
  static const xxl = 48.0;
}

abstract final class AppTypeScale {
  static const navigation = 11.0;
  static const caption = 12.0;
  static const compactLabel = 13.0;
  static const label = 14.0;
  static const body = 14.0;
  static const bodyLarge = 16.0;
}

abstract final class AppControlSize {
  static const buttonHeight = 52.0;
  static const compactHeight = 44.0;
  static const compactVisualHeight = 36.0;
  static const minTouchTarget = 44.0;
  static const buttonHorizontalPadding = 16.0;
  static const compactHorizontalPadding = 12.0;
  static const contentGap = 8.0;
}

abstract final class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];

  static const control = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 180);
  static const slow = Duration(milliseconds: 240);
  static const max = Duration(milliseconds: 320);
}

abstract final class AppTheme {
  static Color? _mobileOverlay(Set<WidgetState> states) {
    if (states.contains(WidgetState.hovered)) return Colors.transparent;
    if (states.contains(WidgetState.pressed)) {
      return AppColors.ink.withValues(alpha: 0.08);
    }
    return null;
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.orange,
      onPrimary: AppColors.ink,
      secondary: AppColors.coral,
      surface: Colors.white,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Pretendard',
      hoverColor: Colors.transparent,
      splashColor: AppColors.ink.withValues(alpha: 0.06),
      highlightColor: AppColors.ink.withValues(alpha: 0.04),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.29,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          height: 1.36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.44,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypeScale.body,
          height: 1.5,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.15,
        ),
        bodySmall: TextStyle(
          fontSize: AppTypeScale.caption,
          height: 1.5,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
        ),
        labelLarge: TextStyle(
          fontSize: AppTypeScale.label,
          height: 1.43,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        labelMedium: TextStyle(
          fontSize: AppTypeScale.compactLabel,
          height: 1.38,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        labelSmall: TextStyle(
          fontSize: AppTypeScale.caption,
          height: 1.33,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.05,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x18000000),
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppControlSize.buttonHeight),
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.orange,
          disabledForegroundColor: AppColors.inkSoft,
          disabledBackgroundColor: AppColors.surfaceMuted,
          padding: const EdgeInsets.symmetric(
            horizontal: AppControlSize.buttonHorizontalPadding,
          ),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: AppTypeScale.label,
            height: 1.43,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(_mobileOverlay),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppControlSize.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppControlSize.buttonHorizontalPadding,
          ),
          alignment: Alignment.center,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: AppTypeScale.label,
            height: 1.43,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(_mobileOverlay),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.inkSoft,
          minimumSize: const Size(
            AppControlSize.minTouchTarget,
            AppControlSize.compactHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppControlSize.compactHorizontalPadding,
          ),
          alignment: Alignment.center,
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: AppTypeScale.label,
            height: 1.43,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(_mobileOverlay),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppControlSize.minTouchTarget),
          padding: const EdgeInsets.all(10),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(_mobileOverlay),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Pretendard',
          fontSize: AppTypeScale.body,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF9C9894)),
        prefixIconColor: AppColors.inkSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppControlSize.buttonHorizontalPadding,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
    );
  }
}
