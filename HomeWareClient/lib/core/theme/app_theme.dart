import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

// 主题配置
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    
    // AppBar 主题
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    
    // Card 主题
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // InputDecoration 主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    // BottomNavigationBar 主题
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    // Divider 主题
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    
    // FloatingActionButton 主题
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
    ),
  );
}