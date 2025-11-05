import 'package:flutter/foundation.dart';
import '../services/session_service.dart';

class SessionProvider with ChangeNotifier {
  Map<String, dynamic>? _activeSession;
  List<Map<String, dynamic>> _sessionHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get activeSession => _activeSession;
  List<Map<String, dynamic>> get sessionHistory => _sessionHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// โหลด active session
  Future<void> loadActiveSession() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await SessionService.getActiveSession();

      if (result['success'] && result['session'] != null) {
        _activeSession = result['session'];
        
        if (kDebugMode) {
          print('✅ Active session loaded: ${_activeSession?['id']}');
        }
      } else {
        _activeSession = null;
        
        if (kDebugMode) {
          print('ℹ️ No active session');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'ไม่สามารถโหลด session ได้: $e';
      _isLoading = false;
      
      if (kDebugMode) {
        print('❌ Error loading active session: $e');
      }
      
      notifyListeners();
    }
  }

  /// ✅ เพิ่ม: โหลดประวัติ session
  Future<void> loadSessionHistory(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await SessionService.getSessionHistory(token);

      if (result['success']) {
        _sessionHistory = List<Map<String, dynamic>>.from(
          result['sessions'] ?? []
        );
        
        if (kDebugMode) {
          print('✅ Session history loaded: ${_sessionHistory.length} sessions');
        }
      } else {
        _errorMessage = result['message'] ?? 'ไม่สามารถโหลดประวัติได้';
        _sessionHistory = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: $e';
      _sessionHistory = [];
      _isLoading = false;
      
      if (kDebugMode) {
        print('❌ Error loading session history: $e');
      }
      
      notifyListeners();
    }
  }

  /// สร้าง session ใหม่
  Future<Map<String, dynamic>> createSession(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await SessionService.createSession(token);

      if (result['success'] && result['session'] != null) {
        _activeSession = result['session'];
        
        if (kDebugMode) {
          print('✅ Session created: ${_activeSession?['id']}');
        }
      }

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _errorMessage = 'ไม่สามารถสร้าง session ได้: $e';
      _isLoading = false;
      
      if (kDebugMode) {
        print('❌ Error creating session: $e');
      }
      
      notifyListeners();

      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// จบ session
  Future<Map<String, dynamic>> completeSession(
    String token,
    int sessionId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await SessionService.completeSession(token, sessionId);

      if (result['success']) {
        _activeSession = null;
        
        if (kDebugMode) {
          print('✅ Session completed: $sessionId');
        }
      }

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _errorMessage = 'ไม่สามารถจบ session ได้: $e';
      _isLoading = false;
      
      if (kDebugMode) {
        print('❌ Error completing session: $e');
      }
      
      notifyListeners();

      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// รีเซ็ต
  void reset() {
    _activeSession = null;
    _sessionHistory = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// ล้าง error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}