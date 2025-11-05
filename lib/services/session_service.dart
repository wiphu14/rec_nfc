import 'dart:convert';
import 'package:flutter/foundation.dart';
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

      if (kDebugMode) {
        debugPrint('🔍 Fetching active session...');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/sessions/active.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (kDebugMode) {
        debugPrint('📊 Get Active Session Status: ${response.statusCode}');
        debugPrint('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return SessionModel.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting active session: $e');
      }
      return null;
    }
  }

  /// Create new session
  Future<SessionModel?> createSession() async {
    try {
      final token = await _getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('❌ No token found');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║      CREATING NEW SESSION              ║');
        debugPrint('╚════════════════════════════════════════╝');
        debugPrint('📍 URL: ${AppConfig.baseUrl}/sessions/create_session.php');
        debugPrint('🔑 Token: ${token.substring(0, 20)}...');
      }

      // ✅ แก้ไข: ใช้ create_session.php แทน create.php
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/sessions/create_session.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}), // ส่ง empty JSON object
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║      CREATE SESSION RESPONSE           ║');
        debugPrint('╚════════════════════════════════════════╝');
        debugPrint('📊 Status Code: ${response.statusCode}');
        debugPrint('📋 Headers: ${response.headers}');
        debugPrint('📄 Body: ${response.body}');
      }

      // Accept both 200 and 201 status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          if (kDebugMode) {
            debugPrint('✅ Session created successfully!');
            debugPrint('📦 Session Data: ${jsonEncode(data['data'])}');
          }
          
          return SessionModel.fromJson(data['data']);
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ API returned success=false');
            debugPrint('💬 Message: ${data['message']}');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Unexpected status code: ${response.statusCode}');
        }
      }

      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error creating session: $e');
        debugPrint('🔍 StackTrace: $stackTrace');
      }
      return null;
    }
  }

  /// Complete session
  Future<bool> completeSession(int sessionId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      if (kDebugMode) {
        debugPrint('🏁 Completing session: $sessionId');
      }

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

      if (kDebugMode) {
        debugPrint('📊 Complete Session Status: ${response.statusCode}');
        debugPrint('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error completing session: $e');
      }
      return false;
    }
  }

  /// Cancel session
  Future<bool> cancelSession(int sessionId, String? reason) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      if (kDebugMode) {
        debugPrint('🚫 Cancelling session: $sessionId');
      }

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

      if (kDebugMode) {
        debugPrint('📊 Cancel Session Status: ${response.statusCode}');
        debugPrint('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cancelling session: $e');
      }
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

      if (kDebugMode) {
        debugPrint('📜 Fetching session history (page: $page, limit: $limit)');
      }

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

      if (kDebugMode) {
        debugPrint('📊 Get Sessions Status: ${response.statusCode}');
      }

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
      if (kDebugMode) {
        debugPrint('❌ Error getting sessions: $e');
      }
      return [];
    }
  }
}