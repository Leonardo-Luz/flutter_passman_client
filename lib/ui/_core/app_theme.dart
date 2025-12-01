import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData appTheme = ThemeData.dark().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:  WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.backgroundHoveredBarColor;
        }

        return AppColors.backgroundBarColor;
      }),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.mainColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.black),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          } else if (states.contains(WidgetState.pressed)) {
            return AppColors.pressedColor;
          }
          return AppColors.mainColor;
        }),
      ),
    ),
  );
}
