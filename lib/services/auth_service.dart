import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserData = 'user_data';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '${AppConfig.baseUrl}/auth/login.php';
      
      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║         LOGIN REQUEST START            ║');
        debugPrint('╚════════════════════════════════════════╝');
        debugPrint('📍 URL: $url');
        debugPrint('👤 Username: $username');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Status Code: ${response.statusCode}');
        debugPrint('📄 Response: ${response.body}');
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        if (kDebugMode) {
          debugPrint('❌ Invalid content type: $contentType');
          debugPrint('Body: ${response.body}');
        }
        return {
          'success': false,
          'message': 'Server ส่งข้อมูลผิดรูปแบบ',
        };
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['user'] == null || data['token'] == null) {
            throw Exception('ข้อมูลไม่ครบถ้วน');
          }

          final user = UserModel.fromJson(data['user']);
          await _saveAuthData(data['token'], data['user']);

          if (kDebugMode) {
            debugPrint('✅ Login successful');
            debugPrint('👤 User: ${user.username}');
          }

          return {
            'success': true,
            'user': user,
            'token': data['token'],
            'message': data['message'] ?? 'เข้าสู่ระบบสำเร็จ',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ',
          };
        }
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
        };
      } else {
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาด (HTTP ${response.statusCode})',
        };
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAuthToken, token);
      await prefs.setString(_keyUserData, jsonEncode(userData));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving auth data: $e');
      }
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyAuthToken);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);

      if (userDataString == null || userDataString.isEmpty) {
        return null;
      }

      final userData = jsonDecode(userDataString);
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyUserData);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> refreshUserData() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'ไม่พบ Token',
        };
      }

      final url = '${AppConfig.baseUrl}/auth/profile.php';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyUserData, jsonEncode(data['user']));

          return {
            'success': true,
            'user': user,
          };
        }
      } else if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Token หมดอายุ',
          'token_expired': true,
        };
      }

      return {
        'success': false,
        'message': 'ไม่สามารถดึงข้อมูลได้',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }
}
