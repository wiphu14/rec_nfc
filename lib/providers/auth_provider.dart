import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Authentication Provider
/// 
/// จัดการ state ของ authentication ทั้งหมด
/// - User data
/// - Token
/// - Login/Logout
/// - Loading state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isUser => _user?.isUser ?? false;

  /// Check if user is logged in on app start
  /// 
  /// Returns true if user is logged in, false otherwise
  Future<bool> checkLoginStatus() async {
    try {
      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║      CHECKING LOGIN STATUS             ║');
        debugPrint('╚════════════════════════════════════════╝');
      }

      // Check if token exists
      final savedToken = await _authService.getToken();

      if (savedToken == null || savedToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ No token found - user not logged in');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('🔑 Token found: ${savedToken.substring(0, min(50, savedToken.length))}...');
      }

      // Get saved user data
      final savedUser = await _authService.getSavedUser();

      if (savedUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ No user data found - clearing token');
        }
        await logout();
        return false;
      }

      // Set user and token
      _token = savedToken;
      _user = savedUser;

      if (kDebugMode) {
        debugPrint('✅ Login status valid');
        debugPrint('👤 User: ${_user!.username}');
        debugPrint('🏢 Organization: ${_user!.organization}');
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error checking login status: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      return false;
    }
  }

  /// Login with username and password
  /// 
  /// Returns true if login successful, false otherwise
  Future<bool> login(String username, String password) async {
    if (kDebugMode) {
      debugPrint('╔════════════════════════════════════════╗');
      debugPrint('║        AUTH PROVIDER LOGIN             ║');
      debugPrint('╚════════════════════════════════════════╝');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call auth service
      final response = await _authService.login(username, password);

      if (response['success'] == true) {
        // Login successful
        _token = response['token'];
        _user = response['user'];

        if (kDebugMode) {
          debugPrint('✅ Login successful in provider');
          debugPrint('👤 User: ${_user!.username}');
          debugPrint('🔑 Token: ${_token!.substring(0, min(50, _token!.length))}...');
        }

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // Login failed
        _errorMessage = response['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ';

        if (kDebugMode) {
          debugPrint('❌ Login failed: $_errorMessage');
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';

      if (kDebugMode) {
        debugPrint('❌ Exception in login: $e');
        debugPrint('StackTrace: $stackTrace');
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  /// 
  /// Clears all user data and token
  Future<void> logout() async {
    try {
      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║       AUTH PROVIDER LOGOUT             ║');
        debugPrint('╚════════════════════════════════════════╝');
      }

      // Clear service data
      await _authService.logout();

      // Clear local state
      _user = null;
      _token = null;
      _errorMessage = null;

      if (kDebugMode) {
        debugPrint('✅ Logout successful');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during logout: $e');
      }
      rethrow;
    }
  }

  /// Refresh user data from server
  /// 
  /// Updates user information while maintaining login state
  Future<bool> refreshUser() async {
    if (_token == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot refresh user - no token');
      }
      return false;
    }

    try {
      if (kDebugMode) {
        debugPrint('🔄 Refreshing user data...');
      }

      final response = await _authService.refreshUserData();

      if (response['success'] == true) {
        _user = response['user'];

        if (kDebugMode) {
          debugPrint('✅ User data refreshed successfully');
        }

        notifyListeners();
        return true;
      } else {
        // Check if token expired
        if (response['token_expired'] == true) {
          if (kDebugMode) {
            debugPrint('⚠️ Token expired - logging out');
          }
          await logout();
        }

        _errorMessage = response['message'];

        if (kDebugMode) {
          debugPrint('❌ Failed to refresh user: $_errorMessage');
        }

        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error refreshing user: $e');
      }
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user info locally
  /// 
  /// Use this when you update user info without server call
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('📝 User updated locally: ${user.username}');
    }
  }

  /// Force reload user data from saved storage
  Future<void> reloadUser() async {
    try {
      final savedUser = await _authService.getSavedUser();

      if (savedUser != null) {
        _user = savedUser;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('🔄 User reloaded from storage: ${savedUser.username}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error reloading user: $e');
      }
    }
  }

  /// Get user display name
  String get displayName => _user?.displayName ?? 'ผู้ใช้';

  /// Get user organization
  String get organization => _user?.organization ?? 'N/A';

  /// Get user role display
  String get roleDisplay {
    if (_user == null) return 'ไม่ระบุ';
    
    switch (_user!.role) {
      case 'admin':
        return 'ผู้ดูแลระบบ';
      case 'super_admin':
        return 'ผู้ดูแลระบบสูงสุด';
      case 'user':
        return 'ผู้ใช้งาน';
      default:
        return _user!.role;
    }
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _user?.role == role;
  }

  /// Helper method to get minimum of two numbers
  int min(int a, int b) => a < b ? a : b;
}