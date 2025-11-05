import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class SessionService {
  static final String baseUrl = AppConfig.baseUrl;

  /// ดึง active session
  static Future<Map<String, dynamic>> getActiveSession() async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║     FETCHING ACTIVE SESSION            ║');
        print('╚════════════════════════════════════════╝');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sessions/active.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'session': data['data']?['session'],
        };
      } else {
        return {
          'success': false,
          'message': 'ไม่สามารถดึงข้อมูล session ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in getActiveSession: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// ✅ เพิ่ม: ดึงประวัติ session
  static Future<Map<String, dynamic>> getSessionHistory(String token) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║     FETCHING SESSION HISTORY           ║');
        print('╚════════════════════════════════════════╝');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sessions/history.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'sessions': data['data']?['sessions'] ?? [],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token หมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง',
        };
      } else {
        return {
          'success': false,
          'message': 'ไม่สามารถดึงประวัติ session ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in getSessionHistory: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// สร้าง session ใหม่
  static Future<Map<String, dynamic>> createSession(String token) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║       CREATING NEW SESSION             ║');
        print('╚════════════════════════════════════════╝');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/sessions/create_session.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'session': data['data']?['session'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถสร้าง session ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in createSession: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// จบ session
  static Future<Map<String, dynamic>> completeSession(
    String token,
    int sessionId,
  ) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║      COMPLETING SESSION                ║');
        print('╚════════════════════════════════════════╝');
        print('📍 Session ID: $sessionId');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/sessions/complete_session.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session_id': sessionId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถจบ session ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in completeSession: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }
}