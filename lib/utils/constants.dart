class Constants {
  // App Info
  static const String appName = 'NFC Event System';
  static const String appVersion = '1.0.0';
  
  // Status
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  
  // Session Status Labels
  static const Map<String, String> sessionStatusLabels = {
    'in_progress': 'กำลังดำเนินการ',
    'completed': 'เสร็จสิ้น',
    'cancelled': 'ยกเลิก',
  };
  
  // Messages
  static const String msgLoginSuccess = 'เข้าสู่ระบบสำเร็จ';
  static const String msgLogoutSuccess = 'ออกจากระบบสำเร็จ';
  static const String msgNetworkError = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
  static const String msgSessionExpired = 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Image Quality
  static const int imageQuality = 85;
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 300;
}