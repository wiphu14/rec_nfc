import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Application Configuration
/// 
/// จัดการการตั้งค่าทั้งหมดของแอพพลิเคชัน
class AppConfig {
  // ==========================================================================
  // APP INFORMATION
  // ==========================================================================
  
  static const String appName = 'NFC Event System';
  static const String appVersion = '1.0.0';

  // ==========================================================================
  // API CONFIGURATION
  // ==========================================================================
  
  /// Base URL สำหรับ Android Emulator
  /// - ใช้ 10.0.2.2 แทน localhost
  /// - เหมาะสำหรับการ run บน Android Studio Emulator
  static const String _emulatorBaseUrl = 'http://10.0.2.2/back_nfc/api';
  
  /// Base URL สำหรับ Real Device (มือถือจริง)
  /// - เปลี่ยนเป็น IP Address ของเครื่องที่รัน XAMPP
  /// - ตรวจสอบ IP: เปิด CMD พิมพ์ ipconfig (Windows) หรือ ifconfig (Mac/Linux)
  /// - คอมกับมือถือต้องอยู่ WiFi เดียวกัน
  static const String _realDeviceBaseUrl = 'http://192.168.1.130/back_nfc/api';
  
  /// Base URL สำหรับ iOS Simulator
  /// - iOS Simulator สามารถใช้ localhost ได้
  /*static const String _iosSimulatorBaseUrl = 'http://localhost/back_nfc/api';
  */
  /// Auto-select Base URL ตามสถานการณ์การใช้งาน
  /// 
  /// วิธีเปลี่ยน URL:
  /// 1. ถ้าใช้ Android Emulator -> ตั้ง useRealDevice = false
  /// 2. ถ้าใช้มือถือจริง -> ตั้ง useRealDevice = true
  static String get baseUrl {
    // ตั้งค่าตรงนี้ว่าจะใช้อุปกรณ์จริงหรือ emulator
    // true = ใช้มือถือจริง, false = ใช้ emulator
    const bool useRealDevice = true; // ✅ เปลี่ยนเป็น true เพราะใช้มือถือจริง
    
      // ใช้ IP Address สำหรับมือถือจริง
      return _realDeviceBaseUrl;
  }

  /// Connection timeout (30 วินาที)
  static const int connectionTimeout = 30000;
  
  /// Receive timeout (30 วินาที)
  static const int receiveTimeout = 30000;

  // ==========================================================================
  // COLORS
  // ==========================================================================
  
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  static const Color accentColor = Color(0xFF4F46E5);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // ==========================================================================
  // TEXT STYLES
  // ==========================================================================
  
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF555555),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF666666),
  );

  // ==========================================================================
  // SPACING
  // ==========================================================================
  
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 12.0;

  // ==========================================================================
  // ANIMATION
  // ==========================================================================
  
  static const Duration animationDuration = Duration(milliseconds: 300);

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================
  
  /// Print configuration สำหรับ debugging
  static void printConfig() {
    if (kDebugMode) {
      debugPrint('╔════════════════════════════════════════╗');
      debugPrint('║        APP CONFIGURATION               ║');
      debugPrint('╚════════════════════════════════════════╝');
      debugPrint('📱 App Name: $appName');
      debugPrint('🔢 Version: $appVersion');
      debugPrint('🌐 Base URL: $baseUrl');
      debugPrint('⏱️ Connection Timeout: ${connectionTimeout}ms');
      debugPrint('⏱️ Receive Timeout: ${receiveTimeout}ms');
      debugPrint('═══════════════════════════════════════════');
    }
  }

  /// ตรวจสอบว่าใช้ Real Device หรือไม่
  static bool get isUsingRealDevice {
    return baseUrl == _realDeviceBaseUrl;
  }

  /// ตรวจสอบว่าใช้ Emulator หรือไม่
  static bool get isUsingEmulator {
    return baseUrl == _emulatorBaseUrl;
  }
}