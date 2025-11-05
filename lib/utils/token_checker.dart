import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class TokenChecker {
  static final StorageService _storageService = StorageService();

  /// Check if token exists and show dialog if not
  static Future<bool> checkAndPromptLogin(BuildContext context) async {
    final token = await _storageService.getToken();
    
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Token หมดอายุ'),
              ],
            ),
            content: const Text(
              'กรุณาเข้าสู่ระบบใหม่อีกครั้ง',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                ),
                child: const Text('เข้าสู่ระบบ'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    
    return true;
  }

  /// Get token info (existence, validity, expiry)
  static Future<Map<String, dynamic>> getTokenInfo() async {
    final token = await _storageService.getToken();
    
    if (token == null || token.isEmpty) {
      return {
        'exists': false,
        'valid': false,
        'message': 'No token found',
      };
    }

    // Parse JWT token to check expiry
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return {
          'exists': true,
          'valid': false,
          'message': 'Invalid token format',
        };
      }

      // Decode payload (base64)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);

      final exp = data['exp'];
      final iat = data['iat'];
      
      if (exp != null) {
        final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();
        final isExpired = now.isAfter(expDate);
        
        return {
          'exists': true,
          'valid': !isExpired,
          'expired': isExpired,
          'expiry_date': expDate.toIso8601String(),
          'issued_at': iat != null 
              ? DateTime.fromMillisecondsSinceEpoch(iat * 1000).toIso8601String() 
              : null,
          'time_remaining_minutes': !isExpired 
              ? expDate.difference(now).inMinutes 
              : 0,
          'time_remaining_hours': !isExpired 
              ? expDate.difference(now).inHours 
              : 0,
        };
      }

      return {
        'exists': true,
        'valid': true,
        'message': 'Token exists but no expiry found',
      };
    } catch (e) {
      return {
        'exists': true,
        'valid': false,
        'error': e.toString(),
        'message': 'Error parsing token',
      };
    }
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    final info = await getTokenInfo();
    return info['expired'] == true;
  }

  /// Check if token is valid (exists and not expired)
  static Future<bool> isTokenValid() async {
    final info = await getTokenInfo();
    return info['exists'] == true && info['valid'] == true;
  }

  /// Get time remaining until token expires (in minutes)
  static Future<int?> getTimeRemaining() async {
    final info = await getTokenInfo();
    if (info['exists'] == true && info['valid'] == true) {
      return info['time_remaining_minutes'] as int?;
    }
    return null;
  }

  /// Show token expiry warning if less than specified minutes remaining
  static Future<void> showExpiryWarningIfNeeded(
    BuildContext context, {
    int warningThresholdMinutes = 30,
  }) async {
    final timeRemaining = await getTimeRemaining();
    
    if (timeRemaining != null && 
        timeRemaining > 0 && 
        timeRemaining <= warningThresholdMinutes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Token จะหมดอายุใน $timeRemaining นาที กรุณาเข้าสู่ระบบใหม่',
            ),
            backgroundColor: AppConfig.warningColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'เข้าสู่ระบบ',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        );
      }
    }
  }

  /// Format token info for display
  static Future<String> getTokenInfoString() async {
    final info = await getTokenInfo();
    
    if (info['exists'] == false) {
      return 'ไม่พบ Token';
    }
    
    if (info['valid'] == false) {
      return info['expired'] == true 
          ? 'Token หมดอายุแล้ว' 
          : 'Token ไม่ถูกต้อง';
    }
    
    final minutes = info['time_remaining_minutes'] as int?;
    final hours = info['time_remaining_hours'] as int?;
    
    if (hours != null && hours > 0) {
      return 'Token ใช้งานได้อีก $hours ชั่วโมง';
    } else if (minutes != null && minutes > 0) {
      return 'Token ใช้งานได้อีก $minutes นาที';
    }
    
    return 'Token ใช้งานได้';
  }

  /// Clear token
  static Future<void> clearToken() async {
    await _storageService.clearAll();
  }
}