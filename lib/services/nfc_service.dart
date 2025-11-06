import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class NfcService {
  /// ตรวจสอบว่าอุปกรณ์รองรับ NFC หรือไม่
  static Future<bool> isNfcAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking NFC availability: $e');
      }
      return false;
    }
  }

  /// สแกน NFC Tag และคืนค่า UID
  static Future<String?> scanNfcTag({
    Function(String)? onTagDetected,
    Function(String)? onError,
  }) async {
    try {
      // ตรวจสอบว่ารองรับ NFC
      bool isAvailable = await isNfcAvailable();
      if (!isAvailable) {
        onError?.call('อุปกรณ์นี้ไม่รองรับ NFC');
        return null;
      }

      String? nfcUid;

      if (kDebugMode) {
        print('🔍 Starting NFC scan...');
      }

      // เริ่มสแกน NFC
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          if (kDebugMode) {
            print('📡 NFC Tag discovered!');
            print('📦 Raw tag data: ${tag.data}');
          }
          
          // แปลง tag data เป็น UID
          nfcUid = _extractNfcUid(tag);
          
          if (nfcUid != null && nfcUid!.isNotEmpty) {
            if (kDebugMode) {
              print('✅ NFC UID: $nfcUid');
            }
            onTagDetected?.call(nfcUid!);
          } else {
            if (kDebugMode) {
              print('❌ ไม่สามารถอ่าน NFC UID ได้');
            }
            onError?.call('ไม่สามารถอ่าน NFC Tag ได้');
          }

          // หยุดการสแกน
          await NfcManager.instance.stopSession();
        },
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
      );

      return nfcUid;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ NFC Error: $e');
      }
      onError?.call('เกิดข้อผิดพลาด: $e');
      return null;
    }
  }

  /// หยุดการสแกน NFC
  static Future<void> stopNfcSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping NFC session: $e');
      }
    }
  }

  /// แปลง NFC Tag เป็น UID string
  static String? _extractNfcUid(NfcTag tag) {
    try {
      // ✅ แก้ไข: เข้าถึง tag.data ได้โดยตรง
      final data = tag.data;
      
      if (kDebugMode) {
        print('📱 Tag data type: ${data.runtimeType}');
        print('📱 Tag data: $data');
      }

      // ✅ ตรวจสอบว่า data เป็น Map หรือไม่
      if (data is! Map) {
        if (kDebugMode) {
          print('❌ Tag data is not a Map');
        }
        
        // ✅ พยายามแปลงเป็น Map
        try {
          final Map<Object?, Object?> rawData = Map<Object?, Object?>.from(data as dynamic);
          return _extractUidFromMap(rawData);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Failed to convert to Map: $e');
          }
          return null;
        }
      }

      // ✅ Cast เป็น Map<Object?, Object?>
      final Map<Object?, Object?> tagData = Map<Object?, Object?>.from(data);
      return _extractUidFromMap(tagData);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error extracting UID: $e');
      }
      return null;
    }
  }

  /// ✅ ฟังก์ชันช่วยแยก UID จาก Map
  static String? _extractUidFromMap(Map<Object?, Object?> tagData) {
    if (kDebugMode) {
      print('📱 Available technologies: ${tagData.keys.toList()}');
    }

    Uint8List? identifier;

    // ลองหา identifier จากทุก technology ที่เป็นไปได้
    
    // 1. nfca (Android NFC-A)
    identifier = _tryExtractIdentifier(tagData, 'nfca');
    if (identifier != null) return _bytesToHex(identifier);

    // 2. nfcb (Android NFC-B)
    identifier = _tryExtractIdentifier(tagData, 'nfcb');
    if (identifier != null) return _bytesToHex(identifier);

    // 3. nfcf (Android NFC-F)
    identifier = _tryExtractIdentifier(tagData, 'nfcf');
    if (identifier != null) return _bytesToHex(identifier);

    // 4. nfcv (Android NFC-V)
    identifier = _tryExtractIdentifier(tagData, 'nfcv');
    if (identifier != null) return _bytesToHex(identifier);

    // 5. isodep (Android ISO-DEP)
    identifier = _tryExtractIdentifier(tagData, 'isodep');
    if (identifier != null) return _bytesToHex(identifier);

    // 6. mifareclassic (Android)
    identifier = _tryExtractIdentifier(tagData, 'mifareclassic');
    if (identifier != null) return _bytesToHex(identifier);

    // 7. mifareultralight (Android)
    identifier = _tryExtractIdentifier(tagData, 'mifareultralight');
    if (identifier != null) return _bytesToHex(identifier);

    // 8. felica (iOS FeliCa)
    if (tagData.containsKey('felica')) {
      final felicaData = tagData['felica'];
      if (felicaData is Map) {
        final felicaMap = Map<Object?, Object?>.from(felicaData);
        if (felicaMap.containsKey('currentIDm')) {
          identifier = felicaMap['currentIDm'] as Uint8List?;
          if (identifier != null && identifier.isNotEmpty) {
            if (kDebugMode) print('✅ Found UID from felica');
            return _bytesToHex(identifier);
          }
        }
      }
    }

    // 9. iso15693 (iOS)
    identifier = _tryExtractIdentifier(tagData, 'iso15693');
    if (identifier != null) return _bytesToHex(identifier);

    // 10. mifare (iOS)
    identifier = _tryExtractIdentifier(tagData, 'mifare');
    if (identifier != null) return _bytesToHex(identifier);

    // 11. ndef
    identifier = _tryExtractIdentifier(tagData, 'ndef');
    if (identifier != null) return _bytesToHex(identifier);

    if (kDebugMode) {
      print('❌ ไม่พบ identifier ใน technologies: ${tagData.keys.toList()}');
    }
    return null;
  }

  /// ✅ ฟังก์ชันช่วยพยายามดึง identifier จาก technology
  static Uint8List? _tryExtractIdentifier(
    Map<Object?, Object?> tagData, 
    String technology
  ) {
    try {
      if (!tagData.containsKey(technology)) return null;

      final techData = tagData[technology];
      if (techData is! Map) return null;

      final techMap = Map<Object?, Object?>.from(techData);
      if (!techMap.containsKey('identifier')) return null;

      final identifier = techMap['identifier'];
      
      // ✅ แปลงเป็น Uint8List
      if (identifier is Uint8List) {
        if (identifier.isNotEmpty) {
          if (kDebugMode) {
            print('✅ Found UID from $technology');
          }
          return identifier;
        }
      } else if (identifier is List) {
        // ✅ ถ้าเป็น List ให้แปลงเป็น Uint8List
        try {
          final bytes = Uint8List.fromList(List<int>.from(identifier));
          if (bytes.isNotEmpty) {
            if (kDebugMode) {
              print('✅ Found UID from $technology (converted from List)');
            }
            return bytes;
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Failed to convert identifier to Uint8List: $e');
          }
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error extracting identifier from $technology: $e');
      }
      return null;
    }
  }

  /// แปลง bytes เป็น hex string (format: AA:BB:CC:DD)
  static String _bytesToHex(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  /// แปลง hex string เป็น bytes
  static Uint8List hexToBytes(String hex) {
    hex = hex.replaceAll(':', '').replaceAll(' ', '');
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byte = hex.substring(i, i + 2);
      bytes.add(int.parse(byte, radix: 16));
    }
    return Uint8List.fromList(bytes);
  }
}