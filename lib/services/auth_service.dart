import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

/// Authentication Service
/// 
/// จัดการทุกอย่างที่เกี่ยวข้องกับการ authentication
/// - Login
/// - Logout
/// - Token management
/// - User data persistence
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Keys for SharedPreferences
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserData = 'user_data';

  /// Login with username and password
  /// 
  /// Returns Map with:
  /// - success: bool
  /// - user: UserModel (if success)
  /// - token: String (if success)
  /// - message: String (if error)
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '${AppConfig.baseUrl}/auth/login.php';
      
      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║         LOGIN REQUEST START            ║');
        debugPrint('╚════════════════════════════════════════╝');
        debugPrint('📍 URL: $url');
        debugPrint('👤 Username: $username');
        debugPrint('⏰ Time: ${DateTime.now()}');
      }

      // Send POST request
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
          throw Exception('Connection timeout - ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
        },
      );

      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║         RESPONSE RECEIVED              ║');
        debugPrint('╚════════════════════════════════════════╝');
        debugPrint('📊 Status Code: ${response.statusCode}');
        debugPrint('📋 Headers: ${response.headers}');
        debugPrint('📦 Body Length: ${response.body.length} chars');
        debugPrint('📄 Body Preview: ${_truncateString(response.body, 200)}');
      }

      // Validate content type
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        if (kDebugMode) {
          debugPrint('❌ ERROR: Invalid content type');
          debugPrint('Expected: application/json');
          debugPrint('Got: $contentType');
          debugPrint('Body: ${_truncateString(response.body, 300)}');
        }
        return {
          'success': false,
          'message': 'Server ส่งข้อมูลผิดรูปแบบ\nกรุณาตรวจสอบ Backend API',
        };
      }

      // Handle response by status code
      if (response.statusCode == 200) {
        return await _handleSuccessResponse(response);
      } else if (response.statusCode == 401) {
        return _handleUnauthorizedResponse(response);
      } else if (response.statusCode == 400) {
        return _handleBadRequestResponse(response);
      } else if (response.statusCode == 500) {
        return _handleServerErrorResponse(response);
      } else {
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาด (HTTP ${response.statusCode})',
        };
      }
    } on FormatException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FormatException: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'ข้อมูลจาก Server ไม่ถูกต้อง\nกรุณาตรวจสอบ Backend API',
      };
    } on http.ClientException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ ClientException: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้\n'
            'กรุณาตรวจสอบ:\n'
            '1. เปิด XAMPP แล้วหรือไม่\n'
            '2. URL: ${AppConfig.baseUrl}\n'
            '3. การเชื่อมต่ออินเทอร์เน็ต',
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Unknown Error: $e');
        debugPrint('Type: ${e.runtimeType}');
        debugPrint('StackTrace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }

  /// Handle successful response (200)
  Future<Map<String, dynamic>> _handleSuccessResponse(
      http.Response response) async {
    try {
      final data = jsonDecode(response.body);

      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║      PARSING SUCCESS RESPONSE          ║');
        debugPrint('╚════════════════════════════════════════╝');
        debugPrint('✅ Success: ${data['success']}');
        debugPrint('💬 Message: ${data['message']}');
      }

      if (data['success'] == true) {
        // Validate required fields
        if (data['user'] == null) {
          throw Exception('ข้อมูลผู้ใช้ไม่ถูกต้อง (user is null)');
        }

        if (data['token'] == null || data['token'].isEmpty) {
          throw Exception('Token ไม่ถูกต้อง');
        }

        if (kDebugMode) {
          debugPrint('👤 User Data: ${jsonEncode(data['user'])}');
          debugPrint('🔑 Token: ${_truncateString(data['token'], 50)}...');
        }

        // Parse user model
        final user = UserModel.fromJson(data['user']);

        if (kDebugMode) {
          debugPrint('╔════════════════════════════════════════╗');
          debugPrint('║       USER MODEL CREATED               ║');
          debugPrint('╚════════════════════════════════════════╝');
          debugPrint('🆔 ID: ${user.id}');
          debugPrint('👤 Username: ${user.username}');
          debugPrint('📝 Full Name: ${user.fullName}');
          debugPrint('📧 Email: ${user.email ?? 'N/A'}');
          debugPrint('🏢 Organization: ${user.organization}');
          debugPrint('👔 Role: ${user.role}');
          debugPrint('✅ Active: ${user.isActive}');
        }

        // Save to SharedPreferences
        await _saveAuthData(data['token'], data['user']);

        if (kDebugMode) {
          debugPrint('💾 Auth data saved to SharedPreferences');
          debugPrint('✅ LOGIN SUCCESS');
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error parsing success response: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล: ${e.toString()}',
      };
    }
  }

  /// Handle unauthorized response (401)
  Map<String, dynamic> _handleUnauthorizedResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
      };
    }
  }

  /// Handle bad request response (400)
  Map<String, dynamic> _handleBadRequestResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'ข้อมูลไม่ถูกต้อง',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'ข้อมูลไม่ถูกต้อง',
      };
    }
  }

  /// Handle server error response (500)
  Map<String, dynamic> _handleServerErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์',
      };
    }
  }

  /// Save authentication data to SharedPreferences
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAuthToken, token);
      await prefs.setString(_keyUserData, jsonEncode(userData));

      if (kDebugMode) {
        debugPrint('✅ Auth data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving auth data: $e');
      }
      rethrow;
    }
  }

  /// Get saved authentication token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyAuthToken);

      if (kDebugMode) {
        if (token != null) {
          debugPrint('🔑 Token retrieved: ${_truncateString(token, 50)}...');
        } else {
          debugPrint('⚠️ No token found');
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting token: $e');
      }
      return null;
    }
  }

  /// Get saved user data
  Future<UserModel?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);

      if (userDataString == null || userDataString.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ No user data found');
        }
        return null;
      }

      final userData = jsonDecode(userDataString);
      final user = UserModel.fromJson(userData);

      if (kDebugMode) {
        debugPrint('👤 User retrieved: ${user.username}');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting saved user: $e');
      }
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║           LOGOUT START                 ║');
        debugPrint('╚════════════════════════════════════════╝');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyUserData);

      if (kDebugMode) {
        debugPrint('✅ Logout successful');
        debugPrint('🗑️ Auth data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during logout: $e');
      }
      rethrow;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      if (kDebugMode) {
        debugPrint('🔐 Is logged in: $isLoggedIn');
      }

      return isLoggedIn;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking login status: $e');
      }
      return false;
    }
  }

  /// Refresh user data from server
  Future<Map<String, dynamic>> refreshUserData() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'ไม่พบ Token กรุณาเข้าสู่ระบบอีกครั้ง',
        };
      }

      final url = '${AppConfig.baseUrl}/auth/profile.php';

      if (kDebugMode) {
        debugPrint('📡 Refreshing user data from: $url');
      }

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

          // Update saved user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyUserData, jsonEncode(data['user']));

          if (kDebugMode) {
            debugPrint('✅ User data refreshed successfully');
          }

          return {
            'success': true,
            'user': user,
          };
        }
      } else if (response.statusCode == 401) {
        // Token expired
        await logout();
        return {
          'success': false,
          'message': 'Token หมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง',
          'token_expired': true,
        };
      }

      return {
        'success': false,
        'message': 'ไม่สามารถดึงข้อมูลผู้ใช้ได้',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error refreshing user data: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }

  /// Clear all authentication data (for debugging)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (kDebugMode) {
        debugPrint('🗑️ All auth data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing auth data: $e');
      }
    }
  }

  // ========== HELPER METHODS ==========

  /// Truncate string for logging
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) {
      return str;
    }
    return '${str.substring(0, maxLength)}...';
  }
}