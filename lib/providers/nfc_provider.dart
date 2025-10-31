import 'package:flutter/foundation.dart';
import '../services/nfc_service.dart';
import '../models/nfc_scan_result.dart';

class NfcProvider with ChangeNotifier {
  final NfcService _nfcService = NfcService();

  bool _isScanning = false;
  bool _isAvailable = false;
  String _statusMessage = '';
  NfcScanResult? _lastScanResult;
  String? _errorMessage;

  // Getters
  bool get isScanning => _isScanning;
  bool get isAvailable => _isAvailable;
  String get statusMessage => _statusMessage;
  NfcScanResult? get lastScanResult => _lastScanResult;
  String? get errorMessage => _errorMessage;

  /// Check NFC availability
  Future<bool> checkNfcAvailability() async {
    _isAvailable = await _nfcService.isNfcAvailable();
    notifyListeners();
    return _isAvailable;
  }

  /// Start NFC scan
  Future<NfcScanResult?> startScan() async {
    _errorMessage = null;
    _lastScanResult = null;
    notifyListeners();

    final result = await _nfcService.startNfcScan(
      onError: (error) {
        _errorMessage = error;
        _statusMessage = error;
        _isScanning = false;
        notifyListeners();
      },
      onStatus: (status) {
        _statusMessage = status;
        _isScanning = true;
        notifyListeners();
      },
    );

    if (result != null) {
      _lastScanResult = result;
      _isScanning = false;
      notifyListeners();
    }

    return result;
  }

  /// Stop NFC scan
  Future<void> stopScan() async {
    await _nfcService.stopNfcScan();
    _isScanning = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear status message
  void clearStatus() {
    _statusMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _nfcService.dispose();
    super.dispose();
  }
}