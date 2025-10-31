class NfcHelper {
  // Format NFC Tag UID for display
  static String formatTagUid(String tagUid) {
    // Remove any existing separators
    final cleaned = tagUid.replaceAll(RegExp(r'[:\-\s]'), '');
    
    // Add colons every 2 characters
    final formatted = StringBuffer();
    for (var i = 0; i < cleaned.length; i += 2) {
      if (i > 0) formatted.write(':');
      final end = i + 2 > cleaned.length ? cleaned.length : i + 2;
      formatted.write(cleaned.substring(i, end));
    }
    
    return formatted.toString().toUpperCase();
  }

  // Validate NFC Tag UID format
  static bool isValidTagUid(String tagUid) {
    // Remove separators
    final cleaned = tagUid.replaceAll(RegExp(r'[:\-\s]'), '');
    
    // Check if it's a valid hex string
    final hexRegex = RegExp(r'^[0-9A-Fa-f]+$');
    if (!hexRegex.hasMatch(cleaned)) {
      return false;
    }
    
    // Check length (usually 4-10 bytes = 8-20 characters)
    if (cleaned.length < 8 || cleaned.length > 20) {
      return false;
    }
    
    return true;
  }

  // Get NFC Tag type description
  static String getTagTypeDescription(String? tagType) {
    if (tagType == null) return 'Unknown';
    
    final types = {
      'MIFARE Classic': 'MIFARE Classic',
      'MIFARE Ultralight': 'MIFARE Ultralight',
      'NfcA': 'NFC Type A',
      'NfcB': 'NFC Type B',
      'NfcF': 'NFC Type F (FeliCa)',
      'NfcV': 'NFC Type V (ISO 15693)',
      'IsoDep': 'ISO-DEP',
      'Ndef': 'NDEF',
    };
    
    return types[tagType] ?? tagType;
  }

  // Calculate scan duration
  static String getScanDuration(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} วินาที';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} นาที';
    } else {
      return '${duration.inHours} ชั่วโมง';
    }
  }
}