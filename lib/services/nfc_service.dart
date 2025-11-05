import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/foundation.dart';

class NfcService {
  /// ตรวจสอบว่าอุปกรณ์รองรับ NFC หรือไม่
  static Future<bool> isNfcAvailable() async {
    try {
      // ✅ ใช้ isAvailable() ซึ่งยังใช้ได้ (แม้จะมี deprecation warning)
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

      // ✅ เริ่มสแกน NFC พร้อม pollingOptions
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          if (kDebugMode) {
            print('📡 NFC Tag discovered!');
          }
          
          // แปลง tag data เป็น UID
          nfcUid = _extractNfcUid(tag);
          
          if (nfcUid != null) {
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
        // ✅ เพิ่ม pollingOptions
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
      // ✅ เข้าถึง tag.data และ cast เป็น Map
      final data = tag.data;
      
      if (data is! Map) {
        if (kDebugMode) {
          print('❌ Tag data is not a Map');
        }
        return null;
      }

      final Map<String, dynamic> tagData = Map<String, dynamic>.from(data);
      
      if (kDebugMode) {
        print('📱 Available technologies: ${tagData.keys.toList()}');
      }

      Uint8List? identifier;

      // ลองหลาย technologies
      
      // 1. nfca (Android NFC-A)
      if (tagData.containsKey('nfca')) {
        final nfcaData = tagData['nfca'];
        if (nfcaData is Map) {
          final nfcaMap = Map<String, dynamic>.from(nfcaData);
          if (nfcaMap.containsKey('identifier')) {
            identifier = nfcaMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from nfca');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 2. nfcb (Android NFC-B)
      if (tagData.containsKey('nfcb')) {
        final nfcbData = tagData['nfcb'];
        if (nfcbData is Map) {
          final nfcbMap = Map<String, dynamic>.from(nfcbData);
          if (nfcbMap.containsKey('identifier')) {
            identifier = nfcbMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from nfcb');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 3. nfcf (Android NFC-F)
      if (tagData.containsKey('nfcf')) {
        final nfcfData = tagData['nfcf'];
        if (nfcfData is Map) {
          final nfcfMap = Map<String, dynamic>.from(nfcfData);
          if (nfcfMap.containsKey('identifier')) {
            identifier = nfcfMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from nfcf');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 4. nfcv (Android NFC-V)
      if (tagData.containsKey('nfcv')) {
        final nfcvData = tagData['nfcv'];
        if (nfcvData is Map) {
          final nfcvMap = Map<String, dynamic>.from(nfcvData);
          if (nfcvMap.containsKey('identifier')) {
            identifier = nfcvMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from nfcv');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 5. isodep (Android ISO-DEP)
      if (tagData.containsKey('isodep')) {
        final isodepData = tagData['isodep'];
        if (isodepData is Map) {
          final isodepMap = Map<String, dynamic>.from(isodepData);
          if (isodepMap.containsKey('identifier')) {
            identifier = isodepMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from isodep');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 6. mifareclassic (Android)
      if (tagData.containsKey('mifareclassic')) {
        final mifareData = tagData['mifareclassic'];
        if (mifareData is Map) {
          final mifareMap = Map<String, dynamic>.from(mifareData);
          if (mifareMap.containsKey('identifier')) {
            identifier = mifareMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from mifareclassic');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 7. mifareultralight (Android)
      if (tagData.containsKey('mifareultralight')) {
        final mifareData = tagData['mifareultralight'];
        if (mifareData is Map) {
          final mifareMap = Map<String, dynamic>.from(mifareData);
          if (mifareMap.containsKey('identifier')) {
            identifier = mifareMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from mifareultralight');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 8. felica (iOS FeliCa)
      if (tagData.containsKey('felica')) {
        final felicaData = tagData['felica'];
        if (felicaData is Map) {
          final felicaMap = Map<String, dynamic>.from(felicaData);
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
      if (tagData.containsKey('iso15693')) {
        final isoData = tagData['iso15693'];
        if (isoData is Map) {
          final isoMap = Map<String, dynamic>.from(isoData);
          if (isoMap.containsKey('identifier')) {
            identifier = isoMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from iso15693');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 10. mifare (iOS)
      if (tagData.containsKey('mifare')) {
        final mifareData = tagData['mifare'];
        if (mifareData is Map) {
          final mifareMap = Map<String, dynamic>.from(mifareData);
          if (mifareMap.containsKey('identifier')) {
            identifier = mifareMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from mifare');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      // 11. ndef
      if (tagData.containsKey('ndef')) {
        final ndefData = tagData['ndef'];
        if (ndefData is Map) {
          final ndefMap = Map<String, dynamic>.from(ndefData);
          if (ndefMap.containsKey('identifier')) {
            identifier = ndefMap['identifier'] as Uint8List?;
            if (identifier != null && identifier.isNotEmpty) {
              if (kDebugMode) print('✅ Found UID from ndef');
              return _bytesToHex(identifier);
            }
          }
        }
      }

      if (kDebugMode) {
        print('❌ ไม่พบ identifier ใน technologies: ${tagData.keys.toList()}');
      }
      return null;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error extracting UID: $e');
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