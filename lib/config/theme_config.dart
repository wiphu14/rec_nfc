// lib/config/theme_config.dart

import 'package:flutter/material.dart';
import 'app_config.dart';

/// Theme Configuration
/// 
/// กำหนด Theme ของแอพทั้งหมด
class ThemeConfig {
  /// Get main theme
  static ThemeData getMainTheme() {
    return ThemeData(
      primaryColor: AppConfig.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryColor,
        primary: AppConfig.primaryColor,
        secondary: AppConfig.secondaryColor,
      ),
      scaffoldBackgroundColor: AppConfig.backgroundColor,
      useMaterial3: true,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }
}