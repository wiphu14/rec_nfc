class Validators {
  // Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกชื่อผู้ใช้';
    }
    if (value.length < 3) {
      return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (value.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }
    return null;
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  // Validate phone
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^[0-9]{9,10}$');
    if (!phoneRegex.hasMatch(value.replaceAll('-', ''))) {
      return 'รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง';
    }
    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  // Validate NFC tag UID format
  static String? validateNfcTag(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก NFC Tag UID';
    }
    
    // Basic format validation (can be customized)
    if (value.length < 8) {
      return 'รูปแบบ NFC Tag UID ไม่ถูกต้อง';
    }
    return null;
  }
}