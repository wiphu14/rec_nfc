import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _expiresAtKey = 'token_expires_at';

  // Save token
  Future<bool> saveToken(String token, String expiresAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_expiresAtKey, expiresAt);
      return true;
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  // Get token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Save user data
  Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Get user data
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all data (logout)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_expiresAtKey);
      return true;
    } catch (e) {
      print('Error clearing storage: $e');
      return false;
    }
  }

  // Get token expiry
  Future<String?> getTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_expiresAtKey);
    } catch (e) {
      print('Error getting token expiry: $e');
      return null;
    }
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final expiresAt = await getTokenExpiry();
      if (expiresAt == null) return true;

      final expiryDate = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      print('Error checking token expiry: $e');
      return true;
    }
  }
}