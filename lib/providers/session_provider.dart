import 'package:flutter/foundation.dart';
import '../services/session_service.dart';
import '../models/session_model.dart';

class SessionProvider with ChangeNotifier {
  final SessionService _sessionService = SessionService();

  SessionModel? _activeSession;
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  SessionModel? get activeSession => _activeSession;
  SessionModel? get currentSession => _activeSession; // Alias
  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveSession => _activeSession != null;

  /// Load active session
  Future<void> loadActiveSession() async {
    try {
      _isLoading = true;
      notifyListeners();

      final session = await _sessionService.getActiveSession();

      _activeSession = session;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Error loading active session: $e');
      }
    }
  }

  /// Create new session
  Future<bool> createSession() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final session = await _sessionService.createSession();

      if (session != null) {
        _activeSession = session;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'ไม่สามารถสร้างรอบการตรวจได้';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Error creating session: $e');
      }
      return false;
    }
  }

  /// Start new session (alias for createSession)
  Future<bool> startSession() async {
    return await createSession();
  }

  /// Complete session
  Future<bool> completeSession() async {
    if (_activeSession == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final success = await _sessionService.completeSession(_activeSession!.id);

      if (success) {
        _activeSession = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'ไม่สามารถสิ้นสุดรอบการตรวจได้';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Error completing session: $e');
      }
      return false;
    }
  }

  /// Cancel session
  Future<bool> cancelSession({String? reason}) async {
    if (_activeSession == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final success =
          await _sessionService.cancelSession(_activeSession!.id, reason);

      if (success) {
        _activeSession = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'ไม่สามารถยกเลิกรอบการตรวจได้';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Error cancelling session: $e');
      }
      return false;
    }
  }

  /// Load all sessions (for history)
  Future<void> loadSessions({int page = 1, int limit = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final sessions =
          await _sessionService.getAllSessions(page: page, limit: limit);

      _sessions = sessions;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Error loading sessions: $e');
      }
    }
  }

  /// Check if checkpoint is completed in current session
  bool isCheckpointCompleted(int checkpointId) {
    if (_activeSession == null) return false;
    return _activeSession!.isCheckpointCompleted(checkpointId);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}