import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/session_model.dart';

class SessionService {
  /// Get auth token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get active session
  Future<SessionModel?> getActiveSession() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/sessions/active.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return SessionModel.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create new session
  Future<SessionModel?> createSession() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/sessions/create.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return SessionModel.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Complete session
  Future<bool> completeSession(int sessionId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/sessions/complete.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'session_id': sessionId}),
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Cancel session
  Future<bool> cancelSession(int sessionId, String? reason) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/sessions/cancel.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'reason': reason,
        }),
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get all sessions (for history)
  Future<List<SessionModel>> getAllSessions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/sessions/list.php?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> sessionsJson = data['data'];
          return sessionsJson
              .map((json) => SessionModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}