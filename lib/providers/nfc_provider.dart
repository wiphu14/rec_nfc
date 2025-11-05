import 'package:flutter/foundation.dart';
import '../services/nfc_service.dart';

class NfcProvider with ChangeNotifier {
  bool _isNfcAvailable = false;
  bool _isScanning = false;
  String? _scannedUid;
  String? _errorMessage;

  bool get isNfcAvailable => _isNfcAvailable;
  bool get isScanning => _isScanning;
  String? get scannedUid => _scannedUid;
  String? get errorMessage => _errorMessage;

  /// ตรวจสอบว่าอุปกรณ์รองรับ NFC หรือไม่
  Future<void> checkNfcAvailability() async {
    try {
      // ✅ เรียก static method ด้วย class name
      _isNfcAvailable = await NfcService.isNfcAvailable();
      
      if (kDebugMode) {
        print('📱 NFC Available: $_isNfcAvailable');
      }
      
      notifyListeners();
    } catch (e) {
      _isNfcAvailable = false;
      _errorMessage = 'ไม่สามารถตรวจสอบ NFC ได้: $e';
      
      if (kDebugMode) {
        print('❌ Error checking NFC: $e');
      }
      
      notifyListeners();
    }
  }

  /// เริ่มสแกน NFC
  Future<String?> startNfcScan({
    Function(String)? onTagDetected,
    Function(String)? onError,
  }) async {
    if (_isScanning) {
      if (kDebugMode) {
        print('⚠️ Already scanning');
      }
      return null;
    }

    _isScanning = true;
    _scannedUid = null;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Starting NFC scan...');
      }

      // ✅ เรียก static method scanNfcTag
      final uid = await NfcService.scanNfcTag(
        onTagDetected: (uid) {
          _scannedUid = uid;
          _errorMessage = null;
          
          if (kDebugMode) {
            print('✅ NFC Tag detected: $uid');
          }
          
          onTagDetected?.call(uid);
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error;
          
          if (kDebugMode) {
            print('❌ NFC Error: $error');
          }
          
          onError?.call(error);
          notifyListeners();
        },
      );

      _isScanning = false;
      notifyListeners();

      return uid;
      
    } catch (e) {
      _isScanning = false;
      _errorMessage = 'เกิดข้อผิดพลาด: $e';
      
      if (kDebugMode) {
        print('❌ Exception in startNfcScan: $e');
      }
      
      notifyListeners();
      return null;
    }
  }

  /// หยุดการสแกน NFC
  Future<void> stopNfcScan() async {
    if (!_isScanning) return;

    try {
      // ✅ เรียก static method stopNfcSession
      await NfcService.stopNfcSession();
      
      _isScanning = false;
      
      if (kDebugMode) {
        print('⏹️ NFC scan stopped');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping NFC: $e');
      }
    }
  }

  /// รีเซ็ตข้อมูล NFC
  void reset() {
    _scannedUid = null;
    _errorMessage = null;
    _isScanning = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear scanned UID
  void clearScannedUid() {
    _scannedUid = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // หยุด NFC scan ก่อน dispose
    if (_isScanning) {
      NfcService.stopNfcSession();
    }
    super.dispose();
  }
}